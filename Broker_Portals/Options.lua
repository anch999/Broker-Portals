local Portals = LibStub("AceAddon-3.0"):GetAddon("BrokerPortals")
local L = LibStub("AceLocale-3.0"):GetLocale("BrokerPortals")
--Round number
local function round(num, idp)
	local mult = 10 ^ (idp or 0)
	return math.floor(num * mult + 0.5) / mult
 end

function Portals:OptionsToggle()
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	else
		InterfaceOptionsFrame_OpenToCategory("BrokerPortals")
	end
end

function BrokerPortals_OpenOptions()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	BrokerPortals_DropDownInitialize()
end

--Creates the options frame and all its assets

function Portals:CreateOptionsUI()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	self.options = { frame = {} }
		self.options.frame.panel = CreateFrame("FRAME", "BrokerPortalsOptionsFrame", UIParent, nil)
    	local fstring = self.options.frame.panel:CreateFontString(self.options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText("BrokerPortals Settings")
		fstring:SetPoint("TOPLEFT", 15, -15)
		self.options.frame.panel.name = "BrokerPortals"
		InterfaceOptions_AddCategory(self.options.frame.panel)

	local function CreateOptionsPage(opTable)

		local function CreateCheckButton(addonName, name, lable, setPoint, onClick, onEnter, onLeave)
			self.options[name] = CreateFrame("CheckButton", addonName..name, _G[addonName.."Frame"], "UICheckButtonTemplate")
			self.options[name]:SetPoint(unpack(setPoint))
			self.options[name].Lable = self.options[name]:CreateFontString(nil , "BORDER", "GameFontNormal")
			self.options[name].Lable:SetJustifyH("LEFT")
			self.options[name].Lable:SetPoint("LEFT", 30, 0)
			self.options[name].Lable:SetText(lable)
			self.options[name]:SetScript("OnClick", onClick)
			self.options[name]:SetScript("OnEnter", onEnter)
			self.options[name]:SetScript("OnLeave", onLeave or GameTooltip:Hide())
		end
		
		local function CreateOptionsButton(addonName, name, lable, setPoint, onClick, onEnter, onLeave, size)
			self.options[name] = CreateFrame("Button", addonName..name, _G[addonName.."Frame"], "OptionsButtonTemplate")
			self.options[name]:SetSize(unpack(size))
			self.options[name]:SetPoint(unpack(setPoint))
			self.options[name]:SetText(lable)
			self.options[name]:SetScript("OnClick", onClick)
			self.options[name]:SetScript("OnEnter", onEnter)
			self.options[name]:SetScript("OnLeave", onLeave or GameTooltip:Hide())
		end

		local function CreateDropDownMenu(addonName, name, lable, menu, setPoint, onClick, onEnter, onLeave)
			self.options[name] = CreateFrame("Button", addonName..name.."Menu", _G[addonName.."Frame"], "UIDropDownMenuTemplate")
			self.options[name]:SetPoint(unpack(setPoint))
			self.options[name].Lable = self.options[name]:CreateFontString(nil , "BORDER", "GameFontNormal")
			self.options[name].Lable:SetJustifyH("LEFT")
			self.options[name].Lable:SetPoint("LEFT", self.options[name], 190, 0)
			self.options[name].Lable:SetText(lable)
			self.options[name]:SetScript("OnClick", onClick)
			self.options[name]:SetScript("OnEnter", onEnter)
			self.options[name]:SetScript("OnLeave", onLeave or GameTooltip:Hide())
			self.options[name].Menu = menu
		end

		local function CreateSlider(addonName, name, lable, minMax, setPoint, onShow, onValueChanged, size, step)
			print(minMax[1], minMax[2])
			self.options[name] = CreateFrame("Slider", addonName..name, _G[addonName.."Frame"], "OptionsSliderTemplate")
			self.options[name]:SetPoint(unpack(setPoint))
			self.options[name]:SetSize(unpack(size))
			self.options[name]:SetMinMaxValues(minMax[1], minMax[2])
			_G[self.options[name]:GetName().."Text"]:SetText(lable..": ".." ("..round(self.options[name]:GetValue(),2)..")")
			_G[self.options[name]:GetName().."Low"]:SetText(minMax[1])
			_G[self.options[name]:GetName().."High"]:SetText(minMax[2])
			self.options[name]:SetScript("OnValueChanged", onValueChanged)
			self.options[name]:SetScript("OnShow", onShow)
			self.options[name]:SetValueStep(step)

		end

		for coloum, side in pairs(opTable) do
			local point = -10
			if type(side) == "table" then
				for _, options in pairs(side) do
						if options.Type == "CheckButton" then
							point = point -30
							local setPoint = (coloum == "Left") and {"TOPLEFT", 30, point} or (coloum == "Right") and {"TOPLEFT", 380, point}
							CreateCheckButton(opTable.OptionsName, options.Name, options.Lable, setPoint, options.Func, options.OnEnter, options.OnLeave )
						elseif options.Type == "Button" then
							point = point -35
							local setPoint = (coloum == "Left") and {"TOPLEFT", 30, point} or (coloum == "Right") and {"TOPLEFT", 385, point}
							CreateOptionsButton(opTable.OptionsName, options.Name, options.Lable, setPoint, options.Func, options.OnEnter, options.OnLeave, options.Size )
						elseif options.Type == "Menu" then
							point = point -35
							local setPoint = (coloum == "Left") and {"TOPLEFT", 20, point} or (coloum == "Right") and {"TOPLEFT", 368, point}
							CreateDropDownMenu(opTable.OptionsName, options.Name, options.Lable, options.Menu, setPoint, options.Func, options.OnEnter, options.OnLeave )
						elseif options.Type == "Slider" then
							point = point -50
							local setPoint = (coloum == "Left") and {"TOPLEFT", 35, point} or (coloum == "Right") and {"TOPLEFT", 385, point}
							CreateSlider(opTable.OptionsName, options.Name, options.Lable, options.minMax, setPoint, options.OnShow, options.OnValueChanged, options.Size, options.Step )
						end
				end
			end
		end
	end

	local Options = {
		OptionsName = "BrokerPortalsOptions",
		Left = {
			{
				Type = "CheckButton",
				Name = "HideMenu",
				Lable = "Hide Standalone Button",
				Func = 	function()
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
				Name = "EnableAutoHide",
				Lable = "Only Show Standalone Button on Hover",
				Func = function()
					self.db.enableAutoHide = not self.db.enableAutoHide
					self:ToggleMainButton(self.db.enableAutoHide)
				end
			},
			{
				Type = "CheckButton",
				Name = "AutoMenu",
				Lable = "Open menu on mouse over",
				Func = function() self.db.deleteItem = not self.db.deleteItem end
			},
			{
				Type = "CheckButton",
				Name = "ShowItems",
				Lable = L['SHOW_ITEMS'],
				Func = function() self.db.showItems = not self.db.showItems end
			},
			{
				Type = "CheckButton",
				Name = "ShowItemCooldowns",
				Lable = L['SHOW_ITEM_COOLDOWNS'],
				Func = function() self.db.showItemCooldowns = not self.db.showItemCooldowns end
			},
			{
				Type = "CheckButton",
				Name = "Announce",
				Lable = L['ANNOUNCE'],
				Func = function() self.db.announce = not self.db.announce end
			},
			{
				Type = "Menu",
				Name = "Announce",
				Lable = "Show Announce in",
				Menu = {{"Say", "SAY"}, {"Yell", "YELL"}, {"|cff00ffffParty|r/|cffff7f00Raid", "PARTYRAID"}}
			},
			{
				Type = "CheckButton",
				Name = "ShowPortals",
				Lable = "Show portals only in Party/Raid",
				Func = function() self.db.showPortals = not self.db.showPortals end
			},
			{
				Type = "CheckButton",
				Name = "SwapTeleports",
				Lable = "Swap teleport to portal spells in Party/Raid",
				Func = function() self.db.swapPortals = not self.db.swapPortals end
			},
			{
				Type = "CheckButton",
				Name = "ShowStones",
				Lable = "Show Stones Of Retreats As Menus",
				Func = function() self.db.stonesSubMenu = not self.db.stonesSubMenu end
			},
			{
				Type = "CheckButton",
				Name = "ShowEnemy",
				Lable = "Show enemy faction Stones of Retreats",
				Func = function() self.db.showEnemy = not self.db.showEnemy end
			},
		},
		Right = {
			{
				Type = "CheckButton",
				Name = "AutoDelete",
				Lable = "Delete vanity items after summoning",
				Func = function() self.db.deleteItem = not self.db.deleteItem end
			},
			{
				Type = "CheckButton",
				Name = "HideMinimap",
				Lable = "Hide minimap icon",
				Func = function()
					self.db.minimap = not self.db.minimap
					self:ToggleMainButton(self.db.enableAutoHide)
				end
			},
			{
				Type = "Menu",
				Name = "TxtSize",
				Lable = "Menu text size"
			},
			{
				Type = "Menu",
				Name = "ProfileSelect",
				Lable = "Profile selection",
			},
			{
				Type = "Button",
				Name = "ProfileAdd",
				Lable = "Add Profile",
				Size = {100,25},
				Func = function() StaticPopup_Show("BROKER_PORTALS_ADD_PROFILE") end
			},
			{
				Type = "Button",
				Name = "ProfileDelete",
				Lable = "Delete Profile",
				Size = {100,25},
				Func = function()
					StaticPopupDialogs.BROKER_PORTALS_DELETE_PROFILE.profile = self.activeProfile
					StaticPopup_Show("BROKER_PORTALS_DELETE_PROFILE")
				end
			},
			{
				Type = "Slider",
				Name = "ButtonScale",
				Lable = "Standalone Button Scale",
				minMax = {0.25, 1.5},
				Step = 0.01,
				Size = {240,16},
				OnShow = function() self.options.ButtonScale:SetValue(self.db.buttonScale or 1) end,
				OnValueChanged = function()
					_G[self.options.ButtonScale:GetName().."Text"]:SetText("Standalone Button Scale: ".." ("..round(self.options.ButtonScale:GetValue(),2)..")")
					self.db.buttonScale = self.options.ButtonScale:GetValue()
					if self.standaloneButton then
						self.standaloneButton:SetScale(self.db.buttonScale)
					end
				end
			}
		}
	}
	CreateOptionsPage(Options)
end

Portals:CreateOptionsUI()

function BrokerPortals_Options_Profile_Select_Initialize()
	local i, info, selected = 1
	for name, _ in pairs(Portals.db.favorites) do
		if name == Portals.db.setProfile[GetRealmName()][UnitName("player")] then
			selected = i
		end
		i = i + 1
		info = {
			text = name;
			func = function()
				local thisID = this:GetID();
				UIDropDownMenu_SetSelectedID(BrokerPortalsOptionsProfileSelectMenu, thisID)
				Portals.activeProfile = name
				Portals.favoritesdb = Portals.db.favorites[Portals.activeProfile]
				Portals.db.setProfile[GetRealmName()][UnitName("player")] = Portals.activeProfile
			end;
		}
			UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_SetWidth(BrokerPortalsOptionsProfileSelectMenu, 150)
	UIDropDownMenu_SetSelectedID(BrokerPortalsOptionsProfileSelectMenu, selected)
end

function BrokerPortals_Options_Menu_Initialize()
	local info
	for i = 10, 25 do
		info = {
			text = i;
			func = function() 
				Portals.db.txtSize = i
				local thisID = this:GetID();
				UIDropDownMenu_SetSelectedID(BrokerPortalsOptionsTxtSizeMenu, thisID)
			end;
		}
			UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_SetWidth(BrokerPortalsOptionsTxtSizeMenu, 150)
	UIDropDownMenu_SetSelectedID(BrokerPortalsOptionsTxtSizeMenu, Portals.db.txtSize - 9)
end

function BrokerPortals_Options_Announce_Initialize()
	local info, selected
	for i, announceType in ipairs(BrokerPortalsOptionsAnnounceMenu.Menu) do

		if (Portals.db.announceType == announceType[2]) then
			selected =  i
		end
		info = {
			text = announceType[1];
			func = function()
				local thisID = this:GetID();
				selected = thisID
				UIDropDownMenu_SetSelectedID(BrokerPortalsOptionsAnnounceMenu, thisID)
				Portals.db.announceType = announceType[2]
			end;
		}
			UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_SetWidth(BrokerPortalsOptionsAnnounceMenu, 150)
	UIDropDownMenu_SetSelectedID(BrokerPortalsOptionsAnnounceMenu, selected)
end

function BrokerPortals_DropDownInitialize()
	--Setup for Dropdown menus in the settings
	UIDropDownMenu_Initialize(BrokerPortalsOptionsTxtSizeMenu, BrokerPortals_Options_Menu_Initialize)
	UIDropDownMenu_Initialize(BrokerPortalsOptionsProfileSelectMenu, BrokerPortals_Options_Profile_Select_Initialize)
	UIDropDownMenu_Initialize(BrokerPortalsOptionsAnnounceMenu, BrokerPortals_Options_Announce_Initialize)
end

--Hook interface frame show to update options data
InterfaceOptionsFrame:HookScript("OnShow", function()
	if InterfaceOptionsFrame and BrokerPortalsOptionsFrame:IsVisible() then
		BrokerPortals_OpenOptions()
	end
end)

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