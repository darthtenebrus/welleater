WellEater = WellEater or {}
WellEater.WELLEATER_SAVED_VERSION = 1
WellEater.AddonName = "WellEater"
WellEater.DisplayName = "|cFFFFFFWell |c0099FFEater|r"
WellEater.Version = "1.0.2"
WellEater.Author = "|c5EFFF5esorochinskiy|r"
local NAMESPACE = {}
NAMESPACE.settingsDefaults = {
    enabled = true,
    updateTime = 2000,
    [ITEM_QUALITY_MAGIC] = false,
    [ITEM_QUALITY_ARCANE] = true,
    [ITEM_QUALITY_ARTIFACT] = false,
    [ITEM_QUALITY_LEGENDARY] = false,
    notifyToScreen = true,
    useFood = true,
    useDrink = true,
    slots = {
        [EQUIP_SLOT_MAIN_HAND] = true,
        [EQUIP_SLOT_OFF_HAND] = true,
        [EQUIP_SLOT_BACKUP_MAIN] = true,
        [EQUIP_SLOT_BACKUP_OFF] = true,
    },
    minCharges = 300,
}

function WellEater:isWeaponCheckable()
    local settings = self:getAllUserPreferences()
    for _,val in ipairs(settings.slots) do
        if val then
            return true
        end
    end
    return false
end

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

function WellEater:getUserPreference(setting, categ)
    if not categ or categ == "general" then
        return self.settingsUser and self.settingsUser[setting]
    else
        return self.settingsUser and self.settingsUser[categ] and
                self.settingsUser[categ][setting]
    end
end

function WellEater:getAllUserPreferences()
    return self.settingsUser
end

function WellEater:getUserDefault(setting, categ)
    if not categ or categ == "general" then
        return NAMESPACE.settingsDefaults and NAMESPACE.settingsDefaults[setting]
    else
        return NAMESPACE.settingsDefaults and NAMESPACE.settingsDefaults[categ] and
                NAMESPACE.settingsDefaults[categ][setting]
    end
end

function WellEater:setUserPreference(setting, value, categ)
    self.settingsUser = self.settingsUser or {}
    if not categ or categ == "general" then
        self.settingsUser[setting] = value
    else
        self.settingsUser[categ] = self.settingsUser[categ] or {}
        self.settingsUser[categ][setting] = value
    end

end

function WellEater:isAddonEnabled()
    return self:getUserPreference("enabled")
end

function WellEater:prepareToAnalize()
    return self:isAddonEnabled() and not IsUnitInCombat("player")
            and not IsUnitSwimming("player") and not IsUnitDead("player")
end


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

NAMESPACE.skillUpItems = {
    [64221] = true,   -- Psijic Ambrosia
    [64266] = true,   -- Brain Broth
    [115027] = true,  -- Mythic Aetherial Ambrosia
    [120076] = true,   -- Aetherial Ambrosia

}

-- local functions
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

local function SkillUpItem(itemId)
    return NAMESPACE.skillUpItems[itemId]
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
        local locSettings = WellEater:getAllUserPreferences()
        local useFood = locSettings.useFood
        local useDrink = locSettings.useDrink
        local slotId = itemInfo.slotIndex
        if not itemInfo.stolen then
            local itemType, specialType = GetItemType(bagId, slotId)
            local itemId = GetItemId(bagId, slotId)
            if ((useFood and itemType == ITEMTYPE_FOOD) or
                    (useDrink and itemType == ITEMTYPE_DRINK)) and
                    not SkillUpItem(itemId) then
                local icon, stack, sellPrice, meetsUsageRequirement, locked, equipType, itemStyleId, quality = GetItemInfo(bagId, slotId)

                if meetsUsageRequirement and locSettings and locSettings[quality] then

                    local usable, onlyFromActionSlot = IsItemUsable(bagId, slotId)
                    if usable and not onlyFromActionSlot then

                        local itemLink = GetItemLink(bagId, slotId)
                        local hasAbility,abilityHeader,abilityDescription = GetItemLinkOnUseAbilityInfo(itemLink)
                        local locale = WellEater:getLocale()
                        local formattedName = zo_strformat(locale.youEat, GetItemLinkName(itemLink)) -- no control codes

                        if formattedName and abilityDescription then
                            local toScreen = locSettings.notifyToScreen
                            if toScreen then
                                WellEaterIndicatorLabel:SetText(formattedName)
                                WellEater.AnimIn:PlayFromStart()
                                WellEaterIndicator:SetHidden(false)
                            end
                            df("[%s] %s", WellEater.AddonName, formattedName)
                        end

                        tryToUseItem(bagId, slotId)

                        break
                    end
                end
            end
        end
    end
end

local function checkEquippedWeapon()
    local bagC
    local locSettings = WellEater:getAllUserPreferences()

    if not WellEaterIndicatorWeaponLabel:IsHidden() then
        WellEater.WeaponAnimOut:PlayFromStart()
        WellEaterIndicatorWeaponLabel:SetHidden(true)
    end

    for testSlot,isToCheck in ipairs(locSettings.slots) do
        if isToCheck and HasItemInSlot(BAG_WORN, testSlot)
                and not IsLockedWeaponSlot(testSlot) then

            local linkId = GetItemLink(BAG_WORN, testSlot)
            local numCharges = GetItemLinkNumEnchantCharges(linkId)
            if numCharges and numCharges <= locSettings.minCharges then
                if not bagC then
                    SHARED_INVENTORY:RefreshInventory(BAG_BACKPACK)
                    bagC = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)

                    if not bagC or type(bagC) ~= "table" then
                        return
                    end
                end

                for _, itemInfo in pairs(bagC) do
                    local slotId = itemInfo.slotIndex
                    if not itemInfo.stolen then
                        local itemType, specialType = GetItemType(BAG_BACKPACK, slotId)
                        if itemType == ITEMTYPE_SOUL_GEM then
                            ChargeItemWithSoulGem(BAG_WORN, testSlot, BAG_BACKPACK, slotId)
                            local iName = GetItemLinkName(GetItemLink(BAG_WORN, testSlot))
                            local locale = WellEater:getLocale()
                            local formattedName = zo_strformat(locale.youCharge, iName) -- no control codes
                            df("[%s] %s", WellEater.AddonName, formattedName)
                            local toScreen = locSettings.notifyToScreen
                            if toScreen then
                                WellEaterIndicatorWeaponLabel:SetText(formattedName)
                                WellEater.WeaponAnimIn:PlayFromStart()
                                WellEaterIndicatorWeaponLabel:SetHidden(false)
                            end
                            break
                        end
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
            if not WellEaterIndicator:IsHidden() then
                WellEater.AnimOut:PlayFromStart()
                WellEaterIndicator:SetHidden(true)
            end
            --d(WellEater.AddonName .. "fq = " .. foodQuantity)
            break
        end
    end
    if not haveFood then
        --d(WellEater.AddonName .. " Time To Eat")
        processAutoEat()
    end

    if WellEater:isWeaponCheckable() then
        checkEquippedWeapon()
    end

end

local function StartUp()
    if not WellEater:isAddonEnabled() then
        return
    end

    --d(WellEater.AddonName .. " Timer Started")
    local upTime = WellEater:getUserPreference("updateTime")
    if upTime then
        EVENT_MANAGER:RegisterForUpdate(WellEater.AddonName .. "_TimersUpdate", upTime, TimersUpdate)
    end

end

local function ShutDown()
    --d(WellEater.AddonName .. " Timer cancelled")
    EVENT_MANAGER:UnregisterForUpdate(WellEater.AddonName .. "_TimersUpdate")
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
                    --d(WellEater.AddonName .. " Combat exited")
                    StartUp()
                else
                    --d(WellEater.AddonName .. " Combat entered")
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
                --d(WellEater.AddonName .. " Dead")
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
                --d(WellEater.AddonName .. " Alive")
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
                --d(WellEater.AddonName .. " Swim enter")
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

                --d(WellEater.AddonName .. " Swim exit")
                StartUp()
            end
    )

    -- EVENT_PLAYER_ACTIVATED
    EVENT_MANAGER:RegisterForEvent(
            WellEater.AddonName,
            EVENT_PLAYER_ACTIVATED,
            function(_,initial)
                if initial then
                    if not WellEater:isAddonEnabled() then
                        return
                    end

                    --d(WellEater.AddonName .. " Active")
                    StartUp()
                end
            end
    )

-- EVENT_PLAYER_DEACTIVATED
    EVENT_MANAGER:RegisterForEvent(
            WellEater.AddonName,
            EVENT_PLAYER_DEACTIVATED,
            function()
                if not WellEater:isAddonEnabled() then
                    return
                end
                --d(WellEater.AddonName .. " Inactive")
                ShutDown()
            end
    )

    EVENT_MANAGER:RegisterForEvent(WellEater.AddonName, EVENT_LUA_ERROR, OnUIError)

    -- local lamPanel =
    WellEater:initSettingsMenu()
    WellEater.AnimIn = ANIMATION_MANAGER:CreateTimelineFromVirtual(
            "WellEaterAnnounceFadeIn", WellEaterIndicatorLabel)
    WellEater.AnimOut = ANIMATION_MANAGER:CreateTimelineFromVirtual(
            "WellEaterAnnounceFadeOut", WellEaterIndicatorLabel)

    WellEater.WeaponAnimIn = ANIMATION_MANAGER:CreateTimelineFromVirtual(
            "WellEaterAnnounceFadeIn", WellEaterIndicatorWeaponLabel)
    WellEater.WeaponAnimOut = ANIMATION_MANAGER:CreateTimelineFromVirtual(
            "WellEaterAnnounceFadeOut", WellEaterIndicatorWeaponLabel)

    -- lamPanel:SetHandler("OnEffectivelyHidden", OnSettingsClosed)
end

-- @static global only
function WellEater.InterfaceHook_OnTimerSlider()
    ShutDown()
    StartUp()
end


-- Init Hook --
EVENT_MANAGER:RegisterForEvent(
        WellEater.AddonName, EVENT_ADD_ON_LOADED, InitOnLoad)



