--Create the library instance
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");

local L = AceLocale:NewLocale("BrokerPortals", "zhCN", false);

--Register translations
if L then

-- L["ANNOUNCE"] = "Announce cast of portals"
-- L["ANNOUNCEMENT"] = "Casting"
L["ATT_MINIMAP"] = "依附在小地图"
L["HEARTHSTONE"] = "炉石"
L["INN"] = "旅店："
L["MIN"] = "分"
L["N/A"] = "无法使用"
L["OPTIONS"] = "选项"
L["P"] = "传送门" -- Needs review
L["P_RUNE"] = "传送门符文" -- Needs review
L["RCLICK"] = "右键点击"
L["READY"] = "已就绪"
L["SEC"] = "秒"
L["SEE_SPELLS"] = "查看法术列表"
L["SHOW_ITEMS"] = "显示物品" -- Needs review
L["SHOW_ITEM_COOLDOWNS"] = "显示物品冷却"
L["TP"] = "传送" -- Needs review
L["TP_RUNE"] = "传送符文" -- Needs review


end

