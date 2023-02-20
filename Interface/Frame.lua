local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

--*----------[[ Data ]]----------*--
local tabs = {
    {
        header = L["Review"],
        onClick = function(content)
            private:LoadReviewTab(content)
        end,
    },
    {
        header = L["Analyze"],
        onClick = function(content) end,
    },
    {
        header = L["Settings"],
        onClick = function(content)
            private:LoadSettingsTab(content)
        end,
    },
    {
        header = L["Help"],
        onClick = function(content) end,
    },
}

--*----------[[ Methods ]]----------*--
function private:InitializeFrame()
    local frame = CreateFrame("Frame", "GuildBankSnapshotsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(1000, 500)
    frame:SetPoint("CENTER")
    frame:Hide()

    private:AddBackdrop(frame, "bgColor")
    private:SetFrameSizing(frame, 500, 300, GetScreenWidth() - 400, GetScreenHeight() - 200)
    private:AddSpecialFrame(frame)
    private.frame = frame

    -- [[ Title bar ]]
    frame.titleBar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    frame.titleBar:SetHeight(26)
    frame.titleBar:SetPoint("TOPLEFT")
    frame.titleBar:SetPoint("RIGHT")
    private:AddBackdrop(frame.titleBar, "bgColor")

    frame.closeButton = CreateFrame("Button", nil, frame.titleBar)
    frame.closeButton:SetSize(22, 22)
    frame.closeButton:SetPoint("RIGHT", -4, 0)
    frame.closeButton:SetText("x")
    frame.closeButton:SetNormalFontObject(GameFontNormal)
    frame.closeButton:SetHighlightFontObject(GameFontHighlight)
    frame.closeButton:SetScript("OnClick", function()
        frame:Hide()
    end)

    frame.title = frame.titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.title:SetText(L.addonName)
    frame.title:SetPoint("TOPLEFT", 4, -2)
    frame.title:SetPoint("BOTTOMRIGHT", -4, 2)

    -- [[ Tabs ]]
    frame.tabContainer = CreateFrame("Frame", nil, frame, "GuildBankSnapshotsContainer")
    frame.tabContainer:SetPoint("TOPLEFT", frame.titleBar, "BOTTOMLEFT", 10, -10)
    frame.tabContainer:SetPoint("RIGHT", -10, 0)
    frame.tabContainer.children = {}

    -- [[ Content ]]
    frame.content = CreateFrame("Frame", nil, frame, "GuildBankSnapshotsContainer")
    frame.content:SetPoint("TOPLEFT", frame.tabContainer, "BOTTOMLEFT")
    frame.content:SetPoint("RIGHT", frame.tabContainer, "RIGHT")
    frame.content:SetPoint("BOTTOMRIGHT", -10, 10)
    private:AddBackdrop(frame.content, "insetColor")

    function frame:SelectTab(tabID)
        self.selectedTab = tabID
        self.content:ReleaseAll()
        tabs[tabID].onClick(self.content)
    end

    -- [[ Scripts ]]
    frame:SetScript("OnSizeChanged", function(self)
        self.tabContainer:ReleaseAll()
        private:CloseMenus()

        local width, height = 0, 0

        for tabID, info in addon:pairs(tabs) do
            local tab = self.tabContainer:Acquire("GuildBankSnapshotsTabButton")
            tab:SetTab(tabID, info)
            if tabID == self.selectedTab then
                -- Ensure active tab stays selected when frame size changes, since the tabs are being released and redrawn
                tab:SetSelected(true)
            end
            tab:SetCallback("OnClick", function()
                self:SelectTab(tabID)
            end)

            local tabWidth = tab:GetWidth()
            local tabHeight = tab:GetHeight()

            if (width + tabWidth + ((tabID - 1) * 2)) > self.tabContainer:GetWidth() then
                width = 0
                height = height + tabHeight
            end

            tab:SetPoint("BOTTOMLEFT", width, height)
            width = width + tabWidth

            self.tabContainer:SetHeight(height + tabHeight)
        end
    end, true)

    private:InitializeReviewTab()
end

local loaded
function private:LoadFrame()
    private.frame:Show()
    if not loaded then
        -- Load default tab
        loaded = true
        for tab, _ in private.frame.tabContainer:EnumerateActive() do
            if tab:GetTabID() == 1 then
                tab:Fire("OnClick")
            end
        end
    end
end
