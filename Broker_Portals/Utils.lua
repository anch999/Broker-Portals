local Portals = LibStub("AceAddon-3.0"):GetAddon("BrokerPortals")

local cTip = CreateFrame("GameTooltip","cTooltip",nil,"GameTooltipTemplate")

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