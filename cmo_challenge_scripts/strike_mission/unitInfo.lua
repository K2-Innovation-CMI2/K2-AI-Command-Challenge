-- lookup table for unit constants per side
UnitInfo = {
    Blue = {Airfield = {type = "Facility", unitname = "Airfield", dbid = 1713},
            Eagle = {type = "Aircraft", unitname = "Eagle", dbid = 1771, loadoutid = 3766}},
    Red = {Building = {type = "Facility", unitname = "Building", dbid = 452, points = 100}}
}

-- so I don't have to retype side all the time...
-- this is done because command wants a key called side for most functions involving units
-- so we quietly add it here automatically
for side, units in pairs(UnitInfo) do
    for name, unit in pairs(units) do
        unit.side = side
    end
end
