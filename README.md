# LibMan

> LibMan is a library for managing libraries with [Semantic Versioning](https://semver.org/). It is similar to [LibStub](http://www.wowace.com/addons/libstub/).

![GitHub](https://img.shields.io/github/license/Jayrgo/LibMan?style=flat-square)

## Table of Contents

- [API](#API)
- [Classes](#Classes)
  - [Library](#Library)
  - [Version](#Version)
- [Examples](#Examples)
- [License](#License)
- [Acknowledgements](#Acknowledgements)

## API

```Lua
---@param name string
---@param version string
---@vararg any
---@return Library|nil
---@return Version|nil
:New(name, version)
```

* **Parameters:**
  - `name` (*string*) The name of the library.
  - `version` (*string*) The version of the library (X.Y.Z). Can also be prefixed by a "v" (eg: v1.1.6-alpha1).
* **Returns:**
  - [`Library`](#Library) or `nil`: The [table](#Library) to be used by the library or `nil` if the library is already registered with this or a smaller version
  - [`Version`](#Version) or `nil`: The [version](#Version) of the previous library, if available.

```Lua
---@param name string
---@param major number
---@return Library
---@overload fun(name:string):Library
:Get(name, major)
```

* **Parameters:**
  - `name` (*string*) The name of the library.
  - `major` (*number* or *nil*) The major version of the library or nil to get the latest.
* **Returns:**
  - [`Library`](#Library): The [table](#Library) to be used by the library.
> ***Note: Raises an error if no library is available.***

```Lua
---@param name string
---@param major number
---@return boolean
---@return Version|nil
---@overload fun(name:string):boolean,Version|nil
:Exists(name, major)
```

* **Parameters:**
  - `name` (*string*) The name of the library.
  - `major` (*number* or *nil*) The major version of the library or `nil` for the latest.
* **Returns:**
  - `boolean`: `true` if the library exists.
  - [`Version`](#Version) or `nil`: The (highest) [version](#Version) of the library or `nil` if not found.

## Classes

### Library

#### Fields
  - `_NAME` (*string*) The name of the library. (eg: MyLibrary)
  - `_VERSION` (*[Version](#Version)*) The [version](#Version) of the library.

#### Methods

```Lua
---@param func function
---@vararg any
---@return boolean
---@return any
Library.safecall(func, ...)
```

* **Paramaters:**
  - `func` (*function*)

* **Returns:**
  - `boolean`
  - `any`

```Lua
---@param func function
---@vararg any
---@return boolean
---@return any
Library.xsafecall(func, ...)
```

* **Paramaters:**
  - `func` (*function*)

* **Returns:**
  - `boolean`
  - `any`


#### metamethods
  - `__tostring` String representation of a [library](#Library). (eg: MyLibrary-1.0.0)


### Version

#### Fields
  - `major` (*number*) The major version.
  - `minor` (*number*) The minor version.
  - `patch` (*number*) The patch version.
  - `preRelease` (*string* or *nil*) The pre-release metadata.
  - `build` (*string* or *nil*) The build metadata.

#### Methods

```Lua
---@param other Version
---@return boolean
Version:IsEqual(other)
```

* **Paramaters:**
  - `other` (*[Version](#Version)*)

* **Returns:**
  - `boolean`


```Lua
---@param other Version
---@return boolean
Version:IsLessThan(other)
```

* **Paramaters:**
  - `other` (*[Version](#Version)*)

* **Returns:**
  - `boolean`

```Lua
---@param other Version
---@return boolean
Version:IsGreaterThan(other)
```

* **Paramaters:**
  - `other` (*[Version](#Version)*)

* **Returns:**
  - `boolean`

```Lua
---@param other Version
---@return boolean
Version:IsLessThanOrEqual(other)
```

* **Paramaters:**
  - `other` (*[Version](#Version)*)

* **Returns:**
  - `boolean`

```Lua
---@param other Version
---@return boolean
Version:IsGreaterThanOrEqual(other)
```

* **Paramaters:**
  - `other` (*[Version](#Version)*)

* **Returns:**
  - `boolean`

```Lua
---@param other Version
---@return boolean
Version:IsCompatible(other)
```

* **Paramaters:**
  - `other` (*[Version](#Version)*)

* **Returns:**
  - `boolean`

#### metamethods
- `__tostring` String representation of a [version](#Version). (eg: 1.5.0)
- `__eq` Equality between versions.
- `__lt` Less-than between versions.
- `__le` Less-than or equality between versions.
- `__pow` Compatibility between versions.

## Examples

Create a new library.
```Lua
local lib, oldVersion = LibMan:New("MyLibrary", "1.4.2")
if not lib then return end
```

Get the latest library instance.
```Lua
local lib = LibMan:Get("MyLibrary")
```

Check if a library with a certain major version exists and get it.
```Lua
local lib = LibMan:Exists("MyLibrary", 2) and LibMan("MyLibrary", 2)
```

## License

This project is licensed under the MIT License.

## Acknowledgements

- [Semantic Versioning](https://semver.org/)
