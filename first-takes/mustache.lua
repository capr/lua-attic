
--Mustache implementation for Lua with LPeg.
--Written by Humberto Anjos. MIT License. github.com/hanjos/groucho
--Modified by Cosmin Apreutesei for luapower. Public Domain.

local re = require 'lpeg.re'
local lpeg = require 'lpeg'

local function blankifnil(v)
	return v ~= nil and tostring(v) or ''
end

--tables with an array part and empty tables are seen as lists.
local function islist(t)
	return type(t) == 'table' and (#t > 0 or next(t) == nil)
end

--capture callbacks:
-- * section(s, i, t) -> (i, s): match-time capture which returns the section
-- fully rendered. t holds some fields to aid rendering:
--  tag        : the string to be looked up in the context.
--  textstart  : the position in the full text where the section starts.
--  textfinish : the position in the full text directly after the section end.
--  finalspaces: any spaces before the closing tag (if tag not standalone).
-- * invertedsection(s, i, t) -> (i, s): like section but for inverted sections.
-- * partial(t) -> s: render partial captures, receiving a table with the fields:
--   1           : the name of template to search for.
--   indentation : the indentation in a standalone partial.
--  innerpartial(t) -> s: the same as partial captures, but matches only
--partials inside sections.
--comment(s) -> s      : renders comments.
--unescapedvar(s) -> s : renders unescaped variables.
--var(s) -> s          : renders normal variables.
--atlinestart(s, i) -> i|bool: an LPeg function pattern to check if the index
--is at the beginning of the template or of a line.
local grammar = [[
	Start     <- {~ Template ~} !.
	Template  <- (String (Hole String)*)
	Body      <- (String (InnerHole String)*)
	String    <- (
						!Hole
						!InnerPartial
						!OpenSection !OpenInvertedSection !CloseSection
						!StandaloneOpenSection
						!StandaloneOpenInvertedSection
						!StandaloneCloseSection
					.)*
	Hole      <- Section / InvertedSection / Partial      / Comment / UnescapedVar / Var
	InnerHole <- Section / InvertedSection / InnerPartial / Comment / UnescapedVar / Var
	Section   <- (
				{:tag: StandaloneOpenSection / OpenSection :}
				{:textstart: {} :}
				Body
				{:textfinish: {} :}
				(StandaloneCloseSectionWithTag / ({:finalspaces: %s* :} CloseSectionWithTag))
			) -> {} => section
	InvertedSection <- (
				{:tag: StandaloneOpenInvertedSection / OpenInvertedSection :}
				{:textstart: {} :}
				Body
				{:textfinish: {} :}
				(StandaloneCloseSectionWithTag / ({:finalspaces: %s* :} CloseSectionWithTag))
			) -> {} => invertedsection
		OpenSection         <- OpenDelim '#' %s* { Name } %s* CloseDelim
		OpenInvertedSection <- OpenDelim '^' %s* { Name } %s* CloseDelim
		CloseSection        <- OpenDelim '/' %s* Name %s* CloseDelim
		CloseSectionWithTag <- OpenDelim '/' %s* =tag %s* CloseDelim
		StandaloneOpenSection         <- %atlinestart (!%nl %s)* OpenSection         (!%nl %s)* %nl
		StandaloneOpenInvertedSection <- %atlinestart (!%nl %s)* OpenInvertedSection (!%nl %s)* %nl
		StandaloneCloseSection        <- %atlinestart (!%nl %s)* CloseSection        (!%nl %s)* (%nl / !.)
		StandaloneCloseSectionWithTag <- %atlinestart (!%nl %s)* CloseSectionWithTag (!%nl %s)* (%nl / !.)
	Partial         <- (StandalonePartial / InlinePartial) -> {} -> partial
		StandalonePartial <- %atlinestart {:indentation: (!%nl %s)* :} InlinePartial (!%nl %s)* (%nl / !.)
		InlinePartial     <- OpenDelim '>' %s* { Name } %s* CloseDelim
	InnerPartial    <- (StandalonePartial / InlinePartial) -> {} -> innerpartial
	Comment         <- (StandaloneComment / InlineComment) -> comment
		StandaloneComment <- %atlinestart (!%nl %s)* InlineComment (!%nl %s)* (%nl / !.)
		InlineComment     <- OpenDelim '!' (!CloseDelim .)* CloseDelim
	UnescapedVar    <- ('{{{' %s* { (!(%s* '}}}') .)* } %s* '}}}' /
								OpenDelim '&' %s* { Name } %s* CloseDelim) -> unescapedvar
	Var             <- (OpenDelim ![!#>/{&^] %s* { Name } %s* CloseDelim) -> var
	Name  <- (!(%s* CloseDelim) .)*
]]

local patt --the compiled grammar, fw. declared
local context, partials --current context and partials table

local function render(template)
	return (patt:match(template))
end

local function render_in(template, newctx, newpart)
	local olxctx, oldpart = context, partials
	context, partials = newctx or {}, newpart or {}
	local results = render(template)
	context, partials = olxctx, oldpart
	return results
end

local cb = {} --grammar's callback table

local in_section = false --signal that we're inside a section

--check if s[i] is at the beginning of the string or of a line.
local NL = re.compile'%nl' --pattern to detect line breaks
function cb.atlinestart(s, i)
	return
		not in_section
		and (i == 1 or NL:match(s:sub(i - 1, i - 1)))
		and i
		or false
end

--resolve a variable name in the given context. works with scoped "a.b.c"
--variables too. if lookup fails returns nil.
local function resolve(context, var)
	--check for the internal iterator . first
	if var == '.' then
		return context['.']
	end

	local path = {}
	for s in var:gmatch'[^%.]+' do --split var name by `.`
		table.insert(path, s)
	end

	if #path == 0 then --empty var name
		return nil
	elseif #path == 1 then --not scoped
		return context[var]
	end

	--the "a" in "a.b.c" must be in current scope because it's inherited.
	--it also must be a scope itself in which we lookup "b" and so on.
	local ctx = context
	for i = 1, #path - 1 do
		ctx = ctx[path[i]]
		if ctx == nil or type(ctx) ~= 'table' or islist(ctx) then
			return nil --lookup failed
		end
	end
	return ctx[path[#path]]
end

function cb.unescapedvar(var)
	local resolvedvar = resolve(context, var)
	if type(resolvedvar) == 'function' then
		return blankifnil(render(resolvedvar()))
	end
	return blankifnil(resolvedvar)
end

local escapes = {
	['&']  = '&amp;',
	['\\'] = '&#92;',
	['"']  = '&quot;',
	['<']  = '&lt;',
	['>']  = '&gt;',
}
local function escapehtml(v)
	return v:gsub('[&\\"<>]', escapes)
end

function cb.var(var)
	local resolvedvar = resolve(context, var)
	if type(resolvedvar) == 'function' then
		return escapehtml(blankifnil(render(resolvedvar())))
	end
	return escapehtml(blankifnil(resolvedvar))
end

function cb.comment(comment)
	return ''
end

---indent all lines in the given text with the given indentation.
local function add_indentation(text, indent)
	if not indent or indent == '' then
		return text
	end
	local lastchar = text:sub(-1)
	return indent..text:sub(1, -2):gsub('\n', '\n'..indent)..lastchar
end

---find a partial and returns its text after indentation.
local function process_partial(name, indent, partials)
	local text = assert(partials[name], 'partial not found '..name)
	return add_indentation(text, indent)
end

function cb.partial(partial)
	local text = process_partial(
		partial[1],
		partial.indentation or '',
		partials)
	--include it and evaluate it here
	return render(text)
end

function cb.innerpartial(partial)

	local name, indentation = partial[1], partial.indentation or ''
	local text = process_partial(name, indentation, partials)

	--HACK: substitute this partial to an unescaped variable with a
	--similar known name, and map this variable to a function which
	--will return the partial's text. It will be called later when
	--section is resolved.
	context['partial: '..name] = function () return text end

	return '{{{ partial: '..name..' }}}'
end

---mark the given function as being run inside a section.
local function make_section(func)
	local function pass(...)
		in_section = false
		return ...
	end
	return function(...)
		in_section = true
		return pass(func(...))
	end
end

cb.section = make_section(function(s, i, section)

	local ctx = resolve(context, section.tag)

	if not ctx then --undefined value, nothing to do
		return i, ''
	end

	local text = s:sub(section.textstart, section.textfinish - 1)

	if type(ctx) == 'function' then --call it to provide the result
		return i, render(ctx(text))
	end

	if type(ctx) ~= 'table' then --only the truth matters
		return i, render(text)
	end

	if islist(ctx) then
		if #ctx == 0 then --empty list, nothing to do
			return i, ''
		end

		--render text for each subcontext and accumulate the results
		local results = {}
		for index, subctx in ipairs(ctx) do
			local typectx = type(subctx)
			local newctx
			if typectx == 'table' then
				newctx = setmetatable(subctx, { __index = context })
			elseif typectx == 'string'
					or typectx == 'number'
					or typectx == 'boolean' then
				newctx = setmetatable(
					{ ['.'] = tostring(subctx) }, --create the magic . variable
					{ __index = context })
			else
				error('The context in section '..section.tag..' at index '
					..index..' has an invalid type ('..typectx..')!')
			end

			results[#results + 1] = render_in(text, newctx, partials)
		end

		--use the spaces
		return i, table.concat(results, section.finalspaces or '')
	end

	--ctx is a hash table, use it as the new context, which can also
	--access variables defined in context
	setmetatable(ctx, { __index = context})
	return i, render_in(text, ctx, partials)
end)

cb.invertedsection = make_section(function(s, i, section)
	local ctx = resolve(context, section.tag)
	if ctx and (not islist(ctx) or #ctx > 0) then --defined, nothing to do
		return i, ''
	end

	--render the inner text
	local finalspaces = blankifnil(section.finalspaces)
	local text = s:sub(
		section.textstart,
		(section.textfinish + #finalspaces) - 1)

	return i, render(text)
end)

patt = re.compile(grammar, cb) --fw. declared (not global)

return {
	render = render_in,
}
