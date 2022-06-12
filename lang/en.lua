WellEater = WellEater or {}
local L = {
    generalSetupDescription = "Auto eat your preferred meals provided by your inventory after" ..
            " food or drink buff expiration. Provides weapon autoload",
    foodQualityHeader = "Quality of food to search",
    foodQualityDescription = "Allows to choose the quality of the food",
    foods = {
        [ITEM_QUALITY_MAGIC] = "|c00FB00Normal|r",
        [ITEM_QUALITY_ARCANE] = "|c0077FFExcellent|r",
        [ITEM_QUALITY_ARTIFACT] = "|c9400D3Artifact|r",
        [ITEM_QUALITY_LEGENDARY] = "|cFFFF00Legendary|r",
    },
    timerSetupHeader = "Character status scan timer",
    timerSetupLabel = "Scan period, ms",
    timerSetupLabel_TT = "How often the character is scanned for food buffs. The more the better but more probably " ..
            "you can run out of food for a long time in critical situation",

    youEat = "You have eaten <<1>>",
    youCharge = "Charged <<1>>",
    outputSetupHeader = "notification output",
    outputOnScreen = "On screen",
    outputSetupHeader_TT = "When on the notification about the meal eaten or weapon recharged is written to the screen not only to the debug log",

    mealSetupHeader = "Kind of meal to use",
    mealSetupDescription = "What kind of meal to use: food or drink. WARNING If both are off then" ..
        " there will be no choice made, that is the same as the addon is disabled. Leave at least one on",

    mealSetupFood = "Food",
    mealSetupDrink = "Drink",

    weaponSetupHeader = "Weapon",
    weaponSetupDescription = "Weapon auto enchanting will apply when number of charges decreases to minimum and if soul gem is in inventory",
    weaponSetupEnchantMainHand = "Main hand weapon",
    weaponSetupEnchantOffHand = "Off hand weapon",
    weaponSetupEnchantMainHandBack = "Main hand weapon secondary",
    weaponSetupEnchantOffHandBack = "Off hand weapon secondary",

    minCharges = "Minimum number of charges",
    useCrownGemsTitle = "Use crown soul gems",
    useCrownGemsTitle_TT = "While searching for a soul gem crown ones are taken into the account",

    useCrownFoodTitle = "Use crown food",
    useCrownFoodTitle_TT = "While searching for a food crown meals are taken into the account",



}

function WellEater:getLocale()
    return L
end
