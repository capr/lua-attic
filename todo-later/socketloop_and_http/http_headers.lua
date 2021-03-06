--http header values parsing
local glue = require'glue'
local b64 = require'libb64'
local http_date = require'http_date'
local re = require'lpeg.re' --for tokens()

--simple value parsers

function name(s) --Some-Name -> some_name
	if s == '' then return end
	return (s:gsub('%-','_'):lower())
end

local function int(s) --"123" -> 123
	s = tonumber(s)
	return s and math.floor(s) == s and s or nil
end

local function unquote(s)
	return (s:gsub('\\([^\\])', '%1'))
end

local function qstring(s) --'"a\"c"' -> 'a"c'
	s = s:match'^"(.-)"$'
	if not s then return end
	return unquote(s)
end

--simple compound value parsers (no comments or quoted strings involved)

local date = http_date.parse
local url = glue.pass --urls are not parsed (replace with uri.parse if you want them parsed)

local function namesplit(s)
	local split = glue.gsplit(s,' ?, ?')
	return function()
		local s = split()
		while s == '' do s = split() end --empty values don't count
		return s
	end
end

local function nameset(s) --"a,b" -> {a=true, b=true}
	local t = {}
	for s in namesplit(s) do
		t[name(s)] = true
	end
	return t
end

local function namelist(s) --"a,b" -> {'a','b'}
	local t = {}
	for s in namesplit(s) do
		t[#t+1] = name(s)
	end
	return t
end

--tokenized compound value parsers

local value_re = re.compile([[
	value         <- (quoted_string / comment / separator / token)* -> {}
	quoted_string <- ('"' {(quoted_pair / [^"])*} '"') -> unquote
	comment       <- {'(' (quoted_pair / comment / [^()])* ')'}
	separator     <- {[]()<>@,;:\"/[?={}]} / ' '
	token         <- {(!separator .)+}
	quoted_pair   <- '\' .
]], {
	unquote = unquote,
})

local function tokens(s) -- a,b, "a,b" ; (a,b) -> {a,",",b,",","a,b",";","(a,b)"}
	return value_re:match(s)
end

local function tfind(t, s, start, stop) --tfind({a1,...}, aN) -> N
	for i=start or 1,stop or #t do
		if t[i] == s then return i end
	end
end

local function tsplit(t, sep, start, stop) --{a1,...,aX,sep,aY,...,aZ} -> f; f() -> t,1,X; f() -> t,Y,Z
	start = start or 1
	stop = stop or #t
	local i,next_i = start,start
	return function()
		repeat
			if next_i > stop then return end
			i, next_i = next_i, (tfind(t, sep, next_i, stop) or stop+1)+1
		until next_i-1 - i > 0 --skip empty values
		return t, i, next_i-2
	end
end

local function kv(t, parsers, i, j) --k[=[v]] -> name(k), v|true|''
	local k,eq,v = unpack(t,i,j)
	k = name(k)
	if eq ~= '=' then v = true end
	if not v then v = '' end --the existence of '=' implies an empty value
	if parsers and parsers[k] then v = parsers[k](v) end
	return k,v
end

local function kvlist(t, sep, parsers, i, j) --k1[=[v1]]<sep>... -> {k1=v1|true|'',...}
	local dt = {}
	for t,ii,jj in tsplit(t,sep,i,j) do
		local k,v = kv(t,parsers,ii,jj)
		dt[k] = v
	end
	return dt
end

local function propertylist(s, parsers) --k1[=[v1]],... -> {k1=v1|true|'',...}
	return kvlist(tokens(s), ',', parsers)
end

local function valueparams(t, parsers, i, j) --value[;paramlist] -> t,i,j, params
	i,j = i or 1, j or #t
	local ii = tfind(t,';',i,j)
	local j_before_params = ii and ii-1 or j
	local params = ii and kvlist(t, ';', parsers, ii+1, j)
	return t,i,j_before_params, params
end

local function valueparamslist(s, parsers) --value1[;paramlist1],... -> {value1=custom_t1|true,...}
	local split = tsplit(tokens(s), ',')
	return function()
		local t,i,j = split()
		if not t then return end
		return valueparams(t, parsers, i, j)
	end
end

--parsers for propertylist and valueparamslist: parse(string | true) -> value | nil
local function no_value(b) return b == true or nil end
local function must_value(s) return s ~= true and s or nil end
local function must_int(s) return s ~= true and int(s) or nil end
local function opt_int(s) return s == true or int(s) end
local function must_name(s) return s ~= true and name(s) or nil end
local function must_nameset(s) return s ~= true and nameset(s) or nil end
local function opt_nameset(s) return s == true or nameset(s) end

--individual value parsers per rfc-2616 section 14

local parse = {} --{header_name = parser(s) -> v | nil[,err] }

local accept_parse = {q = tonumber}

function parse.accept(s) --#( type "/" subtype ( ";" token [ "=" ( token | quoted-string ) ] )* )
	local dt = {}
	for t,i,j, params in valueparamslist(s, accept_parse) do
		local type_, slash, subtype = unpack(t,i,j)
		if slash ~= '/' or not subtype then return end
		type_, subtype = name(type_), name(subtype)
		dt[string.format('%s/%s', type_, subtype)] = params or true
	end
	return dt
end

local function accept_list(s) ----1#( ( token | "*" ) [ ";" "q" "=" qvalue ] )
	local dt = {}
	for t,i,j, params in valueparamslist(s, accept_parse) do
		dt[name(t[i])] = params or true
	end
	return dt
end

parse.accept_charset = accept_list
parse.accept_encoding = accept_list
parse.accept_language = accept_list

function parse.accept_ranges(s) -- "none" | 1#( "bytes" | token )
	if s == 'none' then return {} end
	return nameset(s)
end

parse.accept_datetime = date
parse.age = int --seconds
parse.allow = nameset --#method

local function must_hex(len)
	return function(s)
		return s ~= true and #s == len and s:match'^[%x]+$' or nil
	end
end

local credentials_parsers = {
	realm = must_value,       --"realm" "=" quoted-string
	username = must_value,    --"username" "=" quoted-string
	uri = must_value,         --"uri" "=" request-uri   ; As specified by HTTP/1.1
	qop = must_name,          --"qop" "=" ( "auth" | "auth-int" | token )
	nonce = must_value,       --"nonce" "=" quoted-string
	cnonce = must_value,      --"cnonce" "=" quoted-string
	nc = must_hex(8),         --"nc" "=" 8LHEX
	response = must_hex(32),  --"response" "=" <"> 32LHEX <">
	opaque = must_value,      --"opaque" "=" quoted-string
	algorithm = must_name,    --"algorithm" "=" ( "MD5" | "MD5-sess" | token )
}

local function credentials(s) --basic base64-string | digest k=v,... per http://tools.ietf.org/html/rfc2617
	local scheme,s = s:match'^([^ ]+) (.*)$'
	if not scheme then return end
	scheme = name(scheme)
	if scheme == 'basic' then --basic base64("user:password")
		local user,pass = b64.decode_string(s):match'^([^:]*):(.*)$'
		return {scheme = scheme, user = user, pass = pass}
	elseif scheme == 'digest' then
		local dt = propertylist(s, credentials_parsers)
		dt.scheme = scheme
		return dt
	else
		return {scheme = scheme, rest = s}
	end
end

parse.authorization = credentials
parse.proxy_authorization = credentials

local function must_urllist(s)
	if s == true then return end
	local dt = {}
	for s in glue.gsplit(s, ' ') do
		dt[#dt+1] = url(s)
	end
	return #dt > 0 and dt or nil
end

local function must_bool(s)
	if s == true then return end
	s = s:lower()
	if s ~= 'true' and s ~= 'false' then return end
	return s == 'true'
end

local challenge_parsers = {
	realm = must_value,          --"realm" "=" quoted-string
	domain = must_urllist,       --"domain" "=" <"> URI ( 1*SP URI ) <">
	nonce = must_value,          --"nonce" "=" quoted-string
	opaque = must_value,         --"opaque" "=" quoted-string
	stale = must_bool,           --"stale" "=" ( "true" | "false" )
	algorithm = must_name,       --"algorithm" "=" ( "MD5" | "MD5-sess" | token )
	qop = must_nameset,          --"qop" "=" <"> 1# ( "auth" | "auth-int" | token ) <">
}

local function challenges(s) --scheme k=v,... per http://tools.ietf.org/html/rfc2617
	local scheme,s = s:match'^([^ ]+) ?(.*)$'
	if not scheme then return end
	scheme = name(scheme)
	local dt = propertylist(s, challenge_parsers)
	dt.scheme = scheme
	return dt
end

parse.www_authenticate = challenges
parse.proxy_authenticate = challenges

local cc_parse = {
	no_cache = no_value,          --"no-cache"
	no_store = no_value,          --"no-store"
	max_age = must_int,           --"max-age" "=" delta-seconds
	max_stale = opt_int,          --"max-stale" [ "=" delta-seconds ]
	min_fresh = must_int,         --"min-fresh" "=" delta-seconds
	no_transform = no_value,      --"no-transform"
	only_if_cached = no_value,    --"only-if-cached"
	public = no_value,            --"public"
	private = opt_nameset,        --"private" [ "=" <"> 1#field-name <"> ]
	no_cache = opt_nameset,       --"no-cache" [ "=" <"> 1#field-name <"> ]
	no_store = no_value,          --"no-store"
	no_transform = no_value,      --"no-transform"
	must_transform = no_value,    --"must-transform"
	must_revalidate = no_value,   --"must-revalidate"
	proxy_revalidate = no_value,  --"proxy-revalidate"
	max_age = must_int,           --"max-age" "=" delta-seconds
	s_maxage = must_int,          --"s-maxage" "=" delta-seconds
}

function parse.cache_control(s)
	return propertylist(s, cc_parse)
end

parse.connection = nameset --1#(connection-token)
parse.content_encoding = namelist --1#(content-coding)
parse.content_language = nameset --1#(language-tag)
parse.content_length = int
parse.content_location = url

function parse.content_md5(s)
	return glue.tohex(b64.decode_string(s))
end

function parse.content_range(s) --bytes <from>-<to>/<total> -> {from=,to=,total=,size=}
	local from,to,total = s:match'bytes (%d+)%-(%d+)/(%d+)'
	local t = {}
	t.from = tonumber(from)
	t.to = tonumber(to)
	t.total = tonumber(total)
	if t.from and t.to then t.size = t.to - t.from + 1 end
	return t
end

function parse.content_type(s) --type "/" subtype *( ";" name "=" value )
	local t,i,j, params = valueparams(tokens(s))
	if t[i+1] ~= '/' then return end
	params = params or {}
	params.media_type = name(table.concat(t,'',i,j))
	return params
end

parse.date = date

local function etag(s) --[ "W/" ] quoted-string -> {etag = s, weak = true|false}
	local weak_etag = s:match'^W/(.*)$'
	local etag = qstring(weak_etag or s)
	if not etag then return end
	return {etag = etag, weak = weak_etag ~= nil}
end

parse.etag = etag

local expect_parse = {['100_continue'] = no_value}

function parse.expect(s) --1#( "100-continue" | ( token "=" ( token | quoted-string ) ) )
	return propertylist(s, expect_parse)
end

parse.expires = date
parse.from = glue.pass --email-address

function parse.host(s) --host [ ":" port ]
	local host, port = s:match'^(.-) ?: ?(.*)$'
	if not host then
		host, port = s, 80
	else
		port = int(port)
		if not port then return end
	end
	host = host:lower()
	return {host = host, port = port}
end

local function etags(s) -- "*" | 1#( [ "W/" ] quoted-string )
	if s == '*' then return '*' end
	local dt = {}
	for t,i,j in tsplit(tokens(s), ',') do
		local weak,slash,etag = unpack(t,i,j)
		local is_weak = weak == 'W' and slash == '/'
		etag = is_weak and etag or weak
		dt[#dt+1] = {etag = etag, weak = is_weak}
	end
	return dt
end

parse.if_match = etags
parse.if_modified_since = date
parse.if_none_match = etags

function parse.if_range(s) -- etag | date
	local is_etag = s:match'^W/' or s:match'^"'
	return is_etag and etag(s) or date(s)
end

parse.if_unmodified_since = date
parse.last_modified = date
parse.location = url
parse.max_forwards = int

local pragma_parse = {no_cache = no_value}

function parse.pragma(s) -- 1#( "no-cache" | token [ "=" ( token | quoted-string ) ] )
	return propertylist(s, pragma_parse)
end

function parse.range(s) --bytes=<from>-<to> -> {from=,to=,size=}
	local from,to = s:match'bytes=(%d+)%-(%d+)'
	local t = {}
	t.from = tonumber(from)
	t.to = tonumber(to)
	if t.from and t.to then t.size = t.to - t.from + 1 end
	return t
end

parse.referer = url

function parse.retry_after(s) --date | seconds
	return int(s) or date(s)
end

function parse.server(s) --1*( ( token ["/" version] ) | comment )
	local dt = {}
	for t,i,j in tsplit(tokens(s), ',') do
		local product, slash, version = unpack(t,i,j)
		if slash == '/' then
			dt[name(product)] = version or true
		end
	end
	return dt
end

local te_parse = {trailers = no_value, q = must_int}

function parse.te(s) --#( "trailers" | ( transfer-extension [ accept-params ] ) )
	local dt = {}
	for t,i,j, params in valueparamslist(s, te_parse) do
		dt[name(t[i])] = params or true
	end
	return dt
end

parse.trailer = nameset --1#header-name

local trenc_parse = {chunked = no_value}

function parse.transfer_encoding(s) --1# ( "chunked" | token *( ";" name "=" ( token | quoted-string ) ) )
	local dt = {params = {}}
	for t,i,j, params in valueparamslist(s, trenc_parse) do
		local k = name(t[i])
		dt[#dt+1] = k
		dt.params[k] = params
	end
	return dt
end

function parse.upgrade(s) --1#product
	local dt = {}
	for t,i,j in tsplit(tokens(s), ',') do
		local protocol,slash,version = unpack(t,i,j)
		dt[name(protocol)] = version or true
	end
	return dt
end

parse.user_agent = string.lower --1*( product | comment )

function parse.vary(s) --( "*" | 1#field-name )
	if s == '*' then return '*' end
	return nameset(s)
end

function parse.via(s) --1#( [ protocol-name "/" ] protocol-version host [ ":" port ] [ comment ] )
	local dt = {}
	for t,i,j in tsplit(tokens(s), ',') do
		local proto = t[i+1] == '/' and t[i] or nil
		local o = proto and 2 or 0
		if o+j-i+1 < 2 then return end
		local ver, host = t[o+i], t[o+i+1]
		local port = t[o+i+2] ==':' and t[o+i+3] or nil
		local comment = t[o+i+2+(port and 2 or 0)]
		if comment == ',' then comment = nil end
		if ver and host then
			dt[#dt+1] = {
				protocol = proto and name(proto),
				version = ver:lower(),
				host = host:lower(),
				comment = comment
			}
		end
	end
	return dt
end

function parse.warning(s) --1#(code ( ( host [ ":" port ] ) | pseudonym ) text [date])
	local dt = {}
	for t,i,j in tsplit(tokens(s), ',') do
		local code, host, port, message, date
		if t[i+2] == ':' then
			code, host, port, message, date = unpack(t,i,j)
		else
			code, host, message, date = unpack(t,i,j)
		end
		dt[#dt+1] = {code = int(code), host = host:lower(), port = int(port), message = message}
	end
	return dt
end

function parse.dnt(s) return s == '1' end --means "do not track"

function parse.link(s) --</feed>; rel="alternate" (http://tools.ietf.org/html/rfc5988)
	--[[ --TODO
	Link           = "Link" ":" #link-value
	link-value     = "<" URI-Reference ">" *( ";" link-param )
	link-param     = ( ( "rel" "=" relation-types )
					  | ( "anchor" "=" <"> URI-Reference <"> )
					  | ( "rev" "=" relation-types )
					  | ( "hreflang" "=" Language-Tag )
					  | ( "media" "=" ( MediaDesc | ( <"> MediaDesc <"> ) ) )
					  | ( "title" "=" quoted-string )
					  | ( "title*" "=" ext-value )
					  | ( "type" "=" ( media-type | quoted-mt ) )
					  | ( link-extension ) )
	link-extension = ( parmname [ "=" ( ptoken | quoted-string ) ] )
					  | ( ext-name-star "=" ext-value )
	ext-name-star  = parmname "*" ; reserved for RFC2231-profiled
										  ; extensions.  Whitespace NOT
										  ; allowed in between.
	ptoken         = 1*ptokenchar
	ptokenchar     = "!" | "#" | "$" | "%" | "&" | "'" | "("
					  | ")" | "*" | "+" | "-" | "." | "/" | DIGIT
					  | ":" | "<" | "=" | ">" | "?" | "@" | ALPHA
					  | "[" | "]" | "^" | "_" | "`" | "{" | "|"
					  | "}" | "~"
	media-type     = type-name "/" subtype-name
	quoted-mt      = <"> media-type <">
	relation-types = relation-type
					  | <"> relation-type *( 1*SP relation-type ) <">
	relation-type  = reg-rel-type | ext-rel-type
	reg-rel-type   = LOALPHA *( LOALPHA | DIGIT | "." | "-" )
	ext-rel-type   = URI
	]]
	return s
end

function parse.refresh(s) --seconds; url=<url> (not standard but supported)
	local n, url = s:match'^(%d+) ?; ?url ?= ?'
	n = tonumber(n)
	return n and {url = url, pause = n}
end

function parse.set_cookie(s) --TODO
	return s
end

function parse.cookie(s) --TODO

end

function parse.strict_transport_security(s) --http://tools.ietf.org/html/rfc6797
	--[[ --TODO
	  Strict-Transport-Security = "Strict-Transport-Security" ":"
                                 [ directive ]  *( ";" [ directive ] )

     directive                 = directive-name [ "=" directive-value ]
     directive-name            = token
     directive-value           = token | quoted-string
	]]
	return s
end

function parse.content_disposition(s)
	--[[ --TODO
	 content-disposition = "Content-Disposition" ":"
                              disposition-type *( ";" disposition-parm )
        disposition-type = "attachment" | disp-extension-token
        disposition-parm = filename-parm | disp-extension-parm
        filename-parm = "filename" "=" quoted-string
        disp-extension-token = token
        disp-extension-parm = token "=" ( token | quoted-string )
	]]
	return s
end

parse.x_requested_with = name   --"XMLHttpRequest"
parse.x_forwarded_for = nameset --client1, proxy1, proxy2
parse.x_forwarded_proto = name  --"https" | "http"
parse.x_powered_by = glue.pass  --PHP/5.2.1

--parsing API

local function parse_value(k,v)
	if parse[k] then return parse[k](v) end
	return v --unknown header, return unparsed
end

local function parse_values(t)
	local dt, errt = {}, {}
	for k,v in pairs(t) do
		local pv,err = parse_value(k,v)
      dt[k] = pv
		if pv == nil then
			errt[k] = err or string.format('invalid value "%s"', v)
		end
	end
	return dt, errt
end

local function lazy_parse(t) --lazy_parse(s) -> t; t.header_name -> parsed_value
	return setmetatable({}, {__index = function(dt,k)
		dt[k] = parse_value(k, t[k])
		return rawget(dt,k)
	end})
end

if not ... then require'http_headers_test' end

return {
	parsers = parse,
	parse_value = parse_value,
	parse_values = parse_values,
	lazy_parse = lazy_parse,
}

