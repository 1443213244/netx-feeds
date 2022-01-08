-- This is a free software, use it under GNU General Public License v3.0.
-- Created By ImmortalWrt
-- https://github.com/immortalwrt

module("luci.controller.acceleration", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/acceleration") then
		return
	end

	local page
	page = entry({"admin", "services", "acceleration"}, cbi("acceleration"), _("Domestic live broadcast acceleration"), 100)
	page.dependent = true
	page.acl_depends = { "luci-app-acceleration" }
	entry({"admin", "services", "acceleration", "status"},call("act_status")).leaf=true
end

function act_status()
	local e={}
	e.running=luci.sys.call("sysctl net.ipv4.tcp_congestion_control|awk -F \'=\' \'{print \$2}\'")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end