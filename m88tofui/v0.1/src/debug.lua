function printf(fmt, ...)
    print(string.format(tostring(fmt), ...))
end

function echo(fmt,...)
print(string.format(tostring(fmt), ...))
end


function echoError(fmt, ...)
    print("ERR", fmt, ...)
    print(debug.traceback("", 2))
end

function echoInfo(fmt, ...)
    echoLog("INFO", fmt, ...)
end

function echoLog(tag, fmt, ...)
    echo(string.format("[%s] %s", string.upper(tostring(tag)), string.format(tostring(fmt), ...)))
end

function throw(errorType, fmt, ...)
    local arg = {...}
    for k,v in pairs(arg) do
        arg[k] = tostring(v)
    end
    local msg = string.format(tostring(fmt), unpack(arg))
    error(string.format("<<%s>> - %s", tostring(errorType), msg), 2)
end

function dump(object, label, isReturnContents, nesting)
    --if not LUA_DEBUG then return end
    if type(nesting) ~= "number" then nesting = 99 end

    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        v=tostring(v)
        v=string.gsub(v,"%%%%","$")
        --cclog(v)
        return v
    end

    local traceback = string.split(debug.traceback("", 2), "\n")
    echo("dump from: " .. string.trim(traceback[3]))

    local function _dump(object, label, indent, nest, keylen)

        label = label or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(_v(label)))
        end
        if type(object) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(label), spc, _v(object))
        elseif lookupTable[object] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, label, spc)
        else
            lookupTable[object] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, label)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _v(label))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(object) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    if type(v)=="string" then
                      v=string.gsub(v,'%%',"%%%%")
                    end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    _dump(object, label, "- ", 1)

    if isReturnContents then
        --return table.concat(result, "\n")
        return result
    end

    for i, line in ipairs(result) do
        echo(line)
    end
end

function vardump(object, label)
    local lookupTable = {}
    local result = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local function _vardump(object, label, indent, nest)
        label = label or "<var>"
        local postfix = ""
        if nest > 1 then postfix = "," end
        if type(object) ~= "table" then
            if type(label) == "string" then
                result[#result +1] = string.format("%s%s = %s%s", indent, label, _v(object), postfix)
            else
                result[#result +1] = string.format("%s%s%s", indent, _v(object), postfix)
            end
        elseif not lookupTable[object] then
            lookupTable[object] = true

            if type(label) == "string" then
                result[#result +1 ] = string.format("%s%s = {", indent, label)
            else
                result[#result +1 ] = string.format("%s{", indent)
            end
            local indent2 = indent .. "    "
            local keys = {}
            local values = {}
            for k, v in pairs(object) do
                keys[#keys + 1] = k
                values[k] = v
            end
            table.sort(keys, function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                else
                    return tostring(a) < tostring(b)
                end
            end)
            for i, k in ipairs(keys) do
                _vardump(values[k], k, indent2, nest + 1)
            end
            result[#result +1] = string.format("%s}%s", indent, postfix)
        end
    end
    _vardump(object, label, "", 1)

    return table.concat(result, "\n")
end


function tracebackex()
local ret = ""
local level = 2
ret = ret .. "stack traceback:\n"
while true do
   --get stack info
   local info = debug.getinfo(level, "Sln")
   if not info then break end
   if info.what == "C" then                -- C function
    ret = ret .. tostring(level) .. "\tC function\n"
   else           -- Lua function
    ret = ret .. string.format("\t[%s]:%d in function `%s`\n", info.short_src, info.currentline, info.name or "")
   end
   --get local vars
   local i = 1
   while true do
    local name, value = debug.getlocal(level, i)
    if not name then break end
    ret = ret .. "\t\t" .. name .. " =\t" .. tostringex(value, 3) .. "\n"
    i = i + 1
   end
   level = level + 1
end
return ret
end

function tostringex(v, len)
if len == nil then len = 0 end
local pre = string.rep('\t', len)
local ret = ""
if type(v) == "table" then
   if len > 5 then return "\t{ ... }" end
   local t = ""
   for k, v1 in pairs(v) do
    t = t .. "\n\t" .. pre .. tostring(k) .. ":"
    t = t .. tostringex(v1, len + 1)
   end
   if t == "" then
    ret = ret .. pre .. "{ }\t(" .. tostring(v) .. ")"
   else
    if len > 0 then
     ret = ret .. "\t(" .. tostring(v) .. ")\n"
    end
    ret = ret .. pre .. "{" .. t .. "\n" .. pre .. "}"
   end
else
   ret = ret .. pre .. tostring(v) .. "\t(" .. type(v) .. ")"
end
return ret
end