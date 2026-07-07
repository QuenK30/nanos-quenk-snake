Package.Require("translations/fr.lua")
Package.Require("translations/en.lua")

local _langs = { fr = TRANSLATIONS_FR, en = TRANSLATIONS_EN }

-- T(key, ...) returns the translated string for the current LANG.
-- Placeholders {1}, {2}, ... are replaced by the varargs in order.
-- Falls back to French then to the raw key if a string is missing.
function T(key, ...)
    local tbl = _langs[LANG] or _langs.fr
    local str = tbl[key] or _langs.fr[key] or key
    local args = { ... }
    return (str:gsub("{(%d+)}", function(n)
        return tostring(args[tonumber(n)] or "")
    end))
end
