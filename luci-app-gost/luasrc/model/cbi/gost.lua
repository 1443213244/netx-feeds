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

protocol = s:option(Value, "protocol", translate("protocol"))
protocol:value("relay+socks5",translate("relay+socks5"))
protocol:value("relay+mtls",translate("relay+mtls"))
protocol:value("socks5",translate("socks5"))
protocol:value("relay",translate("relay"))
protocol.rmempty = false

server = s:option(Value, "server", translate("server"))
server.rmempty = false

port = s:option(Value, "port", translate("port"))
port.rmempty = false

shunt = s:option(ListValue, "shunt", translate("Shunt"))
shunt:value("1",translate("Global"))
shunt:value("2",translate("Smart"))
shunt.rmempty = false


return mp

