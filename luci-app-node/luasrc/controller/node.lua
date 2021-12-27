-- This is a free software, use it under GNU General Public License v3.0.
-- Created By ImmortalWrt
-- https://github.com/immortalwrt

module("luci.controller.node", package.seeall)
require('luci.model.uci')
local uci = luci.model.uci.cursor()

function index()
	if not nixio.fs.access("/etc/config/node") then
		return
	end

	local page
	page = entry({"admin", "services", "node"}, template("node/node"), _("Node"), 100)
	page.dependent = true
	page.acl_depends = { "luci-app-node" }
	entry({"admin", "services", "node", "start"},call("start_server")).leaf=true
	entry({"admin", "services", "node", "stop"},call("start_server")).leaf=true
end


local user = luci.http.formvalue("user")
local password = luci.http.formvalue("password")
if (use ~= null and password ~= null)then
	uci:set("node","@node[0]", "user", user)
	uci:set("node","@node[0]", "password", password)
	uci:commit('node')
end
	-- local e={}
	-- e.running=luci.sys.call("pgrep gost >/dev/null")==0
	-- luci.http.prepare_content("application/json")
	-- luci.http.write_json(e)
-- luci.http.write('user')

function start_server()
	local user = luci.http.formvalue("id")
	file = io.open("/root/hello", "a")

	-- 在文件最后一行添加 Lua 注释
	file:write(id)

	-- 关闭打开的文件
	file:close()
	luci.http.redirect(luci.dispatcher.build_url("admin/services/node"))
end

function stop_server()
	luci.http.redirect(luci.dispatcher.build_url("admin/services/node"))
end

-- local apply = luci.http.formvalue("cbi.apply")
-- if apply then
--         luci.sys.exec("/etc/init.d/gost restart")
-- end   