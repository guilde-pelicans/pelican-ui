-- PelicanUI Emotes Module
local Emotes = {}
PelicanUI_Emotes = Emotes

local IMAGE_BASE_PATH = "Interface\\AddOns\\pelicanUI\\Medias\\emotes\\"

-- Table of emotes
local emotes = {
    ["<3"] = { behaviour = "replace", image = "heart.tga" },
    [":D"] = { behaviour = "replace", image = "big-smile.tga" },
    [":)"] = { behaviour = "replace", image = "smile.tga" },
    [":("] = { behaviour = "replace", image = "frown.tga" },
    [":o"] = { behaviour = "replace", image = "open-mouth.tga"},
    [";)"] = { behaviour = "replace", image = "wink.tga" },
    [":'("] = { behaviour = "replace", image = "cry.tga" },
    ["fuck"] = { behaviour = "after", image = "gogo-fuck.tga", wholeWord = true },
    ["Molkar"] = { behaviour = "before", image = "gamine.tga" },
    ["murloc"] = { behaviour = "after", image = "murloc.tga", wholeWord = true },
    ["zzz"] = { behaviour = "replace", image = "zzz.tga", wholeWord = true },
    ["caca"] = { behaviour = "replace", image = "poop.tga" },
    ["merde"] = { behaviour = "after", image = "poop.tga" },
    ["+1"] = { behaviour = "replace", image = "nek-pouce.tga"},
    ["ok"] = { behaviour = "replace", image = "nek-pouce.tga", wholeWord = true },
    ["lool"] = { behaviour = "replace", image = "neph-lol.tga"},
    ["saucisse"] = { behaviour = "after", image = "sausage.tga" },
}

-- Helper function to escape special characters in Lua patterns
local function escapePattern(str)
    return str:gsub("([^%w])", "%%%1")
end

-- Function to get the emote tag
local function getEmoteTag(emote)
    return "|T" .. IMAGE_BASE_PATH .. emote.image .. ":16|t"
end

-- Function to replace text with emotes
local function replaceEmotesInText(text)
    for code, emote in pairs(emotes) do
        local emoteTag = getEmoteTag(emote)

        -- Of wholeWord is defined, we replace only the full word with frontier
        local pattern
        if emote.wholeWord then
            pattern = "%f[%w](" .. escapePattern(code) .. ")%f[^%w]"
        else
            pattern = "(" .. escapePattern(code) .. ")"
        end

        local function replaceFunc(match)
            if emote.behaviour == "replace" then
                return emoteTag
            elseif emote.behaviour == "before" then
                return emoteTag .. " " .. match
            elseif emote.behaviour == "after" then
                return match .. " " .. emoteTag
            else
                return match
            end
        end

        text = text:gsub(pattern, replaceFunc)
    end
    return text
end

-- Filter applying emote replacement in messages
local function emoteMessageFilter(_, _, msg, sender, ...)
    local updatedMsg = replaceEmotesInText(msg)
    if updatedMsg ~= msg then
        return false, updatedMsg, sender, ...
    end
    return false
end

-- Initialization of the Emotes module
function Emotes:Initialize()
    local eventsToFilter = {
        "CHAT_MSG_GUILD", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_WHISPER",
        "CHAT_MSG_WHISPER_INFORM", "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER", "CHAT_MSG_SAY",
    }
    for _, event in ipairs(eventsToFilter) do
        ChatFrame_AddMessageEventFilter(event, emoteMessageFilter)
    end
end