local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function GuildBankSnapshotsTabButton_OnLoad(tab)
    tab = private:MixinWidget(tab)

    tab:InitScripts({
        OnAcquire = function(self)
            tab:SetSelected()
            self:SetSize(150, 20)
            self:UpdateText()
            self:UpdateWidth()
        end,

        OnClick = function(self)
            self:SetSelected(true)

            -- Unselect other tabs
            for tab, _ in private.frame.tabContainer:EnumerateActive() do
                if tab:GetTabID() ~= self.tabID then
                    tab:SetSelected()
                end
            end
        end,

        OnRelease = function(self)
            self.tabID = nil
            self.info = nil
        end,
    })

    -- Textures
    tab.border = tab:CreateTexture(nil, "BACKGROUND")
    tab.border:SetColorTexture(private.interface.colors.borderColor:GetRGBA())
    tab.border:SetAllPoints(tab)

    tab.normal = tab:CreateTexture(nil, "BACKGROUND")
    tab.normal:SetColorTexture(private.interface.colors.elementColor:GetRGBA())
    tab.normal:SetPoint("TOPLEFT", tab.border, "TOPLEFT", 1, -1)
    tab.normal:SetPoint("BOTTOMRIGHT", tab.border, "BOTTOMRIGHT", -1, 1)

    tab.selected = tab:CreateTexture(nil, "BACKGROUND")
    tab.selected:SetColorTexture(private.interface.colors.insetColor:GetRGBA())
    tab.selected:SetAllPoints(tab.normal)

    tab.highlight = tab:CreateTexture(nil, "BACKGROUND")
    tab.highlight:SetColorTexture(private.interface.colors.highlightColor:GetRGBA())
    tab.highlight:SetAllPoints(tab.normal)

    tab:SetNormalTexture(tab.normal)
    tab:SetHighlightTexture(tab.highlight)

    -- Text
    tab:SetText("")
    tab:SetNormalFontObject(GameFontNormal)
    tab:SetHighlightFontObject(GameFontHighlight)
    tab:SetPushedTextOffset(0, 0)

    -- Methods
    function tab:GetTabID()
        return self.tabID
    end

    function tab:SetSelected(isSelected)
        if isSelected then
            tab:SetNormalTexture(tab.selected)
        else
            tab:SetNormalTexture(tab.normal)
        end
    end

    function tab:SetTab(tabID, info)
        self.tabID = tabID
        self.info = info
        self:UpdateText()
        self:UpdateWidth()
    end

    function tab:UpdateText()
        tab:SetText("")

        if not self.tabID then
            return
        end

        tab:SetText(self.info.header)
    end

    function tab:UpdateWidth()
        self:SetWidth(150)

        if not self.tabID then
            return
        end

        self:SetWidth(self:GetTextWidth() + 20)
    end
end
