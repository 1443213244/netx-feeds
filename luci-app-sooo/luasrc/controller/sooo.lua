-- This is a free software, use it under GNU General Public License v3.0.
-- Created By ImmortalWrt
-- https://github.com/immortalwrt

module("luci.controller.sooo", package.seeall)
local uci = luci.model.uci.cursor()

function index()
	if not nixio.fs.access("/etc/config/sooo") then
		return
	end

	local page
	page = entry({"admin", "services", "sooo"}, cbi("sooo"), _("Global acceleration"), 100)
	page.dependent = true
	page.acl_depends = { "luci-app-sooo" }
	entry({"admin", "services", "sooo", "status"},call("act_status")).leaf=true
end

function act_status()
	local status = uci:get("sooo","@sooo[0]", "status")
	local e={}
	if status == "0" then
		e.running=false
	else
		e.running=true
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

-- local apply = luci.http.formvalue("cbi.apply")
-- if apply then
--         luci.sys.exec("/etc/init.d/sooo restart")
-- end   
-- luci.sys.exec("/etc/init.d/sooo restart")
