local M = {}

---@param t1? table Left table
---@param t2? table Right table
---@param method? 'merge'|'force' Merge method, by default 'merge'
---@return table new_tbl Merged table
function M.tbl_merge(t1, t2, method)
    t1 = t1 or {}
    t2 = t2 or {}
    for k, v in pairs(t2) do
        if method == 'force' or t1[k] == nil then
            t1[k] = v
        end
    end
    return t1
end

return M
