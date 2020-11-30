module("luci.controller.wireguard", package.seeall)
uci = require 'luci.model.uci'.cursor()
require('luci.model.uci')

function index()
	entry({"admin", "services", "wireguard"}, firstchild(), _("wireguard")).dependent = false
	--entry({"admin", "services", "wireguard", "config"}, cbi("wireguard"), _("Config"), 2)
	--entry({"admin", "services", "wireguard", "control"}, template("control"), _("Control"), 1)
	entry({"admin", "services", "wireguard", "control"}, template("control"))
	entry({"admin", "services", "wireguard", "restart"}, call("restart"))
	entry({"admin", "services", "wireguard", "stop"}, call("stop"))
end

function restart()
	if (luci.http.formvalue('cbid.wireguard.model')) then
    	mode = luci.http.formvalue('cbid.wireguard.model')
		fec = luci.http.formvalue('cbid.wireguard.fec')
		enable = luci.http.formvalue('cbid.wireguard.enable')
		uci:set("wireguard", "wg0", "mode",mode)
		uci:set("wireguard", "wg0", "fec",fec)
		uci:set("wireguard", "wg0", "enable",enable)
    	uci:commit("wireguard")
		luci.sys.exec("/etc/init.d/wireguard restart")
		--luci.sys.exec("sleep 5")
	end
	luci.template.render("control")	

end

function stop()                                              
    luci.sys.exec("/etc/init.d/wireguard stop >/dev/null")
	uci:set("wireguard", "wg0", "enable",2)
    	uci:commit("wireguard")                             
	luci.template.render("control")	
end






