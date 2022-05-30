WellEater = WellEater or {}
local L = {
    generalSetupHeader = "Food search criteria to scan your inventory",
    generalSetupDescription = "Auto eat your preferred meals provided by your inventory after food or drink buff expiration",
    foodQualityMinHeader = "Food Quality Min Range",
    foodQualityMaxHeader = "Food Quality Min Range",
    foodGreen = "Normal (green)",
    foodBlue = "Excellent (blue)",
    foodCyan = "Artifact (cyan)",
    foodGold = "Legendary (gold)",
}

function WellEater:getLocale()
    return L
end