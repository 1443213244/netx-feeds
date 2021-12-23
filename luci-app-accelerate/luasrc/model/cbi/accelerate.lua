-- Created By ImmortalWrt
-- https://github.com/immortalwrt

mp = Map("accelerate", translate("Accelerate"))
mp.description = translate("A simple security tunnel written in Golang.")

mp:section(SimpleSection).template = "accelerate/accelerate_status"

s = mp:section(TypedSection, "accelerate")
s.anonymous=true
s.addremove=false

enable = s:option(Flag, "enable", translate("Enable"))
enable.default = 0
enable.rmempty = false

run_command = s:option(Value, "run_command", translate("Command"))
run_command.rmempty = false

return mp
