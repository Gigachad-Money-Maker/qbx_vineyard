local BARRELS = {}

local function AddBarrel(coords)
    local id = #BARRELS + 1
    BARRELS[id] = {
        created = os.time(),
        coords = coords,
    }
    TriggerClientEvent("vineyard:placeBarrel", -1, BARRELS)
end

local function RemoveBarrel(id)
    BARRELS[id] = nil
end

local function UpdateBarrel(id, data)
    BARRELS[id] = data
end

lib.callback.register('vineyard:CanPlaceBarrel', function(source, coords)
    if exports.ox_inventory:GetItemCount(source, 'wine_barrel') > 0 then
        exports.ox_inventory:RemoveItem(source, 'wine_barrel', 1)
        AddBarrel(coords)
        return true
    else
        return false
    end
end)