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

local addonName, addonTable = ...
local L = addonTable.L

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
  -- Ascension: Scrolls of Retreat
  1175626, -- Orgrimmar
  1175627 -- Stormwind
}

-- IDs of items usable instead of hearthstone
local scrolls = {
  6948, -- Hearthstone
  28585, -- Ruby Slippers
  44315, -- Scroll of Recall III
  44314, -- Scroll of Recall II
  37118 -- Scroll of Recall
}

obj = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(addonName, {
  type = 'data source',
  text = L['P'],
  icon = 'Interface\\Icons\\INV_Misc_Rune_06',
})
local obj = obj
local methods = {}
local portals = nil
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
      { 3561, 'TRUE' }, --TP:Stormwind
      { 3562, 'TRUE' }, --TP:Ironforge
      { 3565, 'TRUE' }, --TP:Darnassus
      { 32271, 'TRUE' }, --TP:Exodar
      { 49359, 'TRUE' }, --TP:Theramore
      { 33690, 'TRUE' }, --TP:Shattrath
      { 53140, 'TRUE' }, --TP:Dalaran
      { 10059, 'TRUE' }, --P:Stormwind
      { 11416, 'TRUE' }, --P:Ironforge
      { 11419, 'TRUE' }, --P:Darnassus
      { 32266, 'TRUE' }, --P:Exodar
      { 49360, 'TRUE' }, --P:Theramore
      { 33691, 'TRUE' }, --P:Shattrath
      { 53142, 'TRUE' } --P:Dalaran
    },
    Horde = {
      { 3563, 'TRUE' }, --TP:Undercity
      { 3566, 'TRUE' }, --TP:Thunder Bluff
      { 3567, 'TRUE' }, --TP:Orgrimmar
      { 32272, 'TRUE' }, --TP:Silvermoon
      { 49358, 'TRUE' }, --TP:Stonard
      { 35715, 'TRUE' }, --TP:Shattrath
      { 53140, 'TRUE' }, --TP:Dalaran
      { 11418, 'TRUE' }, --P:Undercity
      { 11420, 'TRUE' }, --P:Thunder Bluff
      { 11417, 'TRUE' }, --P:Orgrimmar
      { 32267, 'TRUE' }, --P:Silvermoon
      { 49361, 'TRUE' }, --P:Stonard
      { 35717, 'TRUE' }, --P:Shattrath
      { 53142, 'TRUE' } --P:Dalaran
    }
  }

  local _, class = UnitClass('player')
  if class == 'HERO' then
    local faction = UnitFactionGroup('player')
    portals = spells[faction]
    tinsert(portals, { 18960, 'TRUE' })
    tinsert(portals, { 556, 'TRUE' })
  end
  if class == 'MAGE' then
    local faction = UnitFactionGroup('player')
    portals = spells[faction]
  elseif class == 'DEATHKNIGHT' then
    portals = {
      { 50977, 'TRUE' } --Death Gate
    }
  elseif class == 'DRUID' then
    portals = {
      { 18960, 'TRUE' } --TP:Moonglade
    }
  elseif class == 'SHAMAN' then
    portals = {
      { 556, 'TRUE' } --Astral Recall
    }
  end
  -- Ascension: Stones of Retreat
  tinsert(portals, { 777000, 'TRUE' }) -- Orgrimmar
  tinsert(portals, { 777001, 'TRUE' }) -- Undercity
  tinsert(portals, { 777002, 'TRUE' }) -- Thunder Bluff
  tinsert(portals, { 777003, 'TRUE' }) -- Stormwind
  tinsert(portals, { 777004, 'TRUE' }) -- Darnassus
  tinsert(portals, { 777005, 'TRUE' }) -- Ironforge
  tinsert(portals, { 777006, 'TRUE' }) -- Light's Hope
  tinsert(portals, { 777007, 'TRUE' }) -- Everlook
  tinsert(portals, { 777008, 'TRUE' }) -- Booty Bay
  tinsert(portals, { 777009, 'TRUE' }) -- Gadgetzan
  tinsert(portals, { 777010, 'TRUE' }) -- Ratchet
  tinsert(portals, { 777011, 'TRUE' }) -- Thorium Point
  tinsert(portals, { 777012, 'TRUE' }) -- Mudsprocket
  tinsert(portals, { 777013, 'TRUE' }) -- Cenarion Hold
  tinsert(portals, { 777014, 'TRUE' }) -- Silvermoon City
  tinsert(portals, { 777015, 'TRUE' }) -- The Exodar
  tinsert(portals, { 777016, 'TRUE' }) -- Shattrath
  tinsert(portals, { 777017, 'TRUE' }) -- Area 52
  tinsert(portals, { 777018, 'TRUE' }) -- Altar of Sha'tar
  tinsert(portals, { 777019, 'TRUE' }) -- Sanctum of the Stars
  tinsert(portals, { 777020, 'TRUE' }) -- Gurubashi Arena
  tinsert(portals, { 777021, 'TRUE' }) -- Bloodvenom Post
  tinsert(portals, { 777022, 'TRUE' }) -- Area 52
  tinsert(portals, { 777023, 'TRUE' }) -- Azshara
  tinsert(portals, { 777024, 'TRUE' }) -- Zul'Gurub
  tinsert(portals, { 777025, 'TRUE' }) -- Blackrock Mountain
  tinsert(portals, { 777026, 'TRUE' }) -- Gates of Ahn'Quiraj
  tinsert(portals, { 777027, 'TRUE' }) -- Onyxia's Lair
  -- Ascension: Scrolls of Defense
  tinsert(portals, { 83126, 'TRUE' }) -- Ashenvale
  tinsert(portals, { 83128, 'TRUE' }) -- Hillsbrad Foothills
  spells = nil
end

local function UpdateSpells()
  if not portals then
    SetupSpells()
  end

  if portals then
    local reagentCache = {}
    reagentCache['TRUE'] = true

    for _, unTransSpell in ipairs(portals) do
      local spell, _, spellIcon = GetSpellInfo(unTransSpell[1])
      local spellid = findSpell(spell)

      if spellid and reagentCache[unTransSpell[2]] then
        methods[spell] = {
          spellid = spellid,
          text = spell,
          spellIcon = spellIcon,
          isPortal = unTransSpell[2] == 'TRUE',
          secure = {
            type = 'spell',
            spell = spell
          }
        }
      end
    end
  end
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
      break
    end
  end

  if secure ~= nil then
    dewdrop:AddLine(
      'text', text,
      'secure', secure,
      'icon', icon,
      'func', function() UpdateIcon(icon) end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine()
  end
end

local function ShowOtherItems()
  local secure, icon, name
  local i = 0

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
  if i > 0 then
    dewdrop:AddLine()
  end
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
    UpdateSpells()
    dewdrop:AddLine()
    local chatType = (UnitInRaid("player") and "RAID") or (GetNumPartyMembers() > 0 and "PARTY") or nil
    for k, v in pairsByKeys(methods) do
      if v.secure and GetSpellCooldown(v.text) == 0 then
        dewdrop:AddLine(
          'text', v.text,
          'secure', v.secure,
          'icon', v.spellIcon,
          'func', function()
            UpdateIcon(v.spellIcon)
            if v.isPortal and chatType then
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
      ShowOtherItems()
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
  end
end

function frame:PLAYER_LOGIN()
  -- PortalsDB.minimap is there for smooth upgrade of SVs from old version
  if (not PortalsDB) or (PortalsDB.version == nil) then
    PortalsDB = {}
    PortalsDB.minimap = {}
    PortalsDB.minimap.hide = false
    PortalsDB.showItems = true
    PortalsDB.showItemCooldowns = true
    PortalsDB.announce = false
    PortalsDB.version = 4
  end

  -- upgrade from versions
  if PortalsDB.version == 3 then
    PortalsDB.announce = false
    PortalsDB.version = 4
  elseif PortalsDB.version == 2 then
    PortalsDB.showItemCooldowns = true
    PortalsDB.announce = false
    PortalsDB.version = 4
  elseif PortalsDB.version < 2 then
    PortalsDB.showItems = true
    PortalsDB.showItemCooldowns = true
    PortalsDB.announce = false
    PortalsDB.version = 4
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
