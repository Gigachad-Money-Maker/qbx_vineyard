local BARRELS = {}
local BARREL = nil
local placingBarrel = false

local Wait = Wait
local SetEntityHeading = SetEntityHeading
local SetEntityCoords = SetEntityCoords
local SetEntityAlpha = SetEntityAlpha

local function CleanBarrelZones()
    for _,v in pairs(BARRELS) do
        v.zone:destroy()
    end
end

local function CreateBarrelObect(barrelId)
    local data = BARRELS[barrelId]
    local barrel = CreateObject(Config.Barrels.model, data.coords.x, data.coords.y, data.coords.z, false, false, false)
    SetEntityHeading(barrel, data.coords.w)
    SetEntityCollision(barrel, true, false)
    SetEntityInvincible(barrel, true)
    FreezeEntityPosition(barrel, true)
    BARRELS[barrelId].object = barrel
end

local function DeleteBarrelObject(barrelId)
    local data = BARRELS[barrelId]
    if DoesEntityExist(data.object) then
        DeleteObject(data.object)
        BARRELS[barrelId].object = nil
    end
end

local function AddBarrel(barrelId, data)
    local sphere = lib.zones.sphere({
        coords = data.coords.xyz,
        radius = 10,
        debug = true,
        onEnter = CreateBarrelObect(barrelId),
        onExit = DeleteBarrelObject(barrelId)
    })
    BARRELS[barrelId] = data
    BARRELS[barrelId].zone = sphere
end

local function RemoveBarrel(barrelId)
    if BARRELS[barrelId].object then
        DeleteBarrelObject(barrelId)
    end
    BARRELS[barrelId] = nil
end

local function UpdateBarrel(barrelId, data)
    BARRELS[barrelId] = data
end

local function SetupBarrels()
    CreateThread(function()
        for barrelId,barrel in pairs(BARRELS) do
            AddBarrel(barrelId, barrel)
        end
    end)
end

local function RotationToDirection(rotation)
	local adjustedRotation =
	{
		x = (math.pi / 180) * rotation.x,
		y = (math.pi / 180) * rotation.y,
		z = (math.pi / 180) * rotation.z
	}
	local direction =
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

local function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination =
	{
		x = cameraCoord.x + direction.x * distance,
		y = cameraCoord.y + direction.y * distance,
		z = cameraCoord.z + direction.z * distance
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, cache.ped, 0))
	return b, c, e
end

local function NewBarrel(coords)
    local canPlace = lib.callback.await('vineyard:CanPlaceBarrel', false, coords)

    if canPlace then

    else

    end
end

local function CancelPlacement()
    DeleteObject(BARREL)
    DeleteEntity(BARREL)
    placingBarrel = false
    BARREL = nil
end

local function AttemptPlaceBarrel()
    if placingBarrel then return end

    lib.requestModel(Config.Barrels.model)

    BARREL = CreateObject(Config.Barrels.model, 0, 0, 0, false, false, false)
    SetEntityHeading(BARREL, GetEntityHeading(cache.ped))
    SetEntityAlpha(BARREL, 150)
    SetEntityCollision(BARREL, false, false)
    SetEntityInvincible(BARREL, true)
    FreezeEntityPosition(BARREL, true)

    local heading = 0.0
    SetEntityHeading(BARREL, heading)

    placingBarrel = true

    CreateThread(function()
        while placingBarrel do
            local hit, coords, entity = RayCastGamePlayCamera(1000.0)
            if hit then

                if IsControlPressed(0, 174) then
                    heading = heading + 5
                    if heading > 360 then heading = 0.0 end
                end
        
                if IsControlPressed(0, 175) then
                    heading = heading - 5
                    if heading < 0 then heading = 360.0 end
                end
    
                SetEntityCoords(BARREL, coords.x, coords.y, coords.z)
                PlaceObjectOnGroundProperly(BARREL)
                SetEntityHeading(BARREL, heading)
                
                if IsControlJustReleased(0, 38) then
                    NewBarrel(coords)
                elseif IsControlJustReleased(0, 47) then
                    CancelPlacement()
                end
            end
            Wait(0)
        end
    end)
end

RegisterNetEvent("vineyard:UpdateBarrel", function(barrelId, data)
    UpdateBarrel(barrelId, data)
end)

RegisterNetEvent("vineyard:removeBarrel", function(barrelId)
    RemoveBarrel(barrelId)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    CleanBarrelZones()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName()  then return end
    SetupBarrels()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    SetupBarrels()
end)

exports('wine_barrel', function(data, slot)
    AttemptPlaceBarrel()
end)