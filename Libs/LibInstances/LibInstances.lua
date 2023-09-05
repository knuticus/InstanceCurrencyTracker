local lib, oldminor = LibStub:NewLibrary("LibInstances", 1)

-- Already loaded
if not lib then
    return
end

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
    local activityId = (self.activities[size] or {})[difficulty]
    assert(activityId, string.format("Unknown activity for id/size/difficulty: %s/%s/%s", self.id, size, difficulty))
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

infos = {
    [33] = {
        activities = { [5] = { 800, 1084 }, },
        encounters = { "Rethilgore", "Razorclaw the Butcher", "Baron Silverlaine", "Commander Springvale", "Odo the Blindwatcher", "Fenrus the Devourer", "Wolf Master Nandos", "Archmage Arugal" },
        expansion = 0,
        lastBossIndex = 8,
        resets = {},
        sizes = {},
    },
    [34] = {
        activities = { [5] = { 802 }, },
        encounters = { "Targorr the Dread", "Kam Deepfury", "Hamhock", "Dextren Ward", "Bazil Thredd" },
        expansion = 0,
        lastBossIndex = 5,
        resets = {},
        sizes = {},
    },
    [36] = {
        activities = { [5] = { 799 }, },
        encounters = { "Rhahk'zor", "Sneed", "Gilnid", "Mr. Smite", "Cookie", "Captain Greenskin", "Edwin VanCleef" },
        expansion = 0,
        lastBossIndex = 7,
        resets = {},
        sizes = {},
    },
    [43] = {
        activities = { [5] = { 796 }, },
        encounters = { "Lady Anacondra", "Lord Cobrahn", "Kresh", "Lord Pythas", "Skum", "Lord Serpentis", "Verdan the Everliving", "Mutanus the Devourer" },
        expansion = 0,
        lastBossIndex = 8,
        resets = {},
        sizes = {},
    },
    [47] = {
        activities = { [5] = { 804 }, },
        encounters = { "Roogug", "Death Speaker Jargba", "Aggem Thorncurse", "Overlord Ramtusk", "Agathelos the Raging", "Charlga Razorflank" },
        expansion = 0,
        lastBossIndex = 6,
        resets = {},
        sizes = {},
    },
    [48] = {
        activities = { [5] = { 801 }, },
        encounters = { "Ghamoo-ra", "Lady Sarevess", "Gelihast", "Lorgus Jett", "Old Serra'kis", "Twilight Lord Kelris", "Aku'mai" },
        expansion = 0,
        lastBossIndex = 7,
        resets = {},
        sizes = {},
    },
    [70] = {
        activities = { [5] = { 807 }, },
        encounters = { "Revelosh", "The Lost Dwarves", "Ironaya", "Ancient Stone Keeper", "Galgann Firehammer", "Grimlok", "Archaedas" },
        expansion = 0,
        lastBossIndex = 7,
        resets = {},
        sizes = {},
    },
    [90] = {
        activities = { [5] = { 803 }, },
        encounters = { "Grubbis", "Viscous Fallout", "Electrocutioner 6000", "Crowd Pummeler 9-60", "Mekgineer Thermaplugg" },
        expansion = 0,
        lastBossIndex = 5,
        resets = {},
        sizes = {},
    },
    [109] = {
        activities = { [5] = { 810 }, },
        encounters = { "Avatar of Hakkar", "Jammal'an the Prophet", "Dreamscythe", "Weaver", "Morphaz", "Hazzas", "Shade of Eranikus" },
        expansion = 0,
        lastBossIndex = 7,
        resets = {},
        sizes = {},
    },
    [129] = {
        activities = { [5] = { 806 }, },
        encounters = { "Tuten'kash", "Mordresh Fire Eye", "Glutton", "Amnennar the Coldbringer" },
        expansion = 0,
        lastBossIndex = 4,
        resets = {},
        sizes = {},
    },
    [189] = {
        activities = { [5] = { 805, 827, 828, 829, 1081 }, },
        encounters = { "Interrogator Vishas", "Bloodmage Thalnos", "Houndmaster Loksey", "Arcanist Doan", "Herod", "High Inquisitor Fairbanks", "High Inquisitor Whitemane" },
        expansion = 0,
        lastBossIndex = 7,
        resets = {},
        sizes = {},
    },
    [209] = {
        activities = { [5] = { 808 }, },
        encounters = { "Hydromancer Velratha", "Ghaz'rilla", "Antu'sul", "Theka the Martyr", "Witch Doctor Zum'rah", "Nekrum Gutchewer", "Shadowpriest Sezz'ziz", "Chief Ukorz Sandscalp" },
        expansion = 0,
        lastBossIndex = 8,
        resets = {},
        sizes = {},
    },
    [229] = {
        activities = { [5] = { 812 }, [10] = { 837 }, },
        encounters = { "Highlord Omokk", "Shadow Hunter Vosh'gajin", "War Master Voone", "Mother Smolderweb", "Urok Doomhowl", "Quartermaster Zigris", "Halycon", "Gizrul the Slavener", "Overlord Wyrmthalak", "Pyroguard Emberseer", "Solakar Flamewreath", "Warchief Rend Blackhand", "The Beast", "General Drakkisath" },
        expansion = 0,
        lastBossIndex = 14,
        resets = {},
        sizes = {},
    },
    [230] = {
        activities = { [5] = { 811, 1083 }, },
        encounters = { "High Interrogator Gerstahn", "Lord Roccor", "Houndmaster Grebmar", "Ring of Law", "Pyromancer Loregrain", "Lord Incendius", "Warder Stilgiss", "Fineous Darkvire", "Bael'Gar", "General Angerforge", "Golem Lord Argelmach", "Hurley Blackbreath", "Phalanx", "Ribbly Screwspigot", "Plugger Spazzring", "Ambassador Flamelash", "The Seven", "Magmus", "Emperor Dagran Thaurissan" },
        expansion = 0,
        lastBossIndex = 19,
        resets = {},
        sizes = {},
    },
    [249] = {
        activities = { [10] = { 1156 }, [25] = { 1099 }, [40] = { 838 }, },
        encounters = { "Onyxia" },
        expansion = 2,
        lastBossIndex = 1,
        legacy = { expansion = 0, size = 40, },
        resets = { [10] = 7, [25] = 7, [40] = 5, },
        sizes = { 10, 25, 40 },
    },
    [269] = {
        activities = { [5] = { 831, 907 }, },
        encounters = { "Aeonus", "Chrono Lord Deja", "Temporus" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [289] = {
        activities = { [5] = { 797 }, },
        encounters = { "Darkmaster Gandling", "Doctor Theolen Krastinov", "Instructor Malicia", "Jandice Barov", "Kirtonos", "Lady Illucia Barov", "Lord Alexei Barov", "Lorekeeper Polkelt", "Marduk Blackpool", "Ras Frostwhisperer", "Rattlegore", "The Ravenian", "Vectus" },
        expansion = 0,
        lastBossIndex = 13,
        resets = {},
        sizes = {},
    },
    [309] = {
        activities = { [20] = { 836 }, },
        encounters = { "High Priestess Jeklik", "High Priest Venoxis", "High Priestess Mar'li", "Bloodlord Mandokir", "Edge of Madness", "High Priest Thekal", "Gahz'ranka", "High Priestess Arlokk", "Jin'do the Hexxer", "Hakkar" },
        expansion = 0,
        lastBossIndex = 10,
        resets = { [20] = 3, },
        sizes = { 20 },
    },
    [329] = {
        activities = { [5] = { 816 }, },
        encounters = { "Hearthsinger Forresten", "Timmy the Cruel", "Commander Malor", "Willey Hopebreaker", "Instructor Galford", "Balnazzar", "The Unforgiven", "Baroness Anastari", "Nerub'enkan", "Maleki the Pallid", "Magistrate Barthilas", "Ramstein the Gorger", "Lord Aurius Rivendare" },
        expansion = 0,
        lastBossIndex = 13,
        resets = {},
        sizes = {},
    },
    [349] = {
        activities = { [5] = { 809 }, },
        encounters = { "Noxxion", "Razorlash", "Tinkerer Gizlock", "Lord Vyletongue", "Celebras the Cursed", "Landslide", "Rotgrip", "Princess Theradras" },
        expansion = 0,
        lastBossIndex = 8,
        resets = {},
        sizes = {},
    },
    [389] = {
        activities = { [5] = { 798 }, },
        encounters = { "Oggleflint", "Jergosh the Invoker", "Bazzalan", "Taragaman the Hungerer" },
        expansion = 0,
        lastBossIndex = 4,
        resets = {},
        sizes = {},
    },
    [409] = {
        activities = { [40] = { 839 }, },
        encounters = { "Lucifron", "Magmadar", "Gehennas", "Garr", "Shazzrah", "Baron Geddon", "Sulfuron Harbinger", "Golemagg the Incinerator", "Majordomo Executus", "Ragnaros" },
        expansion = 0,
        lastBossIndex = 10,
        resets = { [40] = 7, },
        sizes = { 40 },
    },
    [429] = {
        activities = { [5] = { 813, 814, 815 }, },
        encounters = { "Zevrim Thornhoof", "Hydrospawn", "Lethtendris", "Alzzin the Wildshaper", "Tendris Warpwood", "Illyanna Ravenoak", "Magister Kalendris", "Immol'thar", "Prince Tortheldrin", "Guard Mol'dar", "Stomper Kreeg", "Guard Fengus", "Guard Slip'kik", "Captain Kromcrush", "Cho'Rush the Observer", "King Gordok" },
        expansion = 0,
        lastBossIndex = 16,
        resets = {},
        sizes = {},
    },
    [469] = {
        activities = { [40] = { 840 }, },
        encounters = { "Razorgore the Untamed", "Vaelastrasz the Corrupt", "Broodlord Lashlayer", "Firemaw", "Ebonroc", "Flamegor", "Chromaggus", "Nefarian" },
        expansion = 0,
        lastBossIndex = 8,
        resets = { [40] = 7, },
        sizes = { 40 },
    },
    [509] = {
        activities = { [20] = { 842 }, },
        encounters = { "Kurinnaxx", "General Rajaxx", "Moam", "Buru the Gorger", "Ayamiss the Hunter", "Ossirian the Unscarred" },
        expansion = 0,
        lastBossIndex = 6,
        resets = { [20] = 3, },
        sizes = { 20 },
    },
    [531] = {
        activities = { [40] = { 843 }, },
        encounters = { "The Prophet Skeram", "Silithid Royalty", "Battleguard Sartura", "Fankriss the Unyielding", "Viscidus", "Princess Huhuran", "Twin Emperors", "Ouro", "C'thun" },
        expansion = 0,
        lastBossIndex = 9,
        resets = { [40] = 7, },
        sizes = { 40 },
    },
    [532] = {
        activities = { [10] = { 844 }, },
        encounters = { "Attumen the Huntsman", "Moroes", "Maiden of Virtue", "Opera Hall", "The Curator", "Terestian Illhoof", "Shade of Aran", "Netherspite", "Chess Event", "Prince Malchezaar", "Nightbane" },
        expansion = 1,
        lastBossIndex = 11,
        resets = { [10] = 7, },
        sizes = { 10 },
    },
    [533] = {
        activities = { [10] = { 841 }, [25] = { 1098 }, },
        encounters = { "Anub'Rekhan", "Grand Widow Faerlina", "Maexxna", "Noth the Plaguebringer", "Heigan the Unclean", "Loatheb", "Instructor Razuvious", "Gothik the Harvester", "The Four Horsemen", "Patchwerk", "Grobbulus", "Gluth", "Thaddius", "Sapphiron", "Kel'Thuzad" },
        expansion = 2,
        lastBossIndex = 15,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [534] = {
        activities = { [25] = { 849 }, },
        encounters = { "Rage Winterchill", "Anetheron", "Kaz'rogal", "Azgalor", "Archimonde" },
        expansion = 1,
        lastBossIndex = 5,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [540] = {
        activities = { [5] = { 819, 914 }, },
        encounters = { "Blood Guard Porung", "Grand Warlock Nethekurse", "Warbringer O'mrogg", "Warchief Kargath Bladefist" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [542] = {
        activities = { [5] = { 818, 912 }, },
        encounters = { "The Maker", "Keli'dan the Breaker", "Broggok" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [543] = {
        activities = { [5] = { 817, 913 }, },
        encounters = { "Omor the Unscarred", "Vazruden the Herald", "Watchkeeper Gargolmar" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [544] = {
        activities = { [25] = { 845 }, },
        encounters = { "Magtheridon" },
        expansion = 1,
        lastBossIndex = 1,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [545] = {
        activities = { [5] = { 822, 910 }, },
        encounters = { "Hydromancer Thespia", "Mekgineer Steamrigger", "Warlord Kalithresh" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [546] = {
        activities = { [5] = { 821, 911 }, },
        encounters = { "Ghaz'an", "Hungarfen", "Swamplord Musel'ek", "The Black Stalker" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [547] = {
        activities = { [5] = { 820, 909, 1082 }, },
        encounters = { "Mennu the Betrayer", "Quagmirran", "Rokmar the Crackler" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [548] = {
        activities = { [25] = { 848 }, },
        encounters = { "Hydross the Unstable", "The Lurker Below", "Leotheras the Blind", "Fathom-Lord Karathress", "Morogrim Tidewalker", "Lady Vashj" },
        expansion = 1,
        lastBossIndex = 6,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [550] = {
        activities = { [25] = { 847 }, },
        encounters = { "Al'ar", "Void Reaver", "High Astromancer Solarian", "Kael'thas Sunstrider" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [552] = {
        activities = { [5] = { 834, 915 }, },
        encounters = { "Dalliah the Doomsayer", "Harbinger Skyriss", "Wrath-Scryer Soccothrates", "Zereketh the Unbound" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [553] = {
        activities = { [5] = { 833, 918 }, },
        encounters = { "Commander Sarannis", "High Botanist Freywinn", "Laj", "Thorngrin the Tender", "Warp Splinter" },
        expansion = 1,
        lastBossIndex = 5,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [554] = {
        activities = { [5] = { 832, 916 }, },
        encounters = { "Nethermancer Sepethrea", "Pathaleon the Calculator", "Mechano-Lord Capacitus", "Gatewatcher Gyro-Kill", "Gatewatcher Iron-Hand" },
        expansion = 1,
        lastBossIndex = 5,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [555] = {
        activities = { [5] = { 826, 906 }, },
        encounters = { "Ambassador Hellmaw", "Blackheart the Inciter", "Murmur", "Grandmaster Vorpil" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [556] = {
        activities = { [5] = { 825, 905 }, },
        encounters = { "Talon King Ikiss", "Darkweaver Syth", "Anzu" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [557] = {
        activities = { [5] = { 823, 904 }, },
        encounters = { "Nexus-Prince Shaffar", "Pandemonius", "Yor", "Tavarok" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [558] = {
        activities = { [5] = { 824, 903 }, },
        encounters = { "Exarch Maladaar", "Shirrak the Dead Watcher" },
        expansion = 1,
        lastBossIndex = 2,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [560] = {
        activities = { [5] = { 830, 908 }, },
        encounters = { "Lieutenant Drake", "Epoch Hunter", "Captain Skarloc" },
        expansion = 1,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [564] = {
        activities = { [25] = { 850 }, },
        encounters = { "High Warlord Naj'entus", "Supremus", "Shade of Akama", "Teron Gorefiend", "Gurtogg Bloodboil", "Reliquary of Souls", "Mother Shahraz", "The Illidari Council", "Illidan Stormrage" },
        expansion = 1,
        lastBossIndex = 9,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [565] = {
        activities = { [25] = { 846 }, },
        encounters = { "High King Maulgar", "Gruul the Dragonkiller" },
        expansion = 1,
        lastBossIndex = 2,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [568] = {
        activities = { [10] = { 851 }, },
        encounters = { "Akil'zon", "Nalorakk", "Jan'alai", "Halazzi", "Hex Lord Malacrass", "Zul'jin" },
        expansion = 1,
        lastBossIndex = 6,
        resets = { [10] = 7, },
        sizes = { 10 },
    },
    [574] = {
        activities = { [5] = { 1074, 1122, 1207, 1211, 1225 }, },
        encounters = { "Prince Keleseth", "Skarvold & Dalronn", "Ingvar the Plunderer" },
        expansion = 2,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [575] = {
        activities = { [5] = { 1075, 1125, 1204, 1210, 1224 }, },
        encounters = { "Svala Sorrowgrave", "Gortok Palehoof", "Skadi the Ruthless", "King Ymiron" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [576] = {
        activities = { [5] = { 1077, 1132, 1197, 1213, 1227 }, },
        encounters = { "Grand Magus Telestra", "Anomalus", "Ormorok the Tree-Shaper", "Keristrasza" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [578] = {
        activities = { [5] = { 1067, 1124, 1205, 1212, 1226 }, },
        encounters = { "Drakos the Interrogator", "Varos Cloudstrider", "Mage-Lord Urom", "Ley-Guardian Eregos" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [580] = {
        activities = { [25] = { 852 }, },
        encounters = { "Kalecgos", "Brutallus", "Felmyst", "Eredar Twins", "M'uru", "Kil'jaeden" },
        expansion = 1,
        lastBossIndex = 6,
        resets = { [25] = 7, },
        sizes = { 25 },
    },
    [585] = {
        activities = { [5] = { 835, 917 }, },
        encounters = { "Kael'thas Sunstrider", "Priestess Delrissa", "Selin Fireheart", "Vexallus" },
        expansion = 1,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [595] = {
        activities = { [5] = { 1065, 1126, 1203, 1214, 1228 }, },
        encounters = { "Meathook", "Salram the Fleshcrafter", "Chrono-Lord Epoch", "Mal'ganis" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [599] = {
        activities = { [5] = { 1069, 1128, 1201, 1215, 1229 }, },
        encounters = { "Krystallus", "Maiden of Grief", "Tribunal of Ages", "Sjonnir the Ironshaper" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [600] = {
        activities = { [5] = { 1070, 1129, 1200, 1218, 1232 }, },
        encounters = { "Trollgore", "Novos the Summoner", "King Dred", "The Prophet Tharon'ja" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [601] = {
        activities = { [5] = { 1066, 1121, 1208, 1219, 1233 }, },
        encounters = { "Krik'thir the Gatewatcher", "Hadronox", "Anub'arak" },
        expansion = 2,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [602] = {
        activities = { [5] = { 1068, 1127, 1202, 1216, 1230 }, },
        encounters = { "General Bjarngrim", "Volkhan", "Ionar", "Loken" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [603] = {
        activities = { [10] = { 1106 }, [25] = { 1107 }, },
        encounters = { "Flame Leviathan", "Ignis the Furnace Master", "Razorscale", "XT-002 Deconstructor", "The Iron Council", "Kologarn", "Auriaya", "Hodir", "Thorim", "Freya", "Mimiron", "General Vezax", "Yogg-Saron", "Algalon the Observer" },
        expansion = 2,
        lastBossIndex = 14,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [604] = {
        activities = { [5] = { 1071, 1130, 1199, 1217, 1231 }, },
        encounters = { "Slad'ran", "Drakkari Colossus", "Moorabi", "Gal'darah", "Eck the Ferocious" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [608] = {
        activities = { [5] = { 1073, 1123, 1206, 1209, 1223 }, },
        encounters = { "First Prisoner", "Second Prisoner", "Cyanigosa" },
        expansion = 2,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [615] = {
        activities = { [10] = { 1101 }, [25] = { 1097 }, },
        encounters = { "Vesperon", "Tenebron", "Shadron", "Sartharion" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [616] = {
        activities = { [10] = { 1102 }, [25] = { 1094 }, },
        encounters = { "Malygos" },
        expansion = 2,
        lastBossIndex = 1,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [619] = {
        activities = { [5] = { 1072, 1131, 1198, 1220, 1234 }, },
        encounters = { "Elder Nadox", "Prince Taldaram", "Jedoga Shadowseeker", "Herald Volazj", "Amanitar" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    [624] = {
        activities = { [10] = { 1095 }, [25] = { 1096 }, },
        encounters = { "Archavon the Stone Watcher", "Emalon the Storm Watcher", "Koralon the Flame Watcher", "Toravon the Ice Watcher" },
        expansion = 2,
        lastBossIndex = 4,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    --[631] = {
        --activities = { [10] = { 1110 }, [25] = { 1111 }, },
        --encounters = { "Lord Marrowgar", "Lady Deathwhisper", "Icecrown Gunship Battle", "Deathbringer Saurfang", "Festergut", "Rotface", "Professor Putricide", "Blood Council", "Queen Lana'thel", "Valithria Dreamwalker", "Sindragosa", "The Lich King" },
        --expansion = 2,
        --lastBossIndex = 12,
        --resets = { [10] = 7, [25] = 7, },
        --sizes = { 10, 25 },
    --},
    --[632] = {
        --activities = { [5] = { 1078, 1134, 1240 }, },
        --encounters = { "Bronjahm", "Devourer of Souls" },
        --expansion = 2,
        --lastBossIndex = 2,
        --resets = { [5] = 1, },
        --sizes = { 5 },
    --},
    [649] = {
        activities = { [10] = { 1100 }, [25] = { 1104 }, },
        encounters = { "Northrend Beasts", "Lord Jaraxxus", "Faction Champions", "Val'kyr Twins", "Anub'arak" },
        expansion = 2,
        lastBossIndex = 5,
        resets = { [10] = 7, [25] = 7, },
        sizes = { 10, 25 },
    },
    [650] = {
        activities = { [5] = { 1076, 1133, 1238, 1239 }, },
        encounters = { "Grand Champions", "Argent Champion", "The Black Knight" },
        expansion = 2,
        lastBossIndex = 3,
        resets = { [5] = 1, },
        sizes = { 5 },
    },
    --[658] = {
        --activities = { [5] = { 1079, 1135, 1241 }, },
        --encounters = { "Forgemaster Garfrost", "Krick", "Overlrod Tyrannus" },
        --expansion = 2,
        --lastBossIndex = 3,
        --resets = { [5] = 1, },
        --sizes = { 5 },
    --},
    --[668] = {
        --activities = { [5] = { 1080, 1136, 1242 }, },
        --encounters = { "Falric", "Marwyn", "Escaped from Arthas" },
        --expansion = 2,
        --lastBossIndex = 3,
        --resets = { [5] = 1, },
        --sizes = { 5 },
    --},
    --[724] = {
        --activities = { [10] = { 1108 }, [25] = { 1109 }, },
        --encounters = { "Baltharus the Warborn", "Saviana Ragefire", "General Zarithrian", "Halion" },
        --expansion = 2,
        --lastBossIndex = 4,
        --resets = { [10] = 7, [25] = 7, },
        --sizes = { 10, 25 },
    --},
}
for k, v in pairs(infos) do
    infos[k] = Instances:new(v)
    v.id = k
end
