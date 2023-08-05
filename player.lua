local addOnName, ICT = ...

ICT.Player = {}
local Player = ICT.Player
local Instances = ICT.Instances
local Quests = ICT.Quests
local Currency = ICT.Currency
local MaxLevel = 80

local function dailyReset(player)
    Instances:ResetAll(player.dungeons)
    for k, _ in pairs(ICT.CurrencyInfo) do
        player.currency.daily[k] = player.currency.maxDaily[k] or 0
    end
    for k, _ in pairs(ICT.QuestInfo) do
        player.quests.completed[k] = false
    end
end

local function weeklyReset(player)
    Instances:ResetAll(player.raids)
    for k, _ in pairs(ICT.CurrencyInfo) do
        player.currency.weekly[k] = Currency:CalculateMaxRaidEmblems(k)(player)
    end
end

ICT.ResetInfo = {
    [1] = { name = "Daily", func = dailyReset },
    [3] = { name = "3 Day", func = function() end },
    [5] = { name = "5 Day", func = function() end },
    [7] = { name = "Weekly", func = weeklyReset },
}

function Player:Create()
    local player = {}
    player.name = UnitName("Player")
    player.realm = GetRealmName()
    player.fullName = ICT:GetFullName()
    player.class = select(2, UnitClass("Player"))
    player.faction = select(1, UnitFactionGroup("Player"))
    player.level = UnitLevel("Player")
    player.quests = {
        prereq = {},
        completed = {}
    }
    player.currency = {
        wallet = {},
        weekly = {},
        daily = {},
        maxDaily = {},
        -- There's no prereq for weekly currencies so no player based max weekly.
    }
    self:CreateInstances(player)
    -- Set transient information after copying main tables.
    dailyReset(player)
    weeklyReset(player)
    return player
end

-- Creates instances in the transient tables if necessary.
-- The key is the English name with raid size if multiple sizes.
function Player:CreateInstances(player)
    player.dungeons = player.dungeons or {}
    player.raids = player.raids or {}
    player.oldRaids = player.oldRaids or {}
    for _, v in pairs(ICT.InstanceInfo) do
        if v.expansion == ICT.Expansions[ICT.WOTLK] then
            if #v.maxPlayers > 1 then
                for _, size in pairs(v.maxPlayers) do
                    self:addInstance(player.raids, v, size)
                end
            else
                self:addInstance(player.dungeons, v)
            end
        elseif v.expansion < ICT.Expansions[ICT.WOTLK] then
            self:addInstance(player.oldRaids, v)
        end
        if v.name == "Onyxia's Lair" then
            self:addInstance(player.oldRaids, v)
        end
    end
end

function Player:addInstance(t, info, size)
    local k = size and ICT:GetInstanceName(info.name, size) or info.name
    if not t[k] then
        local instance = { id = info.id, expansion = info.expansion, maxPlayers = size }
        ICT:LocalizeInstanceName(instance)
        Instances:Reset(instance)
        t[k] = instance
    end
end

function Player:LocalizeInstanceNames(player)
    for _, v in pairs(player.dungeons) do
        ICT:LocalizeInstanceName(v)
    end
    for _, v in pairs(player.raids) do
        ICT:LocalizeInstanceName(v)
    end
    for _, v in pairs(player.oldRaids) do
        ICT:LocalizeInstanceName(v)
    end
end

function Player:ResetInstances()
    local timestamp = GetServerTime()
    for k, v in pairs(ICT.db.reset) do
        if v < timestamp then
            print(string.format("[%s] %s reset, updating info.", addOnName, ICT.ResetInfo[k].name))
            for _, player in pairs(ICT.db.players) do
                ICT.ResetInfo[k].func(player)
            end
            -- There doesn't seem to be an API to get 3 or 5 day reset so recalculate from the last known piece.
            -- Keep going until we have a time in the future, the player may have not logged in a while.
            while (ICT.db.reset[k] < timestamp) do
                ICT.db.reset[k] = ICT.db.reset[k] + k * 86400
            end
        end
    end
    -- Old raids have 3, 5 and 7 day resets... so use the instance specific timer.
    -- TODO: in the future we may want to link raids to their reset length.
    for _, player in pairs(ICT.db.players) do
        Player:OldRaidReset(player)
    end
end

function Player:OldRaidReset(player)
    Instances:ResetIfNecessary(player.oldRaids, GetServerTime())
end

function Player:CalculateCurrency(player)
    for k, _ in pairs(ICT.CurrencyInfo) do
        player.currency.wallet[k] = ICT:GetCurrencyAmount(k)
        -- There's no weekly raid quests so just add raid emblems.
        player.currency.weekly[k] = Currency:CalculateRaidEmblems(k)(player)
        player.currency.daily[k] = ICT:add(Currency:CalculateDungeonEmblems(k), Quests:CalculateAvailableDaily(k))(player)
        player.currency.maxDaily[k] = ICT:add(Currency:CalculateMaxDungeonEmblems(k), Quests:CalculateMaxDaily(k))(player)
    end
end

function Player:AvailableCurrency(player, tokenId)
    if not player.currency.weekly[tokenId] or not player.currency.daily[tokenId] then
        return 0
    end
    return player.currency.weekly[tokenId] + player.currency.daily[tokenId]
end

function Player:CalculateQuest(player)
    for k, quest in pairs(ICT.QuestInfo) do
        player.quests.prereq[k] = quest.prereq(player)
        player.quests.completed[k] = Quests:IsDailyCompleted(quest)
    end
end

-- Updates instances and currencies.
-- We may want to decouple these things in the future.
function Player:Update()
    Player:ResetInstances()
    local player = self:GetPlayer()
    Instances:Update(player)
    self:CalculateCurrency(player)
    self:CalculateQuest(player)
    self:CalculateResetTimes(player)
end

-- Returns the provided player or current player if none provided.
function Player:GetPlayer(playerName)
    playerName = playerName or ICT:GetFullName()
    local exists = ICT.db.players[playerName] and true or false
    if not exists then
        print(string.format("[%s] Creating player: %s", addOnName, playerName))
    end
    local player = ICT.db.players[playerName] or Player:Create()
    ICT.db.players[playerName] = player
    return player
end

function Player:WipePlayer(playerName)
    if ICT.db.players[playerName] then
        ICT.db.players[playerName] = nil
        print(string.format("[%s] Wiped player: %s", addOnName, playerName))
    else
        print(string.format("[%s] Unknown player: %s", addOnName, playerName))
    end
    self:Update()
end

function Player:WipeRealm(realmName)
    local count = 0
    for name, _ in ICT:fpairsByValue(ICT.db.players, function(v) return v.realm == realmName end) do
        count = count + 1
        ICT.db.players[name] = nil
    end
    print(string.format("[%s] Wiped %s players on realm: %s", addOnName , count, realmName))
    self:Update()
end

function Player:WipeAllPlayers()
    local count = 0
    for _, _ in pairs(ICT.db.players) do
        count = count + 1
    end
    ICT.db.players = {}
    print(string.format("[%s] Wiped %s players", addOnName, count))
    self:Update()
end

function Player:CalculateResetTimes(player)
    for _, instance in pairs(player.oldRaids) do
        -- Ony40 has a 5 day reset.
        if instance.id == 249 then
            ICT.db.reset[5] = ICT.db.reset[5] or instance.reset
        end
        -- AQ20, ZG, and ZA have 3 day resets.
        if instance.id == 509 or instance.id == 309 or instance.id == 568 then
            ICT.db.reset[3] = ICT.db.reset[3] or instance.reset
        end
    end
    ICT.db.reset[1] = ICT.db.reset[1] or C_DateAndTime.GetSecondsUntilDailyReset() + GetServerTime()
    ICT.db.reset[7] = ICT.db.reset[7] or C_DateAndTime.GetSecondsUntilWeeklyReset() + GetServerTime()
end

local SECONDARY_SKILLS = string.gsub(SECONDARY_SKILLS, ":", "")
local PROFICIENCIES = string.gsub(PROFICIENCIES, ":", "")
function Player:UpdateSkills()
    local player = self:GetPlayer()
    -- Skill list is always in same order, so we can get primary/secondary/weapon by checking the section headers.
    local professionCount = 0
    local isSecondary = false
    local profession = false
    -- Reset skills in case one was dropped.
    player.professions = {}

    for i = 1, GetNumSkillLines() do
        local name, isHeader, _, rank, _, _, max = GetSkillLineInfo(i)
        local icon = select(3, GetSpellInfo(name))
        -- Note we aren't using anything besides professions, in the future we may want to display other attributes.
        if isHeader and name == TRADE_SKILLS then
            isSecondary = false
            profession = true
        elseif isHeader and name == SECONDARY_SKILLS then
            isSecondary = true
            profession = true
        elseif isHeader and string.find(name, COMBAT_RATING_NAME1) then
            profession = false
        elseif isHeader and string.find(name, PROFICIENCIES) then
            profession = false
        elseif isHeader and name == LANGUAGES_LABEL then
            profession = false
        end
        if not isHeader and profession and icon then
            professionCount = professionCount + 1;
            
            player.professions[professionCount] = {
                name = name,
                icon = icon,
                rank = rank,
                max = max,
                isSecondary = isSecondary
            }
        end
    end
end

local function getSpecs(player)
    player.specs = player.specs or { {}, {} }
    return player.specs
end

function Player.UpdateTalents()
    local player = Player:GetPlayer()
    local guid = UnitGUID("Player")
    local active = ICT.LCInspector:GetActiveTalentGroup(guid)
    local specs = getSpecs(player)
    player.activeSpec = active

    for i=1,2 do
        local specialization = ICT.LCInspector:GetSpecialization(guid, i)
        specs[i].name = ICT.LCInspector:GetSpecializationName(player.class, specialization, true)
        specs[i].tab1, specs[i].tab2, specs[i].tab3 = ICT.LCInspector:GetTalentPoints(guid, i)
        specs[i].glyphs = {}
        for j=1,6 do
            local _, _, id, icon = ICT.LCInspector:GetGlyphSocketInfo(guid, j, i)
            specs[i].glyphs[j] = { id = id, icon = icon }   
        end
    end
    Player.UpdateGear()
end

function Player.UpdateGear()
    if TT_GS then
        local player = Player:GetPlayer()
        local guid = UnitGUID("Player")
        local active = ICT.LCInspector:GetActiveTalentGroup(guid)
        local spec = getSpecs(player)[active]
        spec.gearScore, spec.ilvlScore = TT_GS:GetScore(guid)
    end
end

function Player.GetName(player)
    return ICT.db.options.verboseName and player.fullName or player.name
end

function Player.PlayerSort(a, b)
    return Player.GetName(a) < Player.GetName(b)
end

function Player.PlayerEnabled(player)
    return not player.isDisabled and Player.IsMaxLevel(player)
end

function Player.IsMaxLevel(player)
    return player.level == MaxLevel
end