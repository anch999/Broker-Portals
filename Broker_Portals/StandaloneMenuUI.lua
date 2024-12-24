local Portals = LibStub("AceAddon-3.0"):GetAddon("BrokerPortals")
local CYAN =  "|cff00ffff"
local LIMEGREEN = "|cFF32CD32"
local L = LibStub("AceLocale-3.0"):GetLocale("BrokerPortals")
--------------- Creates the main misc menu standalone button ---------------

function Portals:CreateUI()

    self.standaloneButton = CreateFrame("Button", "BrokerPortalsStandaloneButton", UIParent)
    self.standaloneButton:SetSize(70, 70)
    self.standaloneButton:EnableMouse(true)
    self.standaloneButton:SetScript("OnDragStart", function() self.standaloneButton:StartMoving() end)
    self.standaloneButton:SetScript("OnDragStop", function()
        self.standaloneButton:StopMovingOrSizing()
        self.charDB.menuPos = { self.standaloneButton:GetPoint() }
        self.charDB.menuPos[2] = "UIParent"
    end)
    self.standaloneButton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
    self.standaloneButton.icon = self.standaloneButton:CreateTexture(nil, "ARTWORK")
    self.standaloneButton.icon:SetSize(55, 55)
    self.standaloneButton.icon:SetPoint("CENTER", self.standaloneButton, "CENTER", 0, 0)
    self.standaloneButton.icon:SetTexture(self.defaultIcon)
    self.standaloneButton.Text = self.standaloneButton:CreateFontString()
    self.standaloneButton.Text:SetFont("Fonts\\FRIZQT__.TTF", 13)
    self.standaloneButton.Text:SetFontObject(GameFontNormal)
    self.standaloneButton.Text:SetText("|cffffffffBroker\nPortals")
    self.standaloneButton.Text:SetPoint("CENTER", self.standaloneButton.icon, "CENTER", 0, 0)
    self.standaloneButton.Highlight = self.standaloneButton:CreateTexture(nil, "OVERLAY")
    self.standaloneButton.Highlight:SetSize(70, 70)
    self.standaloneButton.Highlight:SetPoint("CENTER", self.standaloneButton, 0, 0)
    self.standaloneButton.Highlight:SetTexture("Interface\\AddOns\\AwAddons\\Textures\\EnchOverhaul\\Slot2Selected")
    self.standaloneButton.Highlight:Hide()
    self.standaloneButton:SetScale(self.db.buttonScale or 1)
    self.standaloneButton:SetScript("OnClick", function(button, btnclick)
        if btnclick == "RightButton" then
            if self.unlocked then
                self:UnlockFrame()
            end
        elseif not self.unlocked then
            self:OpenMenu(button, true)
        end
    end)
    self.standaloneButton:SetScript("OnEnter", function(button)
        if self.unlocked then
            GameTooltip:SetOwner(button, "ANCHOR_TOP")
            GameTooltip:AddLine("Left click to drag")
            GameTooltip:AddLine("Right click to lock frame")
            GameTooltip:Show()
        else
            self:OnEnter(button, true)
            self.standaloneButton.Highlight:Show()
            self:OpenMenu(button, true)
        end
        if self.db.enableAutoHide then
            self.standaloneButton:SetAlpha(10)
        end
    end)
    self.standaloneButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
        if not self.unlocked then
            self.standaloneButton.Highlight:Hide()
        end
        if self.db.enableAutoHide and not self.unlocked then
            self.standaloneButton:SetAlpha(0)
        end
    end)
    self:SetMenuPos()
    self:SetFrameAlpha()
    if not self.db.hideMenu then
        self.standaloneButton:Show()
    end
end

--------------- Frame functions for misc menu standalone button---------------

function Portals:SetMenuPos()
    if self.charDB.menuPos then
        local pos = self.charDB.menuPos
        self.standaloneButton:ClearAllPoints()
        self.standaloneButton:SetPoint(pos[1], pos[2], pos[3], pos[4], pos[5])
    else
        self.standaloneButton:ClearAllPoints()
        self.standaloneButton:SetPoint("CENTER", UIParent)
    end
end

function Portals:SetFrameAlpha()
    if self.db.enableAutoHide then
        self.standaloneButton:SetAlpha(0)
    else
        self.standaloneButton:SetAlpha(10)
    end
end

-- Used to show highlight as a frame mover
function Portals:UnlockFrame()
    self = Portals
    if self.unlocked then
        self.standaloneButton:SetMovable(false)
        self.standaloneButton:RegisterForDrag()
        self.standaloneButton.Highlight:Hide()
        if self.db.enableAutoHide then
            self.standaloneButton:SetAlpha(0)
        end
        self.unlocked = false
        GameTooltip:Hide()
    else
        self.standaloneButton:SetMovable(true)
        self.standaloneButton:RegisterForDrag("LeftButton")
        self.standaloneButton.Highlight:Show()
        if self.db.enableAutoHide then
            self.standaloneButton:SetAlpha(10)
        end
        self.unlocked = true
    end
end

-- toggle the main button frame
function Portals:ToggleStandaloneButton()
    if self.standaloneButton:IsVisible() then
        self.standaloneButton:Hide()
    else
        self.standaloneButton:Show()
    end
end