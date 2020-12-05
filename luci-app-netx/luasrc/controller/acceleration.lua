module('luci.controller.acceleration', package.seeall)
function index()
    if not nixio.fs.access('/etc/config/netx') then
        return
    end

    entry({"admin", "services", "acceleration"}, template("netx/acceleration"), _('acceleration'), 69).dependent = false
end

local x = require("luci.model.uci").cursor()
require('luci.model.uci')

if (luci.http.formvalue('cbid.acceleration.enable') == '1') then
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
	luci.sys.call('/etc/init.d/shadowsocks-libev stop&&/etc/init.d/dnsmasq restart&&killall -9 netx&&killall -9 white')
	local date=os.date("%Y-%m-%d %H:%M:%S")
	local  f = io.open('/var/log/netx','a')
	f:write(date.." stop service")
	f:close()
	luci.util.exec("/etc/init.d/sockd start")
    luci.util.exec("/etc/init.d/redsocks start")
elseif luci.http.formvalue('cbid.acceleration.enable') == '0' then
    luci.util.exec("/etc/init.d/redsocks stop")
	luci.util.exec("/etc/init.d/sockd stop")
else 
    luci.util.exec("hello")
end


