WellEater = WellEater or {}
WellEater.WELLEATER_SAVED_VERSION = 1
WellEater.AddonName = "WellEater"

function WellEater:getUserPreference(setting)
    return self.settingsUser and self.settingsUser[setting]
end

function WellEater:setUserPreference(setting, value)
    self.settingsUser = self.settingsUser or {}
    self.settingsUser[setting] = value

end

function WellEater:isAddonEnabled()

    local locEnabled = self:getUserPreference("enabled")

    if not locEnabled then
        d(WellEater.AddonName .. " NOT enabled")
    end
    return locEnabled
end

function WellEater:prepareToAnalize()
    return self:isAddonEnabled() and not IsUnitInCombat("player") and not IsUnitSwimming("player")
end
-- local functions

local NAMESPACE = {}
NAMESPACE.settingsDefaults = {
    enabled = true,
    updateTime = 2000,
    maxQuality = ITEM_QUALITY_ARTIFACT,
    minQuality = ITEM_QUALITY_ARCANE
}
-- Raid Notifier algorithm. Thanx memus
NAMESPACE.blackList = {
    [43752] = true, -- Soul Summons / Seelenbeschwörung
    [21263] = true, -- Ayleid Health Bonus
    [92232] = true, -- Pelinals Wildheit
    [64210] = true, -- erhöhter Erfahrungsgewinn
    [66776] = true, -- erhöhter Erfahrungsgewinn
    [77123] = true, -- Jubiläums-Erfahrungsbonus 2017
    [85501] = true, -- erhöhter Erfahrungsgewinn
    [85502] = true, -- erhöhter Erfahrungsgewinn
    [85503] = true, -- erhöhter Erfahrungsgewinn
    [86755] = true, -- Feiertags-Erfahrungsbonus
    [88445] = true, -- erhöhter Erfahrungsgewinn
    [89683] = true, -- erhöhter Erfahrungsgewinn
    [91369] = true, -- erhöhter Erfahrungsgewinn der Narrenpastete
}

local function GetActiveFoodBuff(abilityId)
    if NAMESPACE.blackList[abilityId] then
        return false
    end
    if DoesAbilityExist(abilityId) then
        if GetAbilityTargetDescription(abilityId) ~= GetString(SI_TARGETTYPE2)
                or GetAbilityEffectDescription(abilityId) ~= ""
                or GetAbilityRadius(abilityId) > 0
                or GetAbilityAngleDistance(abilityId) > 0
                or GetAbilityDuration(abilityId) < 600000 then
            return false
        end
        local cost, mechanic = GetAbilityCost(abilityId)
        local channeled, castTime = GetAbilityCastInfo(abilityId)
        local minRangeCM, maxRangeCM = GetAbilityRange(abilityId)
        if cost > 0 or mechanic > 0 or channeled or castTime > 0 or minRangeCM > 0 or maxRangeCM > 0 or GetAbilityDescription(abilityId) == "" then
            return false
        end
        return true
    end
end


local function processAutoEat()
    if not WellEater:prepareToAnalize() then
        return
    end

    local bagId = BAG_BACKPACK

    SHARED_INVENTORY:RefreshInventory(bagId)
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(bagId)

    if not bagCache or type(bagCache) ~= "table" then
        return
    end

    for _, itemInfo in pairs(bagCache) do
        local slotId = itemInfo.slotIndex
        if not itemInfo.stolen then
            local itemType, specialType = GetItemType(bagId, slotId)
            if itemType == ITEMTYPE_FOOD or itemType == ITEMTYPE_DRINK then
                local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(bagId, slotId)

                local maxItemQ = WellEater:getUserPreference("maxQuality")
                local minItemQ = WellEater:getUserPreference("minQuality")
                if meetsUsageRequirement and maxItemQ and maxItemQ >= quality
                    and minItemQ and minItemQ <= quality then

                    local usable, onlyFromActionSlot = IsItemUsable(bagId, slotId)
                    if usable and not onlyFromActionSlot then

                        local itemLink = GetItemLink(bagId, slotId)
                        local hasAbility,abilityHeader,abilityDescription = GetItemLinkOnUseAbilityInfo(itemLink)

                        local formattedName = zo_strformat("<<1>>", GetItemLinkName(itemLink)) -- no control codes

                        if formattedName and abilityDescription then
                            d("Name = " .. formattedName)
                            d("Description = " .. abilityDescription)
                        end


                        if IsProtectedFunction("UseItem") then
                            CallSecureProtected("UseItem", bagId, slotId)
                        else
                            UseItem(bagId, slotId)
                        end

                        break
                    end
                end
            end
        end
    end
end

local function TimersUpdate()

    if not WellEater:prepareToAnalize() then
        return
    end

    local haveFood = false
    local now = GetGameTimeMilliseconds()
    local numBuffs = GetNumBuffs("player")
    local foodQuantity = 0
    for i = 1, numBuffs do
        local timeEnding, abilityId, canClickOff
        _, _, timeEnding, _, _, _, _, _, _, _, abilityId, canClickOff = GetUnitBuffInfo("player", i)
        local bFood = (GetActiveFoodBuff(abilityId) and canClickOff)
        foodQuantity = timeEnding * 1000 - now
        haveFood = (bFood and (foodQuantity > 0))
        if haveFood then
            break
        end
    end
    if not haveFood then
        d(WellEater.AddonName .. " Time To Eat")
        processAutoEat()
    end

end

local function StartUp()

    if not WellEater:isAddonEnabled() then
        return
    end

    d(WellEater.AddonName .. " Started")
    local upTime = WellEater:getUserPreference("updateTime")
    if upTime then
        EVENT_MANAGER:RegisterForUpdate(WellEater.AddonName .. "_TimersUpdate", upTime, TimersUpdate)
    end

end

local function ShutDown()
    EVENT_MANAGER:UnregisterForUpdate(WellEater.AddonName .. "_TimersUpdate")
end

local function InitOnLoad(_, addonName)
    if WellEater.AddonName ~= addonName then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(WellEater.AddonName, EVENT_ADD_ON_LOADED)
    StartUp()
end

local function OnUIError(_,errorString)
    --Hide some bugs
    --      if string.match(errorString,"Too many anchors")~=nil
    --      or string.match(errorString,"LibMapPins")~=nil
    if string.match(errorString,WellEater.AddonName) then
        ShutDown()
        ZO_UIErrorsTextEdit:SetText(errorString)
        ZO_UIErrorsTextEdit:SetCursorPosition(1)
    end
end

-- Settings initialization
WellEater.settingsUser = ZO_SavedVars:NewCharacterIdSettings( "WellEater_Settings",
        WellEater.WELLEATER_SAVED_VERSION,
        "general",
        NAMESPACE.settingsDefaults)

-- Init Hook --
EVENT_MANAGER:RegisterForEvent(
        WellEater.AddonName, EVENT_ADD_ON_LOADED, InitOnLoad)

EVENT_MANAGER:RegisterForEvent(
        WellEater.AddonName,
        EVENT_PLAYER_COMBAT_STATE,
        function(_, arg)

            if not WellEater:isAddonEnabled() then
                return
            end

            if not arg then
                d(WellEater.AddonName .. " Combat entered")
                StartUp()
            else
                d(WellEater.AddonName .. " Combat exit")
                ShutDown()
            end
        end
)

EVENT_MANAGER:RegisterForEvent(
        WellEater.AddonName,
        EVENT_PLAYER_SWIMMING,
        function()
            if not WellEater:isAddonEnabled() then
                return
            end
            d(WellEater.AddonName .. " Swim enter")
            ShutDown()
        end
)

EVENT_MANAGER:RegisterForEvent(
        WellEater.AddonName,
        EVENT_PLAYER_NOT_SWIMMING,
        function()
            if not WellEater:isAddonEnabled() then
                return
            end

            d(WellEater.AddonName .. " Swim exit")
            StartUp()
        end
)

EVENT_MANAGER:RegisterForEvent(WellEater.AddonName, EVENT_LUA_ERROR, OnUIError)


