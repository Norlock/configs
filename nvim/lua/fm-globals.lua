local M = {}

function M.is_item_directory(item)
    local ending = "/" -- TODO windows variant
    return item:sub(- #ending) == ending
end

function M.debug(val)
    local function dump(o)
        if type(o) == 'table' then
            local s = '{ '
            for k, v in pairs(o) do
                if type(k) ~= 'number' then k = '"' .. k .. '"' end
                s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
            end
            return s .. '} '
        else
            return tostring(o)
        end
    end

    print(dump(val))
end

return M
