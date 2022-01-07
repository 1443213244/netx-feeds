-- Created By ImmortalWrt
-- https://github.com/immortalwrt
local uci = luci.model.uci.cursor()
local util = require "luci.util"


mp = Map("acceleration", translate("Acceleration"))
mp.description = translate("A simple security tunnel written in Golang.")

mp:section(SimpleSection).template = "acceleration/acceleration_status"

s = mp:section(TypedSection, "acceleration")
s.anonymous=true
s.addremove=false

enable = s:option(Value, "enable", translate("Enable"))
enable:value("1",translate("off"))
enable:value("2",translate("on"))
enable.rmempty = false

pattern = s:option(Value, "pattern", translate("Pattern"))
pattern:value("bbr",translate("Radical"))
pattern:value("cubic",translate("Classic"))
pattern.rmempty = false

enddate = s:option(DummyValue, "enddate", translate("Expire"))

return mp
