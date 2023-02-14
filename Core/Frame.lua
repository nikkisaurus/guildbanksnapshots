local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")
local AceSerializer = LibStub("AceSerializer-3.0")

-- [[ Col/Headers ]]
-------------
local cols = {
    [1] = {
        header = "Date",
        width = 1,
        text = function(data)
            return date(private.db.global.settings.preferences.dateFormat, private:GetTransactionDate(data.scanID, data.year, data.month, data.day, data.hour))
        end,
        sortValue = function(data)
            return private:GetTransactionDate(data.scanID, data.year, data.month, data.day, data.hour)
        end,
    },
    [2] = {
        header = "Tab",
        width = 1,
        text = function(data)
            return private:GetTabName(private.frame.guildDropdown.selected, data.tabID)
        end,
        sortValue = function(data)
            return private:GetTabName(private.frame.guildDropdown.selected, data.tabID)
        end,
    },
    [3] = {
        header = "Type",
        width = 1,
        text = function(data)
            return data.transactionType
        end,
        sortValue = function(data)
            return data.transactionType
        end,
    },
    [4] = {
        header = "Name",
        width = 1,
        text = function(data)
            return data.name
        end,
        sortValue = function(data)
            return data.name
        end,
    },
    [5] = {
        header = "Item/Amount",
        width = 2.25,
        text = function(data)
            return data.itemLink or GetCoinTextureString(data.amount)
        end,
        icon = function(icon, data)
            if data.itemLink then
                icon:SetPoint("TOPLEFT")
                icon:SetTexture(GetItemIcon(data.itemLink))
                icon:SetSize(12, 12)
                return true
            end
        end,
        tooltip = function(data)
            if data.itemLink then
                GameTooltip:SetHyperlink(data.itemLink)
                return true
            end
        end,
        sortValue = function(data)
            local itemString = select(3, strfind(data.itemLink or "", "|H(.+)|h"))
            local itemName = select(3, strfind(itemString or "", "%[(.+)%]"))
            return itemName or data.amount
        end,
    },
    [6] = {
        header = "Quantity",
        width = 0.5,
        text = function(data)
            return data.count or ""
        end,
        sortValue = function(data)
            return data.count or 0
        end,
    },
    [7] = {
        header = "Move Origin",
        width = 1,
        text = function(data)
            return data.moveOrigin and data.moveOrigin > 0 and private:GetTabName(private.frame.guildDropdown.selected, data.moveOrigin) or ""
        end,
        sortValue = function(data)
            return data.moveOrigin or 0
        end,
    },
    [8] = {
        header = "Move Destination",
        width = 1,
        text = function(data)
            return data.moveDestination and data.moveDestination > 0 and private:GetTabName(private.frame.guildDropdown.selected, data.moveDestination) or ""
        end,
        sortValue = function(data)
            return data.moveDestination or 0
        end,
    },
    [9] = {
        header = "Scan ID",
        width = 0.25,
        text = function(data)
            return ""
        end,
        icon = function(icon)
            icon:SetPoint("TOP")
            icon:SetTexture(374216)
            icon:SetSize(12, 12)
            return true
        end,
        tooltip = function(data, order)
            GameTooltip:AddLine(format("%s %d", L["Entry"], order))
            GameTooltip:AddDoubleLine(L["Scan Date"], date(private.db.global.settings.preferences.dateFormat, data.scanID), nil, nil, nil, 1, 1, 1)
            GameTooltip:AddDoubleLine(L["Tab ID"], data.tabID, nil, nil, nil, 1, 1, 1)
            GameTooltip:AddDoubleLine(L["Transaction ID"], data.transactionID, nil, nil, nil, 1, 1, 1)
            if data.moveOrigin and data.moveOrigin > 0 then
                GameTooltip:AddDoubleLine(L["Move Origin ID"], data.moveOrigin, nil, nil, nil, 1, 1, 1)
            end
            if data.moveDestination and data.moveDestination > 0 then
                GameTooltip:AddDoubleLine(L["Move Destination ID"], data.moveDestination, nil, nil, nil, 1, 1, 1)
            end
        end,
        sortValue = function(data)
            return data.scanID
        end,
    },
}

-- [[ Sorter ]]
---------------
local function CreateSorter()
    local sorter = CreateFrame("Frame", nil, private.frame.sorters, "BackdropTemplate")
    sorter:EnableMouse(true)
    sorter:RegisterForDrag("LeftButton")
    sorter:SetHeight(20)

    -- Textures
    private:AddBackdrop(sorter)

    -- Text
    sorter.orderText = private:CreateFontString(sorter)
    sorter.orderText:SetSize(20, 20)
    sorter.orderText:SetPoint("RIGHT", -4, 0)

    sorter.text = private:CreateFontString(sorter)
    sorter.text:SetHeight(20)
    sorter.text:SetPoint("TOPLEFT", 4, -4)
    sorter.text:SetPoint("RIGHT", sorter.orderText, "LEFT", -4, 0)
    sorter.text:SetPoint("BOTTOM", 0, 4)

    -- Methods
    function sorter:IsDescending()
        if not self.colID then
            return
        end

        return private.db.global.settings.preferences.descendingHeaders[self.colID]
    end

    function sorter:SetColID(sorterID, colID)
        sorter.sorterID = sorterID
        sorter.colID = colID
        self:UpdateText()
    end

    function sorter:SetDescending(bool)
        if not self.colID then
            return
        end

        private.db.global.settings.preferences.descendingHeaders[self.colID] = bool
    end

    function sorter:UpdateText(insertSorter)
        if not self.colID then
            self.orderText:SetText("")
            self.text:SetText("")
            return
        end

        local order = self:IsDescending() and "▼" or "▲"
        self.orderText:SetText(order)

        local header = cols[self.colID].header
        self.text:SetText(format("%s%s%s", insertSorter or "", insertSorter and " " or "", header))
    end

    function sorter:UpdateWidth()
        self:SetWidth((self:GetParent():GetWidth() - 10) / addon:tcount(cols))
    end

    -- Scripts
    sorter:SetScript("OnDragStart", function(self)
        private.frame.sorters.dragging = self.sorterID
        self:SetBackdropColor(unpack(private.defaults.gui.emphasizeBgColor))
    end)

    sorter:SetScript("OnDragStop", function(self)
        -- Must reset dragging ID in this script in addition to the receiving sorter in case it isn't dropped on a valid sorter
        -- Need to delay to make sure the ID is still accessible to the receiving sorter
        C_Timer.After(1, function()
            private.frame.sorters.dragging = nil
        end)

        sorter:SetBackdropColor(unpack(private.defaults.gui.darkBgColor))
    end)

    sorter:SetScript("OnEnter", function(self)
        -- Emphasize highlighted text
        self.text:SetTextColor(unpack(private.defaults.gui.emphasizeFontColor))

        -- Add indicator for sorting insertion
        local sorterID = self.sorterID
        local draggingID = private.frame.sorters.dragging

        if draggingID and draggingID ~= sorterID then
            if sorterID < draggingID then
                -- Insert before
                self:UpdateText("<")
            else
                -- Insert after
                self:UpdateText(">")
            end

            -- Highlight frame to indicate where dragged header is moving
            sorter:SetBackdropColor(unpack(private.defaults.gui.highlightBgColor))
        end

        -- Show tooltip if text is truncated
        if not self.colID or self.text:GetWidth() > self.text:GetStringWidth() then
            return
        end

        private:InitializeTooltip(self, "ANCHOR_RIGHT", function(self, cols)
            GameTooltip:AddLine(cols[self.colID].header, 1, 1, 1)
        end, self, cols)
    end)

    sorter:SetScript("OnLeave", function(self)
        -- Restore default text color
        sorter.text:SetTextColor(unpack(private.defaults.gui.fontColor))

        -- Remove sorting indicator
        self:UpdateText()
        if self.sorterID ~= private.frame.sorters.dragging then
            -- Don't reset backdrop on dragging frame; this is done in OnDragStop
            self:SetBackdropColor(unpack(private.defaults.gui.darkBgColor))
        end

        -- Hide tooltips
        private:ClearTooltip()
    end)

    sorter:SetScript("OnMouseUp", function(self)
        -- Changes sorting order
        self:SetDescending(not private.db.global.settings.preferences.descendingHeaders[sorter.colID])
        self:UpdateText()
        private.frame.scrollBox.Sort()
    end)

    sorter:SetScript("OnReceiveDrag", function(self)
        local sorterID = self.sorterID
        local draggingID = private.frame.sorters.dragging

        if not draggingID or draggingID == sorterID then
            return
        end

        private.frame.sorters.dragging = nil

        -- Get the colID to be inserted and remove the col from the sorting table
        -- The insert will go before/after by default because of the removed entry
        local colID = private.frame.sorters.children[draggingID].colID
        tremove(private.db.global.settings.preferences.sortHeaders, draggingID)
        tinsert(private.db.global.settings.preferences.sortHeaders, sorterID, colID)

        -- Reset sorters based on new order
        self:GetParent():LoadSorters()
    end)

    return sorter
end

local function ResetSorter(__, frame)
    frame:Hide()
end

local Sorter = CreateObjectPool(CreateSorter, ResetSorter)

-- [[ Frame ]]
--------------
local function InitializeGuildDropdown(self, level, menuList)
    local info = self.info

    local sortKeys = function(a, b)
        return private:GetGuildDisplayName(a) < private:GetGuildDisplayName(b)
    end

    for guildID, guild in addon:pairs(private.db.global.guilds, sortKeys) do
        info.value = guildID
        info.text = private:GetGuildDisplayName(guildID)
        info.checked = self.selected == guildID
        info.func = function()
            self:SetValue(self, guildID)
        end

        self:AddButton()
    end
end

local function SetGuildDropdown(self, guildID)
    self.selected = guildID
    self:SetText(private:GetGuildDisplayName(guildID))
    private:LoadTransactions(guildID)
end

function private:InitializeFrame()
    local frame = CreateFrame("Frame", addonName .. "Frame", UIParent, "SettingsFrameTemplate")
    frame.NineSlice.Text:SetFont(unpack(private.defaults.gui.fontLarge))
    frame.NineSlice.Text:SetText(L.addonName)
    frame:SetSize(1000, 500)
    frame:SetPoint("CENTER")
    frame:Hide()

    private:SetFrameSizing(frame, 500, 300, GetScreenWidth() - 400, GetScreenHeight() - 200)
    private:AddSpecialFrame(frame)
    private.frame = frame

    -- [[ Ribbon ]]
    ----------------
    -- Guild dropdown
    frame.guildDD = private:CreateDropdown(frame, addonName .. "GuildDropdown", SetGuildDropdown, InitializeGuildDropdown)
    frame.guildDD:SetDropdownWidth(200)
    frame.guildDD:SetPoint("TOPLEFT", frame.Bg, "TOPLEFT", 10, -10)
    frame.guildDD:SetScript("OnShow", function(self)
        self:Initialize()
    end)

    -- Sorters
    frame.sorters = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.sorters:SetHeight(30)
    frame.sorters.children = {}

    frame.sorters.text = frame.sorters:CreateFontString(nil, "OVERLAY", "NumberFontNormalYellow")
    frame.sorters.text:SetJustifyH("LEFT")
    frame.sorters.text:SetText(L["Sort By Header"])

    frame.sorters.text:SetPoint("TOPLEFT", frame.guildDD, "BOTTOMLEFT", 0, -10)
    frame.sorters:SetPoint("TOPLEFT", frame.sorters.text, "BOTTOMLEFT", 0, -2)
    frame.sorters:SetPoint("RIGHT", -10, 0)

    -- [[ Table ]]
    ---------------------
    local scrollBox = CreateFrame("Frame", nil, frame, "WoWScrollBoxList")
    function scrollBox:Sort()
        local DataProvider = scrollBox:GetDataProvider()
        if DataProvider then
            DataProvider:Sort()
        end
    end

    local scrollBar = CreateFrame("EventFrame", nil, frame, "MinimalScrollBar")

    -- Headers
    frame.headers = {}
    for id, col in addon:pairs(cols) do
        -- [[ Header ]]
        local header = frame.headers[id] or CreateFrame("Button", nil, frame, "BackdropTemplate")
        header:SetBackdrop({
            bgFile = [[Interface\Buttons\WHITE8x8]],
            edgeFile = [[Interface\Buttons\WHITE8x8]],
            edgeSize = 1,
        })
        header:SetBackdropBorderColor(0, 0, 0)
        header:SetBackdropColor(0, 0, 0, 0.5)

        header:SetHeight(20)
        frame.headers[id] = header

        header.debugTex = header.debugTex or header:CreateTexture(nil, "BACKGROUND")
        header.debugTex:SetAllPoints(header)
        header.debugTex:SetColorTexture(fastrandom(), fastrandom(), fastrandom(), 1)
        header.debugTex:Hide()

        header.text = header.text or header:CreateFontString(nil, "OVERLAY", "NumberFontNormalYellow")
        header.text:SetPoint("TOPLEFT", 4, -4)
        header.text:SetPoint("BOTTOMRIGHT", -4, 4)
        header.text:SetJustifyH("LEFT")
        header.text:SetJustifyV("BOTTOM")
        header.text:SetText(col.header)

        header:SetScript("OnEnter", function()
            if header.text:GetWidth() < header.text:GetStringWidth() then
                GameTooltip:SetOwner(header, "ANCHOR_RIGHT")
                GameTooltip:AddLine(header.text:GetText(), 1, 1, 1)
                GameTooltip:Show()
            end
        end)

        header:SetScript("OnLeave", function()
            private:ClearTooltip()
        end)

        -- header:SetScript("OnClick", function()
        --     local DataProvider = scrollBox:GetDataProvider()
        --     if DataProvider then
        --         if col.des then
        --             col.des = nil
        --         else
        --             col.des = true
        --         end

        --         DataProvider:Sort()
        --         scrollBox:Update()
        --     end
        -- end)

        function header:DoLayout()
            header:SetPoint("TOP", frame.sorters, "BOTTOM", 0, -10)
            if id == 1 then
                header:SetPoint("LEFT", frame.sorters, "LEFT", 0, 0)
            else
                header:SetPoint("LEFT", frame.headers[id - 1], "RIGHT", 0, 0)
            end
            header:SetWidth((scrollBox.colWidth or 0) * col.width)
        end

        header:DoLayout()
    end

    -- Set scrollBox/scrollBar points
    scrollBar:SetPoint("BOTTOMRIGHT", -10, 10)
    scrollBar:SetPoint("TOP", frame.headers[1], "BOTTOM", 0, -10)
    scrollBox:SetPoint("TOPLEFT", frame.headers[1], "BOTTOMLEFT", 0, 0)
    scrollBox:SetPoint("RIGHT", scrollBar, "LEFT", -10, 0)
    scrollBox:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)

    -- Create scrollView
    local scrollView = CreateScrollBoxListLinearView()

    scrollView:SetElementExtentCalculator(function()
        return 20
    end)

    scrollView:SetElementInitializer("Frame", function(frame, data)
        frame.bg = frame.bg or frame:CreateTexture(nil, "BACKGROUND")
        frame.bg:SetAllPoints(frame)
        frame.bg:SetColorTexture(0, 0, 0, 0.5)

        frame.cells = frame.cells or {}

        function frame:SetHighlighted(isHighlighted)
            for _, cell in pairs(frame.cells) do
                if isHighlighted then
                    cell.text:SetTextColor(1, 0.82, 0, 1)
                else
                    cell.text:SetTextColor(1, 1, 1, 1)
                end
            end

            if isHighlighted then
                frame.bg:SetColorTexture(0, 0, 0, 0.25)
            else
                frame.bg:SetColorTexture(0, 0, 0, 0.5)
            end
        end

        frame:SetScript("OnEnter", function()
            frame:SetHighlighted(true)
        end)

        frame:SetScript("OnLeave", function()
            frame:SetHighlighted()
            private:ClearTooltip()
        end)

        for id, col in pairs(cols) do
            local cell = frame.cells[id] or CreateFrame("Button", nil, frame)
            frame.cells[id] = cell

            cell.debugTex = cell.debugTex or cell:CreateTexture(nil, "BACKGROUND")
            cell.debugTex:SetAllPoints(cell)
            cell.debugTex:SetColorTexture(fastrandom(), fastrandom(), fastrandom(), 1)
            cell.debugTex:Hide()

            cell.icon = cell.icon or cell:CreateTexture(nil, "ARTWORK")
            cell.icon:ClearAllPoints()
            cell.icon:SetTexture()

            cell.text = cell.text or cell:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
            cell.text:SetPoint("TOPLEFT", 2, -2)
            cell.text:SetPoint("BOTTOMRIGHT", -2, 2)
            cell.text:SetJustifyH("LEFT")
            cell.text:SetJustifyV("TOP")
            cell.text:SetText(col.text(data))

            if col.icon then
                local success = col.icon(cell.icon, data)
                if success then
                    cell.text:SetPoint("TOPLEFT", cell.icon, "TOPRIGHT", 2, 0)
                end
            end

            function cell:SetPoints()
                cell:SetPoint("TOP")
                if id == 1 then
                    cell:SetPoint("LEFT", 0, 0)
                    cell:SetPoint("RIGHT", frame, "LEFT", (scrollBox.colWidth or 0) * col.width, 0)
                else
                    cell:SetPoint("LEFT", frame.cells[id - 1], "RIGHT", 0, 0)
                    cell:SetPoint("RIGHT", frame.cells[id - 1], "RIGHT", (scrollBox.colWidth or 0) * col.width, 0)
                end
                cell:SetPoint("BOTTOM")
            end

            cell:SetScript("OnEnter", function()
                frame:SetHighlighted(true)
                GameTooltip:SetOwner(cell, "ANCHOR_RIGHT")
                if col.tooltip then
                    local success = col.tooltip(data, frame:GetOrderIndex())
                    GameTooltip:Show()
                    if success then
                        return
                    end
                end

                if cell.text:GetWidth() < cell.text:GetStringWidth() then
                    GameTooltip:AddLine(cell.text:GetText(), 1, 1, 1)
                    GameTooltip:Show()
                end
            end)

            cell:SetScript("OnLeave", function()
                frame:SetHighlighted()
                private:ClearTooltip()
            end)
        end

        function frame:ArrangeCells()
            for _, cell in pairs(frame.cells) do
                cell:SetPoints()
            end
        end

        frame:SetScript("OnSizeChanged", frame.ArrangeCells)
        frame:ArrangeCells()
    end)

    ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, scrollView)

    -- OnSizeChanged scripts

    function frame.sorters:LoadSorters()
        for _, child in pairs(frame.sorters.children) do
            Sorter:Release(child)
        end

        for id = 1, addon:tcount(cols) do
            local sorter = Sorter:Acquire()
            sorter:SetColID(id, private.db.global.settings.preferences.sortHeaders[id])
            frame.sorters.children[id] = sorter

            sorter:Show()
            if id == 1 then
                sorter:SetPoint("LEFT", frame.sorters, "LEFT", 5, 0)
            else
                sorter:SetPoint("LEFT", frame.sorters.children[id - 1], "RIGHT", 0, 0)
            end
        end

        local DataProvider = scrollBox:GetDataProvider()
        if DataProvider then
            DataProvider:Sort()
            scrollBox:Update()
        end
    end

    frame.sorters:LoadSorters()

    function frame:ArrangeHeaders()
        for _, sorter in pairs(frame.sorters.children) do
            sorter:UpdateWidth(frame.sorters)
        end

        for _, header in pairs(frame.headers) do
            header:DoLayout()
        end
    end
    frame:ArrangeHeaders()

    scrollBox:SetScript("OnSizeChanged", function(self, width)
        self.width = width
        self.colWidth = width / addon:tcount(cols)
        frame:ArrangeHeaders()

        -- Need this to populate new entries when scrollBox gains height
        scrollBox:Update()
    end)

    -- [[ Post layout ]]
    frame.guildDropdown = frame.guildDD
    frame.scrollBox = scrollBox
    scrollBox.scrollBar = scrollBar
    scrollBox.scrollView = scrollView

    -- Select default guild
    -- guildDD:SetValue(private.db.global.settings.preferences.defaultGuild)
end

function private:LoadFrame()
    private.frame:Show()
end

-- [[ Data Provider ]]
----------------------
function private:LoadTransactions(guildID)
    local scrollBox = private.frame.scrollBox
    -- Clear transactions if no guildID is provided
    if not guildID then
        scrollBox:Flush()
        return
    end

    local DataProvider = CreateDataProvider()

    for scanID, scan in pairs(private.db.global.guilds[guildID].scans) do
        for tabID, tab in pairs(scan.tabs) do
            for transactionID, transaction in pairs(tab.transactions) do
                local transactionType, name, itemLink, count, moveOrigin, moveDestination, year, month, day, hour = select(2, AceSerializer:Deserialize(transaction))

                DataProvider:Insert({
                    scanID = scanID,
                    tabID = tabID,
                    transactionID = transactionID,
                    transactionType = transactionType,
                    name = name,
                    itemLink = itemLink,
                    count = count,
                    moveOrigin = moveOrigin,
                    moveDestination = moveDestination,
                    year = year,
                    month = month,
                    day = day,
                    hour = hour,
                })
            end
        end

        for transactionID, transaction in pairs(scan.moneyTransactions) do
            local transactionType, name, amount, year, month, day, hour = select(2, AceSerializer:Deserialize(transaction))

            DataProvider:Insert({
                scanID = scanID,
                tabID = MAX_GUILDBANK_TABS + 1,
                transactionID = transactionID,
                transactionType = transactionType,
                name = name,
                amount = amount,
                year = year,
                month = month,
                day = day,
                hour = hour,
            })
        end
    end

    DataProvider:SetSortComparator(function(a, b)
        for i = 1, addon:tcount(private.db.global.settings.preferences.sortHeaders) do
            local id = private.db.global.settings.preferences.sortHeaders[i]
            local sortValue = cols[id].sortValue
            local des = private.db.global.settings.preferences.descendingHeaders[id]

            local sortA = sortValue(a)
            local sortB = sortValue(b)

            if type(sortA) ~= type(sortB) then
                sortA = tostring(sortA)
                sortB = tostring(sortB)
            end

            if sortA > sortB then
                if des then
                    return true
                else
                    return false
                end
            elseif sortA < sortB then
                if des then
                    return false
                else
                    return true
                end
            end
        end
    end)

    scrollBox:SetDataProvider(DataProvider)
end
