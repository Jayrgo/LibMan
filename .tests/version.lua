assert(LibMan)
assert(LibMan._VERSION)

local oldMinor = LibMan._VERSION.minor

LibMan._VERSION.minor = oldMinor - 1
assert(type(LibMan.New) == "function")
LibMan.New = "string"
assert(type(LibMan.New) == "string")
loadfile("../LibMan.lua")()
assert(type(LibMan.New) == "function")

LibMan._VERSION.minor = oldMinor + 1
assert(type(LibMan.New) == "function")
LibMan.New = "string"
assert(type(LibMan.New) == "string")
loadfile("../LibMan.lua")()
assert(type(LibMan.New) == "string")

LibMan._VERSION.minor = oldMinor - 1
loadfile("../LibMan.lua")()
