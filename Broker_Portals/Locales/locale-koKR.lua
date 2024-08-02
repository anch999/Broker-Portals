--Create the library instance
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");

local L = AceLocale:NewLocale("BrokerPortals", "koKR", false);

--Register translations
if L then

-- L["ANNOUNCE"] = "Announce cast of portals"
-- L["ANNOUNCEMENT"] = "Casting"
L["ATT_MINIMAP"] = "미니맵 표시"
L["HEARTHSTONE"] = "귀환석"
L["INN"] = "여관:"
L["MIN"] = "분"
L["N/A"] = "사용 불가"
L["OPTIONS"] = "설정"
L["P"] = "차원의 문" -- Needs review
L["P_RUNE"] = "차원이동의 룬" -- Needs review
L["RCLICK"] = "오른쪽-클릭"
L["READY"] = "사용 가능"
L["SEC"] = "초"
L["SEE_SPELLS"] = "주문 목록 보기"
L["SHOW_ITEMS"] = "아이템 보이기"
L["SHOW_ITEM_COOLDOWNS"] = "아이템 재사용시간 표시"
L["TP"] = "순간이동" -- Needs review
L["TP_RUNE"] = "순간이동의 룬" -- Needs review


end
