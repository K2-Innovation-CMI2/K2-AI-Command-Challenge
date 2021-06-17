-- Handle a unit being destroyed

local unit = ScenEdit_UnitX()

for k,v in pairs(UnitInfo[unit.side]) do
	if v.dbid == unit.dbid then 
		updateScore(v.score, unit.name .. " destroyed")
		break
	end
end

-- Done outside the loop because munitions count as units!
-- This way, the scenario won't end it missiles are still in the air
-- The loop above only handles applying scores, this check will end
-- the scenario if one side has been eliminated and that side has no
-- active attacks
if #getUnits(unit.side) < 1 then
	ScenEdit_EndScenario()
end
