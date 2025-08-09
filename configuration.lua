-- Create a configuration panel for PelicanUI
local optionsFrame = CreateFrame("Frame", "PelicanUIOptionsFrame")
optionsFrame.name = "PelicanUI"

-- Panel title
local title = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Pelican UI - Configuration")

local configurationDesc = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
configurationDesc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -5)
configurationDesc:SetText("Beaucoup de réglages pour un add-on qui ne sert à rien.")

-- Display the Murloc image
local murlocImage = optionsFrame:CreateTexture(nil, "ARTWORK")
murlocImage:SetTexture("Interface\\AddOns\\PelicanUI\\Medias\\configuration-logo.png")
murlocImage:SetSize(256, 256)
murlocImage:SetPoint("TOPRIGHT", -16, -16)
murlocImage:SetAlpha(0.5)

-- Checkbox to enable/disable the Emotes module
local emotesCheckbox = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
emotesCheckbox:SetPoint("TOPLEFT", configurationDesc, "BOTTOMLEFT", 0, -20)
emotesCheckbox.text = emotesCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
emotesCheckbox.text:SetPoint("LEFT", emotesCheckbox, "RIGHT", 4, 0)
emotesCheckbox.text:SetText("Activer le module Emotes")
emotesCheckbox:SetScript("OnClick", function(self)
    PelicanUI_Settings.EmotesEnabled = self:GetChecked()
end)

-- Checkbox to enable/disable the Emotes module
local tooltipsCheckbox = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
tooltipsCheckbox:SetPoint("TOPLEFT", emotesCheckbox, "BOTTOMLEFT", 0, -8)
tooltipsCheckbox.text = tooltipsCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
tooltipsCheckbox.text:SetPoint("LEFT", tooltipsCheckbox, "RIGHT", 4, 0)
tooltipsCheckbox.text:SetText("Activer le module Tooltips")
tooltipsCheckbox:SetScript("OnClick", function(self)
    PelicanUI_Settings.TooltipsEnabled = self:GetChecked()
end)

-- Checkbox to enable/disable the Emotes module
local readyCheckCheckbox = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
readyCheckCheckbox:SetPoint("TOPLEFT", tooltipsCheckbox, "BOTTOMLEFT", 0, -8)
readyCheckCheckbox.text = readyCheckCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
readyCheckCheckbox.text:SetPoint("LEFT", readyCheckCheckbox, "RIGHT", 4, 0)
readyCheckCheckbox.text:SetText("Activer le module Ready-Check")
readyCheckCheckbox:SetScript("OnClick", function(self)
    PelicanUI_Settings.ReadyCheckEnabled = self:GetChecked()
end)

-- Checkbox to enable/disable the Pelimeme module
local pelimemeCheckbox = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
pelimemeCheckbox:SetPoint("TOPLEFT", readyCheckCheckbox, "BOTTOMLEFT", 0, -8)
pelimemeCheckbox.text = pelimemeCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
pelimemeCheckbox.text:SetPoint("LEFT", pelimemeCheckbox, "RIGHT", 4, 0)
pelimemeCheckbox.text:SetText("Activer le module PeliMeme")
pelimemeCheckbox:SetScript("OnClick", function(self)
    PelicanUI_Settings.PelimemeEnabled = self:GetChecked()
end)

-- Checkbox to enable/disable the Awards module
local awardsCheckbox = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
awardsCheckbox:SetPoint("TOPLEFT", pelimemeCheckbox, "BOTTOMLEFT", 0, -8)
awardsCheckbox.text = awardsCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
awardsCheckbox.text:SetPoint("LEFT", awardsCheckbox, "RIGHT", 4, 0)
awardsCheckbox.text:SetText("Activer le module Pélican Awards")
awardsCheckbox:SetScript("OnClick", function(self)
    PelicanUI_Settings.AwardsEnabled = self:GetChecked()
end)

-- Checkbox to disable the sound of Pelimeme
local disableSoundCheckbox = CreateFrame("CheckButton", nil, optionsFrame, "UICheckButtonTemplate")
disableSoundCheckbox:SetPoint("TOPLEFT", awardsCheckbox, "BOTTOMLEFT", 0, -8)
disableSoundCheckbox.text = disableSoundCheckbox:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
disableSoundCheckbox.text:SetPoint("LEFT", disableSoundCheckbox, "RIGHT", 4, 0)
disableSoundCheckbox.text:SetText("Désactiver les sons (je n'aime pas le fun)")
disableSoundCheckbox:SetScript("OnClick", function(self)
    PelicanUI_Settings.DisableSounds = self:GetChecked()
end)

-- Add a title for the slider
local delayLabel = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
delayLabel:SetPoint("TOPLEFT", disableSoundCheckbox, "BOTTOMLEFT", 0, -20)
delayLabel:SetText("Délai minimum entre la réception de deux PéliMemes (en secondes)")

-- Add a technical description
local delayDescription = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
delayDescription:SetPoint("TOPLEFT", delayLabel, "BOTTOMLEFT", 0, -5)
delayDescription:SetText("Pour éviter d'être spammé (parce qu'on est un peu con quand même)")

-- Add a slider for PelimemeMinDelay
local minDelaySlider = CreateFrame("Slider", "PelicanUIPelimemeMinDelaySlider", optionsFrame, "OptionsSliderTemplate")
minDelaySlider:SetPoint("TOPLEFT", delayDescription, "BOTTOMLEFT", 0, -20)
minDelaySlider:SetMinMaxValues(1, 600)
minDelaySlider:SetValueStep(1)
minDelaySlider:SetValue(PelicanUI_Settings.PelimemeMinDelay or 10)
minDelaySlider:SetWidth(200)

-- Replace the "Low" and "High" texts
_G[minDelaySlider:GetName() .. "Low"]:SetText("1 seconde")
_G[minDelaySlider:GetName() .. "High"]:SetText("10 minutes")
_G[minDelaySlider:GetName() .. "Text"]:SetText("")

minDelaySlider.text = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
minDelaySlider.text:SetPoint("LEFT", minDelaySlider, "RIGHT", 8, 0)
minDelaySlider.text:SetText((PelicanUI_Settings.PelimemeMinDelay or 10) .. " secondes")

-- Adjust the value and save on change
minDelaySlider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value)
    PelicanUI_Settings.PelimemeMinDelay = value
    self.text:SetText(value .. " secondes")
end)

-- Warning at the bottom
local warningText = optionsFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
warningText:SetPoint("BOTTOMLEFT", 16, 16)
warningText:SetJustifyH("LEFT")
warningText:SetWidth(520)
warningText:SetText("|cffff0000Attention|r : après l'activation ou la désactivation d'un module, il est nécessaire de faire un |cffffff00/reload|r")

-- Update checkboxes and the slider when the panel is displayed
optionsFrame:SetScript("OnShow", function()
    emotesCheckbox:SetChecked(PelicanUI_Settings.EmotesEnabled)
    readyCheckCheckbox:SetChecked(PelicanUI_Settings.ReadyCheckEnabled)
    pelimemeCheckbox:SetChecked(PelicanUI_Settings.PelimemeEnabled)
    awardsCheckbox:SetChecked(PelicanUI_Settings.AwardsEnabled)
    tooltipsCheckbox:SetChecked(PelicanUI_Settings.TooltipsEnabled)
    disableSoundCheckbox:SetChecked(PelicanUI_Settings.DisableSounds)
    minDelaySlider:SetValue(PelicanUI_Settings.PelimemeMinDelay or 10)
end)

local addonCategory = Settings.RegisterCanvasLayoutCategory(optionsFrame, "PelicanUI")
addonCategory.ID = "PelicanUI"
Settings.RegisterAddOnCategory(addonCategory)

-- /pelican shortcut to open configuration panel
SLASH_PELICAN1 = "/pelican"
SlashCmdList["PELICAN"] = function(msg)
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(addonCategory.ID)
    else
        print("Impossible d’ouvrir la configuration: API Settings indisponible.")
    end
end