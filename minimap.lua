local ADDON_NAME = "PelicanUI"
local ICON_PATH = "Interface\\AddOns\\PelicanUI\\Medias\\icon.tga"

PelicanUI_Settings = PelicanUI_Settings or {}
PelicanUI_Settings.minimap = PelicanUI_Settings.minimap or {} -- LibDBIcon saved vars table

local function OpenSettings()
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory("PelicanUI")
    else
        print("PelicanUI: unable to open settings (Settings API unavailable).")
    end
end

local function InitMinimapButton()
    local LDB = LibStub and LibStub("LibDataBroker-1.1", true)
    local LDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    if not LDB or not LDBIcon then
        -- If libs are missing, nothing to do
        return
    end

    -- Create or reuse the DataObject
    local dataObject = LDB:GetDataObjectByName(ADDON_NAME)
    if not dataObject then
        dataObject = LDB:NewDataObject(ADDON_NAME, {
            type = "launcher",
            icon = ICON_PATH,
            label = ADDON_NAME,
            OnClick = function(_, button)
                if button == "LeftButton" then
                    OpenSettings()
                end
            end,
            OnTooltipShow = function(tt)
                if not tt or not tt.AddLine then return end
                tt:AddLine("PelicanUI")
                tt:AddLine("|cffffff00Left-click|r: Ouvrir la configuration")
                tt:AddLine("|cffffff00Drag|r: Déplacer le bouton de minimap")
            end,
        })
    end

    -- Register and show the minimap icon
    if not LDBIcon:IsRegistered(ADDON_NAME) then
        LDBIcon:Register(ADDON_NAME, dataObject, PelicanUI_Settings.minimap)
    end
    LDBIcon:Show(ADDON_NAME)
end

-- Initialize after the UI is ready
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", InitMinimapButton)