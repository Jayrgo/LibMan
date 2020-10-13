floor = math.floor
format = string.format
max = math.max
strfind = string.find
strlen = string.len
strmatch = string.match
strsub = string.sub
---@param delimiter string
---@param subject string
---@param pieces number|nil
function strsplit(delimiter, subject, pieces)
    local result = {}
    for piece in string.gmatch(subject, format("([^%%%s]+)", delimiter)) do result[#result + 1] = piece end
    pieces = pieces or #result
    if #result > pieces then
        local rest = {}
        for i = pieces, #result do rest[#rest + 1] = result[i] end
        result[pieces] = table.concat(rest, delimiter)
        for i = pieces + 1, #result do result[i] = nil end
    end
    return unpack(result)
end
---@param str string
---@param chars string|nil
function strtrim(str, chars)
    chars = chars or "%s\t\r\n"
    return strmatch(str, "^()[ \t\r\n]*$") and "" or strmatch(str, "^[ \t\r\n]*(.*[^ \t\r\n])")
end

---@param tbl table
---@param first number|nil
---@param last number|nil
function unpack(tbl, first, last)
    first = first or 1
    last = last or #tbl
    if first > last then return end
    return tbl[first], unpack(tbl, first + 1, last)
end

