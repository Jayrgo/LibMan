local lib = LibMan:Get("Lib")
assert(tostring(lib._VERSION) == "2.0.1-alpha")

local lib = LibMan:Get("Lib", 1)
assert(tostring(lib._VERSION) == "1.1.0")
