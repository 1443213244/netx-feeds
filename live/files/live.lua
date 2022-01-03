#!/usr/bin/lua
local cjson = require('cjson')

function getServer(path)
    file = io.open(path, 'r')
    local text = file:read('*a')
    file:close()
    local servers = cjson.decode(text)
    return servers
end

function getPort(localServers)
    local port = 5000
    local index = table.getn(localServers['Servers'])
    if (index ~= 0) then
        port = localServers['Servers'][index].Relay
    end
    return port
end

function isInServer(t, val)
    for k, v in ipairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

function getLastList(localServers, lastServers)
    local localnodes = {}
    local lastsnodes = {}
    for k, v in ipairs(localServers['Servers']) do
        node = localServers['Servers'][k].Ip .. ':' .. localServers['Servers'][k].Port
        table.insert(localnodes, node)
    end

    for k, v in ipairs(lastServers['Servers']) do
        node = lastServers['Servers'][k].Ip .. ':' .. lastServers['Servers'][k].Port
        if isInServer(localnodes, node) ~= true then
            table.insert(lastsnodes, k)
        end
    end
    return lastsnodes
end

function addServer(lastservers, lastnodes, port, localServers)
    port = port
    for k, v in ipairs(lastnodes) do
        print(lastservers['Servers'][k].EndDate)
        node = {
            Scosk5 = port + 1,
            Relay = port + 2,
            Ip = lastservers['Servers'][k].Ip,
            Port = lastservers['Servers'][k].Port,
            Protocol = lastservers['Servers'][k].Protocol,
            EndDate = lastservers['Servers'][k].EndDate
        }
        table.insert(localServers['Servers'], node)
        port = port + 2
    end
    text = cjson.encode(localServers)
    file = io.open('/etc/live/server.json', 'w')
    file:write(text)
    file:close()
end

function GostConf(servers)
    config = {Debug=true,Retries=0,Routes = {}}
    
    for k,v in ipairs(servers['Servers']) do
        node = {
            Retries = 1,
            ServeNodes = {':'..servers['Servers'][k].Scosk5,"relay:\/\/:"..servers['Servers'][k].Relay},
            ChainNodes = {servers['Servers'][k].Protocol..":\/\/"..servers['Servers'][k].Ip..":"..servers['Servers'][k].Port}
        }
        table.insert(config['Routes'],node)
    end
    content = cjson.encode(config)
    file = io.open('/etc/live/config.json', 'w')
    file:write(content)
    file:close()
end

function main()
    localServers = getServer('/etc/live/server.json')
    lastServers = getServer('/etc/live/lastserver.json')
    port = getPort(localServers)
    lastnodes = getLastList(localServers, lastServers)
    addServer(lastServers, lastnodes, port, localServers)
    GostConf(localServers)
end

main()
