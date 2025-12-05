local Portals = LibStub("AceAddon-3.0"):GetAddon("BrokerPortals")

-- Ascension: Stones of Retreat
--{ stoneID, faction, expansionNum, factionlock }
Portals.stones = {
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
      76918,-- Chillwind Camp
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
      777031, -- Karazhan
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
  
  Portals.stoneInfo = {
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
      [76918] = { fac = "Alliance", expac = 1 , zone = "Western Plaguelands" }, -- Light's Hope
      [777008] = { fac = "Neutral", expac = 1 , zone = "Stranglethorn Vale" }, -- Booty Bay
      [777011] = { fac = "Neutral", expac = 1 , zone = "Searing Gorge" }, -- Thorium Point
      [777020] = { fac = "Neutral", expac = 1 , zone = "Stranglethorn Vale" }, -- Gurubashi Arena
      [777024] = { fac = "Neutral", expac = 1 , zone = "Stranglethorn Vale" }, -- Zul'Gurub
      [777025] = { fac = "Neutral", expac = 1 , zone = "Burning Steppes" }, -- Blackrock Mountain
      [1777023] = { fac = "Neutral", expac = 1 , zone = "Stranglethorn Vale" }, -- Yojamba Isle
      [1777070] = { fac = "Neutral", expac = 1 , zone = "Stranglethorn Vale" }, -- Nesingwary's Expedition
      [1777080] = { fac = "Neutral", expac = 1 , zone = "Arathi Highlands" }, -- Faldir's Cove
      [777031] = { fac = "Neutral", expac = 1 , zone = "Deadwind Pass" }, -- Karazhan
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