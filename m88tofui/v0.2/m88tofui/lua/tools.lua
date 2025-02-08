
function string.ltrim(input)
    return string.gsub(input, "^[ \t\n\r]+", "")
end

function string.rtrim(input)
    return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.trim(input)
    input = string.gsub(input, "^[ \t\n\r]+", "")
    return string.gsub(input, "[ \t\n\r]+$", "")
end


function string.split(str, delimiter, toNum)
    str = tostring(str)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos) end do
        --cclog("st="..st.." sp="..sp)
        local ss = string.sub(str, pos, st - 1)
        if toNum then
            ss = tonumber(ss)
        end
        table.insert(arr, ss)
        pos = sp + 1
    end

    local ss = string.sub(str, pos)
    if toNum then
       if ss=="true" or ss=="false" then
       else
          ss = tonumber(ss)
       end
    end
    table.insert(arr, ss)
    return arr
end

function string.split2(str,ch1,ch2,toNum)
  local tmp
  local ret={}
  tmp=string.split(str,ch1)
  for k,v in ipairs(tmp) do
      ret[k]=string.split(v,ch2,toNum)
  end

  return ret
end


local function all_matches(str, pattern)
    local start = 1
    return function()
        local s, e = string.find(str, pattern, start, false) -- true 表示纯文本搜索，不使用模式匹配
        if s then
            start = e + 1  -- 更新起始位置为当前匹配的末尾之后的位置
            return s, e, s and str:sub(s, e) or nil  -- 返回开始位置、结束位置和匹配的子串
        end
        return nil  -- 没有更多匹配时返回nil
    end
end
 
--[[
local pattern = "V(%d+)"
for s, e, match in all_matches(str, pattern) do
    --print(s, e, match)
    volumes[s]=match
end
]]

function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

function io.readfile(path,mode)
    mode=mode and mode or "r"
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 or b== 92 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

function table.insertTo(dest, src, begin)

	if begin == nil then
		begin = #dest + 1
	end

    begin = tonumber(begin)
	local len = #src
	for i = 0, len - 1 do
		dest[i + begin] = src[i + 1]
	end
end

function table.keys(t)
    local keys = {}
    for k, v in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end

function clone(tbl)
    local newTable = {}
    for k, v in pairs(tbl) do
        newTable[k] = v
    end
    return newTable
end
