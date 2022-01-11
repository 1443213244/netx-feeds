-- Created By ImmortalWrt
-- https://github.com/immortalwrt
local sy = require "luci.sys"

mp = Map("sooo", translate("Global acceleration"))
mp.description = translate("Accelerate global network connectivity and help enterprises develop efficiently.")

mp:section(SimpleSection).template = "sooo/sooo_status"

s = mp:section(TypedSection, "sooo")
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

domains = s:option(DynamicList, "domain", translate("domain"))
domains:depends("shunt","2")
domains.rows = 10
domains.width = 30


function mp.on_commit(self)
    sy.call("/etc/init.d/sooo restart >/dev/null 2>&1")
end

return mp