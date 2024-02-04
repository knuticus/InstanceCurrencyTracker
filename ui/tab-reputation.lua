local addOnName, ICT = ...

local BAR = LibStub("XLibSimpleBar-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("InstanceCurrencyTracker")
local log = ICT.log
local UI = ICT.UI
local ReputationTab = {}
ICT.ReputationTab = ReputationTab

function ReputationTab:printReputation(x, y, faction, depth)
    local cell = self.cells(x, y)
    local name = faction.factionId and GetFactionInfoByID(faction.factionId) or BINDING_HEADER_OTHER
    y = faction.isHeader and cell:printSectionTitle(name) or cell:printLine(name)
    if faction.hasRep then
        local color = FACTION_BAR_COLORS[faction.standingId]
        cell.bar = cell.bar or BAR:NewSimpleBar()
        local cap = faction.max - faction.min
        local value = faction.value - faction.min
        cell.bar:Create(cell.frame, value, cap, UI:getCellWidth() / 2, UI:getCellHeight() * .9)
        cell.bar:SetPoint("TOPRIGHT", cell.frame, "TOPRIGHT")
        cell.bar:SetColor(color.r, color.g, color.b)
        cell.bar.fontString = cell.bar.fontString or cell.bar:CreateFontString()
        cell.bar.fontString:SetPoint("CENTER")
        cell.bar.fontString:SetFont(UI.font,  UI:getFontSize() * .9)
        cell.bar.fontString:SetJustifyH("CENTER")
        cell.bar.fontString:SetText(string.format("%s / %s", value, cap))
        cell.bar:Show()
    else
        _ = cell.bar and cell.bar:Hide()
    end
    if faction.isHeader and self.cells:isSectionExpanded(name)  then
        self.cells.indent = string.rep("  ", depth)
        for _, v in pairs(faction.children or {}) do
            y = ReputationTab:printReputation(x, y, v, depth + 1)
        end
        self.cells.indent = ""
    end
    return y
end

function ReputationTab:printPlayer(player, x)
    local y = 1
    y = self.cells(x, y):printPlayerTitle(player)
    if ICT:size(player.reputationHeaders) == 0 then
        print("WTF")
    end
    for _, v in pairs(player.reputationHeaders or {}) do
        y = self:printReputation(x, y, v, 1)
    end
    return y
end

function ReputationTab:show()
    self.frame:Show()
end

function ReputationTab:hide()
    self.frame:Hide()
end
