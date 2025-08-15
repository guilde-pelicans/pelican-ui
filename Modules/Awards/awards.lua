-- PelicanUI Awards Module
local Awards = {}
PelicanUI_Awards = Awards

local IMAGE_BASE_PATH = "Interface\\AddOns\\PelicansUI\\Medias\\awards\\"
local SOUND_BASE_PATH = "Interface\\AddOns\\PelicansUI\\Medias\\sounds\\"
local CUSTOM_FONT_PATH = "Interface\\AddOns\\PelicansUI\\Medias\\fonts\\Impacted20.ttf"
local AWARD_DISPLAY_SIZE = 450

-- Awards configurations
local awards = {
    ["aggro"] = { desc = "Gros boule", image = "gros-boule.png", sound = "sad-noise.mp3" },
    ["carpette"] = { desc = "Carpette", image = "carpette.png", sound = "sad-noise.mp3" },
    ["looter"] = { desc = "Looter", image = "looter.png", sound = "celebration.mp3" },
    ["rageux"] = { desc = "Rageux", image = "rageux.png", sound = "murloc.mp3" },
    ["slacker"] = { desc = "Slacker", image = "slacker.png", sound = "sad-noise.mp3" },
    ["carry"] = { desc = "Carry", image = "carry.png", sound = "celebration.mp3" },
}

local function sanitizePseudo(str)
    if not str or str == "" then
        return ""
    end

    local repl = {
        -- A
        ["À"]="A", ["Á"]="A", ["Â"]="A", ["Ã"]="A", ["Ä"]="A", ["Å"]="A",
        ["à"]="a", ["á"]="a", ["â"]="a", ["ã"]="a", ["ä"]="a", ["å"]="a",
        -- AE / OE / autres ligatures
        ["Æ"]="AE", ["æ"]="ae", ["Œ"]="OE", ["œ"]="oe",
        -- C
        ["Ç"]="C", ["ç"]="c",
        -- E
        ["È"]="E", ["É"]="E", ["Ê"]="E", ["Ë"]="E",
        ["è"]="e", ["é"]="e", ["ê"]="e", ["ë"]="e",
        -- I
        ["Ì"]="I", ["Í"]="I", ["Î"]="I", ["Ï"]="I",
        ["ì"]="i", ["í"]="i", ["î"]="i", ["ï"]="i",
        -- N
        ["Ñ"]="N", ["ñ"]="n",
        -- O
        ["Ò"]="O", ["Ó"]="O", ["Ô"]="O", ["Õ"]="O", ["Ö"]="O", ["Ø"]="O",
        ["ò"]="o", ["ó"]="o", ["ô"]="o", ["õ"]="o", ["ö"]="o", ["ø"]="o",
        -- U
        ["Ù"]="U", ["Ú"]="U", ["Û"]="U", ["Ü"]="U",
        ["ù"]="u", ["ú"]="u", ["û"]="u", ["ü"]="u",
        -- Y
        ["Ý"]="Y", ["Ÿ"]="Y", ["ý"]="y", ["ÿ"]="y",
        -- S
        ["ß"]="b",
    }

    -- Appliquer les remplacements
    str = (str:gsub("[\192-\255][\128-\191]*", repl))

    return str
end

-- Store last award time per user for anti-spam
local lastReceivedAwardTimestamp = {}

-- Helper function to check if the player has sufficient permissions
local function hasPermissions()
    return UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
end

-- Function to play sounds only if allowed
local function playSound(filePath)
    if not filePath or filePath == "" then
        return
    end

    if not PelicanUI_Settings.DisableSounds then
        PlaySoundFile(SOUND_BASE_PATH .. filePath, "Master")
    end
end

-- Handle incoming award messages with anti-spam logic
local function handleAwardReception(sender, message)
    local awardType, pseudo = strsplit(";", message)

    -- Validate the award type
    local award = awards[awardType]
    if not award then
        return
    end

    -- Check anti-spam
    local currentTime = GetServerTime()
    local cooldownPeriod = 60 -- 60 seconds

    if lastReceivedAwardTimestamp[sender] and (currentTime - lastReceivedAwardTimestamp[sender] < cooldownPeriod) then
        local remainingTime = cooldownPeriod - (currentTime - lastReceivedAwardTimestamp[sender])
        C_ChatInfo.SendAddonMessage("PELAWARD_BLOCKED", "Essayez à nouveau dans " .. tostring(remainingTime) .. " secondes.", "WHISPER", sender)
        return
    end

    -- Update last award timestamp for the sender
    lastReceivedAwardTimestamp[sender] = currentTime

    -- Display the award locally
    PelicanUI_Awards.displayAward(IMAGE_BASE_PATH .. award.image, award.sound, pseudo)

    -- Play the associated sound
    if award.sound then
        playSound("drum-roll.mp3")
    end
end

-- Animation function to display Award
function PelicanUI_Awards.displayAward(imagePath, sound, pseudo)

    local frame = CreateFrame("Frame", nil, UIParent)
    local screenHeight = GetScreenHeight()
    local screenWidth = GetScreenWidth()

    -- Create the texture for the image
    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetTexture(imagePath)

    local width, height = AWARD_DISPLAY_SIZE, AWARD_DISPLAY_SIZE

    -- Configure frame size and position
    frame:SetSize(width, height)
    frame:ClearAllPoints()
    frame:SetPoint("TOP", UIParent, "TOP", 0, height + 50)
    texture:SetAllPoints(frame)

    -- Add pseudo text directly on the frame to move with it
    local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")

    -- Sanitize le pseudo pour l'affichage (sans accents/ligatures/caractères spéciaux)
    local safePseudo = sanitizePseudo(pseudo)

    text:SetText(safePseudo)
    text:SetTextColor(0, 0, 0, 1)

    local fontLoaded = text:SetFont(CUSTOM_FONT_PATH, 30)
    if not fontLoaded then
        -- fallback to default
        text:SetFont(text:GetFont(), 30, "OUTLINE")
    end

    text:SetPoint("CENTER", frame, "CENTER", 0, -155)
    text:SetScale(1)

    -- Fireworks effect for the entire screen
    local fireworks = CreateFrame("Frame", nil, UIParent)
    fireworks:SetSize(screenWidth, screenHeight)
    fireworks:SetPoint("CENTER", UIParent, "CENTER")
    fireworks:Hide() -- Initially hidden

    -- Create multiple spark textures to simulate fireworks
    local sparkTextures = {}
    for i = 1, 20 do
        -- Adjust number of sparks for density
        local spark = fireworks:CreateTexture(nil, "OVERLAY")
        spark:SetTexture([[Interface\Cooldown\star4]])
        spark:SetBlendMode("ADD")
        spark:SetAlpha(0)
        spark:SetSize(64, 64)
        table.insert(sparkTextures, spark)
    end

    -- Function to randomly position and animate sparks
    local function animateSparks()
        for _, spark in ipairs(sparkTextures) do
            spark:ClearAllPoints()
            spark:SetPoint("CENTER", fireworks, "BOTTOMLEFT", math.random(0, screenWidth), math.random(0, screenHeight))
            spark:SetAlpha(0)

            local animation = spark:CreateAnimationGroup()
            local fadeIn = animation:CreateAnimation("Alpha")
            fadeIn:SetFromAlpha(0)
            fadeIn:SetToAlpha(1)
            fadeIn:SetDuration(0.3) -- Fade-in duration

            local fadeOut = animation:CreateAnimation("Alpha")
            fadeOut:SetFromAlpha(1)
            fadeOut:SetToAlpha(0)
            fadeOut:SetDuration(0.3) -- Fade-out duration
            fadeOut:SetStartDelay(0.3)

            -- Stop the animation properly to avoid infinite loops causing memory leaks
            animation:SetScript("OnFinished", function()
                animation:Stop()
            end)

            animation:Play()
        end
    end

    -- Main animation group for the image and text
    local animationGroup = frame:CreateAnimationGroup()

    -- Wait for 4 seconds before starting the animation
    local initialDelay = animationGroup:CreateAnimation("Alpha")
    initialDelay:SetFromAlpha(1)
    initialDelay:SetToAlpha(1)
    initialDelay:SetDuration(3)
    initialDelay:SetOrder(1)

    -- Move the image and text down together
    local slideDown = animationGroup:CreateAnimation("Translation")
    slideDown:SetOffset(0, -height - 200) -- Slide into the screen
    slideDown:SetDuration(1.5)
    slideDown:SetSmoothing("IN_OUT")
    slideDown:SetOrder(2)

    -- Pause and trigger the fireworks effect
    local pause = animationGroup:CreateAnimation("Alpha")
    pause:SetFromAlpha(1)
    pause:SetToAlpha(1)
    pause:SetDuration(4)
    pause:SetOrder(3)

    pause:SetScript("OnPlay", function()
        playSound(sound)
        fireworks:Show()
        animateSparks()
    end)

    -- Move the image and text back up together
    local slideUp = animationGroup:CreateAnimation("Translation")
    slideUp:SetOffset(0, height + 200)
    slideUp:SetDuration(1.5)
    slideUp:SetSmoothing("IN_OUT")
    slideUp:SetOrder(4)

    -- Cleanup: Hide the frame and stop fireworks animations
    animationGroup:SetScript("OnFinished", function()
        for _, spark in ipairs(sparkTextures) do
            spark:Hide()
            spark = nil
        end
        fireworks:Hide()
        fireworks = nil

        frame:Hide()
        frame = nil
    end)

    -- Start the animations
    frame:Show()
    fireworks:Hide() -- Ensure fireworks are hidden initially
    animationGroup:Play()
end

-- Create context menu for players
local function UpdateContextMenu(_, parent, data)

    -- Afficher le menu uniquement si le joueur a les permissions (chef de groupe/raid ou assistant de raid)
    if not hasPermissions() then
        return
    end

    local targetPlayer = data.name
    local submenu;

    if targetPlayer then
        submenu = parent:CreateButton("Décerner un award à " .. targetPlayer)
        submenu:CreateTitle("Décerner un award");
    end

    for awardId, awardDefinition in pairs(awards) do
        if submenu then
            submenu:CreateButton(awardDefinition.desc, function()
                -- Send the award message to the group or raid
                if IsInRaid() then
                    C_ChatInfo.SendAddonMessage("PELAWARD", awardId .. ";" .. targetPlayer, "RAID")
                elseif IsInGroup() then
                    C_ChatInfo.SendAddonMessage("PELAWARD", awardId .. ";" .. targetPlayer, "PARTY")
                else
                    C_ChatInfo.SendAddonMessage("PELAWARD", awardId .. ";" .. targetPlayer, "WHISPER", targetPlayer)
                end
            end, false)
        end
    end
end

function Awards:Initialize()

    -- Register event listener for addon messages
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("CHAT_MSG_ADDON")
    frame:SetScript("OnEvent", function(_, _, prefix, message, _, sender)
        if prefix == "PELAWARD" then
            handleAwardReception(sender, message)
        elseif prefix == "PELAWARD_BLOCKED" then
            print("Votre award a été bloqué. " .. message)
        end
    end)
    C_ChatInfo.RegisterAddonMessagePrefix("PELAWARD")
    C_ChatInfo.RegisterAddonMessagePrefix("PELAWARD_BLOCKED")

    -- Command for /awards
    SLASH_PELAWARD1 = "/awards"
    SlashCmdList["PELAWARD"] = function(msg)
        -- Show available awards if no arguments
        if msg == "" or msg == nil then
            print("Utilisation : /awards [type_award] [pseudo]")
            print("Types d'awards disponibles :")
            for awardType, _ in pairs(awards) do
                print(" - " .. awardType)
            end
            return
        end

        -- Parse arguments
        local awardType, pseudo = msg:match('^(%S+)%s+(%S+)$')
        if not awardType or not pseudo then
            print("Utilisation : /awards [type_award] [pseudo]")
            return
        end

        -- Check permissions
        if not hasPermissions() then
            print("Vous n'avez pas la permission de lancer un award.")
            return
        end

        -- Validate the award type
        local award = awards[awardType]
        if not award then
            print("Type d'award invalide : " .. awardType)
            return
        end

        -- Build the message to send
        local message = awardType .. ";" .. pseudo

        -- Send the award message to the group or raid
        if IsInRaid() then
            C_ChatInfo.SendAddonMessage("PELAWARD", message, "RAID")
        elseif IsInGroup() then
            C_ChatInfo.SendAddonMessage("PELAWARD", message, "PARTY")
        else
            print("Vous devez être dans un groupe ou un raid pour utiliser cette commande.")
            return
        end
    end

    PelicanUI_Menu.RegisterBuilder(UpdateContextMenu, 10)
end