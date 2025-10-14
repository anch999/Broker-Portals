local Portals = LibStub("AceAddon-3.0"):GetAddon("BrokerPortals")
local L = LibStub("AceLocale-3.0"):GetLocale("BrokerPortals")
local WHITE = "|cffFFFFFF"

function Portals:OptionsToggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("Broker_Portals")
	end
end

--Creates the options frame and all its assets
function Portals:CreateOptionsUI()
	local Options = {
		AddonName = "Broker_Portals",
		TitleText = "Broker Portals Settings",
		{
		Name = "Broker Poratls",
		Left = {
			{
				Type = "CheckButton",
				Name = "hideMenu",
				Lable = "Hide Standalone Button",
				OnClick = 	function()
					if self.db.hideMenu then
						self.standaloneButton:Show()
						self.db.hideMenu = false
					else
						self.standaloneButton:Hide()
						self.db.hideMenu = true
					end
				end
			},
			{
				Type = "CheckButton",
				Name = "enableAutoHide",
				Lable = "Only Show Standalone Button on Hover",
				OnClick = function()
					self.db.enableAutoHide = not self.db.enableAutoHide
					self:SetFrameAlpha()
				end
			},
			{
				Type = "CheckButton",
				Name = "autoMenu",
				Lable = "Open menu on mouse over",
				OnClick = function() self.db.autoMenu = not self.db.autoMenu end
			},
			{
				Type = "CheckButton",
				Name = "showItems",
				Lable = L['SHOW_ITEMS'],
				OnClick = function() self.db.showItems = not self.db.showItems end
			},
			{
				Type = "CheckButton",
				Name = "showItemCooldowns",
				Lable = L['SHOW_ITEM_COOLDOWNS'],
				OnClick = function() self.db.showItemCooldowns = not self.db.showItemCooldowns end
			},
			{
				Type = "CheckButton",
				Name = "announce",
				Lable = L['ANNOUNCE'],
				OnClick = function() self.db.announce = not self.db.announce end
			},
			{
				Type = "Menu",
				Name = "announce",
				Lable = "Show Announce in",
				Menu = { "Say", "Yell", "Party/Raid" }
			},
			{
				Type = "CheckButton",
				Name = "showPortals",
				Lable = "Show portals only in Party/Raid",
				OnClick = function() self.db.showPortals = not self.db.showPortals end
			},
			{
				Type = "CheckButton",
				Name = "swapPortals",
				Lable = "Swap teleport to portal spells in Party/Raid",
				OnClick = function() self.db.swapPortals = not self.db.swapPortals end
			},
			{
				Type = "CheckButton",
				Name = "stonesSubMenu",
				Lable = "Show Stones Of Retreats As Menus",
				OnClick = function() self.db.stonesSubMenu = not self.db.stonesSubMenu end
			},
		},
		Right = {
			{
				Type = "CheckButton",
				Name = "deleteItem",
				Lable = "Delete vanity items after summoning",
				OnClick = function() self.db.deleteItem = not self.db.deleteItem end
			},
			{
				Type = "CheckButton",
				Name = "minimap",
				Lable = "Hide minimap icon",
				OnClick = function()
					self:ToggleMinimap()
				end
			},
			{
				Type = "Menu",
				Name = "txtSize",
				Lable = "Menu text size",
				Menu = {10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}
			},
			{
				Type = "Menu",
				Name = "ProfileSelect",
				Lable = "Profile selection",
				Func = 	function(name)
					self.activeProfile = name
					self.favoritesdb = self.db.favorites[self.activeProfile]
					self.db.setProfile[GetRealmName()][UnitName("player")] = self.activeProfile
				end,
				Menu = function()
					local selections = {}
					for name, _ in pairs(self.db.favorites) do
						tinsert(selections, name)
					end
					return selections
				end
			},
			{
				Type = "Button",
				Name = "ProfileAdd",
				Lable = "Add Profile",
				Size = {100,25},
				OnClick = function() StaticPopup_Show("BROKER_PORTALS_ADD_PROFILE") end
			},
			{
				Type = "Button",
				Position = "Right",
				Name = "ProfileDelete",
				Lable = "Delete Profile",
				Size = {100,25},
				OnClick = function()
					StaticPopupDialogs.BROKER_PORTALS_DELETE_PROFILE.profile = self.activeProfile
					StaticPopup_Show("BROKER_PORTALS_DELETE_PROFILE")
				end
			},
			{
				Type = "Slider",
				Name = "buttonScale",
				Lable = "Standalone Button Scale",
				MinMax = {0.25, 1.5},
				Step = 0.01,
				Size = {240,16},
				OnShow = function() self.options.buttonScale:SetValue(self.db.buttonScale or 1) end,
				OnValueChanged = function()
					self.db.buttonScale = self.options.buttonScale:GetValue()
					if self.standaloneButton then
						self.standaloneButton:SetScale(self.db.buttonScale)
					end
				end
			};
			{
				Type = "CheckButton",
				Name = "selfCast",
				Lable = "Cast placeable items/spells on self",
				OnClick = function() self.db.selfCast = not self.db.selfCast end
			},
			{
				Type = "CheckButton",
				Name = "showStonesZone",
				Lable = "Show stone of retreat zones",
				OnClick = function() self.db.showStonesZone = not self.db.showStonesZone end
			},
		}
		}
	}
	self.options = self:CreateOptionsPages(Options, PortalsDB)

end

StaticPopupDialogs["BROKER_PORTALS_ADD_PROFILE"] = {
	text = "Add New Profile",
	button1 = "Confirm",
	button2 = "Cancel",
	hasEditBox = true,
	OnShow = function(self)
	self:SetFrameStrata("TOOLTIP");
  end,
	OnAccept = function (self)
		local text = self.editBox:GetText()
		if text ~= "" then
		  Portals.db.favorites[text] = {}
		  self.activeProfile = text
		  Portals.favoritesdb = Portals.db.favorites[self.activeProfile]
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	enterClicksFirstButton = true,
  }
  
  StaticPopupDialogs["BROKER_PORTALS_DELETE_PROFILE"] = {
	text = "Delete Profile?",
	button1 = "Confirm",
	button2 = "Cancel",
	OnShow = function(self)
	self:SetFrameStrata("TOOLTIP");
	end,
	OnAccept = function (self)
	  local profile = StaticPopupDialogs.BROKER_PORTALS_DELETE_PROFILE.profile
	  if self.activeProfile == profile then
		self.activeProfile = "Default"
		Portals.favoritesdb = Portals.db.favorites[self.activeProfile]
	  end
	  Portals.db.favorites[profile] = nil
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
	enterClicksFirstButton = true,
  }