local M = {}

function M.is_item_directory(item)
    local ending = "/" -- TODO windows variant
    --return vim.fn.isdirectory(item)
    return item:sub(- #ending) == ending
end

function M.debug(val)
    local filewrite = io.open("tempfile", "a+")
    if filewrite == nil then
        print("niet gelukt")
        return
    end

    filewrite:write(vim.inspect(val) .. "\n\n")
    filewrite:close()
end

function M.round(num)
    local fraction = num % 1
    if 0.5 < fraction then
        return math.ceil(num)
    else
        return math.floor(num)
    end
end

function M.split(str, sep)
   local parts ={}
   for part in string.gmatch(str, "([^"..sep.."]+)") do
      table.insert(parts, part)
   end
   return parts
end

function M.trim(str)
    return str:match("^%s*(.-)%s*$")
end

return M
