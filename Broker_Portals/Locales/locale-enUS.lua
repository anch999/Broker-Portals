--Create the library instance
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");

local L = AceLocale:NewLocale("BrokerPortals", "enUS", false);

--Register translations
if L then

L["ATT_MINIMAP"] = "Attach to minimap"
L["HEARTHSTONE"] = "Hearthstone"
L["INN"] = "Inn:"
L["MIN"] = "mins"
L["N/A"] = "Not available"
L["OPTIONS"] = "Options"
L["P_RUNE"] = "Rune of Portals"
L["RCLICK"] = "Right-Click"
L["ALTCLICK"] = "Alt-Click Spells"
L["MOVE_SPELLS"] = "to move them to favorites"
L["READY"] = "Ready"
L["SEC"] = "secs"
L["SEE_SPELLS"] = "to see list of spells"
L["SHOW_ITEM_COOLDOWNS"] = "Show items cooldowns"
L["SHOW_ITEMS"] = "Show items"
L["TP"] = "Teleports"
L["P"] = "Portals"
L["TP_RUNE"] = "Rune of Teleportation"
L["ANNOUNCE"] = "Announce cast of portals"
L["ANNOUNCEMENT"] = "Casting"

end