
UnitInfo = {Blue = {Eagle = {name = "Eagle", type = "Aircraft", dbid = 1771, loadoutid = 12158, score = -100}}, 
	    Red = {Eagle = {name = "Eagle", type = "Aircraft", dbid = 1771, loadoutid = 12158, score = 100}}} 


-- so I don't have to retype side all the time...
-- this is done because command wants a key called side for most functions involving units
-- so we quietly add it here automatically
for side, units in pairs(UnitInfo) do
    for name, unit in pairs(units) do
        unit.side = side
    end
end
