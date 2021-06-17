-- psuedo class for accessing fields from a template table (designated as the parent)
UnitSpec = {}
-- change lookups for unknown indices to refer to the template/parent table
UnitSpec.__index = function(t, k) return t._parent[k] end
-- constructor
UnitSpec.new = function(t, p)
    t._parent = p
    setmetatable(t, UnitSpec)
    return t
end

function inBounds(pos, bounds)
    return pos.latitude >= bounds.latitudeMin and pos.latitude <= bounds.latitudeMax 
            and pos.longitude >= bounds.longitudeMin and pos.longitude <= bounds.longitudeMax
end

function RandomPosition(latitudeMin,latitudeMax,longitudeMin,longitudeMax)
        -- taken from LuaInit.lua in <Command Directory>/Lua/Wooden Leg
        local lat_var = math.random(1,(10^13)) --random number between 1 and 10^13
        local lon_var = math.random(1,(10^13)) --random number between 1 and 10^13
        local pos_lat = math.random(latitudeMin,latitudeMax) + (lat_var/(10^13)) --latitude;
        local pos_lon = math.random(longitudeMin,longitudeMax) + (lon_var/(10^13)) --longitude;
        return {latitude=pos_lat,longitude=pos_lon}
end

function getUnits(side)
    return VP_GetSide({side=side}).units
end

-- There is a weird edge case: large rivers
-- they will have a cover table which will have text: "Land: Water"
-- NOTE command counts that edge case as land, you can't put a ship there
-- SECOND NOTE: there is part of the ocean by antarctica that is encoded like this...
function isLand(pos)
    -- Land has cover info, water has layer info
    if (World_GetLocation(pos).cover) then return true end
    return false
end

function deleteAllUnits(side)
    local units = getUnits(side)
    -- delete units in reverse because we added bases first and
    -- we get an error if we delete a base that still has units in it
    for i=#units,1,-1 do
        ScenEdit_DeleteUnit(units[i])
    end
end

function canSpawn(unit)
-- NOTE, THIS FUNCTION IS NOT COMPLETE!!!!
    -- ASSUMES BASE EXISTS
    -- move this check in isValidConfig, so we can check this
    -- leave this function for units with lat/long
    if(unit.base) then return true end 
    if(not inBounds(unit, SpawnBounds)) then return false end
    if(isLand(unit)) then
        if(unit.type == "Ship") then return false end
    else
        if(unit.type == "Facility") then return false end
        -- todo, add check for ground units
    end
    return true
end

function isValidConfig(units)
-- check if all units are in bounds and can spawn
    for i, unit in ipairs(units) do
        if(not canSpawn(unit)) then
            return false
        end
    end
    return true
end

function spawn(spec)
    -- below doesn't work :<
    -- for some reason it doesn't refer to the template when accessing keys
    --ScenEdit_AddUnit(spec)
    -- to get around this, we have to make a new table that is a deep copy
    local u = merge(merge({}, spec._parent), spec)
    u._parent = nil -- remove the ref to the parent, not necessary now
    local unit = ScenEdit_AddUnit(u)
    -- for some reason, can't assign group in call to AddUnit
    -- this fixes that by setting the group immediately after spawning
    if(u.group) then unit.group = u.group end
    return unit
end

function updateScore(amount, reason)
    return ScenEdit_SetScore("Blue", ScenEdit_GetScore("Blue") + amount, reason)
end
