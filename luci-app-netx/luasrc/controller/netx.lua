module('luci.controller.netx', package.seeall)

function index()
    if not nixio.fs.access('/etc/config/netx') then
        return
    end

    entry({'admin', 'services', 'netx'}, template('netx/index'), _('Netx service'), 40)
    entry({"admin", "services", "netx", "stop"}, cbi("netx/stop"), _(), 78).dependent = false
    entry({"admin", "services", "log"}, template("netx/log"), _("Netx log"), 77).dependent = false
end

uci = require 'luci.model.uci'.cursor()
require('luci.model.uci')
if (luci.http.formvalue('cbid.service.netx.user')) then
    user = luci.http.formvalue('cbid.service.netx.user')
    password = luci.http.formvalue('cbid.service.netx.password')
    model = luci.http.formvalue('cbid.jiasu.model')
    line = luci.http.formvalue('cbid.jiasu.line')
    switch = luci.http.formvalue('cbid.jiasu.switch')
    uci:set("netx", "server", "user_name", user)
	uci:set("netx", "server", "password", password)
    uci:set("netx", "server", "proxy", model)
	uci:set("netx", "server", "line", line)
	uci:set("netx", "server", "redir_enabled", 1)
	uci:set("netx", "server", "fixed", switch)
    uci:commit("netx")
    luci.util.exec("/usr/bin/netx")
end

