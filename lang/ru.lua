WellEater = WellEater or {}
local L = {
    generalSetupHeader = "Критерии поиска еды в инвентаре",
    generalSetupDescription = "После истечения времени эффектов, которые дает еда, позволяет автоматически съесть найденное в инвентаре блюдо",
    foodQualityMinHeader = "Минимум качества еды",
    foodQualityMaxHeader = "Максимум качества еды",
    foodGreen = "Хорошее (зеленое)",
    foodBlue = "Превосходное (синее)",
    foodCyan = "Эпическое (фиолетовое)",
    foodGold = "Легендарное (золотое)",
}

function WellEater:getLocale()
    return L
end