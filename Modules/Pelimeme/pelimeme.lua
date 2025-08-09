-- PelicanUI Pelimeme Module
local Pelimeme = {}
PelicanUI_Pelimeme = Pelimeme

-- Define base directories for memes and sounds
local IMAGE_BASE_PATH = "Interface\\AddOns\\PelicanUI\\Medias\\memes\\"
local SOUND_BASE_PATH = "Interface\\AddOns\\PelicanUI\\Medias\\sounds\\"

local pelimemes = {
    ["jae"] = { desc = "Jae Hippie", image = "jae.png", animation = "simpleDisplay" },
    ["molky"] = { desc = "Molky espiègle", image = "molky.png", animation = "rightSlide", sound = "tu-veut-voir-ma.mp3" },
    ["nephlol"] = { desc = "Neph LOL", image = "nephlol.png", animation = "bounce", sound = "haha.wav" },
    ["gogofuck"] = { desc = "Gogo FUCK", image = "gogofuck.png", animation = "simpleDisplay" },
    ["gogorain"] = { desc = "Pluie de Gogo", image = "gogofuck.png", animation = "rain" },
}

local lastReceivedPelimemeTimestamp = nil
local isMuted = false

-- Function to play a sound
local function playSound(filePath)
    if not filePath or filePath == "" then
        return
    end

    if not PelicanUI_Settings.DisablePelimemeSound then
        PlaySoundFile(SOUND_BASE_PATH .. filePath, "Master")
    end
end

-- Function to display a Pelimeme
local function displayPelimeme(pelimemeID)
    local pelimeme = pelimemes[pelimemeID]
    if not pelimeme then
        print("Pelimeme non défini: " .. pelimemeID)
        return
    end

    local animationFunc = PelicanUI_Animations[pelimeme.animation]
    if not animationFunc or type(animationFunc) ~= "function" then
        print("Animation non définie ou invalide : " .. pelimeme.animation)
        return
    end

    animationFunc(IMAGE_BASE_PATH .. pelimeme.image)
    playSound(pelimeme.sound)
end

-- Handle Pelimeme reception (Anti-Spam and Mute Verification)
local function handlePelimemeReception(sender, pelimemeID)

    -- Check if player is in fight
    if UnitAffectingCombat("player") then
        print("Pelimeme bloqué car vous êtes en combat.")
        C_ChatInfo.SendAddonMessage("PELIMEME_BLOCKED", "Le destinataire est en train de COMBATTRE", "WHISPER", sender)
        return false
    end

    if isMuted then
        print("Pelimeme bloqué. Activez-les avec /pelimeme mute.")
        C_ChatInfo.SendAddonMessage("PELIMEME_BLOCKED", "le destinataire est en mode avion", "WHISPER", sender)
        return false
    end

    -- Check anti-spam
    local currentTime = GetServerTime()
    local minDelay = PelicanUI_Settings.PelimemeMinDelay or 10

    if lastReceivedPelimemeTimestamp and (currentTime - lastReceivedPelimemeTimestamp < minDelay) then
        local remainingTime = minDelay - (currentTime - lastReceivedPelimemeTimestamp)
        C_ChatInfo.SendAddonMessage("PELIMEME_BLOCKED", "Essayez à nouveau dans " .. tostring(remainingTime) .. " secondes.", "WHISPER", sender)
        return false
    end

    lastReceivedPelimemeTimestamp = currentTime

    local desc = pelimemes[pelimemeID] and pelimemes[pelimemeID].desc or "Inconnu"

    displayPelimeme(pelimemeID)
    print(desc .. " reçu de " .. sender)

    return true
end

-- Send Pelimeme with a command
SlashCmdList["PELIMEME"] = function(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        table.insert(args, word)
    end

    if args[1] == "mute" then
        isMuted = not isMuted
        print(isMuted and "Pelimeme désactivés." or "Pelimeme activés.")
    elseif args[1] and args[2] then
        local pelimemeID = args[1]
        local playerName = args[2]

        if isMuted then
            print("Pelimeme désactivé.")
            return
        end

        C_ChatInfo.SendAddonMessage("PELIMEME", pelimemeID, "WHISPER", playerName)
        print("Pelimeme envoyé à " .. playerName)
    else
        print("Utilisation : /pelimeme [nom_pelimeme] [nom_du_joueur] ou /pelimeme mute")
    end
end

-- Create context menu for players
local function UpdateContextMenu(_, parent, data)

    local targetPlayer = data.name

    local personalSubmenu
    if targetPlayer then
        personalSubmenu = parent:CreateButton("Envoyer un PéliMeme à " .. targetPlayer)
        personalSubmenu:CreateTitle("Envoyer à " .. targetPlayer)
    end

    local raidSubmenu
    if IsInRaid() then
        raidSubmenu = parent:CreateButton("Envoyer un PéliMeme au raid")
        raidSubmenu:CreateTitle("Envoyer au raid")
    end

    local groupSubmenu
    if IsInGroup() then
        groupSubmenu = parent:CreateButton("Envoyer un PéliMeme au groupe")
        groupSubmenu:CreateTitle("Envoyer au groupe")
    end

    for pelimemeID, pelimemeInfo in pairs(pelimemes) do
        if personalSubmenu then
            personalSubmenu:CreateButton(pelimemeInfo.desc, function()
                C_ChatInfo.SendAddonMessage("PELIMEME", pelimemeID, "WHISPER", targetPlayer)
            end, false)
        end

        if raidSubmenu then
            raidSubmenu:CreateButton(pelimemeInfo.desc, function()
                C_ChatInfo.SendAddonMessage("PELIMEME", pelimemeID, "RAID")
            end, false)
        end

        if groupSubmenu then
            groupSubmenu:CreateButton(pelimemeInfo.desc, function()
                C_ChatInfo.SendAddonMessage("PELIMEME", pelimemeID, "PARTY")
            end, false)
        end
    end

end

-- Register Pelimeme event for reception
function Pelimeme:Initialize()
    local pelimemeFrame = CreateFrame("Frame")
    pelimemeFrame:RegisterEvent("CHAT_MSG_ADDON")
    pelimemeFrame:SetScript("OnEvent", function(_, _, prefix, message, _, sender)
        if prefix == "PELIMEME" then
            handlePelimemeReception(sender, message)
        elseif prefix == "PELIMEME_BLOCKED" then
            print("Votre Pelimeme a été bloqué. " .. message)
        end
    end)
    C_ChatInfo.RegisterAddonMessagePrefix("PELIMEME")
    C_ChatInfo.RegisterAddonMessagePrefix("PELIMEME_BLOCKED")

    PelicanUI_Menu.RegisterBuilder(UpdateContextMenu, 10)
end
