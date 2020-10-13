debugstack = debug.traceback

loadfile("wowapi.lua")()

loadfile("../LibMan.lua")()

loadfile("version.lua")()

loadfile("new.lua")()
loadfile("exists.lua")()
loadfile("get.lua")()

print("All tests passed!")
