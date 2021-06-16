-- merge the keys from table 2 (source) into table 1 (destination)
function merge(dest, source)
    for k,v in pairs(source) do
        dest[k] = v
    end
    return dest
end

-- create a copy of table t
function copy(t)
    local new_t = {}
    for k, v in pairs(t) do new_t[k] = v end
    return new_t
end

-- expand table 1 with the numerical keys from table 2
function expand(t1, t2)
    for i, v in ipairs(t2) do
        t1[#t1 + 1] = v
    end
    return t1
end
