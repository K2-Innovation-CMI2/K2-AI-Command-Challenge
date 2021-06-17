-- Script taken from the simple A2A quick battle
-- modified to work without the interface

-- sides and postures set in editor now
-- ROETable had a bug where it wasn't being used before
-- 0 - Weapns Free, 1 - Tight, 2 - Hold
ROEValue = 0 --math.random(0,2)
EnemyEMCON = "Radar=Active"

function AddMultipleAircraft(quantity, side, spec, latitude, longitude, heading)
        local circle = World_GetCircleFromPoint({latitude=latitude,longitude=longitude,radius=0.5,numpoints = 72})
        local addedAircraftTable = {}
        if heading == nil then heading = 0 end
        if quantity < 1 then quantity = 1 end
                for i = 1, quantity do
                        if i > 1 then
                                position = circle[i-1]
                        else
                                position = {latitude=latitude,longitude=longitude}
                        end
			local unitSpec = UnitSpec.new({name=side..' #'..i,latitude=position.latitude,longitude=position.longitude,heading=heading,altitude=10972.8}, spec)
			local unit = spawn(unitSpec)
                        table.insert(addedAircraftTable,unit)
                end
        return addedAircraftTable
end

-- XDDDDDDDDDDDDDDDDDDDDDDDDD
--ScenEdit_SetTime({ }) --placeholder/reminder to add set time once function is finalised

-- man why can't they make it where the return value is usable!!!!!!
-- Let's change this later so it spawns somewhere over the US!
ScenEdit_AddReferencePoint({side="Red", name="Centrepoint", lat=56.14277778, lon=3.35333333, highlighted=false})
centrePoint = ScenEdit_GetReferencePoint({side='Red',name='Centrepoint'}) --tied to a reference point so it's easy to move wherever you like

playerRadial = math.random(0,359)
StartDistance = math.random(50, 75) -- will have to tweak the values
splitDistance = StartDistance / 2
-- can change Blue/Red bearings in various difficulties
enemyRadial = (playerRadial + 180)%360

playerStartPosition = World_GetPointFromBearing({
        latitude=centrePoint.latitude,
        longitude=centrePoint.longitude,
        bearing=playerRadial,
        distance=splitDistance})

enemyStartPosition = World_GetPointFromBearing({
        latitude=centrePoint.latitude,
        longitude=centrePoint.longitude,
        bearing=enemyRadial,
        distance=splitDistance})

-- CHANGE THIS
-- We want to set the class and loadout of the aircrafts
-- here is where we can append our unit info
playerAircraft = {dbid = 1771, loadout = 12158}
--ReturnClassAndLoadout(OwnAircraftClassAndLoadout,'_')
enemyAircraft = {dbid = 1771, loadout = 12158}
--ReturnClassAndLoadout(EnemyAircraftClassAndLoadout,'_')
playerCallsign = 'Blue'
enemyCallsign = 'Red'

-- would've been set in qb form
-- Don't really need the table anymore, found a better way to track this
-- We would need it if we paint a subset of units as targets though
unitCount = {Blue = 6, Red = 6}
-- OwnAircraftQuantity = 6
-- EnemyAircraftQuantity = 6

AddMultipleAircraft(
        unitCount.Blue,
        'Blue',
	UnitInfo.Blue.Eagle,
        playerStartPosition.latitude,
        playerStartPosition.longitude,
        enemyRadial
)

enemyAircraftList = AddMultipleAircraft(
        unitCount.Red,
        'Red',
	UnitInfo.Red.Eagle,
        enemyStartPosition.latitude,
        enemyStartPosition.longitude,
        playerRadial
)

--the weather values below are just examples, temperature could probably do with some adjustment
-- change back to 1 based indexing for consisting later
weatherTable = {
        {rainfall =0, undercloud=0, seastate =0, temperature=15},
        {rainfall =0, undercloud=0.1, seastate =1, temperature=14},
        {rainfall =0, undercloud=0.2, seastate =2, temperature=13},
        {rainfall =0, undercloud=0.3, seastate =3, temperature=12},
        {rainfall =0, undercloud=0.4, seastate =4, temperature=11},
        {rainfall =10, undercloud=0.5, seastate =5, temperature=10},
        {rainfall =25, undercloud=0.6, seastate =6, temperature=9},
        {rainfall =40, undercloud=0.7, seastate =7, temperature=8},
        {rainfall =55, undercloud=0.8, seastate =8, temperature=7},
        {rainfall =70, undercloud=0.9, seastate =9, temperature=6},
        {rainfall =100, undercloud=1, seastate =9, temperature=5},
}


v = weatherTable[1]
-- one of the few functions that doesn't take a table in.....
ScenEdit_SetWeather(v.temperature, v.rainfall, v.undercloud, v.seastate)

--29.167nm is a 5 minute stretch at 350kt; this will add one point in front and behind the Red aircraft so they start in the middle of their patrol zone
missionPatrolPoints = {
        World_GetPointFromBearing({latitude=enemyStartPosition.latitude,longitude=enemyStartPosition.longitude,distance=29.167/2,bearing=playerRadial}),
        World_GetPointFromBearing({latitude=enemyStartPosition.latitude,longitude=enemyStartPosition.longitude,distance=29.167/2,bearing=enemyRadial}),
}

missionReferencePoints={}

for k,v in ipairs (missionPatrolPoints) do
        local referencePoint = ScenEdit_AddReferencePoint({side='Red',name='Ref '..k,latitude=v.latitude,longitude=v.longitude})
        table.insert(missionReferencePoints,referencePoint.guid)
end

local mission = ScenEdit_AddMission ('Red', 'Red Mission', 'Patrol', {type='AAW',zone=missionReferencePoints})

for k,v in ipairs (enemyAircraftList) do
        ScenEdit_AssignUnitToMission(v.guid,mission.guid)
end

-- seems to be an issue where units aren't being added to the mission
-- but when I run the same addition code (above, this is a check below)
-- the units are added fine. Really weird
--[[local u = getUnits("Red")
for k, v in ipairs(u) do
    print(ScenEdit_GetUnit(v).mission.name)
end]]--


ScenEdit_SetDoctrine({mission=mission.name,side=mission.side},{weapon_control_status_air=ROEValue})
ScenEdit_SetEMCON("Mission",mission.name,EnemyEMCON)

