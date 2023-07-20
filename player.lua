Player = {}

function Player:Create()
    local player = {}
    player.name = UnitName("Player")
    player.realm = GetRealmName()
    player.fullName = Utils:GetFullName()
    player.class = select(2, UnitClass("Player"))
    player.level = UnitLevel("Player")
    player.dungeons = CopyTable(Instances.dungeons)
    player.raids = CopyTable(Instances.raids)
    player.oldRaids = CopyTable(Instances.oldRaids)
    player.currency = {
        wallet = {},
        weekly = {},
        daily = {},
    }
    -- Set transient information after copying main tables.
    self:DailyReset(player)
    self:WeeklyReset(player)
    Instances:ResetAll(player.oldRaids)
    return player
end

function Player:ResetInstances(player)
    local timestamp = GetServerTime()
    if not player.dailyReset or player.dailyReset < timestamp then
        self:DailyReset(player)
        print(AddOnName .. " - daily reset - wiping " .. player.fullName)
    end
    if not player.weeklyReset or player.weeklyReset < timestamp then
        self:WeeklyReset(player)
        print(AddOnName .. " - weekly reset - wiping " .. player.fullName)
    end
    Player:OldRaidReset(player)
end

function Player:DailyReset(player)
    Instances:ResetAll(player.dungeons)
    for k, v in pairs(Currency) do
        player.currency.daily[k] = v.maxDaily or 0
    end
    player.dailyReset = C_DateAndTime.GetSecondsUntilDailyReset() + GetServerTime()
end

function Player:WeeklyReset(player)
    Instances:ResetAll(player.raids)
    for k, v in pairs(Currency) do
        player.currency.weekly[k] = v.maxWeekly or 0
    end
    player.weeklyReset = C_DateAndTime.GetSecondsUntilWeeklyReset() + GetServerTime()
end

function Player:OldRaidReset(player)
    Instances:ResetIfNecessary(player.oldRaids, GetServerTime())
end

function Player:CalculateCurrency(player)
    for k, v in pairs(Currency) do
        player.currency.wallet[k] = Utils:GetCurrencyAmount(k)
        player.currency.weekly[k] = v.weekly(player)
        player.currency.daily[k] = v.daily(player)
    end
end

function Player:Update(db)
    for _, player in pairs(db.players) do
        Player:ResetInstances(player)
    end
    local player = self:GetPlayer(db)
    Instances:Update(player)
    Player:CalculateCurrency(player)
    -- Update daily max seals
end

-- Returns the provided player or current player if none provided.
function Player:GetPlayer(db, playerName)
    playerName = playerName or Utils:GetFullName()
    local player = db.players[playerName] or Player:Create()
    db.players[playerName] = player
    return player
end

function Player:WipePlayer(db, playerName)
    db.players[playerName] = Player:Create()
    print(AddOnName .. " - wiping player - " .. playerName)
end

function Player:WipeRealm(db, realmName)
    for name, _ in Utils.fpairs(db.players, function(v) return v.realm == realmName end) do
        db.players[name] = {}
    end
    print(AddOnName .. " - wiping players on realm - " .. realmName)
end

function Player:WipeAllPlayers(db)
    db.players = {}
    print(AddOnName .. " - wiping all players")
end

function Player:EnablePlayer(db, playerName)
    local player = self:GetPlayer(db, playerName)
    player.isDisabled = false
end

function Player:DisablePlayer(db, playerName)
    local player = self:GetPlayer(db, playerName)
    player.isDisabled = true
end

function Player:ViewablePlayers(db, options)
    local currentName = Utils:GetFullName()
    local currentRealm = GetRealmName()
    local playerFilter = function(v) return
        -- Show all characters for the realm or specifically the current character.
        (options.showAllAlts or currentName == v.fullName)
        -- Show only max level characters if enabled.
        and (v.level == 80 or not options.onlyMaxLevelCharacters)
        and (v.realm == currentRealm or options.showAllRealms)
        and not v.isDisabled
    end
    local players = {}
    for _, player in Utils.fpairs(db.players, playerFilter) do
        players[player.fullName] = player
    end
    return players
end