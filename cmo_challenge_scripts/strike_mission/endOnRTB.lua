-- Script taken from Wooden Leg scenario and modified to work here

local sideUnits = getUnits("Blue") --VP_GetSide({side='Israel'}).units
local airborneFighters = 0

for i,v in ipairs (sideUnits) do
    local unit = ScenEdit_GetUnit({guid=v.guid})
    if unit.type == 'Aircraft' and unit.dbid == UnitInfo.Blue.Eagle.dbid then -- NEW DBID
        -- NOTE: airbornetime is encoded as a STRING
        -- literally assigned to: X hrs Y mins ...
        -- fortunately, we only need to check if it equals "0"
        -- which is the default value when a plane is parked
        if unit.airbornetime ~= "0" then -- NEW CHECK old: if GetAltitudeAGL(unit.guid) > 2 then
            airborneFighters = airborneFighters + 1
        end
    end
end

if airborneFighters == 0 then
    ScenEdit_EndScenario()
end
