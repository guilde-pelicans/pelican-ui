-- PelicanUI ReadyCheck Module
local ReadyCheck = {}
PelicanUI_ReadyCheck = ReadyCheck

local IMAGE_PATH_RC = "Interface\\AddOns\\PelicanUI\\Medias\\ready\\ready-check.png"
local IMAGE_PATH_GO = "Interface\\AddOns\\PelicanUI\\Medias\\ready\\ready-go.png"
local SOUND_BASE_PATH = "Interface\\AddOns\\PelicanUI\\Medias\\sounds\\"

local function playSound(filePath)
    if not filePath or filePath == "" then
        return
    end
    if not PelicanUI_Settings.DisableSounds then
        PlaySoundFile(SOUND_BASE_PATH .. filePath, "Master")
    end
end

-- reused frame / texture
local f, tex

local function ensureFrame()
    if f and tex then
        return f, tex
    end
    f = CreateFrame("Frame", "PelicanUIReadyCheckFrame", UIParent)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:Hide()
    tex = f:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints(f)
    return f, tex
end

-- Final position after slide down
local FINAL_TOP_OFFSET = -150

local function rcStartAnimation()
    local frame, texture = ensureFrame()
    texture:SetTexture(IMAGE_PATH_RC)

    local w, h = texture:GetSize()
    if not w or not h or w == 0 or h == 0 then
        w, h = 350, 350
    end

    frame:SetSize(w, h)
    frame:ClearAllPoints()
    frame:SetPoint("TOP", UIParent, "TOP", 0, h + 50) -- hors écran avant slide
    frame:SetAlpha(1)

    if frame._ag then
        frame._ag:Stop()
    end
    local ag = frame:CreateAnimationGroup()
    frame._ag = ag

    local slideDown = ag:CreateAnimation("Translation")
    slideDown:SetOffset(0, -h - 200)
    slideDown:SetDuration(1.5)
    slideDown:SetSmoothing("IN_OUT")
    slideDown:SetOrder(1)

    local pause = ag:CreateAnimation("Alpha")
    pause:SetFromAlpha(1)
    pause:SetToAlpha(1)
    pause:SetDuration(5)
    pause:SetOrder(2)

    local fadeOut = ag:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.3)
    fadeOut:SetStartDelay(0.3)
    fadeOut:SetOrder(3)

    frame:Show()
    ag:Play()
end

local function rcGoAnimation()
    local frame, texture = ensureFrame()

    -- Stop running animation and put it directly to its final position
    if frame._ag then
        frame._ag:Stop()
    end
    frame:ClearAllPoints()
    frame:SetPoint("TOP", UIParent, "TOP", 0, FINAL_TOP_OFFSET)
    texture:SetTexture(IMAGE_PATH_GO)

    local w, h = texture:GetSize()
    if not w or not h or w == 0 or h == 0 then
        w, h = frame:GetSize()
        if (not w or w == 0) or (not h or h == 0) then
            w, h = 350, 350
        end
    end
    frame:SetSize(w, h)

    playSound("murloc.mp3")

    -- Fade in, tenue, fade out
    frame:SetAlpha(0)
    frame:Show()

    if frame._goAg then
        frame._goAg:Stop()
    end
    local ag = frame:CreateAnimationGroup()
    frame._goAg = ag

    local fadeIn = ag:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.15)
    fadeIn:SetOrder(1)

    local hold = ag:CreateAnimation("Alpha")
    hold:SetFromAlpha(1)
    hold:SetToAlpha(1)
    hold:SetDuration(2.0)
    hold:SetOrder(2)

    local fadeOut = ag:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.4)
    fadeOut:SetOrder(3)

    ag:SetScript("OnFinished", function()
        frame:Hide()
        frame._goAg = nil
        frame._ag = nil
        frame:Hide()
        f, tex = nil, nil
    end)

    ag:Play()
end

local function ForEachGroupUnit(callback)
    if IsInRaid() then
        for i = 1, GetNumGroupMembers() do
            local unit = "raid" .. i
            if UnitExists(unit) then
                callback(unit)
            end
        end
    else
        callback("player")
        for i = 1, GetNumSubgroupMembers() do
            local unit = "party" .. i
            if UnitExists(unit) then
                callback(unit)
            end
        end
    end
end

local function AreAllReady()
    local everyoneAnswered, allReady = true, true
    ForEachGroupUnit(function(unit)
        -- "ready" | "notready" | "afk" | nil
        local status = GetReadyCheckStatus(unit)
        if status == nil then
            everyoneAnswered, allReady = false, false
        elseif status ~= "ready" then
            allReady = false
        end
    end)
    return everyoneAnswered, allReady
end

function ReadyCheck:Initialize()
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("READY_CHECK")
    frame:RegisterEvent("READY_CHECK_CONFIRM")
    frame:RegisterEvent("READY_CHECK_FINISHED")
    frame:SetScript("OnEvent", function(_, event)
        if event == "READY_CHECK" then
            rcStartAnimation()
        elseif event == "READY_CHECK_CONFIRM" then
            local everyoneAnswered, allReady = AreAllReady()
            if everyoneAnswered and allReady then
                rcGoAnimation()
            end
        elseif event == "READY_CHECK_FINISHED" then
            -- If rc is over but someone is not ready (probably Gorim)
            if f and f:IsShown() and not (f._goAg and f._goAg:IsPlaying()) then
                f:Hide()
            end
        end
    end)
end