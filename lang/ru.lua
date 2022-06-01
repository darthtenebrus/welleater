WellEater = WellEater or {}
local L = {
    generalSetupDescription = "После истечения времени эффектов, которые дает еда, позволяет автоматически съесть найденное в инвентаре блюдо",
    foodQualityHeader = "Качество искомой еды",
    foods = {
        [ITEM_QUALITY_MAGIC] = "Хорошее (зеленое)",
        [ITEM_QUALITY_ARCANE] = "Превосходное (синее)",
        [ITEM_QUALITY_ARTIFACT] = "Эпическое (фиолетовое)",
        [ITEM_QUALITY_LEGENDARY] = "Легендарное (золотое)",
    },
    timerSetupHeader = "Таймер опроса инвентаря",
    timerSetupLabel = "Период опроса, мс",
    timerSetupLabel_TT = "Как часто инвентарь сканируется на наличие еды." ..
    " Большее значение - меньше нагрузка но большая вероятность оказаться без еды на некоторое время"..
    " в критической ситуации",

    youEat = "Вы съели: <<1>>",
    outputSetupHeader = "Вывод сообщения о съеденном блюде",
    outputOnScreen = "На экран",
    outputSetupHeader_TT = "При включенной настройке сообщение о съеденном блюде будет выведено на экран, а не только" ..
            " в лог отладки",

}

function WellEater:getLocale()
    return L
end