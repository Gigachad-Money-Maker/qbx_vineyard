# qbx_vineyard
Vineyard Job For QBox

## Dependencies

* [qbx_core](https://github.com/Qbox-project/qbx_core)
* [ox_lib](https://github.com/overextended/ox_lib)

# WIP Features

- More Job Tasks
- Storing and managing wine barrels
- Crafting Wine Varities
- Packaging and delivering to NPCS.

# Items

```
    ['wine_bottle_empty'] = {
		label = 'Empty Wine Bottle',
		description = 'Empty Wine Bottle',
		weight = 100,
		stack = true,
		close = true,
	},
	
	['wine_barrel'] = {
		label = 'Empty Wine Barrel',
		description = 'Empty Wine Barrel',
		weight = 5000,
		stack = false,
		close = true,
		client = {
			export = 'qbx_vineyard.wine_barrel'
		},
	},
	
	['wine_bottle'] = {
		label = 'Wine Bottle',
		description = 'Wine Bottle',
		weight = 300,
		stack = false,
		close = true,
		client = {
			export = 'qbx_vineyard.winebottle'
		},
		buttons = {
			{
				label = "Label Bottle",
				action = function(slot)
					TriggerEvent("vineyard:LabelBottle", slot)
				end
			}
		}
	},

```