AddOnName = "Instance and Emblem Tracker"
local availableColor = "FFFFFFFF"
local titleColor = "FFFFFF00"
local lockedColor = "FFFF00FF"
local unavailableColor = "FFFF0000"
local nameColor = "FF00FF00"

local CELL_WIDTH = 160
local CELL_HEIGHT = 10
local NUM_CELLS = 1
local content

-- Currently selected player plus the length.
local selectedPlayer = Utils:GetFullName()
local displayLength = 0
local db

function CreateAddOn()
    db = InstanceCurrencyDB
    local f = CreateFrame("Frame", "InstanceCurrencyTracker", LFGParentFrame, "BasicFrameTemplateWithInset")
    f:SetSize(CELL_WIDTH * NUM_CELLS + 60, 600)
    f:SetPoint("CENTER", 300, 0)
    f:SetMovable(true)
    f:SetScript("OnMouseDown", f.StartMoving)
    f:SetScript("OnMouseUp", f.StopMovingOrSizing)
    f:SetAlpha(.5)
    f:Hide()

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetText(AddOnName)
    title:SetAlpha(1)
    title:SetIgnoreParentAlpha(true)
    title:SetPoint("TOP", -10, -6)

    -- adding a scrollframe (includes basic scrollbar thumb/buttons and functionality)
    f.scrollFrame = CreateFrame("ScrollFrame", "ICTScroll", f, "UIPanelScrollFrameTemplate")
    -- Set alpha to 1 for text.
    f.scrollFrame:SetAlpha(1)
    f.scrollFrame:SetIgnoreParentAlpha(true)

    -- Points taken from example online that avoids writing into the frame.
    f.scrollFrame:SetPoint("TOPLEFT", 12, -60)
    f.scrollFrame:SetPoint("BOTTOMRIGHT", -34, 32)

    -- creating a scrollChild to contain the content
    f.scrollFrame.scrollChild = CreateFrame("Frame", "ICTContent", f.scrollFrame)
    f.scrollFrame.scrollChild:SetSize(100, 100)
    f.scrollFrame.scrollChild:SetPoint("TOPLEFT", 5, -5)
    f.scrollFrame:SetScrollChild(f.scrollFrame.scrollChild)

    content = f.scrollFrame.scrollChild
    content.cells = {}
    CreatePlayerDropdown(f)
    CreateOptionDropdown(db, f)
    DisplayPlayer()
    return f
end

-- Gets the associated cell or create it if it doesn't exist yet.
local function getCell(x, y)
    local name = string.format("cell(%s, %s)", x, y)
    if not content.cells[name] then
        local button = CreateFrame("Button", name, content)
        button:SetSize(CELL_WIDTH, CELL_HEIGHT)
        button:SetPoint("TOPLEFT", (x - 1) * CELL_WIDTH, -(y - 1) * CELL_HEIGHT)
        content.cells[name] = button
    end
    -- content.cells[name]:SetScript("OnEnter", function() end)
    -- content.cells[name]:SetScript("OnClick", function() end)

    return content.cells[name]
end

-- Prints text in the associated cell.
local function printCell(x, y, text, color)
    local cell = getCell(x, y)
    -- Create the string if necessary.
    if not cell.value then
        cell.value = cell:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        cell.value:SetPoint("LEFT")
    end
    -- TODO We could make font and size an option here.
    cell.value:SetFont("Fonts\\FRIZQT__.TTF", 10, "")
    cell.value:SetText(string.format("|c%s%s|r", color, text))
    cell:Show()
    return cell
end

local function hideCell(x, y)
    getCell(x, y):Hide()
end

-- Tooltip for instance information upon entering the cell.
local function instanceTooltipOnEnter(key, instance)
    return function(self, motion)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        local instanceColor = instance.locked and lockedColor or nameColor
        GameTooltip:AddLine(instance.name, Utils:hex2rgb(instanceColor))
        local instanceInfo = InstanceInfo[instance.id]

        -- Display the available encounters for the instance.
        local encountersDone = instanceInfo.numEncounters - (instance.encounterProgress or 0)
        GameTooltip:AddLine(string.format("Encounters: %s/%s", encountersDone, instanceInfo.numEncounters), Utils:hex2rgb(availableColor))

        -- Display which players are locked or not for this instance.
        for k, player in Utils:spairs(db.players) do
            local playerInstance = Player:GetInstance(player, key)
            local playerColor = playerInstance.locked and lockedColor or availableColor
            GameTooltip:AddLine(k, Utils:hex2rgb(playerColor))
        end

        -- Display all available currency for the instance.
        for tokenId, _ in Utils:spairs(instanceInfo.tokenIds or {}, CurrencySort) do
            if db.options.currency[tokenId] then
                local max = instanceInfo.maxEmblems(instance, tokenId)
                local available = instance.available[tokenId] or max
                local currency = Utils:GetCurrencyName(tokenId)
                local text = string.format("%s: |c%s%s/%s|r", currency, availableColor, available, max)
                GameTooltip:AddLine(text, Utils:hex2rgb(titleColor))
            end
        end
        GameTooltip:Show()
    end
end

local function hideTooltipOnLeave(self, motion)
    GameTooltip:Hide()
end

-- Prints all the instances with associated tooltips.
local function printInstances(title, instances, x, offset)
    -- Only print the title if there exists an instance for this token.
    local printTitle = true
    for k, v in Utils:spairsByValue(instances, Instances:GetName()) do
        -- WOTLK instances don't have an expansion yet so should always appear.
        if not v.expansion or db.options.oldInstances[v.id] then
            if printTitle then
                printTitle = false
                offset = offset + 1
                printCell(x, offset, title, titleColor)
                -- title:SetScript("OnClick", function()
                --         db.options[title] = not db.options[title]
                --         print(db.options[title])
                -- end
                -- )
            end
            offset = offset + 1
            local color = v.locked and lockedColor or availableColor
            local cell = printCell(x, offset, v.name, color)
            cell:SetScript("OnEnter", instanceTooltipOnEnter(k, v))
            cell:SetScript("OnLeave", hideTooltipOnLeave)
        end
    end
    if not printTitle then
        offset = offset + 1
        hideCell(x, offset)
    end
    return offset
end

local function printInstancesForCurrency(title, instances, tokenId)
    -- Only print the title if there exists an instance for this token.
    local printTitle = true
    for _, v in Utils:spairsByValue(instances, Instances:GetName()) do
        if InstanceInfo[v.id].tokenIds[tokenId] then
            if printTitle then
                printTitle = false
                GameTooltip:AddLine(title, Utils:hex2rgb(titleColor))
            end
            -- Displays available currency out of the total currency for this instance.
            local color = v.locked and lockedColor or availableColor
            local max = InstanceInfo[v.id].maxEmblems(v, tokenId)
            local available = v.available[tokenId] or max
            GameTooltip:AddLine(string.format("%s: %s/%s", v.name, available, max), Utils:hex2rgb(color))
        end
    end
end

-- Tooltip for currency information upon entering the cell.
local function currencyTooltipOnEnter(player, tokenId)
    return function(self, motion)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(Utils:GetCurrencyName(tokenId), Utils:hex2rgb(titleColor))
        printInstancesForCurrency("Dungeons", player.dungeons, tokenId)
        printInstancesForCurrency("Raid", player.raids, tokenId)
        GameTooltip:Show()
    end
end

-- Prints currency with multi line information.
local function printCurrencyVerbose(player, tokenId, x, offset)
    offset = offset + 1
    local currency = Utils:GetCurrencyName(tokenId)
    local cell = printCell(x, offset, currency, titleColor)
    cell:SetScript("OnEnter", currencyTooltipOnEnter(player, tokenId))
    cell:SetScript("OnLeave", hideTooltipOnLeave)
    offset = offset + 1
    local available = (player.currency.weekly[tokenId] + player.currency.daily[tokenId])  or "n/a"
    cell = printCell(x, offset, "Available  " .. available, availableColor)
    cell:SetScript("OnEnter", currencyTooltipOnEnter(player, tokenId))
    cell:SetScript("OnLeave", hideTooltipOnLeave)
    offset = offset + 1
    local current = player.currency.wallet[tokenId] or "n/a"
    cell = printCell(x, offset, "Current     " .. current, availableColor)
    cell:SetScript("OnEnter", currencyTooltipOnEnter(player, tokenId))
    cell:SetScript("OnLeave", hideTooltipOnLeave)
    offset = offset + 1
    hideCell(x, offset)
    return offset
end

-- Prints currency single line information.
local function printCurrencyShort(player, tokenId, x, offset)
    offset = offset + 1
    local currency = Utils:GetCurrencyName(tokenId)
    local current = player.currency.wallet[tokenId] or "n/a"
    local available = (player.currency.weekly[tokenId] + player.currency.daily[tokenId]) or "n/a"
    local text = string.format("%s |c%s%s (%s)|r", currency, availableColor, current, available)
    local cell = printCell(x, offset, text, titleColor)
    cell:SetScript("OnEnter", currencyTooltipOnEnter(player, tokenId))
    cell:SetScript("OnLeave", hideTooltipOnLeave)
    return offset
end

local function questTooltipOnEnter(player)
    return function(self, motion)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Quests", Utils:hex2rgb(titleColor))
        for tokenId, _ in Utils:spairs(Currency, CurrencySort) do
            -- See what hapepns if we go against Quests in the spairs
            if Quests[tokenId] then
                local quests = Quests[tokenId]
                GameTooltip:AddLine(Utils:GetCurrencyName(tokenId), Utils:hex2rgb(titleColor))
                for _, quest in Utils:spairsByValue(quests, function(q) return q.name(player) end) do
                    local color = not quest.prereq(player) and unavailableColor or (Quests:IsDailyCompleted(quest.ids) and lockedColor or availableColor)
                    GameTooltip:AddLine(string.format("%s: %s", quest.name(player), quest.seals), Utils:hex2rgb(color))
                end
            end
        end
        GameTooltip:Show()
    end
end

-- Todo make this a tooltip or show quests then tooltip displays currency and amount?
local function printQuest(player, x, offset)
    offset = offset + 1
    local cell = printCell(x, offset, "Quest", titleColor)
    cell:SetScript("OnEnter", questTooltipOnEnter(player))
    cell:SetScript("OnLeave", hideTooltipOnLeave)
    offset = offset + 1
    hideCell(x, offset)
    return offset
end

-- Prints out selected players with associated instances and currency infromation.
function DisplayPlayer()
    local player = db.players[selectedPlayer]
    local x = 1
    local offset = 1
    -- In case the langauge changed, localize again.
    Player:LocalizeInstanceNames(player)
    printCell(x, offset, string.format("|T%s:16|t%s", CLASS_ICONS[player.class], player.name), nameColor)
    offset = printInstances("Dungeons", player.dungeons, x, offset)
    offset = printInstances("Raids", player.raids, x, offset)
    offset = printInstances("Old Raids", player.oldRaids, x, offset)
    offset = printQuest(player, x, offset)
    local printCurrency = db.options.verboseCurrency and printCurrencyVerbose or printCurrencyShort
    for tokenId, _ in Utils:spairs(Currency, CurrencySort) do
        if db.options.currency[tokenId] then
            offset = printCurrency(player, tokenId, x, offset)
        end
    end
    for i=offset,displayLength do
        hideCell(x, i)
    end
    displayLength = offset
end

function CreatePlayerDropdown(f)
    local dropdown = CreateFrame("Frame", "PlayerSelection", f, 'UIDropDownMenuTemplate')
    dropdown:SetPoint("TOP", f, 0, -30);
    dropdown:SetAlpha(1)
    dropdown:SetIgnoreParentAlpha(true)

    -- Width set to slightly smaller than parent frame.
    UIDropDownMenu_SetWidth(dropdown, 180)
    UIDropDownMenu_SetText(dropdown, selectedPlayer)

    UIDropDownMenu_Initialize(
        dropdown,
        function()
            local info = UIDropDownMenu_CreateInfo()
            for _, v in Utils:spairs(db.players) do
                info.text = v.fullName
                info.checked = selectedPlayer == v.fullName
                info.isNotRadio = true
                info.func = function(self)
                    selectedPlayer = self.value
                    UIDropDownMenu_SetText(dropdown, selectedPlayer)
                    DisplayPlayer()
                end
                UIDropDownMenu_AddButton(info)
            end
        end
    )
end