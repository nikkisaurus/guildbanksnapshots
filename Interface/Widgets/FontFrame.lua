local addonName, private = ...
local addon = LibStub("AceAddon-3.0"):GetAddon(addonName)
local L = LibStub("AceLocale-3.0"):GetLocale(addonName, true)

function GuildBankSnapshotsFontFrame_OnLoad(frame)
    frame:EnableMouse(true)
    frame = private:MixinText(frame)
    frame:InitScripts({
        OnAcquire = function(self)
            self:SetSize(150, 20)
            self:SetAutoHeight(false)
            self:SetFont(GameFontHighlightSmall, private.interface.colors.white)
            self:Justify("CENTER", "MIDDLE")
            self:SetText("")
            self:SetPadding(0, 0)
            self:SetTextColor(1, 1, 1, 1)
        end,

        OnEnter = function(self)
            -- Show full text if truncated
            if not self.autoHeight and not self:GetUserData("disableTooltip") and self.text:GetStringWidth() > self.text:GetWidth() then
                private:InitializeTooltip(self, "ANCHOR_RIGHT", function(self)
                    local text = self.text:GetText()
                    GameTooltip:AddLine(text, unpack(private.interface.colors.white))
                end)
            end
        end,

        OnLeave = GenerateClosure(private.HideTooltip, private),
    })

    -- Elements
    frame.text = frame:CreateFontString(nil, "OVERLAY")

    -- Methods
    function frame:DisableTooltip(isDisabled)
        self:SetUserData("disableTooltip", isDisabled)
    end

    function frame:SetFont(fontObject, color)
        self.text:SetFontObject(fontObject or GameFontHighlightSmall)
        self.text:SetTextColor((color and color or private.interface.colors.white):GetRGBA())
    end
end
