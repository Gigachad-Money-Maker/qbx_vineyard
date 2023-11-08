local BARRELS = {}
local BARREL = nil
local PlacingBarrel = false

local Wait = Wait
local SetEntityHeading = SetEntityHeading
local SetEntityCoords = SetEntityCoords
local SetEntityAlpha = SetEntityAlpha
local IsControlPressed = IsControlPressed
local IsControlJustReleased = IsControlJustReleased

local function CleanBarrelZones()
    for _,v in pairs(BARRELS) do
        v.zone:remove()
        if v.object then
            DeleteObject(v.object)
        end
    end
end

local function CreateBarrelObect(self)
    lib.requestModel(Config.Barrels.model)

    local data = BARRELS[self.barrelId]
    local barrel = CreateObject(Config.Barrels.model, data.coords.x, data.coords.y, data.coords.z, false, false, false)
    SetEntityCoords(barrel, data.coords.x, data.coords.y, data.coords.z)
    SetEntityHeading(barrel, data.coords.w)
    SetEntityCollision(barrel, true, false)
    SetEntityInvincible(barrel, true)
    FreezeEntityPosition(barrel, true)
    PlaceObjectOnGroundProperly(barrel)
    BARRELS[self.barrelId].object = barrel

    exports.ox_target:addEntity(NetworkGetNetworkIdFromEntity(barrel), {
        {
            label = "Pick up",
            icon = "fas fa-wine-bottle",
            serverEvent = "vineyard:AttemptPickupBarrel",
            id = self.barrelId,
            data = self.data
        }
    })
end

local function DeleteBarrelObject(self)
    local data = BARRELS[self.barrelId]
    if DoesEntityExist(data.object) then
        DeleteObject(data.object)
        BARRELS[self.barrelId].object = nil
    end
end

local function AddBarrel(barrelId, data)
    BARRELS[barrelId] = data
    local sphere = lib.zones.sphere({
        coords = data.coords.xyz,
        radius = 10,
        debug = true,
        barrelId = barrelId,
        onEnter = CreateBarrelObect,
        onExit = DeleteBarrelObject
    })
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

local function CancelPlacement()
    DeleteObject(BARREL)
    DeleteEntity(BARREL)
    PlacingBarrel = false
    BARREL = nil
end

local function NewBarrel(coords)
    TriggerServerEvent("vineyard:AttemptPlaceBarrel", coords, GetEntityHeading(BARREL))
    CancelPlacement()
end

local function AttemptPlaceBarrel()
    if PlacingBarrel then return end

    lib.requestModel(Config.Barrels.model)

    BARREL = CreateObject(Config.Barrels.model, 0, 0, 0, false, false, false)
    SetEntityHeading(BARREL, GetEntityHeading(cache.ped))
    SetEntityAlpha(BARREL, 150)
    SetEntityCollision(BARREL, false, false)
    SetEntityInvincible(BARREL, true)
    FreezeEntityPosition(BARREL, true)

    local heading = 0.0
    SetEntityHeading(BARREL, heading)

    PlacingBarrel = true

    CreateThread(function()
        while PlacingBarrel do
            local hit, _, coords, _, _ = lib.raycast.cam(511, 3, 7.0)

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
                    NewBarrel(vec4(coords.x, coords.y, coords.z, heading))
                end
                
                if IsControlJustReleased(0, 47) then
                    CancelPlacement()
                end

            end
            Wait(0)
        end
    end)
end

RegisterNetEvent("vineyard:PlaceBarrel", function(barrelId, data)
    AddBarrel(barrelId, data)
end)

RegisterNetEvent("vineyard:UpdateBarrel", function(barrelId, data)
    UpdateBarrel(barrelId, data)
end)

RegisterNetEvent("vineyard:RemoveBarrel", function(barrelId)
    RemoveBarrel(barrelId)
end)

RegisterNetEvent("vineyard:GetBarrels", function(serverBarrels)
    BARRELS = serverBarrels
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    CleanBarrelZones()
end)

-- AddEventHandler('onResourceStart', function(resourceName)
--     if resourceName ~= GetCurrentResourceName()  then return end
--     SetupBarrels()
-- end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    SetupBarrels()
end)

exports('wine_barrel', function(data, slot)
    AttemptPlaceBarrel()
end)