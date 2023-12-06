if not Config.Barrels.enabled then return end

local BARRELS = {}

local function AddBarrel(coords, data)
    local created = os.time()
    local id = MySQL.insert.await('INSERT INTO wine_barrels (coords, data, created) VALUES ( ?, ?, ?)', {
        json.encode(coords), 
        json.encode(data),
        created
    })

    BARRELS[id] = {
        created = created,
        coords = coords,
    }
    TriggerClientEvent("vineyard:PlaceBarrel", -1, id, BARRELS[id])
end

local function RemoveBarrel(id)
    MySQL.Async.execute("DELETE FROM wine_barrels WHERE id = ?", { id })
    TriggerClientEvent("vineyard:RemoveBarrel", -1, id)
    BARRELS[id] = nil
end

local function UpdateBarrel(id, data)
    BARRELS[id] = data
end

local function SetupBarrels()
    local barrels = MySQL.query.await('SELECT * FROM wine_barrels', {})
    for _,barrel in pairs(barrels) do
        BARRELS[barrel.id] = {
            created = barrel.created,
            coords = json.decode(barrel.coords),
            data = json.decode(barrel.data),
        }
    end
    Wait(500)
    TriggerClientEvent("vineyard:SetBarrels", -1, BARRELS)
end

local function GetWineAge(sec)
    local date = os.date("!*t", sec)
    local age = string.format("%sD %sH %sM %sS", date["day"]-1, date["hour"], date["min"], date["sec"])
    return age
end

RegisterNetEvent('Core:Server:OnPlayerLoaded', function()
    local src = source
    TriggerClientEvent("vineyard:SetBarrels", src, BARRELS)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName()  then return end
    SetupBarrels()
end)

RegisterNetEvent("vineyard:AttemptPickupBarrel", function(data)
    local src = source
    RemoveBarrel(data.id)
    exports.ox_inventory:AddItem(src, 'wine_barrel', 1)
end)

RegisterNetEvent("vineyard:AttemptPlaceBarrel", function(coords)
    local src = source

    if exports.ox_inventory:GetItemCount(src, 'wine_barrel') > 0 then
        exports.ox_inventory:RemoveItem(src, 'wine_barrel', 1)
        AddBarrel(coords, {})
    else
        print("Player attempted to place a barrel without having one.")
    end

end)

RegisterNetEvent("vineyard:AttemptCheckBarrel", function(data)
    local src = source

    if BARRELS[data.id] then
        TriggerClientEvent('ox_lib:notify', src, {
            title = "This barrel's age is: "..GetWineAge(os.time() - BARRELS[data.id].created),
            type = "inform"
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = "Invalid Barrel",
            type = "error"
        })
    end
end)

RegisterNetEvent("vineyard:AttemptTapBarrel", function(data)
    local src = source
    
    if exports.ox_inventory:GetItemCount(src, 'wine_bottle_empty') >= Config.Barrels.requiredBottles then
        exports.ox_inventory:RemoveItem(src, 'wine_bottle_empty', Config.Barrels.requiredBottles)
    
        exports.ox_inventory:AddItem(src, 'wine_bottle', Config.Barrels.requiredBottles,
        {
            wine_age = GetWineAge(os.time() - BARRELS[data.id].created)
        })
        RemoveBarrel(data.id)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = "You don't have enough empty bottles!",
            type = "error"
        })
    end
end)

RegisterNetEvent("vineyard:AttemptLabelBottle", function(label, image, slot)
    local src = source

    local item = exports.ox_inventory:GetSlot(src, slot)

    if item.metadata.labeled then
        TriggerClientEvent('ox_lib:notify', src, {
            title = "This bottle is already labeled!",
            type = "error"
        })
        return
    end

    if item.name == "wine_bottle" then
        item.metadata.label = label or "Wine Bottle"
        if image ~= nil then
            item.metadata.image = image
        end
        item.metadata.labeled = true
        exports.ox_inventory:SetMetadata(src, slot, item.metadata)
    else
        print("Player attempted to label a non-wine bottle.")
    end
end)