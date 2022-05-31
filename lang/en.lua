WellEater = WellEater or {}
local L = {
    generalSetupHeader = "Food search criteria to scan your inventory",
    generalSetupDescription = "Auto eat your preferred meals provided by your inventory after food or drink buff expiration",
    foodQualityMinHeader = "Food Quality Min Range",
    foodQualityMaxHeader = "Food Quality Max Range",
    foodGreen = "Normal (green)",
    foodBlue = "Excellent (blue)",
    foodCyan = "Artifact (cyan)",
    foodGold = "Legendary (gold)",

    timerSetupHeader = "Inventory Scan Timer",
    timerSetupLabel = "Scan period, ms",
    timerSetupLabel_TT = "How often the inventory is scanned for food. The more the better but more probably " ..
            "you can run out of food for a long time in critical situation",
}

function WellEater:getLocale()
    return L
end