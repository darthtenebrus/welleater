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

    timerSetupHeader = "Таймер опроса инвентаря",
    timerSetupLabel = "Период опроса, мс",
    timerSetupLabel_TT = "Как часто инвентарь сканируется на наличие еды." ..
    " Большее значение - меньше нагрузка но большая вероятность оказаться без еды на некоторое время"..
    " в критической ситуации",
}

function WellEater:getLocale()
    return L
end