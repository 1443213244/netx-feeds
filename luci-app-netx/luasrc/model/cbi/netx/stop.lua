--[[
openwrt-dist-luci: service netx
]]--
local x = require("luci.model.uci").cursor()
local m, s, o, e, a

x:delete("dhcp", "@dnsmasq[0]", "noresolv")
x:delete("dhcp", "@dnsmasq[0]", "server")
x:set("shadowsocks-libev",  "hi", "disabled", 1)
x:set("shadowsocks-libev",  "cfg0249c0", "disabled", 1)
x:set("shadowsocks-libev",  "ss_rules", "disabled", 1)
x:commit("shadowsocks-libev")
x:commit("dhcp")
x:set("netx",  "server", "redir_enabled", 0)
x:set("netx",  "server", "status", 0)
x:commit("netx")

luci.sys.call('sed -i \'/switch/\'d /etc/crontabs/root')
luci.sys.call('/etc/init.d/cron restart&')
luci.sys.call('/etc/init.d/shadowsocks-libev stop&&/etc/init.d/dnsmasq restart && killall -9 white')
local date=os.date("%Y-%m-%d %H:%M:%S")
local  f = io.open('/var/log/netx','a')
f:write(date.." stop service")
f:close()

luci.http.redirect(luci.dispatcher.build_url("admin","services", "netx"))
return m



