local exists, version = LibMan:Exists("Lib")
assert(exists)
assert(tostring(version) == "2.0.1-alpha")

local exists, version = LibMan:Exists("Lib", 1)
assert(exists)
assert(tostring(version) == "1.1.0")

local exists, version = LibMan:Exists("Lib", 2)
assert(exists)
assert(tostring(version) == "2.0.1-alpha")
