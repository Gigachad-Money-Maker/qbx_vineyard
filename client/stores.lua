if not Config.Stores.enabled then return end

local STORES = {}

local function CreateStorePed(self)
    lib.requestModel(self.model)
	local ped = CreatePed(4, self.model, self.coords.xyz, self.coords.w, 0, 0, false, false)
	while not ped do Wait(0) end
	
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)

    exports.ox_target:addLocalEntity(ped, {
        {
            label = 'Wine Shop',
            icon = 'fas fa-wine-bottle',
            onSelect =  function()
                exports.ox_inventory:openInventory('shop', { type = 'Vineyard', id = self.storeId })
            end,
            storeId = self.storeId,
        }
    })

    STORES[self.storeId].ped = ped

end

local function DeleteStorePed(self)
    if STORES[self.storeId].ped then
        DeleteEntity(STORES[self.storeId].ped)
        STORES[self.storeId].ped = nil
    end
end

for storeId,v in pairs(Config.Stores.locations) do

    local sphere = lib.zones.sphere({
        coords = v.xyz,
        radius = 30,
        debug = false,
        storeId = storeId,
        model = Config.Stores.model,
        onEnter = CreateStorePed,
        onExit = DeleteStorePed
    })
    STORES[storeId] = {}
    STORES[storeId].zone = sphere
end