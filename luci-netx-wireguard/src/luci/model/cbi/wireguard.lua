require("luci.sys")

m = Map("wireguard", translate("wireguard"), translate("wireguard and udpspeeder"))

s = m:section(TypedSection, "wireguard", "")
s.addremove = false
s.anonymous = true

server = s:option(Value, "privatekey", translate("UDPServer"), translate("UDPServerDesc"))
serverport = s:option(Value, "publickey", translate("ServerPort"), translate("ServerPortDesc"))
client = s:option(Value, "server", translate("UDPClient"), translate("UDPClientDesc"))
clientport = s:option(Value, "server_port", translate("ClientPort"), translate("ClientPortDesc"))
password = s:option(Value, "address", translate("Password"), translate("PasswordDesc"))
fec = s:option(Value, "mode", translate("Fec"), translate("FecDesc"))
timeout = s:option(Value, "enabled", translate("Timeout"), translate("TimeoutDesc"))

return m

