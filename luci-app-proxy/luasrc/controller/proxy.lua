module("luci.controller.proxy", package.seeall)

local uci = luci.model.uci.cursor()
local http = require("luci.http")

function index()
    entry({"admin", "services", "proxy_status"}, template("proxy/proxy_status"), translate("Overseas live broadcast acceleration"), 100)
    entry({"admin", "services", "proxy"}, template("proxy/proxy"))
    entry({"admin", "services", "proxy", "save_proxy"}, call("save_proxy"))
    entry({"admin", "services", "proxy", "delete_proxy"}, call("delete_proxy"))
    entry({"admin", "services", "proxy", "edit_proxy"}, call("edit_proxy"))
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

function find_virtual_interface(ssid)
    local handle = io.popen("iwinfo | grep " .. ssid .. " | awk -F ' ' '{print $1}'")
    local virtualInterface = handle:read("*a")
    handle:close()

    -- Remove newline characters
    virtualInterface = virtualInterface:gsub("\n", "")

    return virtualInterface
end

function create_firewall_zone(zone_name, network, input, output, forward)
    if uci:get("firewall", zone_name) then
        print("Firewall zone '" .. zone_name .. "' already exists.")
        return
    end

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

    uci:commit("firewall")
    uci:save("firewall")

    print("Firewall zone '" .. zone_name .. "' created successfully.")
end

function count_proxies()
    local handle = io.popen("uci show proxy | grep -oE 'proxy\\.[^=]+' | cut -d'.' -f2 | sort -u | wc -l")
    local num_str = handle:read("*a")
    handle:close()

    local num = tonumber(num_str)

    return math.floor(num)
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
    local local_port = luci.http.formvalue("local_port")
    local local_ip = luci.http.formvalue("local_ip")

    if not ssid or not interface or not ip or not port or not username or not password or not protocol then
        luci.http.redirect(luci.dispatcher.build_url("admin", "services", "proxy_status"))
        return
    end

    if not local_port or not local_ip then
        local_port = 1080 + count_proxies()
        local_ip = "192.168." .. (count_proxies() + 2) .. ".1"
    end

    local proxy_section = {
        name = ssid,
        key = key,
        interface = interface,
        ip = ip,
        port = port,
        local_port = local_port,
        local_ip = local_ip,
        username = username,
        password = password,
        protocol = protocol,
    }

    uci:section("proxy", "proxy", ssid, proxy_section)
    uci:commit("proxy")
    uci:save("proxy")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "proxy_status"))

    if interface ~= "lan" then
        local existing_interface = uci:get("network", ssid)
        if existing_interface then
            -- Interface exists, delete it
            uci:delete("network", ssid)
            uci:delete("dhcp", ssid)
            uci:commit("network")  -- Commit changes before deletion
            uci:commit("dhcp")
            uci:save("network")
            uci:save("dhcp")
            os.execute("/etc/init.d/network restart")
        end

        local existing_wireless = uci:get("wireless", ssid)
        if existing_wireless then
            -- Wireless config exists, delete it
            uci:delete("wireless", ssid)
        end

        create_ssid(interface, ssid, key)

        local firewall_config = uci:get("firewall", ssid)
        if firewall_config then
            uci:delete("firewall", ssid)
            uci:delete("firewall", ssid .. "_wan")
            uci:commit("firewall")
            uci:save("firewall")
            create_firewall_zone(ssid, ssid, "ACCEPT", "ACCEPT", "ACCEPT")
        else
            create_firewall_zone(ssid, ssid, "ACCEPT", "ACCEPT", "ACCEPT")
        end

        local device = find_virtual_interface(ssid)
        create_interface(ssid, local_ip, device)
    else
        create_vlan()
    end

    os.execute("/etc/init.d/proxy restart")
end


function delete_proxy()
    local query_string = luci.http.getenv("QUERY_STRING") or ""
    local ssid = string.match(query_string, "ssid=([^&=]+)")

    if not ssid then
        luci.http.redirect(luci.dispatcher.build_url("admin", "services", "proxy_status"))
        return
    end

    -- Delete proxy configuration
    uci:delete("proxy", ssid)
    uci:commit("proxy")
    uci:save("proxy")

    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "proxy_status"))

    local wireless_config = uci:get("wireless", ssid)
    if wireless_config then
        uci:delete("wireless", ssid)
        uci:commit("wireless")
    end

    local firewall_config = uci:get("firewall", ssid)
    if firewall_config then
        uci:delete("firewall", ssid)
        uci:delete("firewall", ssid .. "_wan")
        uci:commit("firewall")
        uci:save("firewall")
    end

    local network_config = uci:get("network", ssid)
    if network_config then
        uci:delete("network", ssid)
        uci:delete("dhcp", ssid)
        uci:commit("network")
        uci:commit("dhcp")
        uci:save("network")
        uci:save("dhcp")
        os.execute("/etc/init.d/network restart")
    end

    os.execute("/etc/init.d/proxy restart")
end

function get_proxy_data(ssid)
    local proxy_data = uci:get_all("proxy", ssid)
    
    if not proxy_data then
        return nil 
    end

    return {
        interface = proxy_data.interface,
        ssid =  uci:get("proxy", ssid, "name"),
        key =  uci:get("proxy", ssid, "key"),
        ip =  uci:get("proxy", ssid, "ip"),
        local_ip = uci:get("proxy", ssid, "local_ip"),
        local_port = uci:get("proxy", ssid, "local_port"),
        port =  uci:get("proxy", ssid, "port"),
        username =  uci:get("proxy", ssid, "username"),
        password =  uci:get("proxy", ssid, "password"),
        protocol = uci:get("proxy", ssid, "protocol")  
    }
end

function edit_proxy()
    local query_string = luci.http.getenv("QUERY_STRING") or ""
    local ssid = string.match(query_string, "ssid=([^&=]+)")

    if not ssid then
        luci.http.redirect(luci.dispatcher.build_url("admin", "services", "proxy_status"))
        return
    end

    -- 获取指定SSID的代理数据
    local proxy_data = get_proxy_data(ssid)

    if not proxy_data then
        luci.http.redirect(luci.dispatcher.build_url("admin", "services", "proxy_status"))
        return
    end

    -- 将数据传递给模板
    luci.template.render("proxy/edit_proxy", { proxy_data = proxy_data })
end