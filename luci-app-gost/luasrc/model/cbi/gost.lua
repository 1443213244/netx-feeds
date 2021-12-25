-- Created By ImmortalWrt
-- https://github.com/immortalwrt

mp = Map("gost", translate("Gost"))
mp.description = translate("A simple security tunnel written in Golang.")

mp:section(SimpleSection).template = "gost/gost_status"

s = mp:section(TypedSection, "gost")
s.anonymous=true
s.addremove=false

enable = s:option(Flag, "enable", translate("Enable"))
enable.default = 0
enable.rmempty = false

server = s:option(Value, "server", translate("server"))
server.rmempty = false

port = s:option(Value, "port", translate("port"))
port.rmempty = false

command = s:option(Value, "command", translate("command"))
command.rmempty = false

shunt = s:option(ListValue, "shunt", translate("Shunt"))
shunt:value("1",translate("Global"))
shunt:value("2",translate("Smart"))
shunt.rmempty = false

model=s:option(ListValue,"model",translate("model"))
model:value("1",translate("proxy"))
model:value("2",translate("local"))
model.rmempty = false

accelerate=s:option(ListValue,"accelerate",translate("accelerate"))
accelerate:value("1",translate("classic"))
accelerate:value("2",translate("radical"))
accelerate.rmempty = false

return mp
