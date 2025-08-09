-- PelicanUI Pelimeme Module
local Tooltips = {}
PelicanUI_Tooltips = Tooltips

local playerNotes = {
    ["Molkar"] = "Le chef de nous",
    ["Lamenas"] = "(Rouge) Quadruple menace",
    ["Dounach"] = "(Ouna) LA CATIN DE ROQUEFORT-LA-BÉDOULE",
    ["Ônclêshû"] = "Cô-GM",
    ["Ôncleshû"] = "Cô-GM",
    ["Önclëshü"] = "Cô-GM",
    ["Rienthar"] = "Chef de la rota heal",
}

-- Register Tooltips event for reception
function Tooltips:Initialize()

    local function AddCustomTooltipInfo(tooltip)
        local _, unit = tooltip:GetUnit()
        if not unit or not UnitExists(unit) then
            return
        end

        if UnitIsPlayer(unit) then
            local playerName = UnitName(unit)

            -- Use mapping to add pelican's note.
            if playerNotes[playerName] then
                local titleLine = _G[tooltip:GetName() .. "TextLeft1"]
                if titleLine then
                    tooltip:AddLine("Pélican's Note: " .. playerNotes[playerName], 1, 0.5, 0)
                    tooltip:Show()
                end
            end
        end
    end

    -- change GameTooltip via hooksecurefunc
    hooksecurefunc(GameTooltip, "SetUnit", AddCustomTooltipInfo)
end


