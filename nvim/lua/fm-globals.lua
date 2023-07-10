local M = {}

function M.is_item_directory(item)
    local ending = "/" -- TODO windows variant
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

function M.split(str, sep)
   local parts ={}
   for part in string.gmatch(str, "([^"..sep.."]+)") do
      table.insert(parts, part)
   end
   return parts
end

return M
