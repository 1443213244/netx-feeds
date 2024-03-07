#!/usr/bin/lua

local function sleep(seconds)
    os.execute("sleep " .. tonumber(seconds))
end

local function reboot()
    os.execute("reboot")
end

-- sleep(30)

local ifconfig = io.popen("/sbin/ifconfig rax0")
local mac_address = ifconfig:read("*all"):match("([0-9a-fA-F]+:[0-9a-fA-F]+:[0-9a-fA-F]+:[0-9a-fA-F]+:[0-9a-fA-F]+:[0-9a-fA-F]+)")
ifconfig:close()

local url = "http://ck.cloud2345.com/jeecgboot/depository/busRuter/mac?mac=" .. mac_address

local http_response = io.popen("curl -m 10 -s '" .. url .. "'"):read("*all")

local success, message, code, result = http_response:match('"success":(.-),"message":(.-),"code":(.-),"result":(.-),"timestamp":.-}')

if success == "true" then
    if result == "null" then
        reboot()
    end
end
