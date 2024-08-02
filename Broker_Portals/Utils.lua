local Portals = LibStub("AceAddon-3.0"):GetAddon("BrokerPortals")
local L = LibStub("AceLocale-3.0"):GetLocale("BrokerPortals")
local cTip = CreateFrame("GameTooltip","cTooltip",nil,"GameTooltipTemplate")
local dewdrop = LibStub('Dewdrop-2.0', true)
local WHITE = "|cffFFFFFF"

function Portals:IsRealmbound(bag, slot)
    cTip:SetOwner(UIParent, "ANCHOR_NONE")
    cTip:SetBagItem(bag, slot)
    cTip:Show()
    for i = 1,cTip:NumLines() do
        local text = _G["cTooltipTextLeft"..i]:GetText()
        if text == "Realm Bound" or text == ITEM_SOULBOUND then
            return true
        end
    end
    cTip:Hide()
    return false
end

function Portals:ConvertCastName(castName)
    local spells = {
        ["Fel Gateway"] = "FelInfused Gateway",
        ["Stone of Retreat: Stormwind"] = "Scroll of Retreat: Stormwind"
    }
    return spells[castName] or castName
end


-- deletes item from players inventory if value 2 in the items table is set
function Portals:RemoveItem(arg2)
	if not self.db.deleteItem then return end
        arg2 = Portals:ConvertCastName(arg2)
        if strfind(arg2, GetItemInfo(self.deleteItem):gsub("%-","")) then
            local found, bag, slot = self:HasItem(self.deleteItem)
            if found and C_VanityCollection.IsCollectionItemOwned(self.deleteItem) and self:IsRealmbound(bag, slot) then
                PickupContainerItem(bag, slot)
                DeleteCursorItem()
            end
            self.deleteItem = nil
        end
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

-- returns true, if player has item with given ID in inventory or bags and it's not on cooldown
function Portals:HasItem(itemID)
    local item, found, id
    -- scan inventory
    for slotId = 1, 19 do
      item = GetInventoryItemLink('player', slotId)
      if item then
        found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
        if found and tonumber(id) == itemID then
            return true
        end
      end
    end
    -- scan bags
    for bag = 0, 4 do
      for slot = 1, GetContainerNumSlots(bag) do
        item = GetContainerItemLink(bag, slot)
        if item then
          found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
          if found and tonumber(id) == itemID then
            return true, bag, slot
          end
        end
      end
    end
    return false
  end

  function Portals:PairsByKeys(t, reverse)
    local function order(a, b)
        if reverse then
            return a > b
        else
            return a < b
        end
    end
    local a = {}
    for n in pairs(t) do
      table.insert(a, n)
    end
    table.sort(a, function(a,b) return order(a,b)  end)

    local i = 0
    local iter = function()
      i = i + 1
      if a[i] == nil then
        return nil
      else
        return a[i], t[a[i]]
      end
    end
    return iter
end

function Portals:GetTipAnchor(frame)
  local x, y = frame:GetCenter()
  if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
  local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
  local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
  return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

local UnknownList = {}
function Portals:LearnUnknown()
  for i, v in pairs(UnknownList) do
    if not v then return end
    if not CA_IsSpellKnown(v) and not Portals:HasItem(i) then
      RequestDeliverVanityCollectionItem(i)
    else
      UnknownList[i] = nil
    end
  end
  Portals:ScheduleTimer("learnUnknown", .1)
end

function Portals:LearnUnknownStones()
  for _,v in pairs(VANITY_ITEMS) do
    if C_VanityCollection.IsCollectionItemOwned(v.itemid) and not CA_IsSpellKnown(v.learnedSpell) and v.name:match("Stone of Retreat") then
      UnknownList[v.itemid] = v.learnedSpell
    end
  end
  Portals:LearnUnknown()
end

--for a adding a divider to dew drop menus 
function Portals:AddDividerLine(maxLenght)
  local text = WHITE.."----------------------------------------------------------------------------------------------------"
    dewdrop:AddLine(
      'text' , text:sub(1, maxLenght),
      'textHeight', self.db.txtSize,
      'textWidth', self.db.txtSize,
      'isTitle', true,
      "notCheckable", true
  )
  return true
end

local gossipInfo
function Portals:GOSSIP_SHOW()
  gossipInfo = nil
  if not self.db.deleteItem then return end
  for ID, frame in pairs(self.dontDeleteAfterCast) do
    if GossipFrameNpcNameText:GetText() == frame then
      gossipInfo = {ID, frame}
      return self:RegisterEvent("GOSSIP_CLOSED")
    end
  end
end

function Portals:GOSSIP_CLOSED()
  self:UnregisterEvent("GOSSIP_CLOSED")
  if not gossipInfo then return end
  self.deleteItem = gossipInfo[1]
  Timer.After(1, function() self:RemoveItem(gossipInfo[2]) end)
end

function Portals:OnEnter(button, unlock)

    if self.db.autoMenu and not UnitAffectingCombat("player") then
      Portals:OpenMenu(button, unlock)
    else
      GameTooltip:SetOwner(button, 'ANCHOR_NONE')
      GameTooltip:SetPoint(Portals:GetTipAnchor(button))
      GameTooltip:ClearLines()

      GameTooltip:AddLine('Broker Portals')
      GameTooltip:AddDoubleLine(L['RCLICK'], L['SEE_SPELLS'], 0.9, 0.6, 0.2, 0.2, 1, 0.2)
      GameTooltip:AddDoubleLine(L['ALTCLICK'], L['MOVE_SPELLS'], 0.9, 0.6, 0.2, 0.2, 1, 0.2)
      GameTooltip:AddLine(' ')
      GameTooltip:AddDoubleLine(L['HEARTHSTONE'] .. ': ' .. GetBindLocation(), Portals:GetHearthCooldown(), 0.9, 0.6, 0.2, 0.2, 1,
        0.2)

      if self.db.showItemCooldowns then
        local cooldowns = Portals:GetItemCooldowns()
        if cooldowns ~= nil then
          GameTooltip:AddLine(' ')
          for name, cooldown in pairs(cooldowns) do
            GameTooltip:AddDoubleLine(name, cooldown, 0.9, 0.6, 0.2, 0.2, 1, 0.2)
          end
        end
      end

    GameTooltip:Show()
  end
end

local worldFrameHook
function Portals:OpenMenu(button, showUnlock)
  GameTooltip:Hide()
  dewdrop:Open(button,
  'point', function(parent)
    local point1, _, point2 = self:GetTipAnchor(button)
    return point1, point2
  end,
  'children', function(level, value)
      Portals:UpdateMenu(level, value, showUnlock)
  end)

  if not worldFrameHook then
    WorldFrame:HookScript("OnEnter", function()
        if dewdrop:IsOpen(button) then
            dewdrop:Close()
        end
    end)
    worldFrameHook = true
end
end