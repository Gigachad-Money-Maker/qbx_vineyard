if not Config.Barrels.enabled then return end

local BARRELS = {}
local BARREL = nil
local PlacingBarrel = false

local Wait = Wait
local SetEntityHeading = SetEntityHeading
local SetEntityCoords = SetEntityCoords
local SetEntityAlpha = SetEntityAlpha
local IsControlPressed = IsControlPressed
local IsControlJustReleased = IsControlJustReleased

exports.ox_inventory:displayMetadata({
    wine_age = "Wine Age",
})

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

    exports.ox_target:addLocalEntity(barrel, {
        {
            label = "Pick up",
            icon = "fas fa-wine-bottle",
            serverEvent = "vineyard:AttemptPickupBarrel",
            id = self.barrelId,
            data = self.data
        },
        {
            label = "Check Barrel",
            icon = "fas fa-magnifying-glass",
            serverEvent = "vineyard:AttemptCheckBarrel",
            id = self.barrelId,
            data = self.data
        },
        {
            label = "Tap Barrel",
            icon = "fas fa-hand-holding-droplet",
            serverEvent = "vineyard:AttemptTapBarrel",
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
        coords = vec3(data.coords.x, data.coords.y, data.coords.z),
        radius = 10,
        debug = false,
        barrelId = barrelId,
        onEnter = CreateBarrelObect,
        onExit = DeleteBarrelObject
    })
    BARRELS[barrelId].zone = sphere
end

local function RemoveBarrel(barrelId)
    if BARRELS[barrelId].object then
        DeleteBarrelObject({ barrelId = barrelId })
    end

    BARRELS[barrelId].zone:remove()
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

RegisterNetEvent("vineyard:SetBarrels", function(serverBarrels)
    BARRELS = serverBarrels
    SetupBarrels()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    CleanBarrelZones()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    SetupBarrels()
end)

RegisterNetEvent("vineyard:LabelBottle", function(slot)
    local input = lib.inputDialog('Bottle Labeling Service', {
        {type = 'input', label = 'Label Name', description = '', required = true, min = 4, max = 24},
        {type = 'input', label = 'Label Image', description = '', required = false},
    })

    if input then
        TriggerServerEvent("vineyard:AttemptLabelBottle", input[1], input[2], slot)
    end
end)

exports('wine_barrel', function(data, slot)
    AttemptPlaceBarrel()
end)