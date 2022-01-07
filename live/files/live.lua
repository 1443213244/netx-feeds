#!/usr/bin/lua
require('luci.model.uci')
local http = require('socket.http')
local ltn12 = require("ltn12")
local cjson = require('cjson')
local host = 'http://192.168.1.162:8080'
local uci = luci.model.uci.cursor()

function httpRequest(url,method,request_body,token)
  local response_body = {}
  local res, code, response_headers =
      http.request {
      url = host .. url,
      method = method,
      headers = {
          ['Content-Type'] = 'application/json',
          ['Content-Length'] = #request_body,
          ['X-Access-Token'] = token
      },
      source = ltn12.source.string(request_body),
      sink = ltn12.sink.table(response_body)
  }
  if code == 200 then
      respbody = table.concat(response_body)
      respons = cjson.decode(respbody)
  end
  return respons
end

function getCheckCode()
    url = '/jeecg-boot/sys/getCheckCode'
    respons = httpRequest(url,get,'','')
    checkCode = {respons['result']['code'], respons['result']['key']}
    return checkCode
    
end

function getToken(username, password, checkCode)
   url = '/jeecg-boot/sys/login'
   request_body = cjson.encode({username="esong1",password="Esong123*",captcha=checkCode[1],checkKey=checkCode[2]})
   respons = httpRequest(url,'POST', request_body,'')
   return respons['result']['token']
  
end

function getServers(user,token)
  url = '/jeecg-boot/gost/server/list?username='..user
  respbody = "username=esong1"
  respons = httpRequest(url,"GET",'',token)
  servers = {Servers = respons["result"]["records"]}
  content = cjson.encode(servers)
  file = io.open('/etc/live/lastserver.json', 'w')
  file:write(content)
  file:close()
end

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
    print(port)
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
        node = lastServers['Servers'][k].ip .. ':' .. lastServers['Servers'][k].port
        if isInServer(localnodes, node) ~= true then
            table.insert(lastsnodes, k)
        end
    end
    return lastsnodes
end

function addServer(lastservers, lastnodes, port, localServers)
    port = port
    for k, v in ipairs(lastnodes) do
        print(lastservers['Servers'][k].expire)
        node = {
            Scosk5 = port + 1,
            Relay = port + 2,
            Ip = lastservers['Servers'][k].ip,
            Port = lastservers['Servers'][k].port,
            Protocol = lastservers['Servers'][k].protocol,
            Param = lastservers['Servers'][k].param,
            Expire = lastservers['Servers'][k].expire
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
            ChainNodes = {servers['Servers'][k].Protocol..":\/\/"..servers['Servers'][k].Ip..":"..servers['Servers'][k].Port.."?"..servers['Servers'][k].Param}
        }
        table.insert(config['Routes'],node)
    end
    content = cjson.encode(config)
    file = io.open('/etc/live/config.json', 'w')
    file:write(content)
    file:close()
end

function main()
    username = uci:get("live","@live[0]", "user")
    password = uci:get("live","@live[0]", "password")
    checkCode = getCheckCode()
    token = getToken(username,password,checkCode)
    getServers(username,token)
    localServers = getServer('/etc/live/server.json')
    lastServers = getServer('/etc/live/lastserver.json')
    port = getPort(localServers)
    lastnodes = getLastList(localServers, lastServers)
    addServer(lastServers, lastnodes, port, localServers)
    GostConf(localServers)
end

main()
