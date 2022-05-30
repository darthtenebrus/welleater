WellEater = WellEater or {}
WellEater.WELLEATER_SAVED_VERSION = 1
WellEater.AddonName = "WellEater"
WellEater.DisplayName = "|cFFFFFFWell |c0099FFEater|r"
WellEater.Version = "1.0.0"
WellEater.Author = "|c5EFFF5esorochinskiy|r"
local NAMESPACE = {}
NAMESPACE.settingsDefaults = {
    enabled = true,
    updateTime = 2000,
    maxQuality = ITEM_QUALITY_ARCANE,
    minQuality = ITEM_QUALITY_ARCANE
}

function WellEater:getAddonName()
    return self.AddonName
end

function WellEater:getDisplayName()
    return self.DisplayName
end


function WellEater:getVersion()
    return self.Version
end

function WellEater:getAuthor()
    return self.Author
end

function WellEater:getUserPreference(setting)
    return self.settingsUser and self.settingsUser[setting]
end

function WellEater:getUserDefault(setting)
    return NAMESPACE.settingsDefaults and NAMESPACE.settingsDefaults[setting]
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
    return self:isAddonEnabled() and not IsUnitInCombat("player")
            and not IsUnitSwimming("player") and not IsUnitDead("player")
end
-- local functions

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

local function getActiveFoodBuff(abilityId)
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
        local abilityDescription = GetAbilityDescription(abilityId)
        return not (cost > 0 or mechanic > 0 or channeled or castTime > 0 or
                minRangeCM > 0 or maxRangeCM > 0 or abilityDescription == "")
    end
end

local function tryToUseItem(bagId, slotId)
    if IsProtectedFunction("UseItem") then
        CallSecureProtected("UseItem", bagId, slotId)
    else
        UseItem(bagId, slotId)
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

                        tryToUseItem(bagId, slotId)

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
        local bFood = (getActiveFoodBuff(abilityId) and canClickOff)
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

    d(WellEater.AddonName .. " Timer Started")
    local upTime = WellEater:getUserPreference("updateTime")
    if upTime then
        EVENT_MANAGER:RegisterForUpdate(WellEater.AddonName .. "_TimersUpdate", upTime, TimersUpdate)
    end

end

local function ShutDown()
    d("Shutdown minQ = " .. WellEater.settingsUser.minQuality)
    d("Shutdown maxQ = " .. WellEater.settingsUser.maxQuality)
    d(WellEater.AddonName .. " Timer cancelled")
    EVENT_MANAGER:UnregisterForUpdate(WellEater.AddonName .. "_TimersUpdate")
end

local function OnSettingsClosed()
    ShutDown()
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

local function InitOnLoad(_, addonName)
    if WellEater.AddonName ~= addonName then
        return
    end

    EVENT_MANAGER:UnregisterForEvent(WellEater.AddonName, EVENT_ADD_ON_LOADED)
    -- Settings initialization
    WellEater.settingsUser = ZO_SavedVars:NewCharacterIdSettings( "WellEater_Settings",
            WellEater.WELLEATER_SAVED_VERSION,
            "general",
            NAMESPACE.settingsDefaults)

    EVENT_MANAGER:RegisterForEvent(
            WellEater.AddonName,
            EVENT_PLAYER_COMBAT_STATE,
            function(_, arg)

                if not WellEater:isAddonEnabled() then
                    return
                end

                if not arg then
                    d(WellEater.AddonName .. " Combat exited")
                    StartUp()
                else
                    d(WellEater.AddonName .. " Combat entered")
                    ShutDown()
                end
            end
    )


    EVENT_MANAGER:RegisterForEvent(
            WellEater.AddonName,
            EVENT_PLAYER_DEAD,
            function()
                if not WellEater:isAddonEnabled() then
                    return
                end
                d(WellEater.AddonName .. " Dead")
                ShutDown()
            end
    )

    EVENT_MANAGER:RegisterForEvent(
            WellEater.AddonName,
            EVENT_PLAYER_ALIVE,
            function()
                if not WellEater:isAddonEnabled() then
                    return
                end
                d(WellEater.AddonName .. " Alive")
                StartUp()
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

    local lamPanel = WellEater:InitSettingsMenu()
    lamPanel:SetHandler("OnEffectivelyHidden", OnSettingsClosed)
    StartUp()
end

-- Init Hook --
EVENT_MANAGER:RegisterForEvent(
        WellEater.AddonName, EVENT_ADD_ON_LOADED, InitOnLoad)



