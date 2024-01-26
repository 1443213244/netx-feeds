module("luci.controller.proxy", package.seeall)

local uci = luci.model.uci.cursor()
local http = require("luci.http")

function index()
    -- if not nixio.fs.access("/etc/config/live") then
    --     return
    -- end

    local page = entry({"admin", "services", "proxy"}, template("proxy/proxy"), _("Overseas live broadcast acceleration"), 100)
    page.dependent = true

    entry({"admin", "services", "proxy", "save_proxy"}, call("save_proxy")).leaf = true
end

function create_interface(name, ip, device)
    uci:section("network", "interface", name, {
        device = device,
        proto = "static",
        ipaddr = ip,
        netmask = "255.255.255.0",
    })

    uci:section("dhcp", name, {
        interface = name,
        start = 100,
        limit = 150,
        leasetime = "12h",
        dhcpv4 = "server",
        dhcpv6 = "server",
        ra = "server",
        ra_slaac = "1",
        ra_flags = "managed-config",
        ra_flags = "other-config",

    })

    uci:commit("network")
    uci:commit("dhcp")
end

function create_ssid(interface, ssid, key)
    local device
    if interface == "2.4G" then
        device = "radio0"
    elseif interface == "5G" then
        device = "radio1"
    else
        print("Unknown interface:", interface)
        return
    end

    uci:section("wireless", "wifi-iface", ssid, {
        device = device,
        network = ssid,
        mode = "ap",
        ssid = ssid,
        encryption = "psk2",
        key = key
    })

    uci:commit("wireless")
    print("SSID configuration for " .. interface .. " written successfully.")
end

function create_vlan()
    local file, err = io.open('/ssid', "w")
    if file then
        file:write("lan")
        file:close()
    else
        print("Error opening file:", err)
    end
end

function save_proxy()
    local ssid = luci.http.formvalue("ssid")
    local key = luci.http.formvalue("key")
    local interface = luci.http.formvalue("interface")
    local ip = luci.http.formvalue("ip")
    local port = luci.http.formvalue("port")
    local username = luci.http.formvalue("username")
    local password = luci.http.formvalue("password")
    local protocol = luci.http.formvalue("protocol")

    -- Validate the required fields
    if not ssid or not interface or not ip or not port or not username or not password or not protocol then
        luci.http.redirect(luci.dispatcher.build_url("admin", "services", "proxy"))
        return
    end

    if interface ~= "lan" then
        create_ssid(interface, ssid, key)
        create_firewall_zone(ssid, ssid, "ACCEPT", "ACCEPT", "ACCEPT")
        os.execute("sleep 3")
        local device = find_virtual_interface(ssid)
        create_interface(ssid, "192.168.2.1", device)
    else
        create_vlan()
    end

    -- Generate a unique name (you can use a better logic to generate it)
    local unique_name = os.time()

    -- Save the proxy configuration to UCI
        uci:section("proxy", "proxy", unique_name, {
            name = ssid,
            interface = interface,
            ip = ip,
            port = port,
            username = username,
            password = password,
            protocol = protocol
        })

        uci:commit("proxy")
        uci:save("proxy")


    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "proxy"))
end


function find_virtual_interface(ssid)
    local handle = io.popen("iwinfo | grep " .. ssid .. " | awk -F ' ' '{print $1}'")
    local virtualInterface = handle:read("*a")
    handle:close()

    -- 去除换行符
    virtualInterface = virtualInterface:gsub("\n", "")
    
    return virtualInterface
end

function create_firewall_zone(zone_name, network, input, output, forward)
    -- 检查区域是否已存在，如果存在则返回
    if uci:get("firewall", zone_name) then
        print("Firewall zone '" .. zone_name .. "' already exists.")
        return
    end

    -- 创建防火墙区域
    uci:section("firewall", "zone", zone_name, {
        name = zone_name,
        network = network,
        input = input,
        output = output,
        forward = forward
    })

    uci:section("firewall","forwarding",zone_name.."_wan",{
        src = zone_name,
        dest = "wan"
    })

    -- 提交和保存更改
    uci:commit("firewall")
    uci:save("firewall")

    print("Firewall zone '" .. zone_name .. "' created successfully.")
end


