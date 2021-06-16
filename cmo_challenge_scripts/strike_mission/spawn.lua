SpawnBounds = {latitudeMin = 30,latitudeMax = 48,longitudeMin = -123, longitudeMax = -76}

function genBlueBase(center)
    -- generate a base at center
    -- better way to link units to a base????
    -- need to link by the guid or the name of the base
    local units = {UnitSpec.new(copy(center), UnitInfo.Blue.Airfield)}
    -- add planes to the base
    local lid = 15594 -- loadout id for the plane
    for i=1,8 do
        if (i > 6) then lid = 15595 end -- backup loadout in WoodenLeg
        units[#units + 1] = UnitSpec.new({base = units[1].unitname, loadoutid = lid}, UnitInfo.Blue.Eagle)    
    end
    return units
end

function genRedBase(center)
    --generate buildings in a circle around the center
    local circ = merge({radius = 0.5, numpoints = 6}, center)
    local red_units = {}
    for i, pt in ipairs(World_GetCircleFromPoint(circ)) do
        red_units[i] = UnitSpec.new(merge({autodetectable = true, group = "Red Base"}, pt), UnitInfo.Red.Building)
    end
    return red_units
end

function spawnBases()
    local units = nil
    -- generate random unit configurations until we get a valid one
    -- brute force but effective
    repeat
        units = {}
        blue_center = RandomPosition(SpawnBounds.latitudeMin, SpawnBounds.latitudeMax, 
                                        SpawnBounds.longitudeMin, SpawnBounds.latitudeMax)
        red_center = World_GetPointFromBearing(merge({distance = math.random(200, 400), bearing = math.random()*360}, blue_center))
        expand(units, genBlueBase(blue_center))
        expand(units, genRedBase(red_center))
    until(isValidConfig(units))

    --in a valid config, time to add the units
    for i, unit in ipairs(units) do
        spawn(unit)
    end
end

spawnBases()
