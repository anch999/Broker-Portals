--Create the library instance
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");

local L = AceLocale:NewLocale("BrokerPortals", "esES", false);

--Register translations
if L then

-- L["ANNOUNCE"] = "Announce cast of portals"
-- L["ANNOUNCEMENT"] = "Casting"
L["ATT_MINIMAP"] = "Adjuntar al minimapa"
L["HEARTHSTONE"] = "Piedra de hogar"
L["INN"] = "Posada"
L["MIN"] = "minutos"
L["N/A"] = "No disponible"
L["OPTIONS"] = "Opciones"
L["P"] = "Portales" -- Needs review
L["P_RUNE"] = "Runa de portales" -- Needs review
L["RCLICK"] = "Click-derecho"
L["READY"] = "Lista"
L["SEC"] = "seg"
L["SEE_SPELLS"] = "para ver la lista de hechizos"
L["SHOW_ITEMS"] = "Mostrar items"
L["SHOW_ITEM_COOLDOWNS"] = "Mostrar tiempo de reutilizacion"
L["TP"] = "Teletransporte" -- Needs review
L["TP_RUNE"] = "Runa de teletransporte" -- Needs review


end
