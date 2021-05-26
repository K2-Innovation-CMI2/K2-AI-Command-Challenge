function getUnits(side)
    return VP_GetSide({side=side}).units
end

--[[Some useful code from the original wooden leg LuaInit.lua script

function CircularRandomPosition(x_latitude, x_longitude, max_radius)
        local randomisationCircle = World_GetCircleFromPoint({
                latitude=x_latitude,
                longitude=x_longitude,
                radius=math.random(0.1,max_radius),
                numpoints = 72})
        local randomisedPoint = randomisationCircle[math.random(1,#randomisation     Circle)]
    return randomisedPoint
end

]]--

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
    --[[for i, u in pairs(units) do
        ScenEdit_DeleteUnit(u)
    end]]--
    -- delete units in reverse because we added bases first and
    -- we get an error if we delete a base that still has units in it
    for i=#units,1,-1 do
        ScenEdit_DeleteUnit(units[i])
    end
end

-- TODO, add a conversion from lat/long to miles or meters?
-- May make creating bases easier to understand

function spawnRedBase(circle)
    --[[Gameplan:
    Make a circle around the center to mark the location of buildings
    command has a function for this, num points = num buildings
    Then, we iterate over those points
    if land -> spawn a building
    else -> spawn a boat

    input: circle - a table with keys of {latitude, longitude, radiu, numpoints}
        Provides the circle used to build the base
    
    NOTE, I don't like this way of passing the input because you need to wrap everything
        in a table, even when it doesn't need to be. However, as the command API does
        this BASICALLY EVERYWHERE, this makes coding simpler.

    Spacing and the number of buildings will have to be determined at some point
]]--
    -- Note: we technically can spawn units on top of one another with no errors
    -- however, I'm not sure what would happen during combat or the sim to overlapping units
    local pts = World_GetCircleFromPoint(circle)
    --print(pts)

    for i, unit in ipairs(pts) do
        -- modifying the pts table to contain the info we need to spawn a unit
        -- it is kind of ugly, but as we are not reusing this data anywhere it works
        unit.side = "Red"
        unit.autodetectable = true
        if(isLand(unit)) then
            unit.type = "Facility"
            unit.dbid = 452 -- medium building
            unit.unitname = "Building"
        else
            unit.type = "Ship"
            unit.dbid = 3195 -- training target ship
            unit.unitname = "Ship"
        end
        ScenEdit_AddUnit(unit)
    end
end

function spawnBlueBase(center)
    local spec = {side = "Blue", latitude = center.latitude, longitude = center.longitude};
    if(isLand(center)) then
        print("Spawning base components")
        -- spawn a single unit airfield
        spec.type = "Facility"
        spec.unitname = "Airfield"
        spec.dbid = 1713
    else
        print("Spawn Ship")
        spec.type = "Ship"
        spec.unitname = "Aircraft Carrier"
        spec.dbid = 1211 -- US CV 63 Kitty Hawk 2007-2008
    end

    local home = ScenEdit_AddUnit(spec);
    for i=1,5 do
        -- Spawn Hornets at base with land strike loadout, 
        -- RANGE: 490 nm while cruising at 36k ft
        ScenEdit_AddUnit({side = "Blue", type = "Aircraft", unitname = "Hornet",  
                           dbid = 2038, base = home.guid, loadoutid = 3766})
    end
end

function RandomPosition(latitudeMin,latitudeMax,longitudeMin,longitudeMax)
        -- taken from LuaInit.lua in <Command Directory>/Lua/Wooden Leg
        local lat_var = math.random(1,(10^13)) --random number between 1 and 10^13
        local lon_var = math.random(1,(10^13)) --random number between 1 and 10^13
        local pos_lat = math.random(latitudeMin,latitudeMax) + (lat_var/(10^13)) --latitude;
        local pos_lon = math.random(longitudeMin,longitudeMax) + (lon_var/(10^13)) --longitude;
        return {latitude=pos_lat,longitude=pos_lon}
end


function setup()
    --[[Gameplan:
    Pick a random point as the center of one base -> spawn it
    choose a random bearing and distance and put the other one there
    ]]--
    -- NOTE we have to be careful about the position
    -- if the lat/long is out of range (e.g. you use a larger angle
    -- than expected) it will cause odd behavior! You will not be able
    -- to look up details about the terrain!
    local pos = nil --RandomPosition(-90, 90, -180, 180)
    repeat 
        if(pos) then print("REDO") end
        -- spawning is a box that represents most of the continental US
        -- NOTE, this has the chance to spawn something in Canada or Mexico, 
        -- but close to the border
        pos = RandomPosition(30, 48, -123, -76)
    until(isLand(pos))
    print("BLUE @ (" .. pos.latitude .. ", " .. pos.longitude .. ")")
    spawnBlueBase(pos)
    -- this can throw the base out of the US, might have to edit...
    local redSpec = World_GetPointFromBearing({latitude = pos.latitude, 
                                               longitude = pos.longitude,
                                               distance = math.random(500, 800), --200, 400
                                               bearing = math.random()*360})
    redSpec.radius = 0.5
    redSpec.numpoints = 6
    print("RED @ (" .. redSpec.latitude .. ", " .. redSpec.longitude .. ")")
    spawnRedBase(redSpec)
end

--print("========================================")
--deleteAllUnits("Red")
--deleteAllUnits("Blue")
setup()