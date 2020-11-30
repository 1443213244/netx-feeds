--RexChou<rexchou2012@gmail.com>
local fs = require "nixio.fs"
m=Map("cpc",translate("Netx log"))
s=m:section(TypedSection,"netx")
s.addremove=false
s.anonymous=true
o = s:option(Button, "")
o.title = translate("")
o.inputtitle = translate("Clear")
o.write = function()
	os.execute("echo \"\">/var/log/netx")
	luci.http.redirect(luci.dispatcher.build_url("admin","services", "log"))
 end

view_cfg = s:option(TextValue, "1", nil)
view_cfg.rmempty = false
view_cfg.rows = 43
function view_cfg.cfgvalue()
        return nixio.fs.readfile("/var/log/netx") or ""
end
return m
