local Portals = LibStub("AceAddon-3.0"):GetAddon("BrokerPortals")
local icon = LibStub('LibDBIcon-1.0')
local L = LibStub("AceLocale-3.0"):GetLocale("BrokerPortals")
local dewdrop = LibStub('Dewdrop-2.0', true)

local minimap = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject("BrokerPortals", {
    type = "data source",
    text = L['P'],
    icon = Portals.defaultIcon
})

-- All credit for this func goes to Tekkub and his picoGuild!
local function GetTipAnchor(frame)
    local x, y = frame:GetCenter()
    if not x or not y then return 'TOPLEFT', 'BOTTOMLEFT' end
    local hhalf = (x > UIParent:GetWidth() * 2 / 3) and 'RIGHT' or (x < UIParent:GetWidth() / 3) and 'LEFT' or ''
    local vhalf = (y > UIParent:GetHeight() / 2) and 'TOP' or 'BOTTOM'
    return vhalf .. hhalf, frame, (vhalf == 'TOP' and 'BOTTOM' or 'TOP') .. hhalf
  end
  

function minimap.OnClick(self, button)
    GameTooltip:Hide()
    dewdrop:Open(self,
    'point', function(parent)
      return "TOP", "BOTTOM"
    end,
    'children', function(level, value)
        Portals:UpdateMenu(level, value)
    end)
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function minimap.OnEnter(button)
    GameTooltip:SetOwner(button, 'ANCHOR_NONE')
    GameTooltip:SetPoint(GetTipAnchor(button))
    GameTooltip:ClearLines()

    GameTooltip:AddLine('Broker Portals')
    GameTooltip:AddDoubleLine(L['RCLICK'], L['SEE_SPELLS'], 0.9, 0.6, 0.2, 0.2, 1, 0.2)
    GameTooltip:AddDoubleLine(L['ALTCLICK'], L['MOVE_SPELLS'], 0.9, 0.6, 0.2, 0.2, 1, 0.2)
    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(L['HEARTHSTONE'] .. ': ' .. GetBindLocation(), Portals:GetHearthCooldown(), 0.9, 0.6, 0.2, 0.2, 1,
      0.2)

    if PortalsDB.showItemCooldowns then
      local cooldowns = Portals:GetItemCooldowns()
      if cooldowns ~= nil then
        GameTooltip:AddLine(' ')
        for name, cooldown in pairs(cooldowns) do
          GameTooltip:AddDoubleLine(name, cooldown, 0.9, 0.6, 0.2, 0.2, 1, 0.2)
        end
      end
    end

    GameTooltip:Show()
end

function Portals:ToggleMinimap(msg)
    if msg == "macromenu" then
        if Portals:IsOpen(GetMouseFocus()) then Portals:Close() return end
        Portals:Open(GetMouseFocus(), 'children', function(level, value) Portals:UpdateMenu(level, value) end)
      else
        local hide = not self.db.minimap.hide
        self.db.minimap.hide = hide
        if hide then
          icon:Hide('BrokerPortals')
        else
          icon:Show('BrokerPortals')
        end
      end
end

function Portals:InitializeMinimap()
    if icon then
        self.minimap = {hide = self.db.minimap}
        icon:Register('BrokerPortals', minimap, self.minimap)
    end
    minimap.icon = self.defaultIcon
end

function Portals:SetMapIcon(icon)
    minimap.icon = icon
end