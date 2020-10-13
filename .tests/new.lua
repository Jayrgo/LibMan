local lib, oldVersion = LibMan:New("Lib", "1.0.0")
assert(lib)
assert(not oldVersion)

local newLib, oldVersion = LibMan:New("Lib", "1.0.0")
assert(not newLib)

local newLib, oldVersion = LibMan:New("Lib", "1.1.0")
assert(newLib)
assert(oldVersion and tostring(oldVersion) == "1.0.0")
assert(rawequal(lib, newLib))

local newLib, oldVersion = LibMan:New("Lib", "1.0.1")
assert(not newLib)
assert(not oldVersion)

local newMajorLib, oldVersion = LibMan:New("Lib", "2.0.0")
assert(not rawequal(newLib, newMajorLib))
assert(oldVersion == nil)

local newMajorLib, oldVersion = LibMan:New("Lib", "2.0.1-alpha")
assert(oldVersion)
