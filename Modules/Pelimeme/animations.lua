-- Declare a global namespace for animations
PelicanUI_Animations = {}

-- Animation function: simpleDisplay
function PelicanUI_Animations.simpleDisplay(imagePath)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(250, 250)
    frame:SetPoint("CENTER", UIParent, "TOP", 0, -150)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)
    texture:SetTexture(imagePath)

    frame:SetAlpha(0)

    -- Fade-in and fade-out animation
    local animationGroup = frame:CreateAnimationGroup()

    local fadeAlphaIn = animationGroup:CreateAnimation("Alpha")
    fadeAlphaIn:SetFromAlpha(0)
    fadeAlphaIn:SetToAlpha(1)
    fadeAlphaIn:SetDuration(2)
    fadeAlphaIn:SetOrder(1)

    local delay = animationGroup:CreateAnimation("Alpha")
    delay:SetFromAlpha(1)
    delay:SetToAlpha(1)
    delay:SetDuration(3)
    delay:SetOrder(2)

    local fadeAlphaOut = animationGroup:CreateAnimation("Alpha")
    fadeAlphaOut:SetFromAlpha(1)
    fadeAlphaOut:SetToAlpha(0)
    fadeAlphaOut:SetDuration(1)
    fadeAlphaOut:SetOrder(3)

    animationGroup:SetScript("OnFinished", function()
        frame:Hide()
    end)

    frame:Show()
    animationGroup:Play()
end

-- Animation function: bounce
function PelicanUI_Animations.bounce(imagePath)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(200, 200)
    frame:SetPoint("CENTER", UIParent, "CENTER", 250, 250)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)
    texture:SetTexture(imagePath)

    local bounce = frame:CreateAnimationGroup()
    local translateUp = bounce:CreateAnimation("Translation")
    translateUp:SetOffset(0, 100)
    translateUp:SetDuration(0.6)
    translateUp:SetSmoothing("OUT")
    translateUp:SetOrder(1)

    local translateDown = bounce:CreateAnimation("Translation")
    translateDown:SetOffset(0, -100)
    translateDown:SetDuration(0.6)
    translateDown:SetSmoothing("IN")
    translateDown:SetOrder(2)

    bounce:SetScript("OnFinished", function()
        frame:Hide()
    end)

    frame:Show()
    bounce:Play()
end

-- Animation function: rain (with memes twice as large)
function PelicanUI_Animations.rain(imagePath)
    local duration = 2.5
    local numImages = 70
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    local imageSize = 128 -- Image size doubled (64 * 2)

    for i = 1, numImages do
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetSize(imageSize, imageSize) -- Using the doubled size
        frame:SetPoint("TOPLEFT", math.random(0, screenWidth), math.random(0, screenHeight))

        local texture = frame:CreateTexture(nil, "BACKGROUND")
        texture:SetAllPoints(frame)
        texture:SetTexture(imagePath)
        texture:SetAlpha(1)

        local animationGroup = frame:CreateAnimationGroup()

        local moveDown = animationGroup:CreateAnimation("Translation")
        moveDown:SetOffset(0, -screenHeight - 200)
        moveDown:SetDuration(duration)
        moveDown:SetSmoothing("OUT")

        animationGroup:SetScript("OnFinished", function()
            frame:Hide()
            frame = nil
        end)

        C_Timer.After(math.random() * 0.8, function()
            frame:Show()
            animationGroup:Play()
        end)
    end
end

-- Animation function: leftSlide
function PelicanUI_Animations.leftSlide(imagePath)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(300, 300)

    -- Initial position completely off-screen to the left
    frame:SetPoint("LEFT", UIParent, "LEFT", -300, 0)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)
    texture:SetTexture(imagePath)

    local animationGroup = frame:CreateAnimationGroup()

    -- Animation: The image slides into the screen
    local slideIn = animationGroup:CreateAnimation("Translation")
    slideIn:SetOffset(300, 0)
    slideIn:SetDuration(1.5)
    slideIn:SetSmoothing("IN_OUT")
    slideIn:SetOrder(1)

    -- Remains visible for 2 seconds
    local pause = animationGroup:CreateAnimation("Alpha")
    pause:SetFromAlpha(1)
    pause:SetToAlpha(1)
    pause:SetDuration(2)
    pause:SetOrder(2)

    -- Moves out, completely off-screen
    local slideOut = animationGroup:CreateAnimation("Translation")
    slideOut:SetOffset(-300, 0)
    slideOut:SetDuration(1)
    slideOut:SetSmoothing("IN_OUT")
    slideOut:SetOrder(3)

    -- Once the animation is finished, hide the frame
    animationGroup:SetScript("OnFinished", function()
        frame:Hide()
        frame = nil
    end)

    frame:Show()
    animationGroup:Play()
end

-- Animation function: rightSlide
function PelicanUI_Animations.rightSlide(imagePath)
    local frame = CreateFrame("Frame", nil, UIParent)
    frame:SetSize(300, 300)

    -- Initial position completely off-screen to the right
    frame:SetPoint("RIGHT", UIParent, "RIGHT", 300, 0)

    local texture = frame:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints(frame)
    texture:SetTexture(imagePath)

    local animationGroup = frame:CreateAnimationGroup()

    -- Animation: The image slides into the screen
    local slideIn = animationGroup:CreateAnimation("Translation")
    slideIn:SetOffset(-300, 0) -- Slides in by the full width of the image
    slideIn:SetDuration(1.5)
    slideIn:SetSmoothing("IN_OUT")
    slideIn:SetOrder(1)

    -- Remains visible for 2 seconds
    local pause = animationGroup:CreateAnimation("Alpha")
    pause:SetFromAlpha(1)
    pause:SetToAlpha(1)
    pause:SetDuration(2)
    pause:SetOrder(2)

    -- Moves out, completely off-screen
    local slideOut = animationGroup:CreateAnimation("Translation")
    slideOut:SetOffset(300, 0)
    slideOut:SetDuration(1)
    slideOut:SetSmoothing("IN_OUT")
    slideOut:SetOrder(3)

    -- Once the animation is finished, hide the frame
    animationGroup:SetScript("OnFinished", function()
        frame:Hide()
        frame = nil
    end)

    frame:Show()
    animationGroup:Play()
end