WellEater = WellEater or {}

function WellEater:InitSettingsMenu()

    local L = self:getLocale()
    local LAM = LibAddonMenu2
    local optionsTable = {}
    local index = 0

    local function MakeControlEntry(data, category, key)

        if (category and key) then
            -- for the majority of the settings
            data.category = category
            data.key      = key

            -- build simple table with zero-based values for choices
            if data.choices and not data.choicesValues then
                data.choicesValues = {}
                for i=1, #data.choices do
                    tinsert(data.choicesValues, i-1)
                end
            end

            -- setup default value
            if not data.default then
                local default = self:getUserDefault(key)
                data.default = default
            end

            if not data.noAlert then
                index = index + 1
                data.reference = "WESettingCtrl"..index
            end

            -- add get/set functions if they were not provided
            if not data.getFunc then
                data.getFunc = function()
                    return self:getUserPreference(data.key)
                end
            end
            if not data.setFunc then
                data.setFunc = function(value)
                    self:setUserPreference(data.key, value)
                end
            end

        end

        -- add to appropriate table
        table.insert(optionsTable, data)

    end


    self.panelData = {
        type = "panel",
        name = self:getDisplayName(),
        author = self:getAuthor(),
        version = self:getVersion(),
        registerForRefresh = true,
        registerForDefaults = true,
    }

    MakeControlEntry({
        type = "description",
        text = L.generalSetupDescription,
    })

    MakeControlEntry({
        type = "header",
        name = L.generalSetupHeader,
    })

    MakeControlEntry({
        type = "dropdown",
        name = L.foodQualityMinHeader,
        tooltip = L.foodQualityMinHeader,
        choices = {
            L.foodGreen,
            L.foodBlue,
            L.foodCyan,
            L.foodGold
        }, choicesValues = {
            ITEM_QUALITY_MAGIC,
            ITEM_QUALITY_ARCANE,
            ITEM_QUALITY_ARTIFACT,
            ITEM_QUALITY_LEGENDARY
        },
        noAlert = true,
    }, "general", "minQuality")

    MakeControlEntry({
        type = "dropdown",
        name = L.foodQualityMaxHeader,
        tooltip = L.foodQualityMaxHeader,
        choices = {
            L.foodGreen,
            L.foodBlue,
            L.foodCyan,
            L.foodGold
        }, choicesValues = {
            ITEM_QUALITY_MAGIC,
            ITEM_QUALITY_ARCANE,
            ITEM_QUALITY_ARTIFACT,
            ITEM_QUALITY_LEGENDARY
        },
        noAlert = true,
    }, "general", "maxQuality")

    self.optionsData = optionsTable

    local myLAMAddonPanel = LAM:RegisterAddonPanel(self:getAddonName() .. "_Settings_Panel", self.panelData)
    LAM:RegisterOptionControls(self:getAddonName() .. "_Settings_Panel", self.optionsData)
    return myLAMAddonPanel
end