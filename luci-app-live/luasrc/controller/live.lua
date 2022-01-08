-- This is a free software, use it under GNU General Public License v3.0.
-- Created By ImmortalWrt
-- https://github.com/immortalwrt

module("luci.controller.live", package.seeall)
require('luci.model.uci')
local uci = luci.model.uci.cursor()
local cjson = require('cjson')

function index()
	if not nixio.fs.access("/etc/config/live") then
		return
	end

	local page
	page = entry({"admin", "services", "live"}, template("live/live"), _("Overseas live broadcast acceleration"), 100)
	page.dependent = true
	page.acl_depends = { "luci-app-live" }
	entry({"admin", "services", "live", "start"},call("start_server")).leaf=true
	entry({"admin", "services", "live", "stop"},call("stop_server")).leaf=true
end


local user = luci.http.formvalue("user")
local password = luci.http.formvalue("password")
if (user ~= nil and password ~= nil)then
	uci:set("live","@live[0]", "user", user)
	uci:set("live","@live[0]", "password", password)
	uci:commit('live')
end
luci.sys.exec("/etc/init.d/live restart")
-- os.execute("/etc/init.d/live restart &");
	-- local e={}
	-- e.running=luci.sys.call("pgrep gost >/dev/null")==0
	-- luci.http.prepare_content("application/json")
	-- luci.http.write_json(e)
-- luci.http.write('user')

function start_server()
	local id = luci.http.formvalue("id")
	file = io.open('/etc/live/server.json','r')
	content = file:read('*a')
	file:close()
	local servers = cjson.decode(content)
    node = server['Server'][id]
	-- cmd = "gost -L :"..node.Socks5.." -L relay://:"..node.Relay.." -F "..node.Protocol.."://"..node.Ip..":"..node.Port.." &"
	-- luci.sys.exec("gost -L :5002 &")
	luci.http.redirect(luci.dispatcher.build_url("admin/services/live"))
end

function stop_server()
	local pid = luci.http.formvalue("pid")
	luci.sys.exec("kill "..pid)
	luci.http.redirect(luci.dispatcher.build_url("admin/services/live"))
end


-- local apply = luci.http.formvalue("cbi.apply")
-- if apply then
--         luci.sys.exec("/etc/init.d/gost restart")
-- end   
