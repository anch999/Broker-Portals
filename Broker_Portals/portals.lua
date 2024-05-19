local Portals = LibStub("AceAddon-3.0"):NewAddon("BrokerPortals", "AceTimer-3.0", "AceEvent-3.0")
BROKERPORTALS = Portals
local dewdrop = LibStub('Dewdrop-2.0', true)
local L = LibStub("AceLocale-3.0"):GetLocale("BrokerPortals")
Portals.defaultIcon = "Interface\\Icons\\INV_Misc_Rune_06"

local xpacLevel = GetAccountExpansionLevel() + 1;
local fac = UnitFactionGroup('player')
local favoritesdb, activeProfile

function Portals:SetupSpells()
  local portals = {}
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
  return portals
end

--used to add items or spells to the favorites
function Portals:AddFavorites(spellID, type, mage, isPortal, portalSpellID)
  if IsAltKeyDown() then
    if favoritesdb[spellID] and favoritesdb[spellID][1] then
      favoritesdb[spellID] = {false}
    else
      favoritesdb[spellID] = {true, type, mage, isPortal, portalSpellID}
    end
  end
end

--set group headers with or without spacers
function Portals:SetHeader(text, headerSet, noSpacer)
  if headerSet then return true end
  if not noSpacer then dewdrop:AddLine() end
  dewdrop:AddLine(
    'text', text,
    'isTitle', true
  )
  return true
end

--get item/spell cooldown
function Portals:GetCooldown(ID, text, type)
  local startTime, duration
  if type == "item" then
    startTime, duration = GetItemCooldown(ID)
  else
    startTime, duration = GetSpellCooldown(text)
  end
  if not startTime then return end
  local cooldown = math.ceil(((duration - (GetTime() - startTime))/60))
  if cooldown > 0 then
    return text.." |cFF00FFFF("..cooldown.." ".. L['MIN'] .. ")"
  end
end

--main function used to add any items or spells to the drop down list
function Portals:DewDropAdd(ID, Type, mage, isPortal, swapPortal)

  local chatType = self.db.announceType
  local name, icon

  if isPortal and self.db.announceType == "PARTYRAID" then
    chatType = (UnitInRaid("player") and "RAID") or (GetNumPartyMembers() > 0 and "PARTY")
  end

  if Type == "item" then
    name, _, _, _, _, _, _, _, _, icon = GetItemInfo(ID)
  elseif (self.db.swapPortals and swapPortal and (GetNumPartyMembers() > 0 or UnitInRaid("player"))) then
    name, _, icon = GetSpellInfo(swapPortal)
  else
    name, _, icon = GetSpellInfo(ID)
  end

  local text = Portals:GetCooldown(ID, name, Type) or name
  local secure = {
    type1 = Type,
    [Type] = name,
  }
  if Portals.stoneInfo[ID] then
    text = gsub(text, "Stone of Retreat", Portals.stoneInfo[ID].zone)
  end
  dewdrop:AddLine(
    'text', text,
    'secure', secure,
    'icon', icon,
    'tooltipText',"Alt click to add/remove favorites",
    'func', function()
      local hasVanity = CA_IsSpellKnown(ID) or Portals:HasItem(ID)
      if IsAltKeyDown() then
        Portals:AddFavorites(ID, secure.type1, mage, isPortal, swapPortal)
      elseif not hasVanity and C_VanityCollection.IsCollectionItemOwned(VANITY_SPELL_REFERENCE[ID] or ID) then
        RequestDeliverVanityCollectionItem(VANITY_SPELL_REFERENCE[ID] or ID)
      else
        if Type == "item" and self.db.deleteItem then
          self.deleteItem = ID
          self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        end
        dewdrop:Close()
      end
      if isPortal and chatType and self.db.announce then
        SendChatMessage(L['ANNOUNCEMENT'] .. ' ' .. name, chatType)
      end
      Portals:SetMapIcon(icon)
    end
  )
end

--shows class teleports/portals
function Portals:ShowClassSpells()
  local portals = Portals:SetupSpells()
  local methods = {}
  local headerSet = false
  if portals then
    for _, v in ipairs(portals) do
      if CA_IsSpellKnown(818045) and CA_IsSpellKnown(v[1]) and (not favoritesdb[v[1]] or not favoritesdb[v[1]][1]) then
        if not v[2] or (v[2] and not self.db.showPortals and not self.db.swapPortals) or (self.db.showPortals and v[2] and not self.db.swapPortals) and (GetNumPartyMembers() > 0 or UnitInRaid("player")) then
          headerSet = Portals:SetHeader("Mage Portals", headerSet)
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
  for _, v in Portals:PairsByKeys(methods) do
    if (not favoritesdb[v.spellID] or not favoritesdb[v.spellID][1]) then
      Portals:DewDropAdd(v.spellID, "spell", true, v.isPortal, v.portalSpellID)
    end
  end
end

function Portals:GetHearthCooldown()
  local cooldown, startTime, duration

  if GetItemCount(6948) > 0 then
    startTime, duration = GetItemCooldown(6948)
    cooldown = duration - (GetTime() - startTime)
    if cooldown >= 60 then
      cooldown = math.floor(cooldown / 60)
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

function Portals:GetItemCooldowns()
  local cooldown, startTime, duration, cooldowns = nil, nil, nil, nil

  -- items
  for _, item in pairs(Portals.items) do
    if GetItemCount(item) > 0 or C_VanityCollection.IsCollectionItemOwned(item) then
      startTime, duration = GetItemCooldown(item)
      cooldown = duration - (GetTime() - startTime)
      if cooldown >= 60 then
        cooldown = math.floor(cooldown / 60)
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
function Portals:ShowHearthstone()
  local headerSet = false 
  for _, itemID in ipairs(Portals.scrolls) do
    if (Portals:HasItem(itemID) or C_VanityCollection.IsCollectionItemOwned(itemID)) and (not favoritesdb[itemID] or not favoritesdb[itemID][1]) then
      headerSet = Portals:SetHeader("Hearthstone: "..GetBindLocation(), headerSet)
      Portals:DewDropAdd(itemID, "item")
    end
  end

  local runeRandom = {}
  for _, spellID in ipairs(Portals.runes) do
    if (CA_IsSpellKnown(spellID) or C_VanityCollection.IsCollectionItemOwned(VANITY_SPELL_REFERENCE[spellID] or spellID)) and (not favoritesdb[spellID] or not favoritesdb[spellID][1]) then
      tinsert(runeRandom, spellID)
    end
  end

  if #runeRandom > 0 then
    local spellID = runeRandom[math.random(1, #runeRandom)]
      headerSet = Portals:SetHeader("Hearthstone: "..GetBindLocation(), headerSet)
      Portals:DewDropAdd(spellID, "spell")
  end

  for _,spellID in ipairs(Portals.hearthspells) do
    if CA_IsSpellKnown(spellID) and (not favoritesdb[spellID] or not favoritesdb[spellID][1]) then
      headerSet = Portals:SetHeader("Hearthstone: "..GetBindLocation(), headerSet)
      Portals:DewDropAdd(spellID, "spell")
    end
  end
end

--Stones of retreat
function Portals:ShowStones(subMenu, spellCheck, noSpacer) --Kalimdor, true

  local function tableSort(zone)
    local sorted = {}
    local headerSet = false
      for ID,v in ipairs(Portals.stones[zone]) do
					if (not favoritesdb[v] or not favoritesdb[v][1]) and not (Portals.stoneInfo[v].factionLock and Portals.stoneInfo[v].fac ~= fac ) and (xpacLevel >= Portals.stoneInfo[v].expac) then --xpacLevel and locked cities check
						if self.db.showEnemy or (Portals.stoneInfo[v].fac == fac or Portals.stoneInfo[v].fac == "Neutral") then --faction or showEnemy check
							--returns on the first found stone to turn the menu on
              if spellCheck and CA_IsSpellKnown(v) then return true end
							if (CA_IsSpellKnown(v) or C_VanityCollection.IsCollectionItemOwned(VANITY_SPELL_REFERENCE[v] or v)) then
                local name =  Portals.stoneInfo[v].zone
                if sorted[name] then
                  name = name..ID
                  sorted[name] = {v}
                else
                  sorted[name] = {v}
                end
              end
						end
					end
      end
      table.sort(sorted)
      for _,v in Portals:PairsByKeys(sorted) do
        headerSet = Portals:SetHeader(Portals.stones[zone].header, headerSet, noSpacer)
        Portals:DewDropAdd(v[1], "spell")
      end
  end

	local function addTable(zone)
		local spellCheck = tableSort(zone)
		if spellCheck then return true end
	end

	if subMenu == "All" then
		for continent, v in pairs(Portals.stones) do
			if xpacLevel >= v.expansion then
        addTable(continent)
      end
		end
	else
		return addTable(subMenu)
	end
end

--scrolls of defense and scrolls of retreat
function Portals:ShowScrolls()
  local headerSet = false
  for _,spellID in ipairs(Portals.sod) do
    if (CA_IsSpellKnown(spellID) or C_VanityCollection.IsCollectionItemOwned(VANITY_SPELL_REFERENCE[spellID] or spellID)) and (not favoritesdb[spellID] or not favoritesdb[spellID][1]) then
      headerSet = Portals:SetHeader("Scrolls Of Defense", headerSet)
      Portals:DewDropAdd(spellID, "spell")
    end
  end
  if (Portals:HasItem(Portals.sor[fac]) or C_VanityCollection.IsCollectionItemOwned(Portals.sor[fac])) and (not favoritesdb[Portals.sor[fac]] or not favoritesdb[Portals.sor[fac]][1]) then
    Portals:DewDropAdd(Portals.sor[fac], "item", fac, true)
  end
end

--other items things like Engineering teleport trinkets
function Portals:ShowOtherItems()
  local headerSet = false
  for _, itemID in ipairs(Portals.items) do
    if (Portals:HasItem(itemID) or C_VanityCollection.IsCollectionItemOwned(itemID)) and (not favoritesdb[itemID] or not favoritesdb[itemID][1]) then
      headerSet = Portals:SetHeader("Other Items", headerSet)
      Portals:DewDropAdd(itemID, "item")
    end
  end
  if UnitLevel("player") <= 8 then
    local itemID = 977028
    if (Portals:HasItem(itemID) or C_VanityCollection.IsCollectionItemOwned(itemID)) and (not favoritesdb[itemID] or not favoritesdb[itemID][1]) then
      headerSet = Portals:SetHeader("Other Items", headerSet)
      Portals:DewDropAdd(itemID, "item")
    end
  end
end

function Portals:ShowOtherPorts()
  local headerSet = false
  for _,spellID in ipairs(Portals.otherportals) do
    if (CA_IsSpellKnown(spellID) or C_VanityCollection.IsCollectionItemOwned(VANITY_SPELL_REFERENCE[spellID] or spellID)) and (not favoritesdb[spellID] or not favoritesdb[spellID][1]) then
      headerSet = Portals:SetHeader("Other Teleports/Portals", headerSet)
      Portals:DewDropAdd(spellID, "spell")
    end
  end
end

--show favorites at the top if there are any added to it
function Portals:ShowFavorites()
  if favoritesdb then
    local headerSet = false
    local sorted = {}
    for ID ,v in pairs(favoritesdb) do
      if type(v) == "table" then
        if v[1] then
          local name
          if v[2] == "item" then
            name = GetItemInfo(ID)
          else
            name = GetSpellInfo(ID)
          end
          if CA_IsSpellKnown(ID) or Portals:HasItem(ID) then
            if Portals.stoneInfo[ID] then
              name = Portals.stoneInfo[ID].zone
            end
            if sorted[name] then
              name = name..ID
              sorted[name] = {ID, v[2], v[3], v[4], v[5]}
            else
              sorted[name] = {ID, v[2], v[3], v[4], v[5]}
            end
          end
        end
      end
    end
    table.sort(sorted)
    for _,v in Portals:PairsByKeys(sorted) do
      --Portals:AddFavorites(spellID 1, type 2, mage 3, isPortal 4, portalSpellID 5)
      if not Portals.stoneInfo[v[1]] or (Portals.stoneInfo[v[1]] and not (Portals.stoneInfo[v[1]].factionLock and Portals.stoneInfo[v[1]].fac ~= fac ) and (xpacLevel >= Portals.stoneInfo[v[1]].expac)) then --xpacLevel and locked cities check
        if self.db.showEnemy or (Portals.stoneInfo[v[1]].fac == fac or Portals.stoneInfo[v[1]].fac == "Neutral") or v[3] then --faction or showEnemy check
          if  ( v[3] and (not v[4] and CA_IsSpellKnown(818045) and CA_IsSpellKnown(v[1])) or
              (v[4] and self.db.showPortals and not self.db.swapPortals and CA_IsSpellKnown(818045) and CA_IsSpellKnown(v[1]) and ((GetNumPartyMembers() > 0 or UnitInRaid("player")))) or
              (v[4] and not self.db.showPortals and not self.db.swapPortals and CA_IsSpellKnown(818045) and CA_IsSpellKnown(v[1]))) or
              (not v[3] and CA_IsSpellKnown(v[1])) or Portals:HasItem(v[1]) then
                headerSet = Portals:SetHeader("Favorites", headerSet, true)
                Portals:DewDropAdd(v[1], v[2], v[3], v[4], v[5])
          end
        end
      end
    end
  end
end

function Portals:UpdateMenu(level, value)
  if level == 1 then
    Portals:ShowFavorites()

    if self.db.stonesSubMenu then
      local mainHeaderSet = false
      --Adds menu if any stone in that category has been learned
			for continent, _ in pairs(Portals.stones) do
				if Portals:ShowStones(continent, true) then
        mainHeaderSet = Portals:SetHeader("Stones Of Retreat", mainHeaderSet)
        dewdrop:AddLine(
        'text', continent,
        'hasArrow', true,
        'value', continent
        )
				end
			end
    else
      Portals:ShowStones("All")
    end

    Portals:ShowClassSpells()

    Portals:ShowHearthstone()

    Portals:ShowOtherPorts()

    if self.db.showItems then
      Portals:ShowScrolls()
      Portals:ShowOtherItems()
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
    Portals:ShowStones("Kalimdor", nil, true)
  elseif level == 2 and value == 'EasternKingdoms' then
    Portals:ShowStones("EasternKingdoms", nil, true)
  elseif level == 2 and value == 'Outlands' then
    Portals:ShowStones("Outlands", nil, true)
  elseif level == 2 and value == 'Northrend' then
    Portals:ShowStones("Northrend", nil, true)
  elseif level == 2 and value == 'options' then
    dewdrop:AddLine(
      'text', "Learn All Unknown Stones",
      'func', function() 
        Portals:LearnUnknownStones()
      end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['SHOW_ITEMS'],
      'checked', self.db.showItems,
      'func', function() self.db.showItems = not self.db.showItems end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['SHOW_ITEM_COOLDOWNS'],
      'checked', self.db.showItemCooldowns,
      'func', function() self.db.showItemCooldowns = not self.db.showItemCooldowns end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['ATT_MINIMAP'],
      'checked', not self.db.minimap.hide,
      'func', function() Portals:ToggleMinimap() end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', L['ANNOUNCE'],
      'checked', self.db.announce,
      'func', function() self.db.announce = not self.db.announce end,
      'closeWhenClicked', true
    )
    if self.db.announce then
      dewdrop:AddLine(
        'text', 'Announce in',
        'hasArrow', true,
        'value', 'announce'
      )
    end
    dewdrop:AddLine(
      'text', 'Show portals only in Party/Raid',
      'checked', self.db.showPortals,
      'func', function() self.db.showPortals = not self.db.showPortals end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', 'Swap teleport to portal spells in Party/Raid',
      'checked', self.db.swapPortals,
      'func', function() self.db.swapPortals = not self.db.swapPortals end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', 'Show Stones Of Retreats As Menus',
      'checked', self.db.stonesSubMenu,
      'func', function() self.db.stonesSubMenu = not self.db.stonesSubMenu end,
      'closeWhenClicked', true
    )
		dewdrop:AddLine(
      'text', 'Show enemy faction Stones of Retreats',
      'checked', self.db.showEnemy,
      'func', function() self.db.showEnemy = not self.db.showEnemy end,
      'closeWhenClicked', true
    )
    dewdrop:AddLine(
      'text', 'Auto delete vanity items after they have been used',
      'checked', self.db.deleteItem,
      'func', function() self.db.deleteItem = not self.db.deleteItem end,
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
        'checked', self.db.announceType == 'SAY',
        'func', function() self.db.announceType = 'SAY' end,
        'closeWhenClicked', true
      )
      dewdrop:AddLine(
        'text', '|cffff0000Yell|r',
        'checked', self.db.announceType == 'YELL',
        'func', function() self.db.announceType = 'YELL' end,
        'closeWhenClicked', true
      )
      dewdrop:AddLine(
        'text', '|cff00ffffParty|r/|cffff7f00Raid',
        'checked', self.db.announceType == 'PARTYRAID',
        'func', function() self.db.announceType = 'PARTYRAID' end,
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
                favoritesdb = self.db.favorites[activeProfile]
            end,
            'closeWhenClicked', true
          )
      for profile, _ in pairs(self.db.favorites) do
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
                favoritesdb = self.db.favorites[activeProfile]
                self.db.setProfile[GetRealmName()][UnitName("player")] = activeProfile
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

function Portals:OnInitialize()
  if (not PortalsDB) then
    PortalsDB = {}
    PortalsDB.minimap = {}
    PortalsDB.minimap.hide = false
    PortalsDB.showItems = true
    PortalsDB.showItemCooldowns = true
    PortalsDB.announce = false
  end
  self.db = PortalsDB
  if not self.db.announceType then self.db.announceType = 'PARTYRAID' end
  if not self.db.showPortals then self.db.showPortals = false end
	if not self.db.showEnemy then self.db.showEnemy = false end
  if not self.db.favorites then self.db.favorites = {} end
  if not self.db.favorites.Default then self.db.favorites.Default = {} end
  if not self.db.setProfile then self.db.setProfile = {} end
  if not self.db.setProfile[GetRealmName()] then self.db.setProfile[GetRealmName()] = {} end
  if not self.db.setProfile[GetRealmName()][UnitName("player")] then self.db.setProfile[GetRealmName()][UnitName("player")] = "Default" end
  activeProfile = self.db.setProfile[GetRealmName()][UnitName("player")]
  if not self.db.favorites[activeProfile] then
    self.db.setProfile[GetRealmName()][UnitName("player")] = "Default"
    activeProfile = "Default"
  end
  favoritesdb = self.db.favorites[activeProfile] or self.db.favorites["Default"]
  if not favoritesdb.version then favoritesdb.version = 0 end
  if favoritesdb.version == 0 then
    for _, db in pairs(favoritesdb) do
      if type(db) == "table" then
        db[3] = db[6]
        db[4] = db[7]
        db[5] = db[8]
        db[6] = nil
        db[7] = nil
        db[8] = nil
        db[9] = nil
        end
    end
    favoritesdb.version = 0.01
  end
end

function Portals:OnEnable()
  self:RegisterEvent("GOSSIP_SHOW")
  self:InitializeMinimap()
end

function Portals:UNIT_SPELLCAST_SUCCEEDED(event, arg1, arg2)
	self:RemoveItem(arg2)
end

-- slashcommand definition
SlashCmdList['BROKER_PORTALS'] = function(msg) Portals:ToggleMinimap(msg) end
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
