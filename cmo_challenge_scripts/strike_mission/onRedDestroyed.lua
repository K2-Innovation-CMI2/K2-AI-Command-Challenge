-- script taken from WoodenLeg, modified slightly to work with our scenario
local theDestroyedUnit = ScenEdit_UnitX()
if theDestroyedUnit.type ~= 'Weapon' then
	--[[local targetList = {
		{type='Facility', dbid=115, points=125, name='Building (Large)', destroyedString=nil},--Building (Large)
		{type='Facility', dbid=452, points=125, name='Building (Medium)', destroyedString=nil},--Building (Medium)
	}]]--

	local matchData = nil

	for k,v in pairs (UnitInfo.Red) do -- NEW iterates over UnitInfo for Red specified in Spawn Bases event
		if v.dbid == theDestroyedUnit.dbid then
			matchData = v
            break
		end
	end

	if matchData.dbid == nil then
		BugMessage('Red Unit Destroyed Event', 'No dbid match found for destroyed unit')
		if DebugModeIsOn() then
			ScenEdit_SpecialMessage('playerside','Could not find match for destroyed unit '..theDestroyedUnit.name..', dbid '..theDestroyedUnit.dbid)
		end
	else
		UpdateScore(matchData.points,'A target building was destroyed.') -- NEW different function
		ScenEdit_SetEvent('Scenario End',{isactive=true})
	end
end
