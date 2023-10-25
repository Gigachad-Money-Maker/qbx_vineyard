local BARRELS = {}

local function AddBarrel(coords)
    local id = #BARRELS + 1
    BARRELS[id] = {
        created = os.time(),
        coords = coords,
    }
    TriggerClientEvent("vineyard:PlaceBarrel", -1, id, BARRELS[id])
end

local function RemoveBarrel(id)
    BARRELS[id] = nil
end

local function UpdateBarrel(id, data)
    BARRELS[id] = data
end

RegisterNetEvent("vineyard:AttemptPlaceBarrel", function(coords)
    local src = source

    if exports.ox_inventory:GetItemCount(src, 'wine_barrel') > 0 then
        exports.ox_inventory:RemoveItem(src, 'wine_barrel', 1)
        AddBarrel(coords)
    else
        print("Player attempted to place a barrel without having one.")
    end

end)