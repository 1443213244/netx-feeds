module('luci.controller.congestion', package.seeall)
function index()
    if not nixio.fs.access('/etc/config/netx') then
        return
    end

    entry({"admin", "services", "congestion"}, template("netx/congestion"), _('congestion'), 70).dependent = false
end

uci = require 'luci.model.uci'.cursor()
require('luci.model.uci')

if (luci.http.formvalue('cbid.jiasu.line') == 'bbr') then
    luci.util.exec("sysctl -w net.ipv4.tcp_congestion_control=bbr")
elseif luci.http.formvalue('cbid.jiasu.line') == 'cubic' then
    luci.util.exec("sysctl -w net.ipv4.tcp_congestion_control=cubic")
else 
    luci.util.exec("hello")
end


