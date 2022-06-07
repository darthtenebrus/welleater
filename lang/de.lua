WellEater = WellEater or {}
local L = {
    generalSetupDescription = "Lässt es Ihnen, nach die Essen- oder Trinken-Bufffs auslaufen, im Inventar gefundene Gericht automatisch essen",
    foodQualityHeader = "Die Qualität der suchenden Lebensmittel",
    foodQualityDescription = "Lasst die Qualität der Lebensmittel auswahlen",
    foods = {
        [ITEM_QUALITY_MAGIC] = "Gut (grün)",
        [ITEM_QUALITY_ARCANE] = "Ausgezeichnet (blau)",
        [ITEM_QUALITY_ARTIFACT] = "Episch (lila)",
        [ITEM_QUALITY_LEGENDARY] = "Legendär (gold)",
    },
    timerSetupHeader = "Abfragezeitmeter für den Charakterstatus",
    timerSetupLabel = "Zeitintervall, ms",
    timerSetupLabel_TT = "Wie oft der Charakterzustand auf Nahrungsbuffs gescannt wird" .. "Höherer Wert gibt eine" ..
            " weniger Belastung, aber eher eine" ..
            " Weile ohne Nahrung in einer kritischen Situation",

    youEat = "Sie haben <<1>> gegessen",
    youCharge = "Eingeladen <<1>>",
    outputSetupHeader = "Anzeigen die Nachricht",
    outputOnScreen = "Auf den Bildschirm",
    outputSetupHeader_TT = "Wenn die Einstellung aktiviert ist, wird eine Nachricht über das gegessene Gericht" ..
            " oder die verzauberte Waffe auf dem Bildschirm angezeigt, und nicht nur zum Debug-Log",

    mealSetupHeader = "Gerichtart",
    mealSetupDescription = "Was zu verwenden: Essen oder Trinken. ACHTUNG Wenn die Beide ausgeschaltet sind," ..
            " dann wird kein Essen verwendet, denn ist es egal, der Addon ausgeschaltet wird. Schalten Sie mindestens" ..
            " einen ein",

    mealSetupFood = "Essen",
    mealSetupDrink = "Trinken",

    weaponSetupHeader = "Waffen",
    weaponSetupDescription = "Es kommt Waffen Autoverzauberung vor, wenn die Gebühranzahl Minimal oder kleiner ist und" ..
            " ein Seelenstein im Inventar vorliegt",
    weaponSetupEnchantMainHand = "Haupthande Waffe",
    weaponSetupEnchantOffHand = "Ergänzendhande Waffe",
    weaponSetupEnchantMainHandBack = "Haupthande Waffe zweitrangig",
    weaponSetupEnchantOffHandBack = "Ergänzendhande Waffe zweitrangig",
    minCharges = "Minimalgebühranzahl",

}

function WellEater:getLocale()
    return L
end
