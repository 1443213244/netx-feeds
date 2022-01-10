-- Created By ImmortalWrt
-- https://github.com/immortalwrt
local uci = luci.model.uci.cursor()
local util = require "luci.util"
local sy = require "luci.sys"


mp = Map("acceleration", translate("Domestic live broadcast acceleration"))
mp.description = translate("The industry's first live broadcast acceleration black technology, 24-hour HD streaming so easy!")

mp:section(SimpleSection).template = "acceleration/acceleration_status"

s = mp:section(TypedSection, "acceleration")
s.anonymous=true
s.addremove=false

enable = s:option(Value, "enable", translate("Enable"))
enable:value("0",translate("off"))
enable:value("1",translate("on"))
enable.rmempty = false

pattern = s:option(Value, "pattern", translate("Pattern"))
pattern:value("bbr",translate("Radical"))
pattern:value("cubic",translate("Classic"))
pattern.rmempty = false

enddate = s:option(DummyValue, "enddate", translate("Expire"))

function mp.on_commit(self)
        sy.call("/etc/init.d/acceleration restart >/dev/null 2>&1")
end

return mp
