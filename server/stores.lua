if not Config.Stores.enabled then return end

exports.ox_inventory:RegisterShop("Vineyard", {
    name = Config.Stores.name,
    inventory = Config.Stores.items,
    locations = Config.Stores.locations,
})