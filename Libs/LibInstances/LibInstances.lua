local lib, oldminor = LibStub:NewLibrary("LibInstances", 1)

-- Already loaded
if not lib then
    return
end

local groups
local infos
local Instances = {}

function lib:GetInfos()
    return infos
end

function lib:GetInfo(id)
    return infos[id]
end

function Instances:new(info)
    setmetatable(info, self)
    self.__index = self
    return info
end

function Instances:getSizes()
    return self.sizes
end

function Instances:getExpansion(size)
    if self.legacy and self.legacy.size == size then
        return self.legacy.expansion
    end
    return self.expansion
end

-- This may change in the future if instances with the same size get legacy-ed...
function Instances:getLegacySize()
    return self.legacy and self.legacy.size or nil
end

function Instances:getResetInterval(size)
    local interval = self.resets[size]
    assert(interval, string.format("Unknown size for: ID=%s size=%s", self.id, size))
    return interval
end

function Instances:getLastBossIndex()
    return self.lastBossIndex
end

function Instances:getEncounters()
    return self.encounters
end

-- This doesn't make sense for zones with subzones (like Scarlet Monastery and Dire Maul)
function Instances:getActivityId(size, difficulty)
    local activities = (self.activities[size] or {})
    local activityId = activities[math.min(difficulty, #activities)]
    return activityId
end

function Instances:getEncountersKilledByIndex(index)
    local instanceId = select(14, GetSavedInstanceInfo(index))
    assert(self.id == instanceId, string.format("GetSavedInstanceInfo InstanceID does not match: ExpectedID=%s, ID=%s Index%s", self.id, instanceId, index))
    local encountersKilled = {}
    for k, _ in pairs(self.encounters) do
        encountersKilled[k] = select(3, GetSavedInstanceEncounterInfo(index, k))
    end
    return encountersKilled
end

function lib:getEncountersKilledByInstanceId()
    for i=1, GetNumSavedInstances() do
        local id = select(14, GetSavedInstanceInfo(i))
        if id == self.id then
            return lib:getEncountersKilledByIndex(i)
        end
    end
    local encountersKilled = {}
    for k, _ in pairs(self.encounters) do
        encountersKilled[k] = 0
    end
    return encountersKilled
end

function lib:getGroupName(id)
    return groups[id]
end

groups = {
    [1] = "Classic Dungeons",
    [2] = "Burning Crusade Normal",
    [3] = "Burning Crusade Heroic",
    [4] = "Wrath of the Lich King Normal",
    [5] = "Wrath of the Lich King Heroic",
    [6] = "Classic Raid",
    [7] = "Burning Crusade Raid",
    [8] = "Wrath of the Lich King Raid (10)",
    [9] = "Wrath of the Lich King Raid (25)",
    [11] = "World Events",
    [174] = "Titan Rune Dungeon Protocol Gamma",
    [175] = "Titan Rune Dungeon Protocol Beta",
    [176] = "Titan Rune Dungeon Protocol Alpha",
}

infos = {
    [33] = {
        activities = { [1] = 8, [11] = 288, },
        encounters = { "Rethilgore", "Razorclaw the Butcher", "Baron Silverlaine", "Commander Springvale", "Odo the Blindwatcher", "Fenrus the Devourer", "Wolf Master Nandos", "Archmage Arugal" },
        expansion = 0,
        lastBossIndex = 8,
        resets = {},
        sizes = {},
    },
    [34] = {
        activities = { [1] = 12, },
        encounters = { "Targorr the Dread", "Kam Deepfury", "Hamhock", "Dextren Ward", "Bazil Thredd" },
        expansion = 0,
        lastBossIndex = 5,
        resets = {},
        sizes = {},
    },
    [36] = {
        activities = { [1] = 6, },
        encounters = { "Rhahk'zor", "Sneed", "Gilnid", "Mr. Smite", "Cookie", "Captain Greenskin", "Edwin VanCleef" },
        expansion = 0,
        lastBossIndex = 7,
        resets = {},
        sizes = {},
    },
    [43] = {
        activities = { [1] = 1, },
        encounters = { "Lady Anacondra", "Lord Cobrahn", "Kresh", "Lord Pythas", "Skum", "Lord Serpentis", "Verdan the Everliving", "Mutanus the Devourer" },
        expansion = 0,
        lastBossIndex = 8,
        resets = {},
        sizes = {},
    },
    [47] = {
        activities = { [1] = 16, },
        encounters = { "Roogug", "Death Speaker Jargba", "Aggem Thorncurse", "Overlord Ramtusk", "Agathelos the Raging", "Charlga Razorflank" },
        expansion = 0,
        lastBossIndex = 6,
        resets = {},
        sizes = {},
    },
    [48] = {
        activities = { [1] = 10, },
        encounters = { "Ghamoo-ra", "Lady Sarevess", "Gelihast", "Lorgus Jett", "Old Serra'kis", "Twilight Lord Kelris", "Aku'mai" },
        expansion = 0,
        lastBossIndex = 7,
        resets = {},
        sizes = {},
    },
    [70] = {
        activities = { [1] = 22, },
        encounters = { "Revelosh", "The Lost Dwarves", "Ironaya", "Ancient Stone Keeper", "Galgann Firehammer", "Grimlok", "Archaedas" },
        expansion = 0,
        lastBossIndex = 7,
        resets = {},
        sizes = {},
    },
    [90] = {
        activities = { [1] = 14, },
        encounters = { "Grubbis", "Viscous Fallout", "Electrocutioner 6000", "Crowd Pummeler 9-60", "Mekgineer Thermaplugg" },
        expansion = 0,
        lastBossIndex = 5,
        resets = {},
        sizes = {},
    },
    [109] = {
        activities = { [1] = 28, },
        encounters = { "Avatar of Hakkar", "Jammal'an the Prophet", "Dreamscythe", "Weaver", "Morphaz", "Hazzas", "Shade of Eranikus" },
        expansion = 0,
        lastBossIndex = 7,
        resets = {},
        sizes = {},
    },
    [129] = {
        activities = { [1] = 20, },
        encounters = { "Tuten'kash", "Mordresh Fire Eye", "Glutton", "Amnennar the Coldbringer" },
        expansion = 0,
        lastBossIndex = 4,
        resets = {},
        sizes = {},
    },
    [189] = {
        activities = { [1] = 165, [11] = 285, },
        encounters = { "Interrogator Vishas", "Bloodmage Thalnos", "Houndmaster Loksey", "Arcanist Doan", "Herod", "High Inquisitor Fairbanks", "High Inquisitor Whitemane" },
        expansion = 0,
        lastBossIndex = 7,
        resets = {},
        sizes = {},
    },
    [209] = {
        activities = { [1] = 24, },
        encounters = { "Hydromancer Velratha", "Ghaz'rilla", "Antu'sul", "Theka the Martyr", "Witch Doctor Zum'rah", "Nekrum Gutchewer", "Shadowpriest Sezz'ziz", "Chief Ukorz Sandscalp" },
        expansion = 0,
        lastBossIndex = 8,
        resets = {},
        sizes = {},
    },
    [229] = {
        activities = { [1] = 44, },
        encounters = { "Highlord Omokk", "Shadow Hunter Vosh'gajin", "War Master Voone", "Mother Smolderweb", "Urok Doomhowl", "Quartermaster Zigris", "Halycon", "Gizrul the Slavener", "Overlord Wyrmthalak", "Pyroguard Emberseer", "Solakar Flamewreath", "Warchief Rend Blackhand", "The Beast", "General Drakkisath" },
        expansion = 0,
        lastBossIndex = 14,
        resets = {},
        sizes = {},
    },
    [230] = {
        activities = { [1] = 276, [11] = 287, },
        encounters = { "High Interrogator Gerstahn", "Lord Roccor", "Houndmaster Grebmar", "Ring of Law", "Pyromancer Loregrain", "Lord Incendius", "Warder Stilgiss", "Fineous Darkvire", "Bael'Gar", "General Angerforge", "Golem Lord Argelmach", "Hurley Blackbreath", "Phalanx", "Ribbly Screwspigot", "Plugger Spazzring", "Ambassador Flamelash", "The Seven", "Magmus", "Emperor Dagran Thaurissan" },
        expansion = 0,
        lastBossIndex = 19,
        resets = {},
        sizes = {},
    },
    [249] = {
        activities = { [8] = 46, [9] = 257, },
        encounters = { "Onyxia" },
        expansion = 2,
        lastBossIndex = 1,
        legacy = { expansion = 0, size = 40, },
        resets = { [10] = 7, [25] = 7, [40] = 5, },
        sizes = { 10, 25, 40 },
    },
    [269] = {
        activities = { [2] = 171, [3] = 182, },
        encounters = { "Aeonus", "Chrono Lord Deja", "Temporus" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [289] = {
        activities = { [1] = 2, },
        encounters = { "Darkmaster Gandling", "Doctor Theolen Krastinov", "Instructor Malicia", "Jandice Barov", "Kirtonos", "Lady Illucia Barov", "Lord Alexei Barov", "Lorekeeper Polkelt", "Marduk Blackpool", "Ras Frostwhisperer", "Rattlegore", "The Ravenian", "Vectus" },
        expansion = 0,
        lastBossIndex = 13,
        resets = {},
        sizes = {},
    },
    [309] = {
        activities = { [6] = 42, },
        encounters = { "High Priestess Jeklik", "High Priest Venoxis", "High Priestess Mar'li", "Bloodlord Mandokir", "Edge of Madness", "High Priest Thekal", "Gahz'ranka", "High Priestess Arlokk", "Jin'do the Hexxer", "Hakkar" },
        expansion = 0,
        lastBossIndex = 10,
        resets = { [20] = 3, },
        sizes = { 20 },
    },
    [329] = {
        activities = { [1] = 274, },
        encounters = { "Hearthsinger Forresten", "Timmy the Cruel", "Commander Malor", "Willey Hopebreaker", "Instructor Galford", "Balnazzar", "The Unforgiven", "Baroness Anastari", "Nerub'enkan", "Maleki the Pallid", "Magistrate Barthilas", "Ramstein the Gorger", "Lord Aurius Rivendare" },
        expansion = 0,
        lastBossIndex = 13,
        resets = {},
        sizes = {},
    },
    [349] = {
        activities = { [1] = 273, },
        encounters = { "Noxxion", "Razorlash", "Tinkerer Gizlock", "Lord Vyletongue", "Celebras the Cursed", "Landslide", "Rotgrip", "Princess Theradras" },
        expansion = 0,
        lastBossIndex = 8,
        resets = {},
        sizes = {},
    },
    [389] = {
        activities = { [1] = 4, },
        encounters = { "Oggleflint", "Jergosh the Invoker", "Bazzalan", "Taragaman the Hungerer" },
        expansion = 0,
        lastBossIndex = 4,
        resets = {},
        sizes = {},
    },
    [409] = {
        activities = { [6] = 48, },
        encounters = { "Lucifron", "Magmadar", "Gehennas", "Garr", "Shazzrah", "Baron Geddon", "Sulfuron Harbinger", "Golemagg the Incinerator", "Majordomo Executus", "Ragnaros" },
        expansion = 0,
        lastBossIndex = 10,
        resets = { [40] = 7, },
        sizes = { 40 },
    },
    [429] = {
        activities = { [1] = 38, },
        encounters = { "Zevrim Thornhoof", "Hydrospawn", "Lethtendris", "Alzzin the Wildshaper", "Tendris Warpwood", "Illyanna Ravenoak", "Magister Kalendris", "Immol'thar", "Prince Tortheldrin", "Guard Mol'dar", "Stomper Kreeg", "Guard Fengus", "Guard Slip'kik", "Captain Kromcrush", "Cho'Rush the Observer", "King Gordok" },
        expansion = 0,
        lastBossIndex = 16,
        resets = {},
        sizes = {},
    },
    [469] = {
        activities = { [6] = 50, },
        encounters = { "Razorgore the Untamed", "Vaelastrasz the Corrupt", "Broodlord Lashlayer", "Firemaw", "Ebonroc", "Flamegor", "Chromaggus", "Nefarian" },
        expansion = 0,
        lastBossIndex = 8,
        resets = { [40] = 7, },
        sizes = { 40 },
    },
    [509] = {
        activities = { [6] = 160, },
        encounters = { "Kurinnaxx", "General Rajaxx", "Moam", "Buru the Gorger", "Ayamiss the Hunter", "Ossirian the Unscarred" },
        expansion = 0,
        lastBossIndex = 6,
        resets = { [20] = 3, },
        sizes = { 20 },
    },
    [531] = {
        activities = { [6] = 161, },
        encounters = { "The Prophet Skeram", "Silithid Royalty", "Battleguard Sartura", "Fankriss the Unyielding", "Viscidus", "Princess Huhuran", "Twin Emperors", "Ouro", "C'thun" },
        expansion = 0,
        lastBossIndex = 9,
        resets = { [40] = 7, },
        sizes = { 40 },
    },
    [532] = {
        activities = { [7] = 175, },
        encounters = { "Attumen the Huntsman", "Moroes", "Maiden of Virtue", "Opera Hall", "The Curator", "Terestian Illhoof", "Shade of Aran", "Netherspite", "Chess Event", "Prince Malchezaar", "Nightbane" },
        expansion = 1,
        lastBossIndex = 11,
        resets = { [10] = 7, },
        sizes = { 10 },
    },
    [533] = {
        activities = { [8] = 159, [9] = 227, },
        encounters = { "Anub'Rekhan", "Grand Widow Faerlina", "Maexxna", "Noth the Plaguebringer", "Heigan the Unclean", "Loatheb", "Instructor Razuvious", "Gothik the Harvester", "The Four Horsemen", "Patchwerk", "Grobbulus", "Gluth", "Thaddius", "Sapphiron", "Kel'Thuzad" },
        expansion = 2,
        lastBossIndex = 15,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [534] = {
        activities = { [7] = 195, },
        encounters = { "Rage Winterchill", "Anetheron", "Kaz'rogal", "Azgalor", "Archimonde" },
        expansion = 1,
        lastBossIndex = 5,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [540] = {
        activities = { [2] = 138, [3] = 189, },
        encounters = { "Blood Guard Porung", "Grand Warlock Nethekurse", "Warbringer O'mrogg", "Warchief Kargath Bladefist" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [542] = {
        activities = { [2] = 137, [3] = 187, },
        encounters = { "The Maker", "Keli'dan the Breaker", "Broggok" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [543] = {
        activities = { [2] = 136, [3] = 188, },
        encounters = { "Omor the Unscarred", "Vazruden the Herald", "Watchkeeper Gargolmar" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [544] = {
        activities = { [7] = 176, },
        encounters = { "Magtheridon" },
        expansion = 1,
        lastBossIndex = 1,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [545] = {
        activities = { [2] = 147, [3] = 185, },
        encounters = { "Hydromancer Thespia", "Mekgineer Steamrigger", "Warlord Kalithresh" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [546] = {
        activities = { [2] = 146, [3] = 186, },
        encounters = { "Ghaz'an", "Hungarfen", "Swamplord Musel'ek", "The Black Stalker" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [547] = {
        activities = { [2] = 140, [3] = 184, [11] = 286, },
        encounters = { "Mennu the Betrayer", "Quagmirran", "Rokmar the Crackler" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [548] = {
        activities = { [7] = 194, },
        encounters = { "Hydross the Unstable", "The Lurker Below", "Leotheras the Blind", "Fathom-Lord Karathress", "Morogrim Tidewalker", "Lady Vashj" },
        expansion = 1,
        lastBossIndex = 6,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [550] = {
        activities = { [7] = 193, },
        encounters = { "Al'ar", "Void Reaver", "High Astromancer Solarian", "Kael'thas Sunstrider" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [552] = {
        activities = { [2] = 174, [3] = 190, },
        encounters = { "Dalliah the Doomsayer", "Harbinger Skyriss", "Wrath-Scryer Soccothrates", "Zereketh the Unbound" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [553] = {
        activities = { [2] = 173, [3] = 191, },
        encounters = { "Commander Sarannis", "High Botanist Freywinn", "Laj", "Thorngrin the Tender", "Warp Splinter" },
        expansion = 1,
        lastBossIndex = 5,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [554] = {
        activities = { [2] = 172, [3] = 192, },
        encounters = { "Nethermancer Sepethrea", "Pathaleon the Calculator", "Mechano-Lord Capacitus", "Gatewatcher Gyro-Kill", "Gatewatcher Iron-Hand" },
        expansion = 1,
        lastBossIndex = 5,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [555] = {
        activities = { [2] = 151, [3] = 181, },
        encounters = { "Ambassador Hellmaw", "Blackheart the Inciter", "Murmur", "Grandmaster Vorpil" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [556] = {
        activities = { [2] = 150, [3] = 180, },
        encounters = { "Talon King Ikiss", "Darkweaver Syth", "Anzu" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [557] = {
        activities = { [2] = 148, [3] = 179, },
        encounters = { "Nexus-Prince Shaffar", "Pandemonius", "Yor", "Tavarok" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [558] = {
        activities = { [2] = 149, [3] = 178, },
        encounters = { "Exarch Maladaar", "Shirrak the Dead Watcher" },
        expansion = 1,
        lastBossIndex = 2,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [560] = {
        activities = { [2] = 170, [3] = 183, },
        encounters = { "Lieutenant Drake", "Epoch Hunter", "Captain Skarloc" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [564] = {
        activities = { [7] = 196, },
        encounters = { "High Warlord Naj'entus", "Supremus", "Shade of Akama", "Teron Gorefiend", "Gurtogg Bloodboil", "Reliquary of Souls", "Mother Shahraz", "The Illidari Council", "Illidan Stormrage" },
        expansion = 1,
        lastBossIndex = 9,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [565] = {
        activities = { [7] = 177, },
        encounters = { "High King Maulgar", "Gruul the Dragonkiller" },
        expansion = 1,
        lastBossIndex = 2,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [568] = {
        activities = { [7] = 197, },
        encounters = { "Akil'zon", "Nalorakk", "Jan'alai", "Halazzi", "Hex Lord Malacrass", "Zul'jin" },
        expansion = 1,
        lastBossIndex = 6,
        resets = { [10] = 7, },
        sizes = { 10 },
    },
    [574] = {
        activities = { [4] = 202, [5] = 242, [174] = 2448, [175] = 2474, [176] = 2491, },
        encounters = { "Prince Keleseth", "Skarvold & Dalronn", "Ingvar the Plunderer" },
        expansion = 2,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [575] = {
        activities = { [4] = 203, [5] = 205, [174] = 2453, [175] = 2479, [176] = 2489, },
        encounters = { "Svala Sorrowgrave", "Gortok Palehoof", "Skadi the Ruthless", "King Ymiron" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [576] = {
        activities = { [4] = 225, [5] = 226, [174] = 2450, [175] = 2477, [176] = 2492, },
        encounters = { "Grand Magus Telestra", "Anomalus", "Ormorok the Tree-Shaper", "Keristrasza" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [578] = {
        activities = { [4] = 206, [5] = 211, [174] = 2451, [175] = 2482, [176] = 2497, },
        encounters = { "Drakos the Interrogator", "Varos Cloudstrider", "Mage-Lord Urom", "Ley-Guardian Eregos" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [580] = {
        activities = { [7] = 199, },
        encounters = { "Kalecgos", "Brutallus", "Felmyst", "Eredar Twins", "M'uru", "Kil'jaeden" },
        expansion = 1,
        lastBossIndex = 6,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [585] = {
        activities = { [2] = 198, [3] = 201, },
        encounters = { "Kael'thas Sunstrider", "Priestess Delrissa", "Selin Fireheart", "Vexallus" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [595] = {
        activities = { [4] = 209, [5] = 210, [174] = 2449, [175] = 2472, [176] = 2493, },
        encounters = { "Meathook", "Salram the Fleshcrafter", "Chrono-Lord Epoch", "Mal'ganis" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [599] = {
        activities = { [4] = 208, [5] = 213, [174] = 2460, [175] = 2473, [176] = 2488, },
        encounters = { "Krystallus", "Maiden of Grief", "Tribunal of Ages", "Sjonnir the Ironshaper" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [600] = {
        activities = { [4] = 214, [5] = 215, [174] = 2457, [175] = 2481, [176] = 2496, },
        encounters = { "Trollgore", "Novos the Summoner", "King Dred", "The Prophet Tharon'ja" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [601] = {
        activities = { [4] = 204, [5] = 241, [174] = 2456, [175] = 2483, [176] = 2494, },
        encounters = { "Krik'thir the Gatewatcher", "Hadronox", "Anub'arak" },
        expansion = 2,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [602] = {
        activities = { [4] = 207, [5] = 212, [174] = 2459, [175] = 2480, [176] = 2487, },
        encounters = { "General Bjarngrim", "Volkhan", "Ionar", "Loken" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [603] = {
        activities = { [8] = 243, [9] = 244, },
        encounters = { "Flame Leviathan", "Ignis the Furnace Master", "Razorscale", "XT-002 Deconstructor", "The Iron Council", "Kologarn", "Auriaya", "Hodir", "Thorim", "Freya", "Mimiron", "General Vezax", "Yogg-Saron", "Algalon the Observer" },
        expansion = 2,
        lastBossIndex = 14,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [604] = {
        activities = { [4] = 216, [5] = 217, [174] = 2458, [175] = 2478, [176] = 2490, },
        encounters = { "Slad'ran", "Drakkari Colossus", "Moorabi", "Gal'darah", "Eck the Ferocious" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [608] = {
        activities = { [4] = 220, [5] = 221, [174] = 2454, [175] = 2475, [176] = 2495, },
        encounters = { "First Prisoner", "Second Prisoner", "Cyanigosa" },
        expansion = 2,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [615] = {
        activities = { [8] = 224, [9] = 238, },
        encounters = { "Vesperon", "Tenebron", "Shadron", "Sartharion" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [616] = {
        activities = { [8] = 223, [9] = 237, },
        encounters = { "Malygos" },
        expansion = 2,
        lastBossIndex = 1,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [619] = {
        activities = { [4] = 218, [5] = 219, [174] = 2455, [175] = 2476, [176] = 2486, },
        encounters = { "Elder Nadox", "Prince Taldaram", "Jedoga Shadowseeker", "Herald Volazj", "Amanitar" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [624] = {
        activities = { [8] = 239, [9] = 240, },
        encounters = { "Archavon the Stone Watcher", "Emalon the Storm Watcher", "Koralon the Flame Watcher", "Toravon the Ice Watcher" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [631] = {
        activities = { [8] = 279, [9] = 280, },
        encounters = { "Lord Marrowgar", "Lady Deathwhisper", "Icecrown Gunship Battle", "Deathbringer Saurfang", "Festergut", "Rotface", "Professor Putricide", "Blood Council", "Queen Lana'thel", "Valithria Dreamwalker", "Sindragosa", "The Lich King" },
        expansion = 2,
        lastBossIndex = 12,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [632] = {
        activities = { [4] = 251, [5] = 252, [174] = 2463, },
        encounters = { "Bronjahm", "Devourer of Souls" },
        expansion = 2,
        lastBossIndex = 2,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [649] = {
        activities = { [8] = 247, [9] = 250, },
        encounters = { "Northrend Beasts", "Lord Jaraxxus", "Faction Champions", "Val'kyr Twins", "Anub'arak" },
        expansion = 2,
        lastBossIndex = 5,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [650] = {
        activities = { [4] = 245, [5] = 249, [174] = 2452, [175] = 2471, },
        encounters = { "Grand Champions", "Argent Champion", "The Black Knight" },
        expansion = 2,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [658] = {
        activities = { [4] = 253, [5] = 254, [174] = 2462, },
        encounters = { "Forgemaster Garfrost", "Krick", "Overlrod Tyrannus" },
        expansion = 2,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [668] = {
        activities = { [4] = 255, [5] = 256, [174] = 2461, },
        encounters = { "Falric", "Marwyn", "Escaped from Arthas" },
        expansion = 2,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [724] = {
        activities = { [8] = 293, [9] = 294, },
        encounters = { "Baltharus the Warborn", "Saviana Ragefire", "General Zarithrian", "Halion" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
}

for k, v in pairs(infos) do
    infos[k] = Instances:new(v)
    v.id = k
end