if not LibStub then return end

local dewdrop = LibStub('Dewdrop-2.0', true)
local icon = LibStub('LibDBIcon-1.0')
local math_floor = math.floor
local aceTimer = LibStub('AceTimer-3.0')
local UpdateMenu

local xpacLevel = GetAccountExpansionLevel() + 1;

local addonName, addonTable = ...
local L = addonTable.L
local fac = UnitFactionGroup('player')
local favoritesdb, activeProfile
local hasItem

local UnknownList = {}
function aceTimer:learnUnknown()
  for i, v in pairs(UnknownList) do
    if not v then return end
    if not CA_IsSpellKnown(v) and not hasItem(i) then
      RequestDeliverVanityCollectionItem(i)
    else
      UnknownList[i] = nil
    end
  end
  aceTimer:ScheduleTimer("learnUnknown", .1)
end

local function learnUnknownStones()
  for _,v in pairs(VANITY_ITEMS) do
    if C_VanityCollection.IsCollectionItemOwned(v.itemid) and not CA_IsSpellKnown(v.learnedSpell) and v.name:match("Stone of Retreat") then
      UnknownList[v.itemid] = v.learnedSpell
    end
  end
  aceTimer:learnUnknown()
end

function aceTimer:learnUnknown()
  for i, v in pairs(UnknownList) do
    if not v then return end
    if not CA_IsSpellKnown(v) then
    RequestDeliverVanityCollectionItem(i)
    else
      UnknownList[i] = nil
    end
  end
  aceTimer:ScheduleTimer("learnUnknown", .1)
end

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
  10, -- Flight Master's Whistle
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
    777007, -- Everlook
    777009, -- Gadgetzan
    777010, -- Ratchet
    777012, -- Mudsprocket
    777013, -- Cenarion Hold
    777021, -- Bloodvenom Post
    777023, -- Azshara
    777026, -- Gates of Ahn'Qiraj
    777027, -- Onyxia's Lair
    1777024, -- Camp Mojache
    1777025, -- Feathermoon Stronghold
    1777045, -- Marshal's Refuge
    1777058, -- Emerald Sanctuary
    777004, -- Darnassus
    777015, -- The Exodar
    1777044, -- Nijel's Point
    1777046, -- Thalanaar
    1777048, -- Theramore Isle
    1777054, -- Stonetalon Peak
    1777056, -- Talrendis Point
    1777059, -- Auberdine
    1777060, -- Grove of the Ancients
    1777061, -- Astranaar
    1777062, -- Forest Song
    1777087, -- Dolanaar
    777000, -- Orgrimmar
    777002, -- Thunder Bluff
    1777043, -- Shadowprey Village
    1777047, -- Freewind Post
    1777049, -- Brackenwall Village
    1777050, -- Camp Taurajo
    1777051, -- The Crossroads
    1777052, -- Mor'shan Base Camp
    1777053, -- Sun Rock Retreat
    1777055, -- Ghost Walker Post
    1777057, -- Valormok
    1777063, -- Splintertree Post
    1777064, -- Zoram'gar Outpost
    1777088, -- Sen'jin Village
    1777089, -- Razor Hill
    1777090, -- Bloodhoof Village
  },

  EasternKingdoms = {
    expansion = 1,
    header = "Eastern Kingdoms",
    777006, -- Light's Hope
    777008, -- Booty Bay
    777011, -- Thorium Point
    777020, -- Gurubashi Arena
    777024, -- Zul'Gurub
    777025, -- Blackrock Mountain
    1777023, -- Yojamba Isle
    1777070, -- Nesingwary's Expedition
    1777080, -- Faldir's Cove
    777003, -- Stormwind
    777005, -- Ironforge
    1777026, -- Nethergarde Keep
    1777036, -- Aerie Peak
    1777065, -- Darkshire
    1777066, -- Eastvale Logging Camp
    1777067, -- Sentinel Hill
    1777069, -- Rebel Camp
    1777071, -- Lakeshire
    1777072, -- Morgan's Vigil
    1777074, -- Hammertoe Digsite
    1777075, -- Farstrider Lodge
    1777076, -- Thelsamar
    1777077, -- Menethil Harbor
    1777078, -- Refuge Pointe
    1777081, -- Southshore
    1777084, -- Kharanos
    1777086, -- Goldshire
    1777092, -- The Harborage
    1777093, -- Ambermill
    777001, -- Undercity
    777014, -- Silvermoon City
    1777027, -- Stonard
    1777037, -- Revantusk Village
    1777068, -- Grom'gol Basecamp
    1777073, -- Kargath
    1777079, -- Hammerfall
    1777082, -- Tarren Mill
    1777083, -- The Sepulcher
    1777085, -- Brill
    1777091, -- Flame Crest
    1777094, -- The Bulwark
  },

  Outlands = {
    expansion = 2,
    header = "Outlands",
    102179, -- Altar of Shatar
    102180, -- Cenarion Refuge
    102181, -- Cosmowrench
    102182, -- Evergrove
    102183, -- Falcon Watch
    102186, -- Ogri'la
    102188, -- Sanctum of the Stars
    102191, -- Swamprat Post
    102192, -- Sylvanaar
    102194, -- Telredor
    102195, -- Temple of Telhamat
    102196, -- The Stormspire
    102198, -- Thunderlord Stronghold
    102199, -- Toshley's Station
    777016, -- Shattrath
    777017, -- Area 52
    777018, -- Altar of Sha'tar
    777019, -- Sanctum of the Stars
    777022, -- Area 52
    102178, -- Allerian Stronghold
    102185, -- Honor Hold
    102187, -- Orebor Harborage
    102193, -- Telaar
    102200, -- Wildhammer Stronghold
    102184, -- Garadar
    102189, -- Shadowmoon Village
    102190, -- Stonebreaker Hold
    102197, -- Thrallmar
    102201, -- Zabra'jin
  },
  Northrend = {
    expansion = 3,
    header = "Northrend",
    76876, -- Warsong Hold
    76877, -- Valiance Keep
    76878, -- Coldarra
    76879, -- Unu'pe
    76880, -- Vengeance Landing
    76881, -- New Agamand
    76882, -- Utgarde Keep
    76883, -- Valgarde
    76884, -- Westguard Keep
    76885, -- Naxxramas (Dragonblight)
    76886, -- Wintergarde Keep
    76887, -- Wyrmrest Temple
    76888, -- Moa'ki Harbor
    76889, -- Agmar's Hammer
    76890, -- Azjol-Nerub
    76891, -- Venture Bay
    76892, -- Conquest Hold
    76893, -- Westfall Brigade Encampment
    76894, -- The Argent Stand
    76895, -- Drak'Tharon Keep
    76896, -- Gundrak
    76897, -- Ladeside Landing
    76898, -- Nesingwary Base Camp
    76899, -- Ulduar
    76900, -- K3
    76901, -- Grom'arsh Crash-Site
    76902, -- Frosthold
    76903, -- Brunnhildar Village
    76904, -- Dun Niffelem
    76905, -- Argent Tournament Grounds
    76906, -- The Shadow Vault
    76907, -- Blackwatch
    76908, -- Icecrown Citadel
    76909, -- The Argent Vanguard
    76910, -- Zim'Torga
    76911, -- Amberpine Lodge
    76912, -- Camp Oneqwah
    76913, -- Camp Winterhoof
    76914, -- Stars' Rest
    76915, -- Venomspite
    777028, -- Dalaran City
  }

}

local stoneInfo = {
    --Kalimdor
    [777007] = { fac = "Neutral", expac = 1 , zone = "Winterspring" }, -- Everlook
    [777009] = { fac = "Neutral", expac = 1 , zone = "Tanaris" }, -- Gadgetzan
    [777010] = { fac = "Neutral", expac = 1 , zone = "The Barrens" }, -- Ratchet
    [777012] = { fac = "Neutral", expac = 1 , zone = "Dustwallow Marsh" }, -- Mudsprocket
    [777013] = { fac = "Neutral", expac = 1 , zone = "Silithus" }, -- Cenarion Hold
    [777021] = { fac = "Neutral", expac = 1 , zone = "Felwood" }, -- Bloodvenom Post
    [777023] = { fac = "Neutral", expac = 1 , zone = "Azshara" }, -- Azshara
    [777026] = { fac = "Neutral", expac = 1 , zone = "Silithus" }, -- Gates of Ahn'Qiraj
    [777027] = { fac = "Neutral", expac = 1 , zone = "Onyxia's Lair" }, -- Onyxia's Lair
    [1777024] = { fac = "Horde", expac = 1 , zone = "Feralas" }, -- Camp Mojache
    [1777025] = { fac = "Alliance", expac = 1 , zone = "Feralas" }, -- Feathermoon Stronghold
    [1777045] = { fac = "Neutral", expac = 1 , zone = "Un'Goro Crater" }, -- Marshal's Refuge
    [1777058] = { fac = "Neutral", expac = 1 , zone = "Felwood" }, -- Emerald Sanctuary
    [777004] = { fac = "Alliance", expac = 1 , zone = "Teldrassil" }, -- Darnassus
    [777015] = { fac = "Alliance", expac = 2, zone = "Azuremyst Isle", factionLock = true }, -- The Exodar
    [1777044] = { fac = "Alliance", expac = 1 , zone = "Desolace" }, -- Nijel's Point
    [1777046] = { fac = "Alliance", expac = 1 , zone = "Feralas" }, -- Thalanaar
    [1777048] = { fac = "Alliance", expac = 1 , zone = "Dustwallow Marsh" }, -- Theramore Isle
    [1777054] = { fac = "Alliance", expac = 1 , zone = "Stonetalon Mountains" }, -- Stonetalon Peak
    [1777056] = { fac = "Alliance", expac = 1 , zone = "Azshara" }, -- Talrendis Point
    [1777059] = { fac = "Alliance", expac = 1 , zone = "Darkshore" }, -- Auberdine
    [1777060] = { fac = "Alliance", expac = 1 , zone = "Darkshore" }, -- Grove of the Ancients
    [1777061] = { fac = "Alliance", expac = 1 , zone = "Ashenvale" }, -- Astranaar
    [1777062] = { fac = "Alliance", expac = 1 , zone = "Ashenvale" }, -- Forest Song
    [1777087] = { fac = "Alliance", expac = 1 , zone = "Teldrassil" }, -- Dolanaar
    [777000] = { fac = "Horde", expac = 1, zone = "Durotar", factionLock = true }, -- Orgrimmar
    [777002] = { fac = "Horde", expac = 1 , zone = "Mulgore" }, -- Thunder Bluff
    [1777043] = { fac = "Horde", expac = 1 , zone = "Desolace" }, -- Shadowprey Village
    [1777047] = { fac = "Horde", expac = 1 , zone = "Thousand Needles" }, -- Freewind Post
    [1777049] = { fac = "Horde", expac = 1 , zone = "Dustwallow Marsh" }, -- Brackenwall Village
    [1777050] = { fac = "Horde", expac = 1 , zone = "The Barrens" }, -- Camp Taurajo
    [1777051] = { fac = "Horde", expac = 1 , zone = "The Barrens" }, -- The Crossroads
    [1777052] = { fac = "Horde", expac = 1 , zone = "The Barrens" }, -- Mor'shan Base Camp
    [1777053] = { fac = "Horde", expac = 1 , zone = "Stonetalon Mountains" }, -- Sun Rock Retreat
    [1777055] = { fac = "Horde", expac = 1 , zone = "Desolas" }, -- Ghost Walker Post
    [1777057] = { fac = "Horde", expac = 1 , zone = "Azshara" }, -- Valormok
    [1777063] = { fac = "Horde", expac = 1 , zone = "Ashenvale" }, -- Splintertree Post
    [1777064] = { fac = "Horde", expac = 1 , zone = "Ashenvale" }, -- Zoram'gar Outpost
    [1777088] = { fac = "Horde", expac = 1 , zone = "Durotar" }, -- Sen'jin Village
    [1777089] = { fac = "Horde", expac = 1 , zone = "Durotar" }, -- Razor Hill
    [1777090] = { fac = "Horde", expac = 1 , zone = "Mulgore" }, -- Bloodhoof Village
    --EasternKingdoms
    [777006] = { fac = "Neutral", expac = 1 , zone = "Eastern Plaguelands" }, -- Light's Hope
    [777008] = { fac = "Neutral", expac = 1 , zone = "Stranglethorn Vale" }, -- Booty Bay
    [777011] = { fac = "Neutral", expac = 1 , zone = "Searing Gorge" }, -- Thorium Point
    [777020] = { fac = "Neutral", expac = 1 , zone = "Stranglethorn Vale" }, -- Gurubashi Arena
    [777024] = { fac = "Neutral", expac = 1 , zone = "Stranglethorn Vale" }, -- Zul'Gurub
    [777025] = { fac = "Neutral", expac = 1 , zone = "Burning Steppes" }, -- Blackrock Mountain
    [1777023] = { fac = "Neutral", expac = 1 , zone = "Stranglethorn Vale" }, -- Yojamba Isle
    [1777070] = { fac = "Neutral", expac = 1 , zone = "Stranglethorn Vale" }, -- Nesingwary's Expedition
    [1777080] = { fac = "Neutral", expac = 1 , zone = "Arathi Highlands" }, -- Faldir's Cove
    [777003] = { fac = "Alliance", expac = 1, zone = "Elwynn Forest", factionLock = true }, -- Stormwind
    [777005] = { fac = "Alliance", expac = 1 , zone = "Dun Morogh" }, -- Ironforge
    [1777026] = { fac = "Alliance", expac = 1 , zone = "Blasted Lands" }, -- Nethergarde Keep
    [1777036] = { fac = "Alliance", expac = 1 , zone = "The Hinterlands" }, -- Aerie Peak
    [1777065] = { fac = "Alliance", expac = 1 , zone = "Duskwood" }, -- Darkshire
    [1777066] = { fac = "Alliance", expac = 1 , zone = "Elwynn Forest" }, -- Eastvale Logging Camp
    [1777067] = { fac = "Alliance", expac = 1 , zone = "Westfall" }, -- Sentinel Hill
    [1777069] = { fac = "Alliance", expac = 1 , zone = "Stranglethorn Vale" }, -- Rebel Camp
    [1777071] = { fac = "Alliance", expac = 1 , zone = "Redridge Mountains" }, -- Lakeshire
    [1777072] = { fac = "Alliance", expac = 1 , zone = "Burning Steppes" }, -- Morgan's Vigil
    [1777074] = { fac = "Alliance", expac = 1 , zone = "Badlands" }, -- Hammertoe Digsite
    [1777075] = { fac = "Alliance", expac = 1 , zone = "Loch Modan" }, -- Farstrider Lodge
    [1777076] = { fac = "Alliance", expac = 1 , zone = "Loch Modan" }, -- Thelsamar
    [1777077] = { fac = "Alliance", expac = 1 , zone = "Wetlands" }, -- Menethil Harbor
    [1777078] = { fac = "Alliance", expac = 1 , zone = "Arathi Highlands" }, -- Refuge Pointe
    [1777081] = { fac = "Alliance", expac = 1 , zone = "Hillsbrad Foothills" }, -- Southshore
    [1777084] = { fac = "Alliance", expac = 1 , zone = "Dun Morogh" }, -- Kharanos
    [1777086] = { fac = "Alliance", expac = 1 , zone = "Elwynn Forest" }, -- Goldshire
    [1777092] = { fac = "Alliance", expac = 1 , zone = "Swamp of Sorrows" }, -- The Harborage
    [1777093] = { fac = "Alliance", expac = 1 , zone = "Silverpine Forest" }, -- Ambermill
    [777001] = { fac = "Horde", expac = 1 , zone = "Tirisfal Glades" }, -- Undercity
    [777014] = { fac = "Horde", expac = 2, zone = "Eversong Woods", factionLock = true }, -- Silvermoon City
    [1777027] = { fac = "Horde", expac = 1 , zone = "Swamp of Sorrows" }, -- Stonard
    [1777037] = { fac = "Horde", expac = 1 , zone = "The Hinterlands" }, -- Revantusk Village
    [1777068] = { fac = "Horde", expac = 1 , zone = "Stranglethorn Vale" }, -- Grom'gol Basecamp
    [1777073] = { fac = "Horde", expac = 1 , zone = "Badlands" }, -- Kargath
    [1777079] = { fac = "Horde", expac = 1 , zone = "Arathi Highlands" }, -- Hammerfall
    [1777082] = { fac = "Horde", expac = 1 , zone = "Hillsbrad Foothills" }, -- Tarren Mill
    [1777083] = { fac = "Horde", expac = 1 , zone = "Silverpine Forest" }, -- The Sepulcher
    [1777085] = { fac = "Horde", expac = 1 , zone = "Tirisfal Glades" }, -- Brill
    [1777091] = { fac = "Horde", expac = 1 , zone = "Burning Steppes" }, -- Flame Crest
    [1777094] = { fac = "Horde", expac = 1 , zone = "Tirisfal Glades" }, -- The Bulwark
    --OutLands
    [102179] = { fac = "Neutral", expac = 2 , zone = "Shadowmoon Valley" }, -- Altar of Shatar
    [102180] = { fac = "Neutral", expac = 2 , zone = "Zangarmarsh" }, -- Cenarion Refuge
    [102181] = { fac = "Neutral", expac = 2 , zone = "Netherstorm" }, -- Cosmowrench
    [102182] = { fac = "Neutral", expac = 2 , zone = "Blade's Edge Mountains" }, -- Evergrove
    [102183] = { fac = "Neutral", expac = 2 , zone = "Hellfire Peninsula" }, -- Falcon Watch
    [102186] = { fac = "Neutral", expac = 2 , zone = "Blade's Edge Mountains" }, -- Ogri'la
    [102188] = { fac = "Neutral", expac = 2 , zone = "Shadowmoon Valley" }, -- Sanctum of the Stars
    [102191] = { fac = "Neutral", expac = 2 , zone = "Zangarmarsh" }, -- Swamprat Post
    [102192] = { fac = "Neutral", expac = 2 , zone = "Blade's Edge Mountains" }, -- Sylvanaar
    [102194] = { fac = "Neutral", expac = 2 , zone = "Zangarmarsh" }, -- Telredor
    [102195] = { fac = "Neutral", expac = 2 , zone = "Hellfire Peninsula" }, -- Temple of Telhamat
    [102196] = { fac = "Neutral", expac = 2 , zone = "Netherstorm" }, -- The Stormspire
    [102198] = { fac = "Neutral", expac = 2 , zone = "Blade's Edge Mountains" }, -- Thunderlord Stronghold
    [102199] = { fac = "Neutral", expac = 2 , zone = "Blade's Edge Mountains" }, -- Toshley's Station
    [777016] = { fac = "Neutral", expac = 2 , zone = "Terrokar Forest" }, -- Shattrath
    [777017] = { fac = "Neutral", expac = 2 , zone = "Netherstorm" }, -- Area 52
    [777018] = { fac = "Neutral", expac = 2 , zone = "Shadowmoon Valley" }, -- Altar of Sha'tar
    [777019] = { fac = "Neutral", expac = 2 , zone = "Shadowmoon Valley" }, -- Sanctum of the Stars
    [777022] = { fac = "Neutral", expac = 2 , zone = "Netherstorm" }, -- Area 52
    [102178] = { fac = "Alliance", expac = 2 , zone = "Terrokar Forest" }, -- Allerian Stronghold
    [102185] = { fac = "Alliance", expac = 2 , zone = "Hellfire Peninsula" }, -- Honor Hold
    [102187] = { fac = "Alliance", expac = 2 , zone = "Zangarmarsh" }, -- Orebor Harborage
    [102193] = { fac = "Alliance", expac = 2 , zone = "Nagrand" }, -- Telaar
    [102200] = { fac = "Alliance", expac = 2 , zone = "Shadowmoon Valley" }, -- Wildhammer Stronghold
    [102184] = { fac = "Horde", expac = 2 , zone = "Nagrand" }, -- Garadar
    [102189] = { fac = "Horde", expac = 2 , zone = "Shadowmoon Valley" }, -- Shadowmoon Village
    [102190] = { fac = "Horde", expac = 2 , zone = "Terrokar Forest" }, -- Stonebreaker Hold
    [102197] = { fac = "Horde", expac = 2 , zone = "Hellfire Peninsula" }, -- Thrallmar
    [102201] = { fac = "Horde", expac = 2 , zone = "Zangarmarsh" }, -- Zabra'jin
    --Northend
    [76876] = { fac = "Horde", expac = 3 , zone = "Borean Tundra" }, -- Warsong Hold
    [76877] = { fac = "Alliance", expac = 3 , zone = "Borean Tundra" }, -- Valiance Keep
    [76878] = { fac = "Neutral", expac = 3 , zone = "Coldarra" }, -- Coldarra
    [76879] = { fac = "Neutral", expac = 3 , zone = "Borean Tundra" }, -- Unu'pe
    [76880] = { fac = "Horde", expac = 3 , zone = "Howling Fjord" }, -- Vengeance Landing
    [76881] = { fac = "Horde", expac = 3 , zone = "Howling Fjord" }, -- New Agamand
    [76882] = { fac = "Neutral", expac = 3 , zone = "Howling Fjord" }, -- Utgarde Keep
    [76883] = { fac = "Alliance", expac = 3 , zone = "Howling Fjord" }, -- Valgarde
    [76884] = { fac = "Alliance", expac = 3 , zone = "Howling Fjord" }, -- Westguard Keep
    [76885] = { fac = "Neutral", expac = 3 , zone = "Dragonblight" }, -- Naxxramas (Dragonblight)
    [76886] = { fac = "Alliance", expac = 3 , zone = "Dragonblight" }, -- Wintergarde Keep
    [76887] = { fac = "Neutral", expac = 3 , zone = "Dragonblight" }, -- Wyrmrest Temple
    [76888] = { fac = "Neutral", expac = 3 , zone = "Dragonblight" }, -- Moa'ki Harbor
    [76889] = { fac = "Horde", expac = 3 , zone = "Dragonblight" }, -- Agmar's Hammer
    [76890] = { fac = "Neutral", expac = 3 , zone = "Azjol-Nerub" }, -- Azjol-Nerub
    [76891] = { fac = "Neutral", expac = 3 , zone = "Grizzly Hills" }, -- Venture Bay
    [76892] = { fac = "Horde", expac = 3 , zone = "Grizzly Hills" }, -- Conquest Hold
    [76893] = { fac = "Alliance", expac = 3 , zone = "Grizzly Hills" }, -- Westfall Brigade Encampment
    [76894] = { fac = "Alliance", expac = 3 , zone = "Zul'Drak" }, -- The Argent Stand
    [76895] = { fac = "Neutral", expac = 3 , zone = "Zul'Drak" }, -- Drak'Tharon Keep
    [76896] = { fac = "Neutral", expac = 3 , zone = "Zul'Drak" }, -- Gundrak
    [76897] = { fac = "Neutral", expac = 3 , zone = "Sholazar Basin" }, -- Lakeside Landing
    [76898] = { fac = "Neutral", expac = 3 , zone = "Sholazar Basin" }, -- Nesingwary Base Camp
    [76899] = { fac = "Neutral", expac = 3 , zone = "The Storm Peaks" }, -- Ulduar
    [76900] = { fac = "Neutral", expac = 3 , zone = "The Storm Peaks" }, -- K3
    [76901] = { fac = "Horde", expac = 3 , zone = "The Storm Peaks" }, -- Grom'arsh Crash-Site
    [76902] = { fac = "Alliance", expac = 3 , zone = "The Storm Peaks" }, -- Frosthold
    [76903] = { fac = "Neutral", expac = 3 , zone = "The Storm Peaks" }, -- Brunnhildar Village
    [76904] = { fac = "Neutral", expac = 3 , zone = "The Storm Peaks" }, -- Dun Niffelem
    [76905] = { fac = "Neutral", expac = 3 , zone = "Icecrown" }, -- Argent Tournament Grounds
    [76906] = { fac = "Neutral", expac = 3 , zone = "Icecrown" }, -- The Shadow Vault
    [76907] = { fac = "Neutral", expac = 3 , zone = "Icecrown" }, -- Blackwatch
    [76908] = { fac = "Neutral", expac = 3 , zone = "Icecrown" }, -- Icecrown Citadel
    [76909] = { fac = "Neutral", expac = 3 , zone = "Icecrown" }, -- The Argent Vanguard
    [76910] = { fac = "Neutral", expac = 3 , zone = "Zul'Drak" }, -- Zim'Torga
    [76911] = { fac = "Alliance", expac = 3 , zone = "Grizzly Hills" }, -- Amberpine Lodge
    [76912] = { fac = "Horde", expac = 3 , zone = "Grizzly Hills" }, -- Camp Oneqwah
    [76913] = { fac = "Horde", expac = 3 , zone = "Grizzly Hills" }, -- Camp Winterhoof
    [76914] = { fac = "Alliance", expac = 3 , zone = "Dragonblight" }, -- Stars' Rest
    [76915] = { fac = "Horde", expac = 3 , zone = "Dragonblight" }, -- Venomspite
    [777028] = { fac = "Neutral", expac = 3 , zone = "Crystalsong Forest" } -- Dalaran City
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
  1518960, -- TP:Moonglade Vanity
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
hasItem = function(itemID)
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
local function addFavorites(spellID, type, mage, isPortal, portalSpellID)
  if IsAltKeyDown() then
    if favoritesdb[spellID] and favoritesdb[spellID][1] then
      favoritesdb[spellID] = {false}
    else
      favoritesdb[spellID] = {true, type, mage, isPortal, portalSpellID}
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
local function dewdropAdd(ID, type, mage, isPortal, swapPortal)
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
  if stoneInfo[ID] then
    text = gsub(text, "Stone of Retreat", stoneInfo[ID].zone)
  end
  dewdrop:AddLine(
    'text', text,
    'secure', secure,
    'icon', icon,
    'tooltipText',"Alt click to add/remove favorites",
    'func', function()
      addFavorites(ID, secure.type1, mage, isPortal, swapPortal)
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
      dewdropAdd(v.spellID, "spell", true, v.isPortal, v.portalSpellID)
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
    if CA_IsSpellKnown(spellID) then
      headerSet = setHeader("Hearthstone: "..GetBindLocation(), headerSet)
      dewdropAdd(spellID, "spell")
    end
  end

  for _,spellID in ipairs(hearthspells) do
    if CA_IsSpellKnown(spellID) and (not favoritesdb[spellID] or not favoritesdb[spellID][1]) then
      headerSet = setHeader("Hearthstone: "..GetBindLocation(), headerSet)
      dewdropAdd(spellID, "spell")
    end
  end
end

--Stones of retreat
local function showStones(subMenu, spellCheck, noSpacer) --Kalimdor, true

  local function tableSort(zone)
    local sorted = {}
    local headerSet = false
      for ID,v in ipairs(stones[zone]) do
					if (not favoritesdb[v] or not favoritesdb[v][1]) and not (stoneInfo[v].factionLock and stoneInfo[v].fac ~= fac ) and (xpacLevel >= stoneInfo[v].expac) then --xpacLevel and locked cities check
						if PortalsDB.showEnemy or (stoneInfo[v].fac == fac or stoneInfo[v].fac == "Neutral") then --faction or showEnemy check
							--returns on the first found stone to turn the menu on
              if spellCheck and CA_IsSpellKnown(v) then return true end
							if CA_IsSpellKnown(v) then
                local name =  stoneInfo[v].zone
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
      for _,v in pairsByKeys(sorted) do
        headerSet = setHeader(stones[zone].header, headerSet, noSpacer)
        dewdropAdd(v[1], "spell")
      end
  end

	local function addTable(zone)
		local spellCheck = tableSort(zone)
		if spellCheck then return true end
	end

	if subMenu == "All" then
		for continent, v in pairs(stones) do
			if xpacLevel >= v.expansion then
        addTable(continent)
      end
		end
	else
		return addTable(subMenu)
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

local function ToggleMinimap(msg)
  if msg == "macromenu" then
    if dewdrop:IsOpen(GetMouseFocus()) then dewdrop:Close() return end
    dewdrop:Open(GetMouseFocus(), 'children', function(level, value) UpdateMenu(level, value) end)
  else
    local hide = not PortalsDB.minimap.hide
    PortalsDB.minimap.hide = hide
    if hide then
      icon:Hide('Broker_Portals')
    else
      icon:Show('Broker_Portals')
    end
  end
end

--show favorites at the top if there are any added to it
local function showFavorites()
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
          if CA_IsSpellKnown(ID) or hasItem(ID) then
            if stoneInfo[ID] then
              name = stoneInfo[ID].zone
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
    for _,v in pairsByKeys(sorted) do
      --addFavorites(spellID 1, type 2, mage 3, isPortal 4, portalSpellID 5)
      if not stoneInfo[v[1]] or (stoneInfo[v[1]] and not (stoneInfo[v[1]].factionLock and stoneInfo[v[1]].fac ~= fac ) and (xpacLevel >= stoneInfo[v[1]].expac)) then --xpacLevel and locked cities check
        if PortalsDB.showEnemy or (stoneInfo[v[1]].fac == fac or stoneInfo[v[1]].fac == "Neutral") or v[3] then --faction or showEnemy check
          if  ( v[3] and (not v[4] and CA_IsSpellKnown(818045) and CA_IsSpellKnown(v[1])) or
              (v[4] and PortalsDB.showPortals and not PortalsDB.swapPortals and CA_IsSpellKnown(818045) and CA_IsSpellKnown(v[1]) and ((GetNumPartyMembers() > 0 or UnitInRaid("player")))) or
              (v[4] and not PortalsDB.showPortals and not PortalsDB.swapPortals and CA_IsSpellKnown(818045) and CA_IsSpellKnown(v[1]))) or
              (not v[3] and CA_IsSpellKnown(v[1])) or hasItem(v[1]) then
                headerSet = setHeader("Favorites", headerSet, true)
                dewdropAdd(v[1], v[2], v[3], v[4], v[5])
          end
        end
      end
    end
  end
end

UpdateMenu = function(level, value)
  if level == 1 then
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
  elseif level == 2 and value == 'Northrend' then
    showStones("Northrend", nil, true)
  elseif level == 2 and value == 'options' then
    dewdrop:AddLine(
      'text', "Learn All Unknown Stones",
      'func', function() 
        learnUnknownStones()
      end,
      'closeWhenClicked', true
    )
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
    dewdrop:Open(self, 'children', function(level, value) UpdateMenu(level, value) end)
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
SlashCmdList['BROKER_PORTALS'] = function(msg) ToggleMinimap(msg) end
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
