local Portals = LibStub("AceAddon-3.0"):GetAddon("BrokerPortals")
local icon = LibStub('LibDBIcon-1.0')
local L = LibStub("AceLocale-3.0"):GetLocale("BrokerPortals")
local dewdrop = LibStub('Dewdrop-2.0', true)

local minimap = LibStub:GetLibrary('LibDataBroker-1.1'):NewDataObject("BrokerPortals", {
    type = "data source",
    text = L['P'],
    icon = Portals.defaultIcon
})

function minimap.OnClick(button)
  Portals:OpenMenu(button)
end

function minimap.OnLeave()
    GameTooltip:Hide()
end

function minimap.OnEnter(button)
  Portals:OnEnter(button)
end

function Portals:SlashCommands(msg)
    if msg == "macromenu" then
        if dewdrop:IsOpen(GetMouseFocus()) then dewdrop:Close() return end
        dewdrop:Open(GetMouseFocus(), 'children', function(level, value) self:UpdateMenu(level, value) end)
    elseif msg == "learnstones" then
      self:LearnUnknownStones()
    elseif msg == "resetfavorites" then
      self.db.favorites = { Default = {} }
    else
      self:ToggleMinimap()
      if self.db.minimap and not self.options.minimap:GetChecked() then
        self.options.minimap:SetChecked()
      else
        self.options.minimap:SetChecked(false)
      end
    end
end


function Portals:ToggleMinimap()
  self.db.minimap = not self.db.minimap
  if self.db.minimap then
    icon:Hide('BrokerPortals')
  else
    icon:Show('BrokerPortals')
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