WellEater = WellEater or {}
WellEater.WELL_EATER_SAVED_VERSION = 1
WellEater.AddonName = "Well_Eater"

function WellEater:getUserPreference(setting)
    return self.settingsUser and self.settingsUser[setting]
end

function WellEater:setUserPreference(setting, value)
    self.settingsUser = self.settingsUser or {}
    self.settingsUser[setting] = value

end

function WellEater:isAddonEnabled()
    d(WellEater.AddonName .. " not enabled")
    return self.getUserPreference("enabled")
end

function WellEater:prepareToAnalize()
    return self.isAddonEnabled() and not IsUnitInCombat("player") and not IsUnitSwimming("player")
end

local NAMESPACE = {}
NAMESPACE.settingsDefaults = {
    enabled = true,
    updateTime = 1000,
    quality = ITEM_QUALITY_ARTIFACT,
    foodOnMagicka = true,
    foodOnHealth = true,
    foodOnStamina = true
}

NAMESPACE.buffFood = {
    [72822] = { Health = true }, [17407] = { Health = true }, [66551] = { Health = true },
    [61259] = { Health = true }, [66124] = { Health = true }, [66125] = { Health = true },
    [72816] = { Health = true }, [72824] = { Health = true }, [72957] = { Health = true },
    [72960] = { Health = true }, [72962] = { Health = true }, [72819] = { Health = true },
    [89971] = { Health = true },
    --	[17565]=true,[17567]=true,[17569]=true,[47049]=true,[47051]=true,[66576]=true,[17573]=true,[47050]=true,
    [17577] = { Magicka = true, Stamina = true }, [61294] = { Magicka = true, Stamina = true },
    [72961] = { Magicka = true, Stamina = true }, [84681] = { Magicka = true, Stamina = true },
    [61257] = { Health = true, Magicka = true }, [72959] = { Health = true, Magicka = true },
    [84731] = { Health = true, Magicka = true }, [84735] = { Health = true, Magicka = true },
    [100498] = { Health = true, Magicka = true }, [107748] = { Health = true, Magicka = true },
    [127531] = { Health = true, Magicka = true }, [61261] = { Stamina = true }, [66129] = { Stamina = true },
    [66130] = { Stamina = true }, [68412] = { Stamina = true }, [86673] = { Stamina = true },
    [66127] = { Magicka = true }, [66128] = { Magicka = true }, [68413] = { Magicka = true },
    [66568] = { Magicka = true }, [61260] = { Magicka = true }, [84678] = { Magicka = true },
    [84709] = { Magicka = true }, [84725] = { Magicka = true }, [84720] = { Magicka = true },
    [61341] = true, [61344] = true, [61340] = true, [61335] = true, [61345] = true, [66131] = true,
    [66132] = true, [66136] = true, [66137] = true, [66140] = true, [66141] = true, [17614] = true,
    [61350] = true, [84700] = true, [84704] = true, [100502] = true, [68416] = true, [86746] = true,
    [86559] = true, --Recovery
    [68411] = { Health = true, Magicka = true, Stamina = true }, [17581] = { Health = true, Magicka = true, Stamina = true },
    [61218] = { Health = true, Magicka = true, Stamina = true }, [85484] = { Health = true, Magicka = true, Stamina = true },
    [100488] = { Health = true, Magicka = true, Stamina = true }, [127596] = { Health = true, Magicka = true, Stamina = true },
    [72956] = { Health = true, Stamina = true }, [61255] = { Health = true, Stamina = true }, [89957] = { Health = true, Stamina = true },
    [107789] = { Health = true, Stamina = true }, [127572] = { Health = true, Stamina = true }
}

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

                local itemQ = WellEater:getUserPreference("quality")
                if itemQ and meetsUsageRequirement and itemQ == quality then

                    local usable, onlyFromActionSlot = IsItemUsable(bagId, slotId)
                    if usable and not onlyFromActionSlot then

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

    d(WellEater.AddonName .. " Time Tick")

    local haveFood = false
    local now = GetGameTimeMilliseconds()
    local numBuffs = GetNumBuffs("player")
    local foodQuantity = 0
    for i = 1, numBuffs do
        local timeEnding, abilityId
        _, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        local bFood = NAMESPACE.buffFood[abilityId]
        foodQuantity = timeEnding * 1000 - now
        haveFood = ((bFood and type(bFood) == "table") and (foodQuantity > 0))
        if haveFood then
            break
        end
    end
    d(WellEater.AddonName .. " Char Food = " .. haveFood)
    d(WellEater.AddonName .. " Char Food Quantity = " .. foodQuantity)
    if not haveFood then
        processAutoEat()
    end

end

local function StartUp(_, addonName)
    if WellEater.AddonName ~= addonName then
        return
    end

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

-- Settings initialization
WellEater.settingsUser = ZO_SavedVars:NewCharacterIdSettings( "Well_Eater_Settings",
        WellEater.WELL_EATER_SAVED_VERSION,
        "general",
        NAMESPACE.settingsDefaults)
-- Init Hook --
EVENT_MANAGER:RegisterForEvent(
        WellEater.AddonName, EVENT_ADD_ON_LOADED, StartUp)

EVENT_MANAGER:RegisterForEvent(
        WellEater.AddonName,
        EVENT_PLAYER_COMBAT_STATE,
        function(_, arg)

            if not WellEater:isAddonEnabled() then
                return
            end

            if not arg then
                d(WellEater.AddonName .. " Combat entered")
                StartUp(_,WellEater.AddonName)
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
            StartUp(_,WellEater.AddonName)
        end
)

