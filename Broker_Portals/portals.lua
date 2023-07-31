if not LibStub then return end

local dewdrop = LibStub('Dewdrop-2.0', true)
local icon = LibStub('LibDBIcon-1.0')

local math_floor = math.floor

local xpacLevel = GetAccountExpansionLevel() + 1;

local addonName, addonTable = ...
local L = addonTable.L
local fac = UnitFactionGroup('player')
local favoritesdb, activeProfile

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

-- Ascension: Stones of Retreat
--{ stoneID, faction, expansionNum, factionlock }
local stones = {
  Kalimdor = {
    expansion = 1,
    header = "Kalimdor",
    { 777007, "Neutral", 1 }, -- Everlook
    { 777009, "Neutral", 1 }, -- Gadgetzan
    { 777010, "Neutral", 1 }, -- Ratchet
    { 777012, "Neutral", 1 }, -- Mudsprocket
    { 777013, "Neutral", 1 }, -- Cenarion Hold
    { 777021, "Neutral", 1 }, -- Bloodvenom Post
    { 777023, "Neutral", 1 }, -- Azshara
    { 777026, "Neutral", 1 }, -- Gates of Ahn'Qiraj
    { 777027, "Neutral", 1 }, -- Onyxia's Lair
    { 1777024, "Neutral", 1 }, -- Camp Mojache
    { 1777025, "Neutral", 1 }, -- Feathermoon Stronghold
    { 1777045, "Neutral", 1 }, -- Marshal's Refuge
    { 1777058, "Neutral", 1 }, -- Emerald Sanctuary
    { 777004, "Alliance", 1 }, -- Darnassus
    { 777015, "Alliance", 1, true }, -- The Exodar
    { 1777044, "Alliance", 1 }, -- Nijel's Point
    { 1777046, "Alliance", 1 }, -- Thalanaar
    { 1777048, "Alliance", 1 }, -- Theramore Isle
    { 1777054, "Alliance", 1 }, -- Stonetalon Peak
    { 1777056, "Alliance", 1 }, -- Talrendis Point
    { 1777059, "Alliance", 1 }, -- Auberdine
    { 1777060, "Alliance", 1 }, -- Grove of the Ancients
    { 1777061, "Alliance", 1 }, -- Astranaar
    { 1777062, "Alliance", 1 }, -- Forest Song
    { 1777087, "Alliance", 1 }, -- Dolanaar
    { 777000, "Horde", 1, true }, -- Orgrimmar
    { 777002, "Horde", 1 }, -- Thunder Bluff
    { 1777043, "Horde", 1 }, -- Shadowprey Village
    { 1777047, "Horde", 1 }, -- Freewind Post
    { 1777049, "Horde", 1 }, -- Brackenwall Village
    { 1777050, "Horde", 1 }, -- Camp Taurajo
    { 1777051, "Horde", 1 }, -- The Crossroads
    { 1777052, "Horde", 1 }, -- Mor'shan Base Camp
    { 1777053, "Horde", 1 }, -- Sun Rock Retreat
    { 1777055, "Horde", 1 }, -- Ghost Walker Post
    { 1777057, "Horde", 1 }, -- Valormok
    { 1777063, "Horde", 1 }, -- Splintertree Post
    { 1777064, "Horde", 1 }, -- Zoram'gar Outpost
    { 1777088, "Horde", 1 }, -- Sen'jin Village
    { 1777089, "Horde", 1 }, -- Razor Hill
    { 1777090, "Horde", 1 }, -- Bloodhoof Village
  },

  EasternKingdoms = {
    expansion = 1,
    header = "Eastern Kingdoms",
    { 777006, "Neutral", 1 }, -- Light's Hope
    { 777008, "Neutral", 1 }, -- Booty Bay
    { 777011, "Neutral", 1 }, -- Thorium Point
    { 777020, "Neutral", 1 }, -- Gurubashi Arena
    { 777024, "Neutral", 1 }, -- Zul'Gurub
    { 777025, "Neutral", 1 }, -- Blackrock Mountain
    { 1777023, "Neutral", 1 }, -- Yojamba Isle
    { 1777070, "Neutral", 1 }, -- Nesingwary's Expedition
    { 1777080, "Neutral", 1 }, -- Faldir's Cove
    { 777003, "Alliance", 1, true }, -- Stormwind
    { 777005, "Alliance", 1 }, -- Ironforge
    { 1777026, "Alliance", 1 }, -- Nethergarde Keep
    { 1777036, "Alliance", 1 }, -- Aerie Peak
    { 1777065, "Alliance", 1 }, -- Darkshire
    { 1777066, "Alliance", 1 }, -- Eastvale Logging Camp
    { 1777067, "Alliance", 1 }, -- Sentinel Hill
    { 1777069, "Alliance", 1 }, -- Rebel Camp
    { 1777071, "Alliance", 1 }, -- Lakeshire
    { 1777072, "Alliance", 1 }, -- Morgan's Vigil
    { 1777074, "Alliance", 1 }, -- Hammertoe Digsite
    { 1777075, "Alliance", 1 }, -- Farstrider Lodge
    { 1777076, "Alliance", 1 }, -- Thelsamar
    { 1777077, "Alliance", 1 }, -- Menethil Harbor
    { 1777078, "Alliance", 1 }, -- Refuge Pointe
    { 1777081, "Alliance", 1 }, -- Southshore
    { 1777084, "Alliance", 1 }, -- Kharanos
    { 1777086, "Alliance", 1 }, -- Goldshire
    { 1777092, "Alliance", 1 }, -- The Harborage
    { 1777093, "Alliance", 1 }, -- Ambermill
    { 777001, "Horde", 1 }, -- Undercity
    { 777014, "Horde", 1, true }, -- Silvermoon City
    { 1777027, "Horde", 1 }, -- Stonard
    { 1777037, "Horde", 1 }, -- Revantusk Village
    { 1777068, "Horde", 1 }, -- Grom'gol Basecamp
    { 1777073, "Horde", 1 }, -- Kargath
    { 1777079, "Horde", 1 }, -- Hammerfall
    { 1777082, "Horde", 1 }, -- Tarren Mill
    { 1777083, "Horde", 1 }, -- The Sepulcher
    { 1777085, "Horde", 1 }, -- Brill
    { 1777091, "Horde", 1 }, -- Flame Crest
    { 1777094, "Horde", 1 }, -- The Bulwark
  },

  Outlands = {
    expansion = 2,
    header = "Outlands",
    { 102179, "Neutral", 1 }, -- Altar of Shatar
    { 102180, "Neutral", 1 }, -- Cenarion Refuge
    { 102181, "Neutral", 1 }, -- Cosmowrench
    { 102182, "Neutral", 1 }, -- Evergrove
    { 102183, "Neutral", 1 }, -- Falcon Watch
    { 102186, "Neutral", 1 }, -- Ogri'la
    { 102188, "Neutral", 1 }, -- Sanctum of the Stars
    { 102191, "Neutral", 1 }, -- Swamprat Post
    { 102192, "Neutral", 1 }, -- Sylvanaar
    { 102194, "Neutral", 1 }, -- Telredor
    { 102195, "Neutral", 1 }, -- Temple of Telhamat
    { 102196, "Neutral", 1 }, -- The Stormspire
    { 102198, "Neutral", 1 }, -- Thunderlord Stronghold
    { 102199, "Neutral", 1 }, -- Toshley's Station
    { 777016, "Neutral", 1 }, -- Shattrath
    { 777017, "Neutral", 1 }, -- Area 52
    { 777018, "Neutral", 1 }, -- Altar of Sha'tar
    { 777019, "Neutral", 1 }, -- Sanctum of the Stars
    { 777022, "Neutral", 1 }, -- Area 52
    { 102178, "Alliance", 1 }, -- Allerian Stronghold
    { 102185, "Alliance", 1 }, -- Honor Hold
    { 102187, "Alliance", 1 }, -- Orebor Harborage
    { 102193, "Alliance", 1 }, -- Telaar
    { 102200, "Alliance", 1 }, -- Wildhammer Stronghold
    { 102184, "Horde", 1 }, -- Garadar
    { 102189, "Horde", 1 }, -- Shadowmoon Village
    { 102190, "Horde", 1 }, -- Stonebreaker Hold
    { 102197, "Horde", 1 }, -- Thrallmar
    { 102201, "Horde", 1 }, -- Zabra'jin
  }

}

-- Ascension: Runes of Retreat
local runes = {
  979807, -- Flaming
  80133,  -- Frostforged
  979806, -- Arcane
  979808, -- Freezing
  979809, -- Dark Rune
  979810 -- Holy Rune
}

local hearthspells = {
  556, -- Astral Recall 
}

-- Ascension: Scrolls of Defense
local sod = {
  83126, -- Ashenvale
  83128 -- Hillsbrad Foothills
}

-- Ascension: Scrolls of Retreat
local sor = {
  Horde = 1175627, -- Orgrimmar
  Alliance = 1175626 -- Stormwind
}

local otherportals = {
  28148, -- P:Karazhan
  18960, -- TP:Moonglade
  50977, -- Death Gate
}


local obj = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject(addonName, {
  type = 'data source',
  text = L['P'],
  icon = 'Interface\\Icons\\INV_Misc_Rune_06',
})
local portals = {}
local frame = CreateFrame('frame')

frame:SetScript('OnEvent', function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
frame:RegisterEvent('PLAYER_LOGIN')

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

-- returns true, if player has item with given ID in inventory or bags and it's not on cooldown
local function hasItem(itemID)
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
          return true
        end
      end
    end
  end

  return false
end

local function SetupSpells()
  local spells = {
    Alliance = {
      { 3561 , false, 10059 }, -- TP:Stormwind
      { 3562 , false, 11416 }, -- TP:Ironforge
      { 3565 , false, 11419 }, -- TP:Darnassus
      { 32271, false, 32266 }, -- TP:Exodar
      { 49359, false, 49360 }, -- TP:Theramore
      { 33690, false, 33691 }, -- TP:Shattrath
      { 10059, true }, -- P:Stormwind
      { 11416, true }, -- P:Ironforge
      { 11419, true }, -- P:Darnassus
      { 32266, true }, -- P:Exodar
      { 49360, true }, -- P:Theramore
      { 33691, true }, -- P:Shattrath
    },
    Horde = {
      { 3563 , false, 11418 }, -- TP:Undercity
      { 3566 , false, 11420 }, -- TP:Thunder Bluff
      { 3567 , false, 11417 }, -- TP:Orgrimmar
      { 32272, false, 32267 }, -- TP:Silvermoon
      { 49358, false, 49361 }, -- TP:Stonard
      { 35715, false, 35717 }, -- TP:Shattrath
      { 11418, true }, -- P:Undercity
      { 11420, true }, -- P:Thunder Bluff
      { 11417, true }, -- P:Orgrimmar
      { 32267, true }, -- P:Silvermoon
      { 49361, true }, -- P:Stonard
      { 35717, true }, -- P:Shattrath
    }
  }

  local _, class = UnitClass('player')
  if class == 'HERO' then
    if CA_IsSpellKnown(818045) then
      portals = spells[fac]
      tinsert(portals, { 53140, false, 53142 }) -- TP:Dalaran
      tinsert(portals, { 53142, true }) -- P:Dalaran
    else
      portals = {};
    end
  elseif class == 'MAGE' then
    portals = spells[fac]
    tinsert(portals, { 53140, false, 53142 }) -- TP:Dalaran
    tinsert(portals, { 53142, true }) -- P:Dalaran
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
end

--used to add items or spells to the favorites
local function addFavorites(spellID, type, faction, factionLock, xpac, mage, isPortal, portalSpellID)
  if IsAltKeyDown() then
    if not faction then faction = "Neutral" end
    if favoritesdb[spellID] and favoritesdb[spellID][1] then
      favoritesdb[spellID] = {false}
    else
      favoritesdb[spellID] = {true, type, faction, factionLock, xpac, mage, isPortal, portalSpellID}
    end
  end
end

--set group headers with or without spacers
local function setHeader(text, headerSet, noSpacer)
  if headerSet then return true end
  if not noSpacer then dewdrop:AddLine() end
  dewdrop:AddLine(
    'text', text,
    'isTitle', true
  )
  return true
end

--get item/spell cooldown
local function getCooldown(ID, text, type)
  local startTime, duration
  if type == "item" then
    startTime, duration = GetItemCooldown(ID)
  else
    startTime, duration = GetSpellCooldown(text)
  end
  local cooldown = math.ceil(((duration - (GetTime() - startTime))/60))
  if cooldown > 0 then
    return text.." |cFF00FFFF("..cooldown.." ".. L['MIN'] .. ")"
  end
end

--main function used to add any items or spells to the drop down list
local function dewdropAdd(ID, type, faction, factionLock, xpac, mage, isPortal, swapPortal)
  local chatType = PortalsDB.announceType
  local name, icon

  if isPortal and PortalsDB.announceType == "PARTYRAID" then
    chatType = (UnitInRaid("player") and "RAID") or (GetNumPartyMembers() > 0 and "PARTY")
  end

  if type == "item" then
    name, _, _, _, _, _, _, _, _, icon = GetItemInfo(ID)
  elseif (PortalsDB.swapPortals and swapPortal and (GetNumPartyMembers() > 0 or UnitInRaid("player"))) then
    name, _, icon = GetSpellInfo(swapPortal)
  else
    name, _, icon = GetSpellInfo(ID)
  end

  local text = getCooldown(ID, name, type) or name
  local secure = {
    type1 = type,
    [type] = name,
  }
  dewdrop:AddLine(
    'text', text,
    'secure', secure,
    'icon', icon,
    'tooltipText',"Alt click to add/remove favorites",
    'func', function()
      addFavorites(ID, secure.type1, faction, factionLock, xpac, mage, isPortal, swapPortal)
      if isPortal and chatType and PortalsDB.announce then
        SendChatMessage(L['ANNOUNCEMENT'] .. ' ' .. name, chatType)
      end
      obj.icon = icon
    end,
    'closeWhenClicked', true
  )
end

--shows class teleports/portals
local function showClassSpells()
  SetupSpells()
  local methods = {}
  local headerSet = false
  if portals then
    for _, v in ipairs(portals) do
      if CA_IsSpellKnown(818045) and CA_IsSpellKnown(v[1]) and (not favoritesdb[v[1]] or not favoritesdb[v[1]][1]) then
        if not v[2] or (v[2] and not PortalsDB.showPortals and not PortalsDB.swapPortals) or (PortalsDB.showPortals and v[2] and not PortalsDB.swapPortals) and (GetNumPartyMembers() > 0 or UnitInRaid("player")) then
          headerSet = setHeader("Mage Portals", headerSet)
          local name = GetSpellInfo(v[1])
          methods[name] = {
            spellID = v[1],
            isPortal = v[2],
            portalSpellID = v[3],
          }
        end
      end
    end
  end
  for _, v in pairsByKeys(methods) do
    if (not favoritesdb[v.spellID] or not favoritesdb[v.spellID][1]) then
      dewdropAdd(v.spellID, "spell", nil, nil, nil, true, v.isPortal, v.portalSpellID)
    end
  end
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

--Hearthstone items and spells
local function ShowHearthstone()
  local headerSet = false
  for _, itemID in ipairs(scrolls) do
    if hasItem(itemID) and (not favoritesdb[itemID] or not favoritesdb[itemID][1]) then
      headerSet = setHeader("Hearthstone: "..GetBindLocation(), headerSet)
      dewdropAdd(itemID, "item")
    end
  end

  local runeRandom = {}
  for _, spellID in ipairs(runes) do
    if CA_IsSpellKnown(spellID) and (not favoritesdb[spellID] or not favoritesdb[spellID][1]) then
      tinsert(runeRandom, spellID)
    end
  end

  if #runeRandom > 0 then
    local spellID = runeRandom[math.random(1, #runeRandom)]
<<<<<<< Updated upstream
    if CA_IsSpellKnown(spellID) then
=======
    if IsSpellKnown(spellID) then
      headerSet = setHeader("Hearthstone: "..GetBindLocation(), headerSet)
>>>>>>> Stashed changes
      dewdropAdd(spellID, "spell")
    end
  end

  for _,spellID in ipairs(hearthspells) do
<<<<<<< Updated upstream
    if CA_IsSpellKnown(spellID) and (not favoritesdb[spellID] or not favoritesdb[spellID][1]) then
=======
    if IsSpellKnown(spellID) and (not favoritesdb[spellID] or not favoritesdb[spellID][1]) then
      headerSet = setHeader("Hearthstone: "..GetBindLocation(), headerSet)
>>>>>>> Stashed changes
      dewdropAdd(spellID, "spell")
    end
  end
end

--Stones of retreat
local function showStones(subMenu, spellCheck, noSpacer) --Kalimdor, true

  local function tableSort(zone)
    local sorted = {}
    local headerSet = false
      for _,v in ipairs(stones[zone]) do
					if (not favoritesdb[v[1]] or not favoritesdb[v[1]][1]) and not (v[4] and v[2] ~= fac ) and (xpacLevel >= v[3]) then --xpacLevel and locked cities check
						if PortalsDB.showEnemy or (v[2] == fac or v[2] == "Neutral") then --faction or showEnemy check
							--returns on the first found stone to turn the menu on
              if spellCheck and CA_IsSpellKnown(v[1]) then return true end
							if CA_IsSpellKnown(v[1]) then
                local name = GetSpellInfo(v[1])
                sorted[name] = {v[1], v[2], v[4], v[3]}
              end
						end
					end
      end
      table.sort(sorted)
      for _,v in pairsByKeys(sorted) do
        headerSet = setHeader(stones[zone].header, headerSet, noSpacer)
        dewdropAdd(v[1], "spell", v[2], v[3])
      end
  end

	local function addTable(zone)
		local spellCheck = tableSort(zone)
		if spellCheck then return true end
	end

	if subMenu == "All" then
		for continent, v in pairs(stones) do
			if xpacLevel >= v.expansion then
        addTable(continent);
      end
		end
	else
		return addTable(subMenu);
	end
end

--scrolls of defense and scrolls of retreat
local function ShowScrolls()
  local headerSet = false
  for _,spellID in ipairs(sod) do
    if CA_IsSpellKnown(spellID) and (not favoritesdb[spellID] or not favoritesdb[spellID][1]) then
      headerSet = setHeader("Scrolls Of Defense", headerSet)
      dewdropAdd(spellID, "spell")
    end
  end

  if hasItem(sor[fac]) and (not favoritesdb[sor[fac]] or not favoritesdb[sor[fac]][1]) then
    dewdropAdd(sor[fac], "item", fac, true)
  end
end

--other items things like Engineering teleport trinkets
local function ShowOtherItems()
  local headerSet = false
  for _, itemID in ipairs(items) do
    if hasItem(itemID) and (not favoritesdb[itemID] or not favoritesdb[itemID][1]) then
      headerSet = setHeader("Other Items", headerSet)
      dewdropAdd(itemID, "item")
    end
  end
end

local function ShowOtherPorts()
  local headerSet = false
  for _,spellID in ipairs(otherportals) do
    if CA_IsSpellKnown(spellID) and (not favoritesdb[spellID] or not favoritesdb[spellID][1]) then
      headerSet = setHeader("Other Teleports/Portals", headerSet)
      dewdropAdd(spellID, "spell")
    end
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

--show favorites at the top if there are any added to it
local function showFavorites()
  if favoritesdb then
    local headerSet = false
    local sorted = {}
    for ID ,v in pairs(favoritesdb) do
      if v[1] then
        local name
        if v[2] == "item" then
          name = GetItemInfo(ID)
        else
          name = GetSpellInfo(ID)
        end
        if CA_IsSpellKnown(ID) or hasItem(ID) then
          sorted[name] = {ID, v[2], v[3], v[4], v[5], v[6], v[7], v[8]}
        end
      end
    end
    table.sort(sorted)
    for _,v in pairsByKeys(sorted) do
      --addFavorites(spellID 1, type 2, fac 3, factionLock 4, xpac 5, mage 6, isPortal 7, portalSpellID 8)
      if not (v[4] and v[3] ~= fac ) and (not v[5] or xpacLevel >= v[5]) then --xpacLevel and locked cities check
        if PortalsDB.showEnemy or (v[3] == fac or v[3] == "Neutral") or v[6] then --faction or showEnemy check
          if  (v[6] and not v[7] and CA_IsSpellKnown(818045) and CA_IsSpellKnown(v[1])) or
              (v[6] and v[7] and PortalsDB.showPortals and not PortalsDB.swapPortals and CA_IsSpellKnown(818045) and CA_IsSpellKnown(v[1]) and ((GetNumPartyMembers() > 0 or UnitInRaid("player")))) or
              (v[6] and v[7] and not PortalsDB.showPortals and not PortalsDB.swapPortals and CA_IsSpellKnown(818045) and CA_IsSpellKnown(v[1])) or
              (not v[6] and CA_IsSpellKnown(v[1])) or hasItem(v[1]) then
                headerSet = setHeader("Favorites", headerSet)
                dewdropAdd(v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8])
          end
        end
      end
    end
  end
end

local function UpdateMenu(level, value)
  if level == 1 then
    dewdrop:AddLine(
      'text', 'Broker_Portals',
      'isTitle', true
    )
    showFavorites()

    if PortalsDB.stonesSubMenu then
      local mainHeaderSet = false
      --Adds menu if any stone in that category has been learned
			for continent, _ in pairs(stones) do
				if showStones(continent, true) then
        mainHeaderSet = setHeader("Stones Of Retreat", mainHeaderSet)
        dewdrop:AddLine(
        'text', continent,
        'hasArrow', true,
        'value', continent
        )
				end
			end
    else
      showStones("All")
    end

    showClassSpells()

    ShowHearthstone()

    ShowOtherPorts()

    if PortalsDB.showItems then
      ShowScrolls()
      ShowOtherItems()
    end

    dewdrop:AddLine()
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
  elseif level == 2 and value == 'Kalimdor' then
    showStones("Kalimdor", nil, true)
  elseif level == 2 and value == 'EasternKingdoms' then
    showStones("EasternKingdoms", nil, true)
  elseif level == 2 and value == 'Outlands' then
    showStones("Outlands", nil, true)
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
    dewdrop:AddLine(
      'text', 'Swap teleport to portal spells in Party/Raid',
      'checked', PortalsDB.swapPortals,
      'func', function() PortalsDB.swapPortals = not PortalsDB.swapPortals end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', 'Show Stones Of Retreats As Menus',
      'checked', PortalsDB.stonesSubMenu,
      'func', function() PortalsDB.stonesSubMenu = not PortalsDB.stonesSubMenu end,
      'closeWhenClicked', true
    )
		dewdrop:AddLine(
      'text', 'Show enemy faction Stones of Retreats',
      'checked', PortalsDB.showEnemy,
      'func', function() PortalsDB.showEnemy = not PortalsDB.showEnemy end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
        'text', "Favorites Profiles",
        'hasArrow', true,
        'value', "profile"
      )
  elseif level == 3 then 
    if value == 'announce' then
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
    elseif value == "profile" then
      local checked = false
      if activeProfile == "Default" then checked = true end
      dewdrop:AddLine(
            'text', "Default",
            'checked', checked,
            'tooltipText',"Default can not be removed.",
            'func', function()
                activeProfile = "Default"
                favoritesdb = PortalsDB.favorites[activeProfile]
            end,
            'closeWhenClicked', true
          )
      for profile, _ in pairs(PortalsDB.favorites) do
        local checked = false
        if profile ~= "Default" then
          if profile == activeProfile then checked = true end
          dewdrop:AddLine(
            'text', profile,
            'checked', checked,
            'tooltipText',"Alt click to remove.",
            'func', function()
              if IsAltKeyDown() then
                StaticPopupDialogs.BROKER_PORTALS_DELETE_PROFILE.profile = profile
                StaticPopup_Show("BROKER_PORTALS_DELETE_PROFILE")
              else
                activeProfile = profile
                favoritesdb = PortalsDB.favorites[activeProfile]
              end
            end,
            'closeWhenClicked', true
          )
        end
      end
        dewdrop:AddLine(
        'text', "Add Profile",
        'func', function() StaticPopup_Show("BROKER_PORTALS_ADD_PROFILE") end,
        'closeWhenClicked', true
        )
    end
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
  if not PortalsDB.announceType then PortalsDB.announceType = 'PARTYRAID' end
  if not PortalsDB.showPortals then PortalsDB.showPortals = false end
	if not PortalsDB.showEnemy then PortalsDB.showEnemy = false end
  if not PortalsDB.favorites then PortalsDB.favorites = {} end
  if not PortalsDB.favorites.Default then PortalsDB.favorites.Default = {} end
  if not PortalsDB.setProfile then PortalsDB.setProfile = {} end
  if not PortalsDB.setProfile[GetRealmName()] then PortalsDB.setProfile[GetRealmName()] = {} end
  if not PortalsDB.setProfile[GetRealmName()][UnitName("player")] then PortalsDB.setProfile[GetRealmName()][UnitName("player")] = "Default" end
  activeProfile = PortalsDB.setProfile[GetRealmName()][UnitName("player")]
  if not PortalsDB.favorites[activeProfile] then
    PortalsDB.setProfile[GetRealmName()][UnitName("player")] = "Default"
    activeProfile = "Default"
  end
  favoritesdb = PortalsDB.favorites[activeProfile] or PortalsDB.favorites["Default"]
  if icon then
    icon:Register('Broker_Portals', obj, PortalsDB.minimap)
  end

  self:UnregisterEvent('PLAYER_LOGIN')
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
  GameTooltip:AddDoubleLine(L['ALTCLICK'], L['MOVE_SPELLS'], 0.9, 0.6, 0.2, 0.2, 1, 0.2)
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

StaticPopupDialogs["BROKER_PORTALS_ADD_PROFILE"] = {
  text = "Add New Profile",
  button1 = "Confirm",
  button2 = "Cancel",
  hasEditBox = true,
  OnShow = function(self)
  self:SetFrameStrata("TOOLTIP");
end,
  OnAccept = function (self)
      local text = self.editBox:GetText()
      if text ~= "" then
        PortalsDB.favorites[text] = {}
        activeProfile = text
        favoritesdb = PortalsDB.favorites[activeProfile]
      end
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
  enterClicksFirstButton = true,
}

StaticPopupDialogs["BROKER_PORTALS_DELETE_PROFILE"] = {
  text = "Delete Profile?",
  button1 = "Confirm",
  button2 = "Cancel",
  OnShow = function(self)
  self:SetFrameStrata("TOOLTIP");
  end,
  OnAccept = function (self)
    local profile = StaticPopupDialogs.BROKER_PORTALS_DELETE_PROFILE.profile
    if activeProfile == profile then
      activeProfile = "Default"
      favoritesdb = PortalsDB.favorites[activeProfile]
    end
    PortalsDB.favorites[profile] = nil
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
  enterClicksFirstButton = true,
}