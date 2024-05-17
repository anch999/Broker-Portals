--Create the library instance
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");

local L = AceLocale:NewLocale("BrokerPortals", "frFR", false);

--Register translations
if L then

-- L["ANNOUNCE"] = "Announce cast of portals"
-- L["ANNOUNCEMENT"] = "Casting"
L["ATT_MINIMAP"] = "Attacher à la minicarte"
L["HEARTHSTONE"] = "Pierre de foyer"
L["INN"] = "Auberge"
L["MIN"] = "min."
L["N/A"] = "Indisponible"
L["OPTIONS"] = "Options"
L["P"] = "Portails" -- Needs review
L["P_RUNE"] = "Rune des portails" -- Needs review
L["RCLICK"] = "Clic-droit"
L["READY"] = "Prête"
L["SEC"] = "secs"
L["SEE_SPELLS"] = "pour voir la liste des sorts"
L["SHOW_ITEMS"] = "Afficher les objets"
-- L["SHOW_ITEM_COOLDOWNS"] = "Show items cooldowns"
L["TP"] = "Téléportations" -- Needs review
L["TP_RUNE"] = "Rune de téléportation" -- Needs review


end
