if not LibStub then return end

local dewdrop = LibStub('Dewdrop-2.0', true)
local icon = LibStub('LibDBIcon-1.0')

local math_floor = math.floor

local CreateFrame = CreateFrame
local GetContainerItemCooldown = GetContainerItemCooldown
local GetContainerItemLink = GetContainerItemLink
local GetContainerNumSlots = GetContainerNumSlots
local GetBindLocation = GetBindLocation
local GetInventoryItemCooldown = GetInventoryItemCooldown
local GetInventoryItemLink = GetInventoryItemLink
local GetSpellCooldown = GetSpellCooldown
local GetSpellInfo = GetSpellInfo
local GetSpellName = GetSpellName
local SendChatMessage = SendChatMessage
local UnitInRaid = UnitInRaid
local GetNumPartyMembers = GetNumPartyMembers

local xpaclist = { "CLASSIC", "TBC", "WRATH" };
local expac = xpaclist[GetAccountExpansionLevel() + 1];

local addonName, addonTable = ...
local L = addonTable.L
local fac = UnitFactionGroup('player')


-- IDs of items usable for transportation
local items = {
  -- Dalaran rings
  40586, -- Band of the Kirin Tor
  48954, -- Etched Band of the Kirin Tor
  48955, -- Etched Loop of the Kirin Tor
  48956, -- Etched Ring of the Kirin Tor
  48957, -- Etched Signet of the Kirin Tor
  45688, -- Inscribed Band of the Kirin Tor
  45689, -- Inscribed Loop of the Kirin Tor
  45690, -- Inscribed Ring of the Kirin Tor
  45691, -- Inscribed Signet of the Kirin Tor
  44934, -- Loop of the Kirin Tor
  44935, -- Ring of the Kirin Tor
  40585, -- Signet of the Kirin Tor
  51560, -- Runed Band of the Kirin Tor
  51558, -- Runed Loop of the Kirin Tor
  51559, -- Runed Ring of the Kirin Tor
  51557, -- Runed Signet of the Kirin Tor
  -- Engineering Gadgets
  30542, -- Dimensional Ripper - Area 52
  18984, -- Dimensional Ripper - Everlook
  18986, -- Ultrasafe Transporter: Gadgetzan
  30544, -- Ultrasafe Transporter: Toshley's Station
  48933, -- Wormhole Generator: Northrend
  -- Seasonal items
  37863, -- Direbrew's Remote
  21711, -- Lunar Festival Invitation
  -- Miscellaneous
  46874, -- Argent Crusader's Tabard
  32757, -- Blessed Medallion of Karabor
  35230, -- Darnarian's Scroll of Teleportation
  50287, -- Boots of the Bay
  52251, -- Jaina's Locket
}

-- IDs of items usable instead of hearthstone
local scrolls = {
  6948, -- Hearthstone
  1903515, -- Fel-Infused Gateway
  28585, -- Ruby Slippers
  44315, -- Scroll of Recall III
  44314, -- Scroll of Recall II
  37118 -- Scroll of Recall
}

-- Ascension: Scrolls of Defense
local sod = {
  83126, -- Ashenvale
  83128 -- Hillsbrad Foothills
}
-- Ascension: Scrolls of Retreat
local sor = nil
if fac == "Horde" then
  sor = 1175627 -- Orgrimmar
else
  sor = 1175626 -- Stormwind
end

obj = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(addonName, {
  type = 'data source',
  text = L['P'],
  icon = 'Interface\\Icons\\INV_Misc_Rune_06',
})
local obj = obj
local methods = {}
local portals = {}
local frame = CreateFrame('frame')

frame:SetScript('OnEvent', function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('SKILL_LINES_CHANGED')

local function pairsByKeys(t)
  local a = {}
  for n in pairs(t) do
    table.insert(a, n)
  end
  table.sort(a)

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

function findSpell(spellName)
  local i = 1
  while true do
    local s = GetSpellName(i, BOOKTYPE_SPELL)
    if not s then
      break
    end

    if s == spellName then
      return i
    end

    i = i + 1
  end
end

-- returns true, if player has item with given ID in inventory or bags and it's not on cooldown
local function hasItem(itemID)
  local item, found, id
  -- scan inventory
  for slotId = 1, 19 do
    item = GetInventoryItemLink('player', slotId)
    if item then
      found, _, id = item:find('^|c%x+|Hitem:(%d+):.+')
      if found and tonumber(id) == itemID then
        if GetInventoryItemCooldown('player', slotId) ~= 0 then
          return false
        else
          return true
        end
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
          if GetContainerItemCooldown(bag, slot) ~= 0 then
            return false
          else
            return true
          end
        end
      end
    end
  end

  return false
end

local function SetupSpells()
  local spells = {
    Alliance = {
      { 3561 }, -- TP:Stormwind
      { 3562 }, -- TP:Ironforge
      { 3565 }, -- TP:Darnassus
      { 32271 }, -- TP:Exodar
      { 49359 }, -- TP:Theramore
      { 33690 }, -- TP:Shattrath
      { 10059, 'TRUE' }, -- P:Stormwind
      { 11416, 'TRUE' }, -- P:Ironforge
      { 11419, 'TRUE' }, -- P:Darnassus
      { 32266, 'TRUE' }, -- P:Exodar
      { 49360, 'TRUE' }, -- P:Theramore
      { 33691, 'TRUE' }, -- P:Shattrath
    },
    Horde = {
      { 3563 }, -- TP:Undercity
      { 3566 }, -- TP:Thunder Bluff
      { 3567 }, -- TP:Orgrimmar
      { 32272 }, -- TP:Silvermoon
      { 49358 }, -- TP:Stonard
      { 35715 }, -- TP:Shattrath
      { 11418, 'TRUE' }, -- P:Undercity
      { 11420, 'TRUE' }, -- P:Thunder Bluff
      { 11417, 'TRUE' }, -- P:Orgrimmar
      { 32267, 'TRUE' }, -- P:Silvermoon
      { 49361, 'TRUE' }, -- P:Stonard
      { 35717, 'TRUE' }, -- P:Shattrath
    }
  }

  local _, class = UnitClass('player')
  if expac == "WRATH" then
    tinsert(portals, { 53140 }) -- TP:Dalaran
    tinsert(portals, { 53142, 'TRUE' }) -- P:Dalaran
  end
  if class == 'HERO' then
    if IsSpellKnown(818045) then
      portals = spells[fac]
    else
      portals = {};
    end
    tinsert(portals, { 18960 }) -- TP:Moonglade
    tinsert(portals, { 556 }) -- Astral Recall
  end
  if class == 'MAGE' then
    portals = spells[fac]
  elseif class == 'DEATHKNIGHT' then
    portals = {
      { 50977 } -- Death Gate
    }
  elseif class == 'DRUID' then
    portals = {
      { 18960 }
    }
  elseif class == 'SHAMAN' then
    portals = {
      { 556 }
    }
  end
  -- Ascension: Stones of Retreat
  if fac == "Horde" then
    tinsert(portals, { 777000 }) -- Orgrimmar
    tinsert(portals, { 777001 }) -- Undercity
    tinsert(portals, { 777002 }) -- Thunder Bluff
    tinsert(portals, { 177702 }) -- Camp Mojache
    tinsert(portals, { 777021 }) -- Bloodvenom Post
    tinsert(portals, { 1777027 }) -- Stonard
    tinsert(portals, { 1777037 }) -- Revantusk Village
    tinsert(portals, { 1777043 }) -- Shadowprey Village
  else
    tinsert(portals, { 777003 }) -- Stormwind
    tinsert(portals, { 777004 }) -- Darnassus
    tinsert(portals, { 777005 }) -- Ironforge
    tinsert(portals, { 1777044 }) -- Nijei's Point
    tinsert(portals, { 1777025 }) -- Feathermoon Stronghold
    tinsert(portals, { 1777026 }) -- Nethergarde Keep
    tinsert(portals, { 1777036 }) -- Aerie Peak
  end

  tinsert(portals, { 777006 }) -- Light's Hope
  tinsert(portals, { 777007 }) -- Everlook
  tinsert(portals, { 777008 }) -- Booty Bay
  tinsert(portals, { 777009 }) -- Gadgetzan
  tinsert(portals, { 777010 }) -- Ratchet
  tinsert(portals, { 777011 }) -- Thorium Point
  tinsert(portals, { 777012 }) -- Mudsprocket
  tinsert(portals, { 777013 }) -- Cenarion Hold
  tinsert(portals, { 777023 }) -- Azshara
  tinsert(portals, { 777020 }) -- Gurubashi Arena
  tinsert(portals, { 777024 }) -- Zul'Gurub
  tinsert(portals, { 777025 }) -- Blackrock Mountain
  tinsert(portals, { 777026 }) -- Gates of Ahn'Quiraj
  tinsert(portals, { 777027 }) -- Onyxia's Lair
  tinsert(portals, { 1777023 }) -- Yojamba Isle

  if expac == "TBC" then
    tinsert(portals, { 777016 }) -- Shattrath
    tinsert(portals, { 777017 }) -- Area 52
    tinsert(portals, { 777018 }) -- Altar of Sha'tar
    tinsert(portals, { 777019 }) -- Sanctum of the Stars
    tinsert(portals, { 102182 }) -- Cenarion Refuge
    tinsert(portals, { 102186 }) -- Ogri'la
    tinsert(portals, { 102196 }) -- Stormspire
    tinsert(portals, { 777008 }) -- Sanctum of the Stars
    tinsert(portals, { 777008 }) -- Altar of Sha'tar
    tinsert(portals, { 102180 }) -- Cenarion Refuge

    if fac == "Horde" then
      tinsert(portals, { 777014 }) -- Silvermoon City
      tinsert(portals, { 102197 }) -- Thrallmar
      tinsert(portals, { 102189 }) -- Shadowmoon Village
      tinsert(portals, { 102184 }) -- Garadar
      tinsert(portals, { 102190 }) -- Stonebreaker Hold
      tinsert(portals, { 102201 }) -- Zabra'jin
    else
      tinsert(portals, { 777015 }) -- The Exodar
      tinsert(portals, { 102185 }) -- Honor Hold
      tinsert(portals, { 102193 }) -- Telaar
      tinsert(portals, { 102178 }) -- Allerian Stronghold
      tinsert(portals, { 102187 }) -- Orebor Harborage
      tinsert(portals, { 102200 }) -- Wildhammer Stronghold
    end
  end

  -- Ascension: Runes of Retreat
  local runes = {
    { 979807 }, -- Flaming
    { 80133 }, -- Frostforged
    { 979806 }, -- Arcane
    { 979808 }, -- Freezing
    { 979809 }, -- Dark Rune
    { 979810 } -- Holy Rune
  }
  local runeRandom = {}
  for _, v in ipairs(runes) do
    if IsSpellKnown(v[1]) then
      tinsert(runeRandom, v[1])
    end
  end
  if #runeRandom > 0 then
    tinsert(portals, { runeRandom[math.random(1, #runeRandom)]})
  end
end

local function UpdateSpells()
  SetupSpells()
  local i = 0

  if portals then
    for _, v in ipairs(portals) do
      local spell, _, spellIcon = GetSpellInfo(v[1])
      local spellid = findSpell(spell)

      if spellid then
        if not PortalsDB.showPortals or not v[2] or (GetNumPartyMembers() > 0 or UnitInRaid("player")) then
          methods[spell] = {
            spellid = spellid,
            text = spell,
            spellIcon = spellIcon,
            isPortal = v[2],
            secure = {
              type = 'spell',
              spell = spell
            }
          }
          i = i + 1
        end
      end
    end
  end

  return i
end

local function UpdateIcon(icon)
  obj.icon = icon
end

local function GetHearthCooldown()
  local cooldown, startTime, duration

  if GetItemCount(6948) > 0 then
    startTime, duration = GetItemCooldown(6948)
    cooldown = duration - (GetTime() - startTime)
    if cooldown >= 60 then
      cooldown = math_floor(cooldown / 60)
      cooldown = cooldown .. ' ' .. L['MIN']
    elseif cooldown <= 0 then
      cooldown = L['READY']
    else
      cooldown = cooldown .. ' ' .. L['SEC']
    end
    return cooldown
  else
    return L['N/A']
  end
end

local function GetItemCooldowns()
  local cooldown, startTime, duration, cooldowns = nil, nil, nil, nil

  -- items
  for _, item in pairs(items) do
    if GetItemCount(item) > 0 then
      startTime, duration = GetItemCooldown(item)
      cooldown = duration - (GetTime() - startTime)
      if cooldown >= 60 then
        cooldown = math_floor(cooldown / 60)
        cooldown = cooldown .. ' ' .. L['MIN']
      elseif cooldown <= 0 then
        cooldown = L['READY']
      else
        cooldown = cooldown .. ' ' .. L['SEC']
      end
      local name = GetItemInfo(item)
      if cooldowns == nil then
        cooldowns = {}
      end
      cooldowns[name] = cooldown
    end
  end

  return cooldowns
end

local function ShowHearthstone()
  local text, secure, icon, name
  local bindLoc = GetBindLocation()

  for _, itemID in ipairs(scrolls) do
    if hasItem(itemID) then
      name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
      text = L['INN'] .. ' ' .. bindLoc
      secure = {
        type = 'item',
        item = name
      }
      dewdrop:AddLine(
        'text', text,
        'secure', secure,
        'icon', icon,
        'func', function() UpdateIcon(icon) end,
        'closeWhenClicked', true
      )
    end
  end
  dewdrop:AddLine()
end

local function ShowScrolls()
  local i = 0, secure

  for j = 1, #sod do
    local name, _, icon = GetSpellInfo(sod[j])
    if findSpell(name) then
      secure = {
        type = 'spell',
        spell = name,
      }
      dewdrop:AddLine(
        'text', name,
        'secure', secure,
        'icon', icon,
        'func', function() UpdateIcon(icon) end,
        'closeWhenClicked', true
      )
      i = i + 1
    end
  end

  if hasItem(sor) then
    local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(sor)
    secure = {
      type = 'item',
      item = name
    }
    dewdrop:AddLine(
      'text', name,
      'secure', secure,
      'icon', icon,
      'func', function() UpdateIcon(icon) end,
      'closeWhenClicked', true
    )
    i = i + 1
  end

  return i
end

local function ShowOtherItems()
  local i = 0, secure, icon, name

  for _, itemID in ipairs(items) do
    if hasItem(itemID) then
      name, _, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
      secure = {
        type = 'item',
        item = name
      }
      dewdrop:AddLine(
        'text', name,
        'secure', secure,
        'icon', icon,
        'func', function() UpdateIcon(icon) end,
        'closeWhenClicked', true
      )
      i = i + 1
    end
  end

  return i
end

local function ToggleMinimap()
  local hide = not PortalsDB.minimap.hide
  PortalsDB.minimap.hide = hide
  if hide then
    icon:Hide('Broker_Portals')
  else
    icon:Show('Broker_Portals')
  end
end

local function UpdateMenu(level, value)
  if level == 1 then
    dewdrop:AddLine(
      'text', 'Broker_Portals',
      'isTitle', true
    )

    methods = {}
    if UpdateSpells() > 0 then
      dewdrop:AddLine()
    end
    local chatType = PortalsDB.announceType
    if PortalsDB.announceType == "PARTYRAID" then
      chatType = (UnitInRaid("player") and "RAID") or (GetNumPartyMembers() > 0 and "PARTY")
    end
    for k, v in pairsByKeys(methods) do
      if v.secure and GetSpellCooldown(v.text) == 0 then
        dewdrop:AddLine(
          'text', v.text,
          'secure', v.secure,
          'icon', v.spellIcon,
          'func', function()
            UpdateIcon(v.spellIcon)
            if v.isPortal and chatType and PortalsDB.announce then
              SendChatMessage(L['ANNOUNCEMENT'] .. ' ' .. v.text, chatType)
            end
          end,
          'closeWhenClicked', true
        )
      end
    end

    dewdrop:AddLine()

    ShowHearthstone()

    if PortalsDB.showItems then
      if (ShowScrolls() + ShowOtherItems()) > 0 then dewdrop:AddLine() end
    end

    dewdrop:AddLine(
      'text', L['OPTIONS'],
      'hasArrow', true,
      'value', 'options'
    )

    dewdrop:AddLine(
      'text', CLOSE,
      'tooltipTitle', CLOSE,
      'tooltipText', CLOSE_DESC,
      'closeWhenClicked', true
    )
  elseif level == 2 and value == 'options' then
    dewdrop:AddLine(
      'text', L['SHOW_ITEMS'],
      'checked', PortalsDB.showItems,
      'func', function() PortalsDB.showItems = not PortalsDB.showItems end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['SHOW_ITEM_COOLDOWNS'],
      'checked', PortalsDB.showItemCooldowns,
      'func', function() PortalsDB.showItemCooldowns = not PortalsDB.showItemCooldowns end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['ATT_MINIMAP'],
      'checked', not PortalsDB.minimap.hide,
      'func', function() ToggleMinimap() end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['ANNOUNCE'],
      'checked', PortalsDB.announce,
      'func', function() PortalsDB.announce = not PortalsDB.announce end,
      'closeWhenClicked', true
    )
    if PortalsDB.announce then
      dewdrop:AddLine(
        'text', 'Announce in',
        'hasArrow', true,
        'value', 'announce'
      )
    end
    dewdrop:AddLine(
      'text', 'Show portals only in Party/Raid',
      'checked', PortalsDB.showPortals,
      'func', function() PortalsDB.showPortals = not PortalsDB.showPortals end,
      'closeWhenClicked', true
    )
  elseif level == 3 and value == 'announce' then
    dewdrop:AddLine(
      'text', 'Say',
      'checked', PortalsDB.announceType == 'SAY',
      'func', function() PortalsDB.announceType = 'SAY' end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', '|cffff0000Yell|r',
      'checked', PortalsDB.announceType == 'YELL',
      'func', function() PortalsDB.announceType = 'YELL' end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', '|cff00ffffParty|r/|cffff7f00Raid',
      'checked', PortalsDB.announceType == 'PARTYRAID',
      'func', function() PortalsDB.announceType = 'PARTYRAID' end,
      'closeWhenClicked', true
    )
  end
end

function frame:PLAYER_LOGIN()
  if (not PortalsDB) then
    PortalsDB = {}
    PortalsDB.minimap = {}
    PortalsDB.minimap.hide = false
    PortalsDB.showItems = true
    PortalsDB.showItemCooldowns = true
    PortalsDB.announce = false
  end
  if PortalsDB.announceType == nil then
    PortalsDB.announceType = 'PARTYRAID'
  end
  if PortalsDB.showPortals == nil then
    PortalsDB.showPortals = false
  end

  if icon then
    icon:Register('Broker_Portals', obj, PortalsDB.minimap)
  end

  self:UnregisterEvent('PLAYER_LOGIN')
end

function frame:SKILL_LINES_CHANGED()
  UpdateSpells()
end

-- All credit for this func goes to Tekkub and his picoGuild!
local function GetTipAnchor(frame)
  local x, y = frame:GetCenter()
  if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
  local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
  local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
  return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
end

function obj.OnClick(self, button)
  GameTooltip:Hide()
  if button == 'RightButton' then
    dewdrop:Open(self, 'children', function(level, value) UpdateMenu(level, value) end)
  end
end

function obj.OnLeave()
  GameTooltip:Hide()
end

function obj.OnEnter(self)
  GameTooltip:SetOwner(self, 'ANCHOR_NONE')
  GameTooltip:SetPoint(GetTipAnchor(self))
  GameTooltip:ClearLines()

  GameTooltip:AddLine('Broker Portals')
  GameTooltip:AddDoubleLine(L['RCLICK'], L['SEE_SPELLS'], 0.9, 0.6, 0.2, 0.2, 1, 0.2)
  GameTooltip:AddLine(' ')
  GameTooltip:AddDoubleLine(L['HEARTHSTONE'] .. ': ' .. GetBindLocation(), GetHearthCooldown(), 0.9, 0.6, 0.2, 0.2, 1,
    0.2)

  if PortalsDB.showItemCooldowns then
    local cooldowns = GetItemCooldowns()
    if cooldowns ~= nil then
      GameTooltip:AddLine(' ')
      for name, cooldown in pairs(cooldowns) do
        GameTooltip:AddDoubleLine(name, cooldown, 0.9, 0.6, 0.2, 0.2, 1, 0.2)
      end
    end
  end

  GameTooltip:Show()
end

-- slashcommand definition
SlashCmdList['BROKER_PORTALS'] = function() ToggleMinimap() end
SLASH_BROKER_PORTALS1 = '/portals'
