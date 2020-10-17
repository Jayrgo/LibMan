local _NAME = "LibMan"
local _VERSION = "1.1.0"
local _LICENSE = [[
    MIT License

    Copyright (c) 2020 Jayrgo

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all
    copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE.
]]

local strsub = strsub

---@param str string
---@param start string
---@return boolean
local function startsWith(str, start) return strsub(str, 1, 1) == start end

local assert = assert
local floor = floor
local format = format
local strlen = strlen

---@param number string
---@param name string
---@return number
local function checkNumber(number, name)
    if strlen(number) > 1 and tonumber(number) then
        assert(not startsWith(number, "0"), "Numeric identifiers MUST NOT include leading zeroes")
    end
    number = tonumber(number)
    assert(number, format("'%s' must be a number", name))
    assert(number >= 0, format("'%s' must be a valid positive number", name))
    assert(floor(number) == number, format("'%s' must be an integer", name))
    return number
end

---@class Version
---@field major number
---@field minor number
---@field patch number
---@field preRelease string|nil
---@field build string|nil
local Version = {_TYPE = "Version"}
do
    local strfind = strfind
    local strsplit = strsplit
    local type = type

    ---@param preRelease string
    local function checkPreRelease(preRelease)
        assert(type(preRelease) == "string", "'pre-release' must be a string")
        assert(not startsWith(preRelease, "."), "Pre-release: Identifiers MUST NOT be empty")
        assert(not strfind(preRelease, "..", 1, true), "Pre-release: Identifiers MUST NOT be empty")

        local identifiers = {strsplit(".", preRelease)}
        for i = 1, #identifiers do
            local identifier = identifiers[i]
            assert(identifier ~= "", "Pre-release: Identifiers MUST NOT be empty")

            if tonumber(identifier) then checkNumber(identifier, "pre-release identifier") end
        end
    end

    ---@param build string
    local function checkBuild(build)
        assert(type(build) == "string", "'build' must be a string")
        assert(not startsWith(build, "."), "Build metadata: Identifiers MUST NOT be empty")
        assert(not strfind(build, "..", 1, true), "Build metadata: Identifiers MUST NOT be empty")

        local identifiers = {strsplit(".", build)}
        for i = 1, #identifiers do
            local identifier = identifiers[i]
            assert(identifier ~= "", "Build metadata: Identifiers MUST NOT be empty")

            if tonumber(identifier) then checkNumber(identifier, "build identifier") end
        end
    end

    local strmatch = strmatch

    ---@param version string
    ---@return string
    ---@return string
    ---@return string
    ---@return string
    ---@return string
    local function parseVersion(version)
        local major, minor, patch, preRelease, build = strmatch(version,
                                                                "^v?(%d*)%.(%d*)%.(%d*)%-?([%w%-%.]*)%+?([%w%-%.]*)$")

        return major, minor, patch, preRelease, build
    end

    ---@param a any
    ---@param b any
    ---@return number
    local function compare(a, b) return a == b and 0 or a < b and -1 or 1 end

    ---@param a any
    ---@param b any
    ---@return number
    local function compareIdentifier(a, b)
        local aNumber = tonumber(a)
        local bNumber = tonumber(b)

        if aNumber and bNumber then
            return compare(aNumber, bNumber)
        elseif aNumber then
            return -1
        elseif bNumber then
            return 1
        else
            return compare(a, b)
        end
    end

    ---@param self string
    ---@param other string
    ---@return boolean
    local function isSmallerPreRelease(self, other)
        local selfIdentifiers = {strsplit(".", self)}
        local otherIdentifiers = {strsplit(".", other)}

        local selfIdentifiersLength = #selfIdentifiers
        local otherIdentifiersLength = #otherIdentifiers

        for i = 1, selfIdentifiersLength <= otherIdentifiersLength and selfIdentifiersLength or otherIdentifiersLength do
            local comparison = compareIdentifier(selfIdentifiers[i], otherIdentifiers[i])
            if comparison ~= 0 then return comparison == -1 and true end
        end
        return #selfIdentifiers < #otherIdentifiers
    end

    ---@param self Version
    ---@param other Version
    ---@return boolean
    local function isEqual(self, other)
        return
            self.major == other.major and self.minor == other.minor and self.patch == other.patch and self.preRelease ==
                other.preRelease
    end

    ---@param self Version
    ---@param other Version
    ---@return boolean
    local function isLessThan(self, other)
        if self.major ~= other.major then return self.major < other.major end
        if self.minor ~= other.minor then return self.minor < other.minor end
        if self.patch ~= other.patch then return self.patch < other.patch end
        if self.preRelease and other.preRelease then
            return isSmallerPreRelease(self.preRelease, other.preRelease)
        elseif self.preRelease then
            return true
        end
    end

    ---@param self Version
    ---@param other Version
    ---@return boolean
    local function isLessThanOrEqual(self, other) return isLessThan(self, other) or isEqual(self, other) end

    local Version_MT = {
        __index = Version,
        ---@param self Version
        ---@return string
        __tostring = function(self)
            local str = format("%d.%d.%d", self.major, self.minor, self.patch)
            if self.preRelease then str = format("%s-%s", str, self.preRelease) end
            if self.build then str = format("%s+%s", str, self.build) end
            return str
        end,
        __eq = isEqual,
        __lt = isLessThan,
        __le = isLessThanOrEqual,
        ---@param other Version
        ---@return boolean
        __pow = function(self, other)
            if self.major == 0 then return self == other end
            return self.major == other.major
        end,
    }

    local setmetatable = setmetatable

    ---@param major number|string
    ---@param minor number|nil
    ---@param patch number|nil
    ---@param preRelease string|nil
    ---@param build string|nil
    ---@return Version
    function Version:New(major, minor, patch, preRelease, build)
        assert(self == Version, "Attempt to run factory method on class member")

        assert(major, "At least one parameter is required")

        if type(major) == "string" then
            major, minor, patch, preRelease, build = parseVersion(major)
        else
            minor = minor or 0
            patch = patch or 0
        end

        major = checkNumber(major, "major")
        minor = checkNumber(minor, "minor")
        patch = checkNumber(patch, "patch")
        if preRelease and strlen(preRelease) > 0 then checkPreRelease(preRelease) end
        if build and strlen(build) > 0 then checkBuild(build) end

        return setmetatable({
            major = major,
            minor = minor,
            patch = patch,
            preRelease = preRelease and strlen(preRelease) > 0 and preRelease,
            build = build and strlen(build) > 0 and build,
        }, Version_MT)
    end

    ---@param other Version
    ---@return boolean
    function Version:IsEqual(other)
        assert(self._TYPE == other._TYPE)
        return isEqual(self, other)
    end

    ---@param other Version
    ---@return boolean
    function Version:IsLessThan(other)
        assert(self._TYPE == other._TYPE)
        return isLessThan(self, other)
    end

    ---@param other Version
    ---@return boolean
    function Version:IsGreaterThan(other)
        assert(self._TYPE == other._TYPE)
        return isLessThan(other, self)
    end

    ---@param other Version
    ---@return boolean
    function Version:IsLessThanOrEqual(other)
        assert(self._TYPE == other._TYPE)
        return isLessThanOrEqual(self, other)
    end

    ---@param other Version
    ---@return boolean
    function Version:IsGreaterThanOrEqual(other)
        assert(self._TYPE == other._TYPE)
        return isLessThanOrEqual(other, self)
    end

    ---@param other Version
    ---@return boolean
    function Version:IsCompatible(other)
        if self.major == 0 then return self:IsEqual(other) end
        return self.major == other.major and self.minor <= other.minor
    end
end

_VERSION = Version:New(_VERSION)
local _GLOBALNAME = _NAME .. _VERSION.major

---@class LibMan
---@field libs table<string, table<number, Library>>
local LibMan = _G[_GLOBALNAME]

if not LibMan or _VERSION:IsGreaterThan(LibMan._VERSION) then
    ---@class Library
    ---@field _VERSION Version
    ---@field _NAME string
    local Library = {_TYPE = "Library"}
    do
        local Library_MT = {
            __index = Library,
            ---@param self Library
            ---@return string
            __tostring = function(self) return format("%s-%s", self._NAME, tostring(self._VERSION)) end,
        }

        local select = select

        ---@param library Library|nil
        ---@param name string
        ---@param version Version
        ---@vararg string
        ---@return Library
        function Library:New(library, name, version, ...)
            assert(self == Library, "Attempt to run factory method on class member")
            assert(type(library) == "table" or type(library) == "nil", "Library must be a table or nil")

            library = library or {}
            library._VERSION = version
            library._NAME = name

            for i = 1, select("#", ...), 2 do library[select(i, ...)] = select(i + 1, ...) end

            return setmetatable(library, Library_MT)
        end

        local pcall = pcall

        ---@param func function
        ---@vararg any
        ---@return boolean
        ---@return any
        function Library.safecall(func, ...) return pcall(func, ...) end

        local geterrorhandler = geterrorhandler
        ---@param err string
        ---@return function
        local function errorhandler(err) return geterrorhandler()(err) end

        local xpcall = xpcall

        ---@param func function
        ---@vararg any
        ---@return boolean
        ---@return any
        function Library.xsafecall(func, ...) return xpcall(func, errorhandler, ...) end
    end

    LibMan = _G[_GLOBALNAME] or {libs = {}}
    LibMan._NAME = _NAME
    LibMan._VERSION = _VERSION
    LibMan._LICENSE = _LICENSE
    setmetatable(LibMan, {
        ---@param self LibMan
        ---@return string
        __tostring = function(self) return format("%s-%s", self._NAME, tostring(self._VERSION)) end,
    })
    LibMan.Version = Version
    -- luacheck: push ignore 122
    _G[_GLOBALNAME] = LibMan
    _G.LibMan = (not _G.LibMan or _VERSION:IsGreaterThan(_G.LibMan._VERSION)) and LibMan or _G.LibMan
    -- luacheck: pop

    local libs = LibMan.libs

    local strtrim = strtrim

    ---@param name string
    ---@return string
    local function checkAndGetName(name)
        assert(type(name) == "string", "Name must be a string")
        name = strtrim(name)
        assert(name ~= "", "Name can't be empty")
        return name
    end

    ---@param major number
    local function checkMajor(major)
        assert(type(major) == "number" or type(major) == "nil", "Major must be a number or nil")
        if type(major) == "number" then checkNumber(major, "major") end
    end

    ---@param name string
    ---@param version string
    ---@vararg any
    ---@return Library|nil
    ---@return Version|nil
    function LibMan:New(name, version, ...)
        name = checkAndGetName(name)
        version = Version:New(version)

        local oldVersion = libs[name] and libs[name][version.major] and libs[name][version.major]._VERSION
        if oldVersion and oldVersion:IsGreaterThanOrEqual(version) then return nil, nil end

        libs[name] = libs[name] or {}
        libs[name][version.major] = Library:New(libs[name][version.major], name, version, ...)

        return libs[name][version.major], oldVersion
    end

    local max = max
    local pairs = pairs

    ---@param name string
    ---@param major number
    ---@return Library
    ---@overload fun(name:string):Library
    function LibMan:Get(name, major)
        name = checkAndGetName(name)
        checkMajor(major)

        ---@type Library
        local lib
        if libs[name] then
            if major then
                ---@type Library
                lib = libs[name][major]
            else
                local maxMajor = 0
                for k, v in pairs(libs[name]) do maxMajor = max(k, maxMajor) end
                ---@type Library
                lib = libs[name][maxMajor]
            end
        end
        assert(lib, format("Library '%s' not found.", name))
        return lib
    end

    ---@param name string
    ---@param major number
    ---@return boolean
    ---@return Version|nil
    ---@overload fun(name:string):boolean,Version|nil
    function LibMan:Exists(name, major)
        name = checkAndGetName(name)
        checkMajor(major)

        ---@type Library
        local lib
        if libs[name] then
            if major then
                ---@type Library
                lib = libs[name][major]
            else
                local maxMajor = 0
                for k, v in pairs(libs[name]) do maxMajor = max(k, maxMajor) end
                ---@type Library
                lib = libs[name][maxMajor]
            end
        end
        if lib then
            return true, lib._VERSION
        else
            return false
        end
    end
end
