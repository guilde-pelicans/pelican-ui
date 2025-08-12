-- Saved variables
PelicanUI_Settings = PelicanUI_Settings or {
    EmotesEnabled = true,
    PelimemeEnabled = true,
    TooltipsEnabled = true,
    AwardsEnabled = true,
    ReadyCheckEnabled = true,
    PelimemeMinDelay = 10,
    DisableSounds = false
}

local mainFrame = CreateFrame("Frame")
mainFrame:RegisterEvent("PLAYER_LOGIN")
mainFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        if PelicanUI_Settings.EmotesEnabled then
            PelicanUI_Emotes:Initialize()
            print("Module Emotes - actif")
        end

        if PelicanUI_Settings.PelimemeEnabled then
            PelicanUI_Pelimeme:Initialize()
            print("Module Pelimeme - actif")
        end

        if PelicanUI_Settings.ReadyCheckEnabled then
            PelicanUI_ReadyCheck:Initialize()
            print("Module ReadyCheck - actif")
        end

        if PelicanUI_Settings.AwardsEnabled then
            PelicanUI_Awards:Initialize()
            print("Module Awards - actif")
        end
    end
end)