--[=========================================================================[
   Lunity v0.12 by Gavin Kistner
   See http://github.com/Phrogz/Lunity for usage documentation.
   Licensed under Creative Commons Attribution 3.0 United States License.
   See http://creativecommons.org/licenses/by/3.0/us/ for details.
--]=========================================================================]

-- Cache these so we can silence the real ones during a run
local print,write = print,io.write

-- FIXME: this will fail if two test suites are running interleaved
local assertsPassed, assertsAttempted
local function assertionSucceeded()
	assertsPassed = assertsPassed + 1
	write('.')
	return true
end

-- This is the table that will be used as the environment for the tests,
-- making assertions available within the file.
local lunity = setmetatable({}, {__index=_G})

function lunity.fail(msg)
	assertsAttempted = assertsAttempted + 1
	if not msg then msg = "(test failure)" end
	error(msg, 2)
end

function lunity.assert(testCondition, msg)
	assertsAttempted = assertsAttempted + 1
	if not testCondition then
		if not msg then msg = "assert() failed: value was "..tostring(testCondition) end
		error(msg, 2)
	end
	return assertionSucceeded()
end

function lunity.assertEqual(actual, expected, msg)
	assertsAttempted = assertsAttempted + 1
	if actual~=expected then
		if not msg then
			msg = string.format("assertEqual() failed: expected %s, was %s",
				tostring(expected),
				tostring(actual)
			)
		end
		error(msg, 2)
	end
	return assertionSucceeded()
end

function lunity.assertType(actual, expectedType, msg)
	assertsAttempted = assertsAttempted + 1
	if type(actual) ~= expectedType then
		if not msg then
			msg = string.format("assertType() failed: value %s is a %s, expected to be a %s",
				tostring(actual),
				type(actual),
				expectedType
			)
		end
		error(msg, 2)
	end
	return assertionSucceeded()
end

function lunity.assertTableEquals(actual, expected, msg, keyPath)
	assertsAttempted = assertsAttempted + 1
	-- Easy out
	if actual == expected then
		if not keyPath then
			return assertionSucceeded()
		else
			return true
		end
	end

	if not keyPath then keyPath = {} end

	if type(actual) ~= 'table' then
		if not msg then
			msg = "Value passed to assertTableEquals() was not a table."
		end
		error(msg, 2 + #keyPath)
	end

	-- Ensure all keys in t1 match in t2
	for key,expectedValue in pairs(expected) do
		keyPath[#keyPath+1] = tostring(key)
		local actualValue = actual[key]
		if type(expectedValue)=='table' then
			if type(actualValue)~='table' then
				if not msg then
					msg = "Tables not equal; expected "..table.concat(keyPath,'.').." to be a table, but was a "..type(actualValue)
				end
				error(msg, 1 + #keyPath)
			elseif expectedValue ~= actualValue then
				lunity.assertTableEquals(actualValue, expectedValue, msg, keyPath)
			end
		else
			if actualValue ~= expectedValue then
				if not msg then
					if actualValue == nil then
						msg = "Tables not equal; missing key '"..table.concat(keyPath,'.').."'."
					else
						msg = "Tables not equal; expected '"..table.concat(keyPath,'.').."' to be "..tostring(expectedValue)..", but was "..tostring(actualValue)
					end
				end
				error(msg, 1 + #keyPath)
			end
		end
		keyPath[#keyPath] = nil
	end

	-- Ensure actual doesn't have keys that aren't expected
	for k,_ in pairs(actual) do
		if expected[k] == nil then
			if not msg then
				msg = "Tables not equal; found unexpected key '"..table.concat(keyPath,'.').."."..tostring(k).."'"
			end
			error(msg, 2 + #keyPath)
		end
	end

	return assertionSucceeded()
end

function lunity.assertNotEqual(actual, expected, msg)
	assertsAttempted = assertsAttempted + 1
	if actual==expected then
		if not msg then
			msg = string.format("assertNotEqual() failed: value not allowed to be %s",
				tostring(actual)
			)
		end
		error(msg, 2)
	end
	return assertionSucceeded()
end

function lunity.assertTrue(actual, msg)
	assertsAttempted = assertsAttempted + 1
	if actual ~= true then
		if not msg then
			msg = string.format("assertTrue() failed: value was %s, expected true",
				tostring(actual)
			)
		end
		error(msg, 2)
	end
	return assertionSucceeded()
end

function lunity.assertFalse(actual, msg)
	assertsAttempted = assertsAttempted + 1
	if actual ~= false then
		if not msg then
			msg = string.format("assertFalse() failed: value was %s, expected false",
				tostring(actual)
			)
		end
		error(msg, 2)
	end
	return assertionSucceeded()
end

function lunity.assertNil(actual, msg)
	assertsAttempted = assertsAttempted + 1
	if actual ~= nil then
		if not msg then
			msg = string.format("assertNil() failed: value was %s, expected nil",
				tostring(actual)
			)
		end
		error(msg, 2)
	end
	return assertionSucceeded()
end

function lunity.assertNotNil(actual, msg)
	assertsAttempted = assertsAttempted + 1
	if actual == nil then
		if not msg then msg = "assertNotNil() failed: value was nil" end
		error(msg, 2)
	end
	return assertionSucceeded()
end

function lunity.assertTableEmpty(actual, msg)
	assertsAttempted = assertsAttempted + 1
	if type(actual) ~= "table" then
		msg = string.format("assertTableEmpty() failed: expected a table, but got a %s",
			type(table)
		)
		error(msg, 2)
	else
		local key, value = next(actual)
		if key ~= nil then
			if not msg then
				msg = string.format("assertTableEmpty() failed: table has non-nil key %s=%s",
					tostring(key),
					tostring(value)
				)
			end
			error(msg, 2)
		end
		return assertionSucceeded()
	end
end

function lunity.assertTableNotEmpty(actual, msg)
	assertsAttempted = assertsAttempted + 1
	if type(actual) ~= "table" then
		msg = string.format("assertTableNotEmpty() failed: expected a table, but got a %s",
			type(actual)
		)
		error(msg, 2)
	else
		if next(actual) == nil then
			if not msg then
				msg = "assertTableNotEmpty() failed: table has no keys"
			end
			error(msg, 2)
		end
		return assertionSucceeded()
	end
end

function lunity.assertSameKeys(t1, t2, msg)
	assertsAttempted = assertsAttempted + 1
	local function bail(k,x,y)
		if not msg then msg = string.format("Table #%d has key '%s' not present in table #%d",x,tostring(k),y) end
		error(msg, 3)
	end
	for k,_ in pairs(t1) do if t2[k]==nil then bail(k,1,2) end end
	for k,_ in pairs(t2) do if t1[k]==nil then bail(k,2,1) end end
	return assertionSucceeded()
end

-- Ensures that the value is a function OR may be called as one
function lunity.assertInvokable(value, msg)
	assertsAttempted = assertsAttempted + 1
	local meta = getmetatable(value)
	if (type(value) ~= 'function') and not (meta and meta.__call and (type(meta.__call)=='function')) then
		if not msg then
			msg = string.format("assertInvokable() failed: '%s' can not be called as a function",
				tostring(value)
			)
		end
		error(msg, 2)
	end
	return assertionSucceeded()
end

function lunity.assertErrors(invokable, ...)
	lunity.assertInvokable(invokable)
	if pcall(invokable,...) then
		local msg = string.format("assertErrors() failed: %s did not raise an error",
			tostring(invokable)
		)
		error(msg, 2)
	end
	return assertionSucceeded()
end

function lunity.assertDoesNotError(invokable, ...)
	lunity.assertInvokable(invokable)
	if not pcall(invokable,...) then
		local msg = string.format("assertDoesNotError() failed: %s raised an error",
			tostring(invokable)
		)
		error(msg, 2)
	end
	return assertionSucceeded()
end

function lunity.is_nil(value)      return type(value)=='nil'      end
function lunity.is_boolean(value)  return type(value)=='boolean'  end
function lunity.is_number(value)   return type(value)=='number'   end
function lunity.is_string(value)   return type(value)=='string'   end
function lunity.is_table(value)    return type(value)=='table'    end
function lunity.is_function(value) return type(value)=='function' end
function lunity.is_thread(value)   return type(value)=='thread'   end
function lunity.is_userdata(value) return type(value)=='userdata' end

local function run(self, opts)
	if not opts then opts = {} end
	if opts.quiet then
		_G.print = function() end
		io.write = function() end
	end

	assertsPassed = 0
	assertsAttempted = 0

	local useANSI,useHTML = true, false
	if opts.useHTML ~= nil then useHTML=opts.useHTML end
	if not useHTML and opts.useANSI ~= nil then useANSI=opts.useANSI end

	local suiteName = getmetatable(self).name

	if useHTML then
		print("<h2 style='background:#000; color:#fff; margin:1em 0 0 0; padding:0.1em 0.4em; font-size:120%'>"..suiteName.."</h2><pre style='margin:0; padding:0.2em 1em; background:#ffe; border:1px solid #eed; overflow:auto'>")
	else
		print(string.rep('=',78))
		print(suiteName)
		print(string.rep('=',78))
	end
	io.stdout:flush()


	local testnames = {}
	for name, test in pairs(self) do
		if type(test)=='function' and name~='before' and name~='after' then
			testnames[#testnames+1]=name
		end
	end
	table.sort(testnames)


	local startTime = os.clock()
	local passed = 0
	for _,name in ipairs(testnames) do
		local scratchpad = {}
		write(name..": ")
		if self.before then self.before(scratchpad) end
		local successFlag, errorMessage = pcall(self[name], scratchpad)
		if successFlag then
			print("pass")
			passed = passed + 1
		else
			if useANSI then
				print("\27[31m\27[1mFAIL!\27[0m")
				print("\27[31m"..errorMessage.."\27[0m")
			elseif useHTML then
				print("<b style='color:red'>FAIL!</b>")
				print("<span style='color:red'>"..errorMessage.."</span>")
			else
				print("FAIL!")
				print(errorMessage)
			end
		end
		io.stdout:flush()
		if self.after then self.after(scratchpad) end
	end
	local elapsed = os.clock() - startTime

	if useHTML then
		print("</pre>")
	else
		print(string.rep('-', 78))
	end

	print(string.format("%d/%d tests passed (%0.1f%%)",
		passed,
		#testnames,
		100 * passed / #testnames
	))

	if useHTML then print("<br>") end

	print(string.format("%d total successful assertion%s in ~%.0fms (%.0f assertions/second)",
		assertsPassed,
		assertsPassed == 1 and "" or "s",
		elapsed*1000,
		assertsAttempted / elapsed
	))

	if not useHTML then print("") end
	io.stdout:flush()

	if opts.quiet then
		_G.print = print
		io.write = write
	end
end

local function lunity_module(name)
	return setmetatable(
		{test=setmetatable({}, {__call=run, name=name or '(test suite)'})},
		{__index=lunity}
	)
end

setfenv(1, lunity_module())

------------------------------------------------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------

local SLAXML = require 'slaxml'

local XML = {}
for filename in io.popen('ls slaxml_test'):lines() do
	XML[filename:match('^(.-)%.[^.]+$')] = io.open("slaxml_test/"..filename):read('*all')
end

local function countParsings(xmlName,options,expected)
	local counts,counters = {},{}
	expected.end_tag = expected.start_tag
	for name,_ in pairs(expected) do
		counts[name]   = 0
		counters[name] = function() counts[name]=counts[name]+1 end
	end
	SLAXML.parser(counters):parse(XML[xmlName],options)
	for name,ct in pairs(expected) do
		assertEqual(counts[name],ct,"There should have been be exactly "..ct.." "..name.."() callback(s) in "..xmlName..", not "..counts[name])
	end
end

function test:namespace()
	local elementStack = {}
	SLAXML.parser{
		start_tag = function(name,nsURI)
			table.insert(elementStack,{name=name,nsURI=nsURI})
		end,
		end_tag = function(name,nsURI)
			local pop = table.remove(elementStack)
			assertEqual(name,pop.name,"Got close "..name.." to close "..pop.name)
			assertEqual(nsURI,pop.nsURI,"Got close namespace "..(nsURI or "nil").." to close namespace "..(pop.nsURI or "nil"))
		end,
	}:parse(XML['namespace_prefix'])
end

function test:dom()
	local function checkParentage(el)
		for _,child in ipairs(el) do
			assertEqual(child.parent,el,("'%s' children should have a .parent pointing to their parent '%s'"):format(child.type,el.type))
			if #child > 0 then checkParentage(child) end
		end
	end

	local doc = SLAXML.dom(XML['entities_and_namespaces'])
	assertEqual(doc.type,'document')
	assertEqual(doc[1].type,'pi')
	assertEqual(#doc,3)
	assertEqual(doc[3],doc.root)
	assertEqual(#doc.root,7)
	assertEqual(#doc.root.el,3)
	assertEqual(doc.root.attr.version,"1.0")
	assertEqual(doc.root.attr.xmlns,"http://www.w3.org/2005/07/scxml")
	assertEqual(doc.root.attr['xmlns:p'],"http://phrogz.net/")

	checkParentage(doc)

	local s = doc.root.el[1]
	assertEqual(s.name,'script')
	assertEqual(s.type,'element')
	assertEqual(#s,2)
	assertEqual(#s.el,0)
	assertEqual(s[1].type,'text')
	assertEqual(s[2].type,'text')

	local t = doc.root.el[2].el[1]
	assertEqual(t.name,'transition')
	assertEqual(t[6].type,'comment')

	for _,attr in ipairs(doc.root.attr) do
		assertEqual(attr.parent,doc.root,"Attributes should reference their parent element")
		assertEqual(attr.type,"attribute")
		assertNil(attr.nsURI,"No attribute on the root of this document has a namespace")
	end
end

function test:slim_and_trim_dom()
	local function checkParentage(el)
		for _,child in ipairs(el) do
			assertNil(child.parent,'"slim" dom children should not have a parent')
			if child then checkParentage(child) end
		end
	end

	local doc = SLAXML.dom(XML['entities_and_namespaces'],{simple=true,strip_whitespace=true})
	assertEqual(doc.type,'document')
	assertEqual(doc[1].type,'pi')
	assertEqual(#doc,2)
	local root = doc[2]
	assertEqual(#root,3)
	assertNil(root.el)
	assertNil(root.attr.version)
	assertNil(root.attr.xmlns)
	assertNil(root.attr['xmlns:p'])
	assertEqual(#root.attr,3)

	checkParentage(doc)

	local s = root[1]
	assertEqual(s.name,'script')
	assertEqual(s.type,'element')
	assertEqual(#s,2)
	assertEqual(s[1].type,'text')
	assertEqual(s[2].type,'text')

	local t = root[2][1]
	assertEqual(t.name,'transition')
	assertEqual(#t,5)
	assertEqual(t[3].type,'comment')
end

function test:dom_entities()
	local doc = SLAXML.dom(XML['entities_and_namespaces'])
	local s = doc.root.el[1]
	assertEqual(s[1].value,' ampersand = "&"; ')
	assertEqual(s[2].value,"quote = '\"'; apos  = \"'\"")

	local t = doc.root.el[2].el[1]
	assertEqual(t.attr.cond,[[ampersand=='&' and quote=='"' and apos=="'"]])

	assertEqual(t[6].value,' your code &gt; all ')
end

function test:xml_namespace()
	local doc = SLAXML.dom(XML['xml_namespace'])
	for i,attr in ipairs(doc.root.attr) do
		if attr.name=='space' then
			assertEqual(attr.nsURI,[[http://www.w3.org/XML/1998/namespace]])
			break
		end
	end
end

function test:xml_namespace_immediate_use()
	local doc = SLAXML.dom(XML['namespace_declare_and_use'])
	local cat1 = doc.root.el[1]
	assertEqual(cat1.name,'cat')
	assertEqual(cat1.nsURI,'cat')
	local cat2 = cat1.el[1]
	assertEqual(cat2.name, 'cat')
	assertEqual(cat2.nsURI,'cat')
	local dog1 = cat1.el[2]
	assertEqual(dog1.name, 'dog')
	assertEqual(dog1.nsURI,'dog')
	local cat3 = dog1.el[1]
	assertEqual(cat3.name, 'cat')
	assertEqual(cat3.nsURI,'cat')
	local hog1 = dog1.el[2]
	assertEqual(hog1.name, 'hog')
	assertEqual(hog1.nsURI,'hog')
	for _,attr in ipairs(hog1.attr) do
		if attr.value=='yes' then
			assertEqual(attr.nsURI,attr.name)
		end
	end
	local hog2 = hog1.el[1]
	assertEqual(hog2.name, 'hog')
	assertEqual(hog2.nsURI,'hog')
	local bog1 = hog1.el[2]
	assertEqual(bog1.name, 'bog')
	assertEqual(bog1.nsURI,'bog')
	local dog2 = dog1.el[3]
	assertEqual(dog2.name, 'dog')
	assertEqual(dog2.nsURI,'dog')
	local cog2 = doc.root.el[2]
	assertEqual(cog2.name, 'cog')
	assertEqual(cog2.nsURI,'cog')
end

function test:dom_serializer()

end

function test:dom_namespaces()
	local scxmlNS  = "http://www.w3.org/2005/07/scxml"
	local phrogzNS = "http://phrogz.net/"
	local barNS    = "bar"
	local xNS,yNS  = "xNS", "yNS"

	local doc = SLAXML.dom(XML['entities_and_namespaces'])
	local s = doc.root.el[1]
	local p = doc.root.el[2].el[1].el[2]
	local t = doc.root.el[2].el[1]
	local foo  = t.el[3]
	local bar1 = foo.el[1]
	local bar2 = t.el[4]
	local wrap = doc.root.el[3]
	local e = wrap.el[1]

	assertEqual(doc.root.nsURI,scxmlNS)
	assertEqual(s.nsURI,scxmlNS)
	assertEqual(p.name,'goToSlide')
	assertEqual(p.nsURI,phrogzNS)

	assertEqual(foo.name,'foo')
	assertEqual(foo.nsURI,barNS)
	assertEqual(bar1.nsURI,barNS)
	assertEqual(bar2.nsURI,scxmlNS)

	assertEqual(wrap.nsURI,scxmlNS)
	assertEqual(wrap.attr['xmlns:x'],xNS)
	assertEqual(wrap.attr['xmlns:y'],yNS)
	assertEqual(e.name,'e')
	assertEqual(e.nsURI,scxmlNS)
	assertEqual(#e.attr,6)
	assertEqual(e.attr.a1,"a1")
	assert(e.attr.a2=="a2" or e.attr.a2=="a2-x")

	local nsByValue = {}
	for _,attr in ipairs(e.attr) do nsByValue[attr.value] = attr.nsURI end
	assertNil(nsByValue['a1'])
	assertNil(nsByValue['a2'])
	assertNil(nsByValue['a3'])
	assertEqual(nsByValue['a2-x'],xNS)
	assertEqual(nsByValue['a3-x'],xNS)
	assertEqual(nsByValue['a3-y'],yNS)
end

function test:invalid_documents()
	local silentParser = SLAXML.parser{}
	assertErrors(silentParser.parse, silentParser, XML['invalid_unquoted']        )
	assertErrors(silentParser.parse, silentParser, XML['invalid_pi_only']         )
	assertErrors(silentParser.parse, silentParser, XML['invalid_unclosed_tags']   )
	--TODO: this doesn't raise
	assertErrors(silentParser.parse, silentParser, XML['invalid_literal_gtamplt'] )
end

function test:comments()
	countParsings('commentwrapper',{},{
		pi           = 0,
		comment      = 2,
		start_tag    = 1,
		attr         = 0,
		text         = 2,
		namespace    = 0,
	})
end

function test:serializer()
	local doc = SLAXML.dom(XML['commentwrapper'],{})
	local xml = SLAXML.format(doc)
	assertEqual(xml, XML['commentwrapper'])

	local doc = SLAXML.dom(XML['commentwrapper'],{strip_whitespace=true})
	local xml = SLAXML.format(doc,{indent='\t'})
	assertEqual(xml, '<!-- before -->\n<r/>\n<!-- after -->')

	local doc = SLAXML.dom(XML['cdata'])
	local xml = SLAXML.format(doc)
	assertEqual(xml, XML['cdata'])

	local doc = SLAXML.dom(XML['utf8'],{strip_whitespace=true})

	local xml = SLAXML.format(doc)
	assertEqual(xml, [[<?xml version="1.0" encoding="utf-8"?><root><s a="crêpes: €3">crêpes: €3</s><s a="crêpes: €3">crêpes: €3</s><s a="crêpes: €3">crêpes: €3</s></root>]])

	local xml = SLAXML.format(doc,{indent='\t'})
	assertEqual(xml, [[<?xml version="1.0" encoding="utf-8"?>
<root>
	<s a="crêpes: €3">
		crêpes: €3
	</s>
	<s a="crêpes: €3">
		crêpes: €3
	</s>
	<s a="crêpes: €3">
		crêpes: €3
	</s>
</root>]])

	local xml = SLAXML.format(doc,{indent=3})
	assertEqual(xml, [[<?xml version="1.0" encoding="utf-8"?>
<root>
   <s a="crêpes: €3">
      crêpes: €3
   </s>
   <s a="crêpes: €3">
      crêpes: €3
   </s>
   <s a="crêpes: €3">
      crêpes: €3
   </s>
</root>]])
end

function test:serialize_sorting()
	local doc = SLAXML.dom(XML['state'],{strip_whitespace=true})

	local xml = SLAXML.format(doc,{omit={'nope', 'http://nvidia.com/drive/ar/scxml', 'http://www.w3.org/2005/07/scxml'}})
	assertEqual(xml, '<?xml version="1.0" encoding="UTF-8"?>')

	local xml = SLAXML.format(doc,{sort=true, omit={'nope', 'http://nvidia.com/drive/ar/scxml'}})
	assertEqual(xml, '<?xml version="1.0" encoding="UTF-8"?><scxml version="1" xmlns="http://www.w3.org/2005/07/scxml"><state id="AwaitingChoice"><state id="UpToDate"><transition event="ota.available" target="UpdateAvailable" type="internal"/></state></state></scxml>')

	local xml = SLAXML.format(doc,{indent='\t', sort=true, omit={'nope'}})
	assertEqual(xml, [====[<?xml version="1.0" encoding="UTF-8"?>
<scxml version="1" xmlns="http://www.w3.org/2005/07/scxml" xmlns:nv="http://nvidia.com/drive/ar/scxml">
	<state id="AwaitingChoice" nv:loc="0 0 400 300">
		<state id="UpToDate" nv:loc="10 10 100 40" nv:rgba="0 0.5 1 0.2">
			<transition event="ota.available" target="UpdateAvailable" type="internal" nv:anchor="e1"/>
		</state>
	</state>
</scxml>]====])

	local xml = SLAXML.format(doc,{indent='\t', sort=true})
	assertEqual(xml, [====[<?xml version="1.0" encoding="UTF-8"?>
<scxml version="1" xmlns="http://www.w3.org/2005/07/scxml" xmlns:dumb="nope" xmlns:nv="http://nvidia.com/drive/ar/scxml">
	<state id="AwaitingChoice" nv:loc="0 0 400 300">
		<state id="UpToDate" nv:loc="10 10 100 40" nv:rgba="0 0.5 1 0.2">
			<transition event="ota.available" target="UpdateAvailable" type="internal" dumb:status="very" nv:anchor="e1"/>
		</state>
	</state>
	<dumb:wrapper>
		<state/>
	</dumb:wrapper>
</scxml>]====])



end

function test:simplest()
	countParsings('root_only',{},{
		pi           = 0,
		comment      = 0,
		start_tag    = 1,
		attr         = 0,
		text         = 0,
		namespace    = 0,
	})
end

function test:whitespace()
	countParsings('lotsaspace',{},{
		pi           = 0,
		comment      = 0,
		start_tag    = 3,
		attr         = 2,
		text         = 5,
		namespace    = 0,
	})

	countParsings('lotsaspace',{strip_whitespace=true},{
		pi           = 0,
		comment      = 0,
		start_tag    = 3,
		attr         = 2,
		text         = 2,
		namespace    = 0,
	})

	local simple = SLAXML.dom(XML['lotsaspace'],{strip_whitespace=true}).root
	local a = simple.el[1]
	assertEqual(a[1].value,"It's the end of the world\n  as we know it, and I feel\n	fine.")
	assertEqual(a[2].value,"\nIt's a [raw][[raw]] >\nstring that <do/> not care\n	about honey badgers.\n\n  ")
end

function test:utf8()
	local root = SLAXML.dom(XML['utf8'],{strip_whitespace=true}).root
	for _,s in ipairs(root) do
		assertEqual(s.attr.a,"crêpes: €3")
		assertEqual(s[1].value,"crêpes: €3")
	end
end

test{useANSI=false}

local function soap_example()
	require'pp'(SLAXML.dom([[
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/"
		xmlns:ns0="http://schemas.xmlsoap.org/soap/encoding/"
		xmlns:ns1="http://test.soap.service.luapower.com/"
		xmlns:ns2="http://schemas.xmlsoap.org/soap/envelope/"
		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
		SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
	<SOAP-ENV:Header/>
	<ns2:Body>
		<ns1:serviceA>
			<paramA></paramA>
			<paramB>SOME STUFF</paramB>
			<paramC>123</paramC>
		</ns1:serviceA>
	</ns2:Body>
</SOAP-ENV:Envelope>
]], {simple = true}))
end
--soap_example()
