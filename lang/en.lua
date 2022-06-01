WellEater = WellEater or {}
local L = {
    generalSetupHeader = "Food search criteria to scan your inventory",
    generalSetupDescription = "Auto eat your preferred meals provided by your inventory after food or drink buff expiration",
    foodQualityHeader = "Food Quality",
    foods = {
        [ITEM_QUALITY_MAGIC] = "Normal (green)",
        [ITEM_QUALITY_ARCANE] = "Excellent (blue)",
        [ITEM_QUALITY_ARTIFACT] = "Artifact (cyan)",
        [ITEM_QUALITY_LEGENDARY] = "Legendary (gold)",
    },
    timerSetupHeader = "Inventory Scan Timer",
    timerSetupLabel = "Scan period, ms",
    timerSetupLabel_TT = "How often the inventory is scanned for food. The more the better but more probably " ..
            "you can run out of food for a long time in critical situation",

    youEat = "You have eaten <<1>>",
}

function WellEater:getLocale()
    return L
end