Config = {
	Debug = false,
	PickAmount = {min = 8, max = 12},
	GrapeAmount = {min = 8, max = 12},
	GrapeJuiceAmount = {min = 6, max = 10},
	WineAmount = {min = 6, max = 10},
	wineTimer = 180,
	Vineyard = {
		wine ={
			coords = vec3(-1879.54, 2062.55, 135.92),
			zones = {
				vec3(-1873.85, 2063.01, 135.92),
				vec3(-1876.35, 2059.48, 135.92),
				vec3(-1883.02, 2062.11, 135.92),
				vec3(-1882.03, 2064.85, 135.92),
				vec3(-1880.51, 2065.44, 135.92)
			},
		},
		grapejuice = {
			coords = vec3(828.76, 2191.16, 52.37),
			zones = {
				vec3(830.91, 2194.49, 52.37),
				vec3(827.81, 2196.07, 52.37),
				vec3(824.6, 2189.71, 52.37),
				vec3(827.54, 2188.28, 52.37),
			},
		}
	},
	grapeLocations = {
		vec3(-1875.41, 2100.37, 138.86),
		vec3(-1908.69, 2107.48, 131.31),
		vec3(-1866.04, 2112.64, 134.41),
		vec3(-1907.76, 2125.35, 124.03),
		vec3(-1850.31, 2142.95, 122.30),
		vec3(-1888.22, 2164.51, 114.81),
		vec3(-1835.52, 2180.59, 104.88),
		vec3(-1891.98, 2208.35, 94.56),
		vec3(-1720.37, 2182.03, 106.18),
		vec3(-1808.52, 2173.14, 107.63),
		vec3(-1784.22, 2222.80, 92.86),
		vec3(-1889.13, 2250.05, 79.63),
		vec3(-1861.16, 2254.32, 81.04),
		vec3(-1886.75, 2272.45, 70.81),
		vec3(-1845.49, 2274.63, 73.33),
		vec3(-1687.28, 2195.76, 97.87),
		vec3(-1741.18, 2173.22, 114.39),
		vec3(-1743.17, 2141.11, 121.18),
		vec3(-1813.84, 2089.57, 134.21),
		vec3(-1698.71, 2150.65, 110.41),
	},
	Stores = {
		enabled = true,
		name = 'Wine Shop',
		model = `a_m_m_farmer_01`,
		items = {
			{ name = 'wine_barrel', price = 10 },
			{ name = 'wine_bottle_empty', price = 10 },
		},
		locations = {
			vec4(-1924.83, 2059.11, 139.83, 301.16)
		}
	},
	Barrels = {
		enabled = true,
		model = 'vw_prop_vw_barrel_01a',
		ageTimeMin = 5, -- Minutes: Minimum amount of time it takes for a barrel to age before it can be harvested.
		requiredBottles = 1, -- Amount of bottles required to harvest a barrel.
	},
	Deliveries = {
		enabled = true,
		payoutMin = 100,
		payoutMax = 200,
		locations = {
			vec3(-1879.54, 2062.55, 135.92),
			vec3(828.76, 2191.16, 52.37),
		},
		customers = {
			'a_f_y_bevhills_02',
			'a_f_y_business_04',
			'a_m_m_bevhills_02',
			'a_m_m_bevhills_01',
		}
	}
}