
--Create the library instance
local AceLocale = LibStub:GetLibrary("AceLocale-3.0");

local L = AceLocale:NewLocale("BrokerPortals", "ruRU", false);

--Register translations
if L then

-- L["ANNOUNCE"] = "Announce cast of portals"
-- L["ANNOUNCEMENT"] = "Casting"
L["ATT_MINIMAP"] = "Закрепить у миникарты"
L["HEARTHSTONE"] = "Камень возвращения"
L["INN"] = "Таверна: "
L["MIN"] = "мин"
L["N/A"] = "Не доступно"
L["OPTIONS"] = "Опции"
L["P"] = "Порталы"
L["P_RUNE"] = "Руна порталов"
L["RCLICK"] = "ПКМ"
L["READY"] = "Готов"
L["SEC"] = "секунд"
L["SEE_SPELLS"] = "Для открытия списка заклинаний"
L["SHOW_ITEMS"] = "Показывать предметы"
L["SHOW_ITEM_COOLDOWNS"] = "Показывать время восстановления"
L["TP"] = "Телепорты"
L["TP_RUNE"] = "Руна телепортации"
end

