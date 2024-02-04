module("luci.controller.proxy", package.seeall)

local uci = luci.model.uci.cursor()
local http = require("luci.http")

function index()
    local page = entry({"admin", "services", "proxy"}, template("proxy/proxy"), _("Overseas live broadcast acceleration"), 100)
    page.dependent = true

    entry({"admin", "services", "proxy", "save_proxy"}, call("save_proxy")).leaf = true
end

function create_interface(name, ip, device)
    local network_section = {
        device = device,
        proto = "static",
        ipaddr = ip,
        netmask = "255.255.255.0",
    }

    uci:section("network", "interface", name, network_section)
    uci:section("dhcp", "dhcp", name, {
        start = '100',
        limit = '150',
        leasetime = '12h',
        force = '1',
        dhcpv4 = 'server',
        ra_flags = 'managed-config',
        ra_flags = 'other-config',
        ra = 'hybrid',
        ndp = 'hybrid',
        dhcpv6 = 'hybrid',
        ra_management = '1',
        interface = name,
    })

    uci:commit("network")
    uci:commit("dhcp")
end

function create_ssid(interface, ssid, key)
    local device

    if interface == "2.4G" then
        device = "MT7981_1_1"
    elseif interface == "5G" then
        device = "MT7981_1_2"
    else
        print("Unknown interface:", interface)
        return
    end

    local wifi_section = {
        device = device,
        network = ssid,
        mode = "ap",
        ssid = ssid,
        encryption = "psk2",
        key = key,
    }

    uci:section("wireless", "wifi-iface", ssid, wifi_section)
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

    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "proxy"))

    if interface ~= "lan" then
        luci.http.redirect(luci.dispatcher.build_url("admin", "services", "proxy"))
        create_ssid(interface, ssid, key)
        create_firewall_zone(ssid, ssid, "ACCEPT", "ACCEPT", "ACCEPT")
        os.execute("sleep 3")
        local device = find_virtual_interface(ssid)
        create_interface(ssid, "192.168." .. count_proxys()+2 .. ".1", device)
    else
        create_vlan()
    end

    -- -- Generate a unique name (you can use a better logic to generate it)
    -- local unique_name = os.time()

    -- -- Save the proxy configuration to UCI
    local proxy_section = {
        name = ssid,
        interface = interface,
        ip = ip,
        port = port,
        local_port = 1080 + count_proxys,
        local_ip = "192.168." .. count_proxys()+2 .. ".1",
        username = username,
        password = password,
        protocol = protocol,
    }

    uci:section("proxy", "proxy", unique_name, proxy_section)
    uci:commit("proxy")
    uci:save("proxy")
    os.execute("/etc/init.d/proxy restart")

end

function find_virtual_interface(ssid)
    local handle = io.popen("iwinfo | grep " .. ssid .. " | awk -F ' ' '{print $1}'")
    local virtualInterface = handle:read("*a")
    handle:close()

    -- Remove newline characters
    virtualInterface = virtualInterface:gsub("\n", "")

    return virtualInterface
end

function create_firewall_zone(zone_name, network, input, output, forward)
    -- Check if the zone already exists, if it does, return
    if uci:get("firewall", zone_name) then
        print("Firewall zone '" .. zone_name .. "' already exists.")
        return
    end

    -- Create the firewall zone
    uci:section("firewall", "zone", zone_name, {
        name = zone_name,
        network = network,
        input = input,
        output = output,
        forward = forward,
    })

    uci:section("firewall", "forwarding", zone_name .. "_wan", {
        src = zone_name,
        dest = "wan",
    })

    -- Commit and save the changes
    uci:commit("firewall")
    uci:save("firewall")

    print("Firewall zone '" .. zone_name .. "' created successfully.")
end

function count_proxys()
    local handle = io.popen("uci show proxy | grep -oE '^proxy\\.@proxy\\[[0-9]+\\]' | sort -u | wc -l")
    local num_str = handle:read("*a")
    handle:close()

    local num = tonumber(num_str)

    return math.floor(num)
end


