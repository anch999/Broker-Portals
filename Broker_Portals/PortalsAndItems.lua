local Portals = LibStub("AceAddon-3.0"):GetAddon("BrokerPortals")

Portals.dontDeleteAfterCast = {
  [10] = "Flight Master's Whistle", -- Flight Master's Whistle
  [977028] = "Travel Permit",
}
-- IDs of items usable for transportation
Portals.items = {
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
  Portals.scrolls = {
    6948, -- Hearthstone
    1903515, -- Fel-Infused Gateway
    97758, -- Homebound portal
    28585, -- Ruby Slippers
    44315, -- Scroll of Recall III
    44314, -- Scroll of Recall II
    37118 -- Scroll of Recall
  }

  -- Ascension: Runes of Retreat
  Portals.runes = {
    979807, -- Flaming
    80133,  -- Frostforged
    979806, -- Arcane
    979808, -- Freezing
    979809, -- Dark Rune
    979810 -- Holy Rune
  }

  Portals.hearthspells = {
    556, -- Astral Recall
  }

  -- Ascension: Scrolls of Defense
  Portals.sod = {
    83126, -- Ashenvale
    83128 -- Hillsbrad Foothills
  }

  -- Ascension: Scrolls of Retreat
  Portals.sor = {
    Horde = 1175627, -- Orgrimmar
    Alliance = 1175626 -- Stormwind
  }

  Portals.otherportals = {
    28148, -- P:Karazhan
    18960, -- TP:Moonglade
    1518960, -- TP:Moonglade Vanity
    50977, -- Death Gate
    992030, -- Molten Core
    992032, -- Zul,grub
    992036, -- Ahn'Qiraj
    992034, -- Blackwing Lair
    992040, -- Onyxia's Lair
    992038 -- Naxxramas
  }