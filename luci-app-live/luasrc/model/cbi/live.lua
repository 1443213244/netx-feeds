-- Created By ImmortalWrt
-- https://github.com/immortalwrt
local uci = luci.model.uci.cursor()
local util = require "luci.util"

local status = luci.util.ubus("system", "info") or { }

mp = Map("live", translate("Live"))
--mp.description = translate("A simple security tunnel written in Golang.")

--mp:section(SimpleSection).template = "node/node_status"

s = mp:section(TypedSection, "live")
s.anonymous=true
s.addremove=false

user = s:option(Value, "user", translate("User"))
user.rmempty = false

password = s:option(Value, "password", translate("Password"))
password.rmempty = false

button = s:option(Button, "button", translate("                 "))             

button.inputtitle = translate("hello")      
button.inputstyle = "apply"                                                     

function button.write(self, section, value)
        uci:commit('live')                                     
        luci.sys.call("echo hello > /dev/console ")                             
end 


-- nodes = s:option(DynamicList,"nodes", translate("nodes"))

local nodes1 = uci:get('live', '@live[0]', 'nodes')
if nodes1 == nil then
        hello= s:option(DummyValue,"null",translate("null"))
else
        for i, v in ipairs(nodes1) do
                v= s:option(DummyValue,v,translate(v))
             end

end





return mp,pm1
