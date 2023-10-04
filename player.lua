local addOnName, ICT = ...

local L = LibStub("AceLocale-3.0"):GetLocale("InstanceCurrencyTracker");
local LibAddonCompat = LibStub("LibAddonCompat-1.0")
local LibInstances = LibStub("LibInstances")
local LibTradeSkillRecipes = LibStub("LibTradeSkillRecipes-1")
local Instance = ICT.Instance
ICT.Player = {}
local Player = ICT.Player

-- Adds "static" fields, 
-- Note: we may wnat to move this information to "onLoad",
-- as anything added won't get picked up by existing players.
function ICT.CreateCurrentPlayer()
    local fullName = Player.GetCurrentPlayer()
    if ICT.db.players[fullName] then
        return
    end
    ICT:print(L["Creating player: %s"], fullName)
    local player = Player:new()
    player.fullName = fullName
    player.name = UnitName("Player")
    player.realm = GetRealmName()
    player.class = select(2, UnitClass("Player"))
    player.faction = select(1, UnitFactionGroup("Player"))
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
    ICT.db.players[fullName] = player
    player:createInstances()
    -- Set transient information after copying main tables.
    player:dailyReset()
    player:weeklyReset()
    player:onLoad()
    return player
end

-- Adds all the functions to the player.
function Player:new(player)
    player = player or {}
    setmetatable(player, self)
    self.__index = self
    return player
end

-- Returns the provided player or current player if none provided.
function ICT.GetPlayer(playerName)
    if not playerName then
        ICT.currentPlayer = ICT.currentPlayer or ICT.db.players[Player.GetCurrentPlayer()]
        return ICT.currentPlayer
    end
    return ICT.db.players[playerName]
end

-- Called when the addon is loaded to update any fields.
function Player:onLoad()
    self:updateProfessions()
    -- Talents calls self:updateGear() for us.
    -- Delay loading talents(specifically gear) until wow has loaded more.
    ICT:throttleFunction("onLoad", 1, Player.updateTalents, ICT.UpdateDisplay)()
    -- Even with getItemInfoInstance we still fail on initial log in so delay.
    ICT:throttleFunction("onLoad", 1, Player.updateBags, ICT.UpdateDisplay)()
    self:updateMoney()
    self:updateGuild()
    self:updateXP()
    self:updateResting()
    self:updateCooldowns()
    self:updatePets()
    -- This may require previous info, e.g. skills and level, so calculate instance/currency 
    self:update()

    -- If the player did a name change, this attempts to reconcile 
    -- the old player using the guid.
    self.guid = UnitGUID("Player")
    for k, v in pairs(ICT.db.players) do
        if v.guid == self.guid and self.fullName ~= k then
            ICT.db.players[k] = nil
            break
        end
    end
end

function Player:createInstances()
    self.instances = self.instances or {}
    for id, info in pairs(LibInstances:GetInfos()) do
        for _, size in pairs(info:getSizes()) do
            local key = Instance:key(id, size)
            self.instances[key] = Instance:new(self.instances[key], id, size)
        end
    end
end

function Player:dailyReset()
    for _, currency in ipairs(ICT.Currencies) do
        self.currency.daily[currency.id] = self.currency.maxDaily[currency.id] or 0
    end
    for k, _ in pairs(ICT.QuestInfo) do
        self.quests.completed[k] = false
    end
end

function Player:weeklyReset()
    for _, currency in ipairs(ICT.Currencies) do
        self.currency.weekly[currency.id] = currency:calculateMaxRaid(self)
    end
end

function Player:resetInstances()
    for _, instance in pairs(self.instances) do
        instance:resetIfNecessary(GetServerTime())
    end
end

local dungeons = {}
function Player:getDungeons(expansion)
    local key = self.fullName .. ":" .. (expansion and expansion or "")
    dungeons[key] = dungeons[key] or ICT:toTable(ICT:nspairsByValue(self.instances, ICT:fWith(Instance.isDungeon, expansion)))
    return dungeons[key]
end

local raids = {}
function Player:getRaids(expansion)
    local key = self.fullName .. ":" .. (expansion and expansion or "")
    raids[key] = raids[key] or ICT:toTable(ICT:nspairsByValue(self.instances, ICT:fWith(Instance.isRaid, expansion)))
    return raids[key]
end

function Player:calculateCurrency()
    for _, currency in ipairs(ICT.Currencies) do
        local id = currency.id
        self.currency.wallet[id] = currency:getAmount()
        -- There's no weekly raid quests so just add raid currency.
        self.currency.weekly[id] = currency:calculateAvailableRaid(self)
        self.currency.daily[id] = currency:calculateAvailableDungeon(self) + currency:calculateAvailableQuest(self)
        self.currency.maxDaily[id] = currency:calculateMaxDungeon(self) + currency:calculateMaxQuest(self)
        -- Because there's no weekly raid quests, there's no variable max hence we don't need to track maxWeekly.
    end
end

function Player:availableCurrency(currency)
    if currency.unlimited then
        return "N/A"
    end
    local id = currency.id
    if not self.currency.weekly[id] or not self.currency.daily[id] then
        return 0
    end
    return self.currency.weekly[id] + self.currency.daily[id]
end

function Player:totalCurrency(currency)
    return self.currency.wallet[currency.id] or 0
end

function Player:calculateQuest()
    for k, quest in pairs(ICT.QuestInfo) do
        self.quests.prereq[k] = quest.prereq(self)
        self.quests.completed[k] = quest:isDailyCompleted()
    end
end

-- Updates instances and currencies.
-- We may want to decouple these things in the future.
function Player:update()
    for _, v in pairs(ICT.Resets) do
        v:reset()
    end
    for _, player in pairs(ICT.db.players) do
        player:resetInstances()
    end
    self:updateInstance()
    self:calculateCurrency()
    self:calculateQuest()
    self:calculateResetTimes()
end

function Player:calculateResetTimes()
    -- Look for 1, 3, 5, and 7 day resets.
    for _, instance in pairs(self.instances) do
        ICT.db.reset[instance:resetInterval()] = ICT.db.reset[instance:resetInterval()] or instance.reset
    end
    -- If we don't have a daily or weekly reset we can use the API.
    ICT.db.reset[1] = ICT.db.reset[1] or C_DateAndTime.GetSecondsUntilDailyReset() + GetServerTime()
    ICT.db.reset[7] = ICT.db.reset[7] or C_DateAndTime.GetSecondsUntilWeeklyReset() + GetServerTime()
end

-- Get all saved instance information and lock the respective instance for the player.
function Player:updateInstance()
    local numSavedInstances = GetNumSavedInstances()
    for i=1, numSavedInstances do
        local _, _, reset, _, locked, _, _, _, maxPlayers, _, _, encounterProgress, _, instanceId = GetSavedInstanceInfo(i)
        local instance = self:getInstance(instanceId, maxPlayers)

        if locked and instance then
            instance:lock(reset, encounterProgress, i)
        end
    end
end

function Player:addProfession(index, isSecondary)
    if index then
        local name, icon, rank, max, _, offset, skillLine, _  = LibAddonCompat:GetProfessionInfo(index)
        local spellId = offset and select(2, GetSpellBookItemInfo(offset + 1, "SPELL"))
        local profession = {
            name = name,
            skillLine = skillLine,
            icon = icon,
            rank = rank,
            max = max,
            spellId = spellId,
            isSecondary = isSecondary or false
        }
        tinsert(self.professions, profession)
    end
end

function Player:getProfessionRank(skillLine)
    for _, v in pairs(self.professions or {}) do
        if v.skillLine == skillLine then
            return v.rank
        end
    end
    return 0
end

function Player:updateProfessions()
    -- Reset skills in case one was dropped.
    self.professions = {}
    local first, second, _, fishing, cooking, firstAid = LibAddonCompat:GetProfessions()
    self:addProfession(first)
    self:addProfession(second)
    self:addProfession(cooking, true)
    self:addProfession(firstAid, true)
    self:addProfession(fishing, true)
    self:updateSkills()
end

function Player:updateSkills()
    self.skills = self.skills or {}
    local numTradeskills = GetNumTradeSkills()
    for i=1,numTradeskills do
        local name, difficulty = GetTradeSkillInfo(i)
        if name and difficulty ~= "header" then
            local spellLink = GetTradeSkillRecipeLink(i)
            local id = tonumber(ICT:enchantLinkSplit(spellLink)[1])
            if id then
                local categoryId = LibTradeSkillRecipes:GetInfoBySpellId(id).categoryId
                self.skills[categoryId] = self.skills[categoryId] or {}
                self.skills[categoryId][id] = { link = spellLink, difficulty = difficulty }
            end
        end
    end
end

function Player:getSpec(id)
    id = id or self.activeSpec
    self:getSpecs()[id] = self:getSpecs()[id] or {}
    return self:getSpecs()[id]
end

function Player:getSpecs()
    self.specs = self.specs or {}
    return self.specs
end

function Player:updateTalents()
    self.activeSpec = GetActiveTalentGroup()
    for i=1,2 do
        ICT.Talents:updateSpec(self:getSpec(i), i)
    end
    self:updateGear()
end

function Player:recreatePets()
    for key, pet in pairs(self:getPets()) do
        pet.player = self
        self.pets[key] = ICT.Pet:new(pet)
    end
end

function Player:updatePets()
    self.pets = self.pets or {}
    local hasUI, isHunterPet = HasPetUI();
    if hasUI and isHunterPet then
        ICT.Talents:updatePet(self)
    end
end

function Player:getPets()
    return self.pets or {}
end

function Player:updateGear()
    local active = GetActiveTalentGroup()
    self.activeSpec = active
    self.specs = self.specs or { {}, {} }
    self.specs[self.activeSpec] = self.specs[self.activeSpec] or {}

    local items = {}
    for i=1,19 do
        local itemLink = GetInventoryItemLink("player", i)
        if itemLink ~= nil then
            local item = {}

            local details = ICT:itemLinkSplit(itemLink)
            -- Use link instead of id so we don't have to worry about looking up an uncached value.
            item.link = itemLink
            -- Convert to number for our table lookup, Blizzard calls handle strings vs numbers.
            item.enchantId = tonumber(details[2])
            item.gems = {}
            item.gems[0] = details[3] and select(5, GetItemInfoInstant(details[3])) or nil
            item.gems[1] = details[4] and select(5, GetItemInfoInstant(details[4])) or nil
            item.gems[2] = details[5] and select(5, GetItemInfoInstant(details[5])) or nil
            item.gems[3] = details[6] and select(5, GetItemInfoInstant(details[6])) or nil
            item.gemTotal = ICT:sumNonNil({item.gems[0], item.gems[1], item.gems[2], item.gems[3]})

            -- Requires the server to be loaded so we have level and invType.
            local _, _, _, level, _, _, _, _, invType, icon, _, classId, subClassId = GetItemInfo(itemLink)
            item.level = level
            item.invType = invType
            item.icon = icon
            item.shouldEnchant = ICT.CheckSlotEnchant[i](self, classId, subClassId)

            local stats = GetItemStats(itemLink, {})
            item.sockets = {}
            item.sockets.red = stats["EMPTY_SOCKET_RED"] or 0
            item.sockets.blue = stats["EMPTY_SOCKET_BLUE"] or 0
            item.sockets.yellow = stats["EMPTY_SOCKET_YELLOW"] or 0
            item.sockets.meta = stats["EMPTY_SOCKET_META"] or 0
            item.extraSocket = ICT.CheckSlotSocket[i] and ICT.CheckSlotSocket[i].check(self) or false
            item.socketTotals = ICT:sum(item.sockets) + (item.extraSocket and 1 or 0)

            items[i] = item
        end
    end
    self.specs[active].items = items

    if TT_GS then
        self.specs[active].gearScore, self.specs[active].ilvlScore = TT_GS:GetScore(self.guid)
    end
end

-- If we decide to work on other versions than WOTLK.
local GetBagName = GetBagName or C_Container.GetBagName
local GetContainerNumFreeSlots = GetContainerNumFreeSlots or C_Container.GetContainerNumFreeSlots;
local GetContainerNumSlots = GetContainerNumSlots or C_Container.GetContainerNumSlots;

local function addBags(index, bags, bagsTotal)
    -- If nil then the slot is empty.
    local total = GetContainerNumSlots(index)
    if total > 0 then
        local name = GetBagName(index)
        -- Default Bank Bag doesn't have a name, so use the "Backpack" localized.
        name = name == "" and GetBagName(0) or name
        local free, type = GetContainerNumFreeSlots(index)
        -- By name requires the item in your inventory so store this for the player.
        local icon = select(5, GetItemInfoInstant(name))
        icon = icon ~= 134400 and icon or "Interface\\Addons\\InstanceCurrencyTracker\\icons\\backpack"
        bags[index] = { name = name, free = free, type = type, total = total, icon = icon }
        bagsTotal[type] = bagsTotal[type] or { free = 0, total = 0 }
        bagsTotal[type].free = bagsTotal[type].free + free
        bagsTotal[type].total = bagsTotal[type].total + total

        -- Handle cases if new bag types are added.
        if not ICT.BagFamily[type] then
            ICT:print(L["Unknown bag type %s (%s), please report this on the addon page."], type, name)
            ICT.BagFamily[type] = { icon = 134400, name = "Unknown" }
        end
    end
end

local function updateBags(self, key, startIndex, length)
    local bags = {}
    local bagsTotal = {}
    -- Surprisingly this one thing that is 0-indexed in WOW.
    local endIndex = startIndex + length
    for index=startIndex,endIndex do
        addBags(index, bags, bagsTotal)
    end
    -- But wait, bank is -1, so handle it!
    if key == "bankBags" then
        addBags(-1, bags, bagsTotal)
    end
    self[key] = bags
    self[key .. "Total"] = bagsTotal
end

function Player:updateBags()
    updateBags(self, "bags", 0, NUM_BAG_SLOTS)
end

function Player:updateBankBags()
    -- BANK_CLOSED fires twice, but data is only on the first event, so skip the second...
    local type = select(2, GetContainerNumFreeSlots(-1))
    if type then
        updateBags(self, "bankBags", NUM_BAG_SLOTS + 1, NUM_BANKBAGSLOTS)
    end
end

local function getAverageDurability()
	local totalCurrent, totalMax = 0, 0
	for i=0,19 do
		local current, max = GetInventoryItemDurability(i)
		if current and max then
			totalCurrent = totalCurrent + current
			totalMax = totalMax + max
		end
	end
	if (totalMax == 0) then
		return 100
	end
	return (totalCurrent / totalMax) * 100
end

function Player:updateDurability()
    self.durability = getAverageDurability()
end

function Player:updateMoney()
    self.money = GetMoney() or 0
end

function Player:updateGuild()
    self.guild, self.guildRank, _ = GetGuildInfo("Player")
    self.guild = self.guild or "No Guild"
    self.guildRank = self.guildRank or ""
end

function Player:updateXP()
    self.currentXP = UnitXP("Player")
    self.maxXP = UnitXPMax("Player")
    self.level = UnitLevel("Player")
    self.restedXP = GetXPExhaustion();
end

function Player:updateResting()
    self.resting = IsResting()
    self.restedXP = GetXPExhaustion();
end

function Player:recreateCooldowns()
    -- Ensure cooldowns have any new functions and values.
    for id, info in pairs(self.cooldowns or {}) do
        -- Accidentally had useless cooldowns in which aren't in the table so remove them.
        local new = ICT.Cooldowns[id]
        if new then
            self.cooldowns[id] = ICT.Cooldown:new(new.info)
            self.cooldowns[id].expires = info.expires
        else
            self.cooldowns[id] = nil
        end
    end
end

function Player:updateCooldowns()
    self.cooldowns = self.cooldowns or {}
    ICT.Cooldown:update(self)
end

function Player:getInstance(id, maxPlayers)
    return self.instances[Instance:key(id, maxPlayers)]
end

-- You gain 5% rested ever 8 hours, so every second equals the follow xp. 
local restedPerSecond = .05 / ( 8 * 60 * 60)
-- If you aren't resting you gain at a quarter of the rate, so divided by 4.
local notRestedPerSecond = restedPerSecond / 4
function Player:getRestedXP()
    -- This was added in later so safety check here.
    if self.resting == nil or not self.time or not self.restedXP or not self.maxXP then
        return 0
    end
    local percentPerSecond = self.resting and restedPerSecond or notRestedPerSecond
    local timeElapsed = GetServerTime() - self.time
    local percent = timeElapsed * percentPerSecond + (self.restedXP / self.maxXP)
    if percent > 1.5 then
        percent = 1.5
    end
	return percent
end

function Player:getName()
    return ICT.db.options.frame.verboseName and self.fullName or self.name
end

function Player:getFullName()
    return self.fullName
end

function Player:getNameWithIcon()
   return string.format("|T%s:14|t%s", ICT.ClassIcons[self.class], self:getName())
end

function Player:getClassColor()
    local classColorHex = select(4, GetClassColor(self.class))
    -- From NIT: Safeguard for weakauras/addons that like to overwrite and break the GetClassColor() function.
    if not classColorHex then
        classColorHex = self.class == "SHAMAN" and "ff0070dd" or "ffffffff"
    end
    return classColorHex
end

function Player:isQuestVisible()
    return function(quest)
        return quest:isVisible() and (self:isQuestAvailable(quest) or not ICT.db.options.quests.hideUnavailable)
    end
end

function Player:isQuestAvailable(quest)
    return self.quests.prereq[quest.key]
end

function Player:isQuestCompleted(quest)
    return self.quests.completed[quest.key]
end

function Player:hasCooking(level)
    return self:getProfessionRank(185) >= (level or 1)
end

function Player:hasFishing(level)
    return self:getProfessionRank(356) >= (level or 1)
end

function Player:isEngineer(level)
    return self:getProfessionRank(202) >= (level or 1)
end

function Player:isEnchanter(level)
    return self:getProfessionRank(333) >= (level or 1)
end

function Player:isBlacksmith(level)
    return self:getProfessionRank(164) >= (level or 1)
end

function Player:isJewelCrafter(level)
    return self:getProfessionRank(755) >= (level or 1)
end

function Player:isLevel(level)
    return self.level >= level
end

function Player:isMaxLevel()
    return self:isLevel(ICT.MaxLevel)
end

function Player:isCurrentPlayer()
    return self == ICT.GetPlayer()
end

function Player:isVisible()
    return not self.isDisabled
end

function Player:setVisible(checked)
    self.isDisabled = not checked
end

function Player:isEnabled()
    return self:isVisible() and self:isLevelVisible()
end

function Player:isLevelVisible()
    return self:isLevel(ICT.db.options.minimumLevel or ICT.MaxLevel)
end

function Player:__eq(other)
    return self.fullName == other.fullName
end

function Player:__lt(other)
    return self.fullName < other.fullName
end

function Player:__tostring()
    return self.fullName
end

function Player.GetCurrentPlayer()
    return string.format("[%s] %s", GetRealmName(), UnitName("Player"))
end