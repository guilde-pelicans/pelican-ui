local Pelican_Menu = {}
PelicanUI_Menu = Pelican_Menu

-- Registre des builders (fonctions UpdateContextMenu des modules)
local _builders = {}

-- API publique: enregistrer une fonction de construction de menu
-- builder doit accepter la même signature que ModifyMenu: function(_, parent, data)
-- order (optionnel): plus petit = exécuté plus tôt
function Pelican_Menu.RegisterBuilder(builder, order)
    table.insert(_builders, { order = tonumber(order) or 100, fn = builder })
end

-- Fonction centrale appelée par Menu.ModifyMenu
local function UpdateContextMenu(_, rootDesc, data)
    if #_builders == 0 then
        return
    end

    rootDesc:CreateDivider()
    local targetPlayer = data.name
    if targetPlayer then
        rootDesc:CreateTitle("Pélican UI")
    end

    table.sort(_builders, function(a, b) return a.order < b.order end)
    for _, reg in ipairs(_builders) do
        -- Garder la même signature que dans les modules: (_, parent, data)
        local ok = pcall(reg.fn, nil, rootDesc, data)
        if not ok then
            -- Optionnel: logger l'erreur en debug
            print("PelicanUI Menu builder error:", err)
        end
    end
end

-- Attacher une seule fois le gestionnaire aux tags pertinents
for _, tag in ipairs({
    "MENU_UNIT_SELF",
    "MENU_UNIT_FRIEND",
    "MENU_UNIT_PARTY",
    "MENU_UNIT_PLAYER",
    "MENU_UNIT_RAID_PLAYER",
}) do
    Menu.ModifyMenu(tag, UpdateContextMenu)
end