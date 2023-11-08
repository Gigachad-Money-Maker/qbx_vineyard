local BARRELS = {}
local NEXT_ID = 0

local function AddBarrel(coords, data)
    -- local id = #BARRELS + 1
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
    MySQL.Async.fetchAll("SELECT * FROM wine_barrels", {}, function(barrels)
        for _,barrel in pairs(barrels) do
            BARRELS[barrel.id] = {
                created = barrel.created,
                coords = json.decode(barrel.coords),
                data = json.decode(barrel.data),
            }
        end
    end)
end

RegisterNetEvent('Core:Server:OnPlayerLoaded', function()
    local src = source
    TriggerClientEvent("vineyard:GetBarrels", src, BARRELS)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName()  then return end
    SetupBarrels()
    TriggerClientEvent("vineyard:GetBarrels", -1, BARRELS)
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