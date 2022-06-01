WellEater = WellEater or {}
local L = {
    generalSetupDescription = "Lässt es Ihnen nach der Wirkzeit von dem Essen im Inventar gefundene Gericht automatisch essen",
    foodQualityHeader = "Die Qualität der suchenden Lebensmittel",
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
    outputSetupHeader = "Anzeigen die Nachricht über das gegessene Gericht",
    outputOnScreen = "Auf den Bildschirm",
    outputSetupHeader_TT = "Wenn die Einstellung aktiviert ist, wird eine Nachricht über das gegessene Gericht" ..
            " auf dem Bildschirm angezeigt, und nicht nur zum Debug-Log",

}

function WellEater:getLocale()
    return L
end