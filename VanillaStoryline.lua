-- for debug
function print(content)
	DEFAULT_CHAT_FRAME:AddMessage(content)
end


-- local later
local storyline = CreateFrame("Frame",nil); -- Event Frame
	storyline.Background = CreateFrame("Frame","StorylineFrame",UIParent) -- Background Frame
	storyline.Player = CreateFrame("Frame",nil,storyline.Background) -- Player Frame
	storyline.NPC = CreateFrame("Frame",nil,storyline.Background) -- NPC Frame
	storyline.Text = CreateFrame("Frame",nil,storyline.Background) -- Text Frame
	storyline.QuestDetail = CreateFrame("Frame",nil,storyline.Background) -- QuestDetail Frame
	storyline.QuestProgress = CreateFrame("Frame",nil,storyline.Background) -- QuestDetail Frame
	storyline.QuestComplete = CreateFrame("Frame",nil,storyline.Background) -- QuestComplete Frame
	storyline.OptionsFrame = CreateFrame("Frame",nil,storyline.Background) -- Options Frame
	storyline.Options = {} -- options
	storyline.Variables = {} -- Variables to work with

-- Events
storyline:RegisterEvent("ADDON_LOADED")
storyline:RegisterEvent("QUEST_DETAIL")
storyline:RegisterEvent("QUEST_PROGRESS")
storyline:RegisterEvent("QUEST_COMPLETE")
storyline:RegisterEvent("QUEST_GREETING")
storyline:RegisterEvent("QUEST_FINISHED")
storyline:RegisterEvent("QUEST_ITEM_UPDATE")

tinsert(UISpecialFrames, "StorylineFrame")

-- Fill Variables and Options
storyline.Options.Fading = 0
storyline.Options.GradientLength = 30
storyline.Options.Offset = 0 -- text offset for max. scroll frame
storyline.Options.Delay = 0.03 -- 30 fps update
storyline.Options.DelayModel = 1
storyline.Options.Version = 0.1 -- version

storyline.Variables.fadingProgress = 0
storyline.Variables.ModelProgress = 0
storyline.Variables.SliderProgress = 0
storyline.Variables.QuesttextLength = 0
storyline.Variables.LastTime = 0
storyline.Variables.ModelTime = 0
storyline.Variables.Time = 0
storyline.Variables.i = 0
storyline.Variables.t = GetTime()

-- Event Function
function storyline:OnEvent()
	if event == "ADDON_LOADED" and arg1 == "VanillaStoryline" then
		-- set Options
		if not StorylineOptions then
			StorylineOptions = {}
			StorylineOptions.HideBlizzardFrames = 1
			StorylineOptions.TextSpeed = 2
		end
		storyline.Options.TextSpeed = StorylineOptions.TextSpeed
		storyline.Options.HideBlizzardFrames = StorylineOptions.HideBlizzardFrames


		storyline.Background:ConfigureFrame() -- configure Background Frame
		storyline.Player:ConfigureFrame() -- configure player 3d Frame
		storyline.NPC:ConfigureFrame() -- configure the NPC 3d frame
		storyline.Text:ConfigureFrame() -- configure fonts
		storyline.QuestDetail:ConfigureFrame() -- configure Quest Detail Frame
		storyline.QuestProgress:ConfigureFrame() -- configure Quest Progress Frame
		storyline.QuestComplete:ConfigureFrame() -- configure Quest complete frame
    storyline.OptionsFrame:ConfigureFrame() -- configure Options Frame
		storyline.Background:Hide()
	elseif event == "QUEST_DETAIL" then
		storyline:HideBlizzard()
		storyline:AcceptQuest()
	elseif event == "QUEST_PROGRESS" then
		storyline:HideBlizzard()
		storyline:ProgressQuest()
	elseif event == "QUEST_COMPLETE" then
		storyline:HideBlizzard()
		storyline:CompleteQuest()
	elseif event == "QUEST_GREETING" then
		print("QUEST_GREETING")
	elseif event == "QUEST_FINISHED" then
		DeclineQuest()
		storyline.Background:Hide()
	elseif event == "QUEST_ITEM_UPDATE" then
		print("QUEST_ITEM_UPDATE")
	end

end

function storyline:OnUpdate()
	storyline.Variables.Time = GetTime()

	-- this ticks every Delay in sec.!
	if storyline.Options.Fading == 1 and storyline.Variables.LastTime + storyline.Options.Delay <= storyline.Variables.Time then

		-- Set Font Fading Progress
		storyline.Variables.fadingProgress = storyline.Variables.fadingProgress + storyline.Options.TextSpeed
		storyline.Variables.SliderProgress = storyline.Variables.SliderProgress + (storyline.Options.TextSpeed/3)

		-- set Slider Progression
		storyline.Background.layer5.Questtext.Slider:SetValue(storyline.Variables.SliderProgress-50)

		-- Set Font Fading
		storyline.Text.Questtext.Font:SetAlphaGradient(storyline.Variables.fadingProgress,storyline.Options.GradientLength)

		-- get new time
		storyline.Variables.LastTime = storyline.Variables.Time

		-- quit OpUpdate
		if storyline.Variables.fadingProgress >= storyline.Variables.QuesttextLength + storyline.Options.Offset then storyline.Options.Fading = 0 end
	end
	--local elapsed = GetTime() - storyline.Variables.t
	--storyline.Variables.t = GetTime()
	--storyline.NPC.PlayerFrame:SetSequenceTime(68,storyline.Variables.i)
	--storyline.NPC.PlayerFrame:SetSequenceTime(6,storyline.Variables.i)
	--storyline.Variables.i=(storyline.Variables.i+(elapsed*1000))
	--[[-- model test
	if storyline.Variables.ModelTime + storyline.Options.DelayModel <= storyline.Variables.Time then

		storyline.Variables.ModelProgress = storyline.Variables.ModelProgress + 1
		--storyline.NPC.PlayerFrame:SetSequenceTime(1, storyline.Variables.ModelProgress)

		storyline.Variables.ModelTime = storyline.Variables.Time
	end]]--
end

storyline:SetScript("OnEvent", storyline.OnEvent)
storyline:SetScript("OnUpdate", storyline.OnUpdate)

	-- moving frames function
function storyline.Options:StartMoving()
	this:StartMoving()
end

function storyline.Options:StopMovingOrSizing()
	this:StopMovingOrSizing()
end

-- decline quest
function storyline:DeclineQuest()

	storyline.Options.Fading = 0
	storyline.Variables.fadingProgress = 0
	storyline.Variables.LastTime = 0
	storyline.Variables.Time = 0

	DeclineQuest()
	PlaySound("igQuestCancel")
	storyline.Background:Hide()
end

-- Configure Background Frame
function storyline.Background:ConfigureFrame()
	-- Layer 1
	self:SetFrameStrata("MEDIUM")
	self:SetWidth(700)
	self:SetHeight(450)
	self:SetPoint("CENTER",0,0)
	self:SetMovable(1)
	--self:EnableMouse(1)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", storyline.Options.StartMoving)
	self:SetScript("OnDragStop", storyline.Options.StopMovingOrSizing)

	-- Layer 2
	self.layer2 = CreateFrame("Frame",nil,self)
	self.layer2:SetFrameStrata("BACKGROUND")
	self.layer2:SetWidth(700)
	self.layer2:SetHeight(450)
	self.layer2:SetPoint("TOPLEFT",0,0)

	self.layer2.Background = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background:SetFrameStrata("BACKGROUND")
	self.layer2.Background:SetWidth(700)
	self.layer2.Background:SetHeight(450)
	self.layer2.Background:SetPoint("TOPLEFT", 20,-20)
	self.layer2.Background:SetPoint("BOTTOMRIGHT", -20,20)
	local Background = self.layer2.Background:CreateTexture()
		Background:SetAllPoints()
		Background:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\DressUpBackground-NightElf1")
		--Background:SetGradient("HORIZONTAL", 0, 0, 0 ,0.5, 0.5, 0.5)

	-- Layer 3
	self.layer3 = CreateFrame("Frame",nil,self.layer2)
	self.layer3:SetWidth(700)
	self.layer3:SetHeight(450)
	self.layer3:SetPoint("TOPLEFT",0, 0)


	self.layer3.Background = CreateFrame("Frame",nil,self.layer3)

	self.layer3.TopLeft = CreateFrame("Frame",nil,self.layer3)
	self.layer3.TopRight = CreateFrame("Frame",nil,self.layer3)
	self.layer3.BottomLeft = CreateFrame("Frame",nil,self.layer3)
	self.layer3.BottomRight = CreateFrame("Frame",nil,self.layer3)

	self.layer3.Left = CreateFrame("Frame",nil,self.layer3)
	self.layer3.Right = CreateFrame("Frame",nil,self.layer3)
	self.layer3.Top = CreateFrame("Frame",nil,self.layer3)
	self.layer3.Bottom = CreateFrame("Frame",nil,self.layer3)

	local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\question-background"}  -- path to the background texture
	self.layer3.Background:SetWidth(700) -- Set these to whatever height/width is needed
	self.layer3.Background:SetHeight(450) -- for your Texture
	self.layer3.Background:SetBackdrop(backdrop)
	self.layer3.Background:SetBackdropColor(1,1,1,0.5)
	self.layer3.Background:SetPoint("TOPLEFT", 20,-20)
	self.layer3.Background:SetPoint("BOTTOMRIGHT", -20,20)

	self.layer3.TopLeft:SetWidth(209) -- Set these to whatever height/width is needed
	self.layer3.TopLeft:SetHeight(125) -- for your Texture
	self.layer3.TopLeft:SetPoint("TOPLEFT", 0, 0)
	local TopLeft = self.layer3.TopLeft:CreateTexture()
		TopLeft:SetAllPoints()
		TopLeft:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Question-Main")
		TopLeft:SetTexCoord(0.00195313,0.41015625,0.61718750,0.92578125)

	self.layer3.TopRight:SetWidth(209) -- Set these to whatever height/width is needed
	self.layer3.TopRight:SetHeight(125) -- for your Texture
	self.layer3.TopRight:SetPoint("TOPRIGHT", 0, 0)
	local TopRight = self.layer3.TopRight:CreateTexture()
		TopRight:SetAllPoints()
		TopRight:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Question-Main")
		TopRight:SetTexCoord(0.41406250,0.82031250,0.61718750,0.92578125)

	self.layer3.BottomLeft:SetWidth(209) -- Set these to whatever height/width is needed
	self.layer3.BottomLeft:SetHeight(125) -- for your Texture
	self.layer3.BottomLeft:SetPoint("BOTTOMLEFT", 0, 0)
	local BottomLeft = self.layer3.BottomLeft:CreateTexture()
		BottomLeft:SetAllPoints()
		BottomLeft:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Question-Main")
		BottomLeft:SetTexCoord(0.00195313,0.41015625,0.30468750,0.61328125)

	self.layer3.BottomRight:SetWidth(209) -- Set these to whatever height/width is needed
	self.layer3.BottomRight:SetHeight(125) -- for your Texture
	self.layer3.BottomRight:SetPoint("BOTTOMRIGHT", 0, 0)
	local BottomRight = self.layer3.BottomRight:CreateTexture()
		BottomRight:SetAllPoints()
		BottomRight:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Question-Main")
		BottomRight:SetTexCoord(0.41406250,0.82226563,0.30468750,0.61328125)

	self.layer3.Left:SetWidth(93) -- Set these to whatever height/width is needed
	self.layer3.Left:SetHeight(256) -- for your Texture
	self.layer3.Left:SetPoint("LEFT", 2, 0)
	self.layer3.Left:SetPoint("TOP", self.layer3.TopLeft,"BOTTOM")
	self.layer3.Left:SetPoint("BOTTOM", self.layer3.BottomLeft,"TOP")
	local Left = self.layer3.Left:CreateTexture()
		Left:SetAllPoints()
		Left:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Question-VTile")
		Left:SetTexCoord(0.00390625,0.36718750,0.00000000,1.00000000)

	self.layer3.Right:SetWidth(94) -- Set these to whatever height/width is needed
	self.layer3.Right:SetHeight(256) -- for your Texture
	self.layer3.Right:SetPoint("RIGHT", 0, 0)
	self.layer3.Right:SetPoint("TOP", self.layer3.TopRight,"BOTTOM")
	self.layer3.Right:SetPoint("BOTTOM", self.layer3.BottomRight,"TOP")
	local Right = self.layer3.Right:CreateTexture()
		Right:SetAllPoints()
		Right:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Question-VTile")
		Right:SetTexCoord(0.37500000,0.74218750,0.00000000,1.00000000)

	self.layer3.Bottom:SetWidth(256) -- Set these to whatever height/width is needed
	self.layer3.Bottom:SetHeight(66) -- TO FIX
	self.layer3.Bottom:SetPoint("BOTTOMLEFT", self.layer3.BottomLeft,"BOTTOMRIGHT",0,2)
	self.layer3.Bottom:SetPoint("BOTTOMRIGHT", self.layer3.BottomRight,"BOTTOMLEFT",0,2)
	local Bottom = self.layer3.Bottom:CreateTexture()
		Bottom:SetAllPoints()
		Bottom:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Question-HTile")
		Bottom:SetTexCoord(0.00000000,1.00000000,0.17187500,0.33984375)

	self.layer3.Top:SetWidth(256) -- Set these to whatever height/width is needed
	self.layer3.Top:SetHeight(70) -- TOO FIX
	self.layer3.Top:SetPoint("TOPLEFT", self.layer3.TopLeft,"TOPRIGHT",0,-1)
	self.layer3.Top:SetPoint("TOPRIGHT", self.layer3.TopRight,"TOPLEFT",0,-1)
	local Top = self.layer3.Top:CreateTexture()
		Top:SetAllPoints()
		Top:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Question-HTile")
		Top:SetTexCoord(0.00000000,1.00000000,0.34375000,0.52148438)

	-- Layer 4
	self.layer4 = CreateFrame("Frame",nil,self.layer3)
		self.layer4:SetWidth(700)
		self.layer4:SetHeight(450)
		self.layer4:SetPoint("TOPLEFT",0, 0)

	self.layer4.Banner = CreateFrame("Frame",nil,self.layer4)
		self.layer4.Banner:SetWidth(384) -- Set these to whatever height/width is needed
		self.layer4.Banner:SetHeight(96) -- for your Texture
		self.layer4.Banner:SetPoint("TOP", 0, 0)
		local Banner = self.layer4.Banner:CreateTexture()
		Banner:SetAllPoints()
		Banner:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\GarrMission_RewardsBanner-Desaturate")

	-- Layer 5
	self.layer5 = CreateFrame("Frame",nil,self.layer4)
		self.layer5:SetWidth(700)
		self.layer5:SetHeight(450)
		self.layer5:SetPoint("TOPLEFT",0, 0)

	-- Questtext Frame
	self.layer5.Questtext = CreateFrame("Frame",nil,storyline.Background.layer4)
		local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\GLUES\\COMMON\\TextPanel-Border", tile=true,tileSize = 16, edgeSize = 24, insets = { left = 4, right = 4, top = 4, bottom = 4 }}  -- path to the background texture
		self.layer5.Questtext:SetBackdrop(backdrop)
		self.layer5.Questtext:SetBackdropColor(1,1,1,1)
		self.layer5.Questtext:SetWidth(650)
		self.layer5.Questtext:SetHeight(100)
		self.layer5.Questtext:SetPoint("BOTTOM",0,20)
		self.layer5.Questtext:EnableMouseWheel(1)
		self.layer5.Questtext:SetScript("OnMouseWheel", function()
		  local value = self.layer5.Questtext.Slider:GetValue()
		  self.layer5.Questtext.Slider:SetValue(value-(arg1*10))
		end)


	-- Scrollframe
	self.layer5.Questtext.Scrollframe = CreateFrame("ScrollFrame", nil, self.layer5.Questtext)
		self.layer5.Questtext.Scrollframe:SetPoint("TOPLEFT", 0, -10)
		self.layer5.Questtext.Scrollframe:SetPoint("BOTTOMRIGHT", -15, 10)

	self.layer5.Questtext.Slider = CreateFrame("Slider", nil, self.layer5.Questtext, "UIPanelScrollBarTemplate")
		self.layer5.Questtext.Slider:SetOrientation('VERTICAL')
		self.layer5.Questtext.Slider:SetWidth(16)
		self.layer5.Questtext.Slider:SetHeight(50)
		self.layer5.Questtext.Slider:SetPoint("RIGHT",-10,0)
		self.layer5.Questtext.Slider:SetMinMaxValues(0, 170)
		self.layer5.Questtext.Slider:SetValueStep(1)
		self.layer5.Questtext.Slider:SetScript("OnValueChanged", function()
																	local value = self.layer5.Questtext.Slider:GetValue()
																	self.layer5.Questtext.Scrollframe:SetVerticalScroll(value)
																end)

	self.layer5.Questtext.Scrollframe.Content = CreateFrame("Frame", nil, self.layer5.Questtext.Scrollframe)
		self.layer5.Questtext.Scrollframe.Content:SetWidth(650)
		self.layer5.Questtext.Scrollframe.Content:SetHeight(170)
		self.layer5.Questtext.Scrollframe:SetScrollChild(self.layer5.Questtext.Scrollframe.Content)

	-- Test Fadeframe
	self.layer5.Questtext.Fade = CreateFrame("Frame",nil,self.layer5.Questtext)
	self.layer5.Questtext.Fade:SetWidth(650)
	self.layer5.Questtext.Fade:SetHeight(100)
	self.layer5.Questtext.Fade:SetPoint("TOPLEFT",0,0)

	self.layer5.Questtext.Fade.Button = CreateFrame("Button",nil,self.layer5.Questtext.Fade)
		self.layer5.Questtext.Fade.Button:SetWidth(650)
		self.layer5.Questtext.Fade.Button:SetHeight(100)
		self.layer5.Questtext.Fade.Button:SetPoint("CENTER",0,0)
		self.layer5.Questtext.Fade.Button:SetScript("OnEnter",function()
															self.layer5.Questtext:SetBackdropBorderColor(0,1,0,1)
															end)
		self.layer5.Questtext.Fade.Button:SetScript("OnLeave",function() self.layer5.Questtext:SetBackdropBorderColor(1,1,1,1) end)
		self.layer5.Questtext.Fade.Button:SetScript("OnClick",function() end)

	-- Bubble Texture
	self.layer5.Questtext.Bubble = CreateFrame("Frame",nil,self.layer5.Questtext)
		self.layer5.Questtext.Bubble:SetWidth(32)
		self.layer5.Questtext.Bubble:SetHeight(32)
		self.layer5.Questtext.Bubble:SetPoint("TOPRIGHT",-30,28)
		local Bubble = self.layer5.Questtext.Bubble:CreateTexture()
			Bubble:SetAllPoints()
			Bubble:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\CHATBUBBLE-TAIL")
			Bubble:SetTexCoord(1,0,1,0)

		-- close button
	self.CloseButton = CreateFrame("Button",nil,storyline.Background)
		self.CloseButton:SetPoint("TOPRIGHT",-8,-8)
		self.CloseButton:SetWidth(32)
		self.CloseButton:SetHeight(32)
		self.CloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
		self.CloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
		self.CloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
		self.CloseButton:SetScript("OnClick",function() PlaySound("igMainMenuOptionCheckBoxOn")
																						DeclineQuest(); storyline:HideAll()
																					end)

	-- Options button
	self.OptionsButton = CreateFrame("Button",nil,storyline.Background)
		self.OptionsButton:SetWidth(16)
		self.OptionsButton:SetHeight(16)
		self.OptionsButton:SetPoint("BOTTOMLEFT",10,10)
		self.OptionsButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
		self.OptionsButton:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-Down")
		self.OptionsButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
		self.OptionsButton:SetScript("OnClick",function() PlaySound("igMainMenuOptionCheckBoxOn")
																						if storyline.OptionsFrame:IsVisible() then  storyline.OptionsFrame:Hide()
																						else  storyline.OptionsFrame:Show() end
																					end)

end

function storyline.QuestDetail:ConfigureFrame()

	-- GetQuest Buttons
	self.GetQuest = CreateFrame("Frame",nil,storyline.Background.layer5)
	self.GetQuest:SetWidth(200)
	self.GetQuest:SetHeight(100)
	self.GetQuest:SetPoint("CENTER",0,70)

	self.GetQuest.Accept = CreateFrame("Frame",nil,self.GetQuest)
	local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\ReadyCheck-Ready"}
		self.GetQuest.Accept:SetBackdrop(backdrop)
		self.GetQuest.Accept:SetBackdropColor(1,1,1,1)
		self.GetQuest.Accept:SetWidth(40)
		self.GetQuest.Accept:SetHeight(40)
		self.GetQuest.Accept:SetPoint("LEFT",20,0)

	self.GetQuest.Accept.Button = CreateFrame("Button",nil,self.GetQuest.Accept)
	self.GetQuest.Accept.Button:SetWidth(40)
	self.GetQuest.Accept.Button:SetHeight(40)
	self.GetQuest.Accept.Button:SetPoint("CENTER",0,0)
	self.GetQuest.Accept.Button:SetHighlightTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\PetBattle-SelectedPetGlow")
	self.GetQuest.Accept.Button:SetScript("OnEnter",function()
														GameTooltip:SetOwner(self.GetQuest.Accept, "ANCHOR_TOPRIGHT",20,-80);
														GameTooltip:SetText("I accept.", 1, 1, 1, 1, 1);
														GameTooltip:Show()
													end)
	self.GetQuest.Accept.Button:SetScript("OnLeave",function() GameTooltip:Hide() end)
	self.GetQuest.Accept.Button:SetScript("OnClick",function() PlaySound("igMainMenuOptionCheckBoxOn"); AcceptQuest(); storyline.Background:Hide() end)

	self.GetQuest.Decline = CreateFrame("Frame",nil,self.GetQuest)
	local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\ReadyCheck-NotReady"}
		self.GetQuest.Decline:SetBackdrop(backdrop)
		self.GetQuest.Decline:SetBackdropColor(1,1,1,1)
		self.GetQuest.Decline:SetWidth(40)
		self.GetQuest.Decline:SetHeight(40)
		self.GetQuest.Decline:SetPoint("RIGHT",-20,0)

	self.GetQuest.Decline.Button = CreateFrame("Button",nil,self.GetQuest.Decline)
	self.GetQuest.Decline.Button:SetWidth(40)
	self.GetQuest.Decline.Button:SetHeight(40)
	self.GetQuest.Decline.Button:SetPoint("CENTER",0,0)
	self.GetQuest.Decline.Button:SetHighlightTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\PetBattle-SelectedPetGlow")
	self.GetQuest.Decline.Button:SetScript("OnEnter",function()
														GameTooltip:SetOwner(self.GetQuest.Decline, "ANCHOR_TOPRIGHT",20,-80);
														GameTooltip:SetText("I refuse.", 1, 1, 1, 1, 1);
														GameTooltip:Show()
													end)
	self.GetQuest.Decline.Button:SetScript("OnLeave",function() GameTooltip:Hide() end)
	self.GetQuest.Decline.Button:SetScript("OnClick",function() storyline:DeclineQuest() end)

	self.GetQuest.CenterItem = CreateFrame("Frame",nil,self.GetQuest)
	local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\FriendsFrameScrollIcon"}
		self.GetQuest.CenterItem:SetBackdrop(backdrop)
		self.GetQuest.CenterItem:SetBackdropColor(1,1,1,1)
		self.GetQuest.CenterItem:SetWidth(40)
		self.GetQuest.CenterItem:SetHeight(40)
		self.GetQuest.CenterItem:SetPoint("CENTER",0,0)

	self.GetQuest.CenterRing = CreateFrame("Frame",nil,self.GetQuest)
	local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\PandarenTrainingLarge_Circular_Frame"}
		self.GetQuest.CenterRing:SetBackdrop(backdrop)
		self.GetQuest.CenterRing:SetBackdropColor(1,1,1,1)
		self.GetQuest.CenterRing:SetWidth(100)
		self.GetQuest.CenterRing:SetHeight(100)
		self.GetQuest.CenterRing:SetPoint("CENTER",0,0)

	self.GetQuest.CenterFlash = CreateFrame("Frame",nil,self.GetQuest)
		self.GetQuest.CenterFlash:SetWidth(100)
		self.GetQuest.CenterFlash:SetHeight(100)
		self.GetQuest.CenterFlash:SetPoint("CENTER",0,0)
	local Flash = self.GetQuest.CenterFlash:CreateTexture()
		Flash:SetAllPoints()
		Flash:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\PandarenTrainingLarge_Circular_Flash")
		Flash:SetTexCoord(1,0,1,0)
		Flash:SetBlendMode("ADD")
end

function storyline.QuestProgress:ConfigureFrame()

	-- Quest Progfress Mainframe Buttons
	self.Mainframe = CreateFrame("Frame",nil,storyline.Background.layer5)
		self.Mainframe:SetWidth(350)
		self.Mainframe:SetHeight(400)
		self.Mainframe:SetPoint("CENTER",0,50)

	-- Center Items
	self.Mainframe.CenterItem = CreateFrame("Frame",nil,self.Mainframe)
		local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\FriendsFrameScrollIcon"}
		self.Mainframe.CenterItem:SetBackdrop(backdrop)
		self.Mainframe.CenterItem:SetBackdropColor(1,1,1,1)
		self.Mainframe.CenterItem:SetWidth(40)
		self.Mainframe.CenterItem:SetHeight(40)
		self.Mainframe.CenterItem:SetPoint("CENTER",0,70)

	self.Mainframe.State = CreateFrame("Frame",nil,self.Mainframe.CenterItem)
		local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\ReadyCheck-Ready"}
		self.Mainframe.State:SetBackdrop(backdrop)
		self.Mainframe.State:SetBackdropColor(1,1,1,1)
		self.Mainframe.State:SetWidth(40)
		self.Mainframe.State:SetHeight(40)
		self.Mainframe.State:SetPoint("CENTER",0,0)

	self.Mainframe.CenterRing = CreateFrame("Frame",nil,self.Mainframe)
		local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\PandarenTrainingLarge_Circular_Frame"}
		self.Mainframe.CenterRing:SetBackdrop(backdrop)
		self.Mainframe.CenterRing:SetBackdropColor(1,1,1,1)
		self.Mainframe.CenterRing:SetWidth(100)
		self.Mainframe.CenterRing:SetHeight(100)
		self.Mainframe.CenterRing:SetPoint("CENTER",0,70)

	self.Mainframe.CenterFlash = CreateFrame("Frame",nil,self.Mainframe)
		self.Mainframe.CenterFlash:SetWidth(100)
		self.Mainframe.CenterFlash:SetHeight(100)
		self.Mainframe.CenterFlash:SetPoint("CENTER",0,70)
		local Flash = self.Mainframe.CenterFlash:CreateTexture()
		Flash:SetAllPoints()
		Flash:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\PandarenTrainingLarge_Circular_Flash")
		Flash:SetTexCoord(1,0,1,0)
		Flash:SetBlendMode("ADD")

	-- Objective Frame
	self.Mainframe.Objective = CreateFrame("Frame",nil,self.Mainframe)
		local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\UI-GuildAchievement-Parchment-Horizontal", edgeFile="Interface\\GLUES\\COMMON\\TextPanel-Border", tile=false,tileSize = 16, edgeSize = 36, insets = { left = 6, right = 6, top = 6, bottom = 6 }}  -- path to the background texture
		self.Mainframe.Objective:SetBackdrop(backdrop)
		self.Mainframe.Objective:SetBackdropColor(1,1,1,0.5)
		self.Mainframe.Objective:SetBackdropBorderColor(1,1,0,1)
		self.Mainframe.Objective:SetWidth(350)
		self.Mainframe.Objective:SetHeight(150)
		self.Mainframe.Objective:SetPoint("CENTER",0,-50)

	self.Mainframe.Objective.Headline = self.Mainframe.Objective:CreateFontString(nil, "OVERLAY")
		self.Mainframe.Objective.Headline:SetPoint("TOP", 0, -10)
		self.Mainframe.Objective.Headline:SetFont("Fonts\\FRIZQT__.TTF", 16)
		self.Mainframe.Objective.Headline:SetWidth(470)
		self.Mainframe.Objective.Headline:SetHeight(70)
		self.Mainframe.Objective.Headline:SetJustifyH("CENTER")
		self.Mainframe.Objective.Headline:SetJustifyV("TOP")
		self.Mainframe.Objective.Headline:SetText("Quest Objectives")
		self.Mainframe.Objective.Headline:SetTextColor(1,0.75,0)
		self.Mainframe.Objective.Headline:SetShadowOffset(1, -1)

	self.Mainframe.Objective.ReqItemsText = self.Mainframe.Objective:CreateFontString(nil, "OVERLAY")
		self.Mainframe.Objective.ReqItemsText:SetPoint("TOP", 0, -30)
		self.Mainframe.Objective.ReqItemsText:SetFont("Fonts\\FRIZQT__.TTF", 14)
		self.Mainframe.Objective.ReqItemsText:SetWidth(320)
		self.Mainframe.Objective.ReqItemsText:SetHeight(50)
		self.Mainframe.Objective.ReqItemsText:SetJustifyH("LEFT")
		self.Mainframe.Objective.ReqItemsText:SetJustifyV("TOP")
		self.Mainframe.Objective.ReqItemsText:SetText("Required:")
		self.Mainframe.Objective.ReqItemsText:SetTextColor(1,0.75,0)
		self.Mainframe.Objective.ReqItemsText:SetShadowOffset(1, -1)

	-- Req. Items Blocks
	self.Mainframe.Objective.Block = {}

	self.Mainframe.Objective.Block[1] = CreateFrame("Frame",nil,self.Mainframe.Objective)
		self.Mainframe.Objective.Block[1]:SetWidth(100)
		self.Mainframe.Objective.Block[1]:SetHeight(30)
		self.Mainframe.Objective.Block[1]:SetPoint("TOPLEFT",15,-50)

		self.Mainframe.Objective.Block[1].Item = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[1])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Objective.Block[1].Item:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[1].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Objective.Block[1].Item:SetWidth(30)
			self.Mainframe.Objective.Block[1].Item:SetHeight(30)
			self.Mainframe.Objective.Block[1].Item:SetPoint("LEFT",0,0)

		self.Mainframe.Objective.Block[1].Item.Font = self.Mainframe.Objective.Block[1].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[1].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Objective.Block[1].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Objective.Block[1].Item.Font:SetWidth(70)
			self.Mainframe.Objective.Block[1].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Objective.Block[1].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[1].Item.Font:SetText("99")
			self.Mainframe.Objective.Block[1].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[1].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Objective.Block[1].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[1])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Objective.Block[1].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[1].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Objective.Block[1].TextBackground:SetWidth(70)
			self.Mainframe.Objective.Block[1].TextBackground:SetHeight(30)
			self.Mainframe.Objective.Block[1].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Objective.Block[1].TextFont = self.Mainframe.Objective.Block[1].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[1].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Objective.Block[1].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Objective.Block[1].TextFont:SetWidth(70)
			self.Mainframe.Objective.Block[1].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Objective.Block[1].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[1].TextFont:SetText("TEST")
			self.Mainframe.Objective.Block[1].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[1].TextFont:SetShadowOffset(1, -1)

	self.Mainframe.Objective.Block[2] = CreateFrame("Frame",nil,self.Mainframe.Objective)
			self.Mainframe.Objective.Block[2]:SetWidth(100)
			self.Mainframe.Objective.Block[2]:SetHeight(30)
			self.Mainframe.Objective.Block[2]:SetPoint("TOPLEFT",120,-50)

		self.Mainframe.Objective.Block[2].Item = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[2])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Objective.Block[2].Item:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[2].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Objective.Block[2].Item:SetWidth(30)
			self.Mainframe.Objective.Block[2].Item:SetHeight(30)
			self.Mainframe.Objective.Block[2].Item:SetPoint("LEFT",0,0)

		self.Mainframe.Objective.Block[2].Item.Font = self.Mainframe.Objective.Block[2].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[2].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Objective.Block[2].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Objective.Block[2].Item.Font:SetWidth(70)
			self.Mainframe.Objective.Block[2].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Objective.Block[2].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[2].Item.Font:SetText("99")
			self.Mainframe.Objective.Block[2].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[2].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Objective.Block[2].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[2])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Objective.Block[2].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[2].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Objective.Block[2].TextBackground:SetWidth(70)
			self.Mainframe.Objective.Block[2].TextBackground:SetHeight(30)
			self.Mainframe.Objective.Block[2].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Objective.Block[2].TextFont = self.Mainframe.Objective.Block[2].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[2].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Objective.Block[2].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Objective.Block[2].TextFont:SetWidth(70)
			self.Mainframe.Objective.Block[2].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Objective.Block[2].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[2].TextFont:SetText("TEST")
			self.Mainframe.Objective.Block[2].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[2].TextFont:SetShadowOffset(1, -1)

	self.Mainframe.Objective.Block[3] = CreateFrame("Frame",nil,self.Mainframe.Objective)
		self.Mainframe.Objective.Block[3]:SetWidth(100)
		self.Mainframe.Objective.Block[3]:SetHeight(30)
		self.Mainframe.Objective.Block[3]:SetPoint("TOPLEFT",225,-50)

		self.Mainframe.Objective.Block[3].Item = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[3])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Objective.Block[3].Item:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[3].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Objective.Block[3].Item:SetWidth(30)
			self.Mainframe.Objective.Block[3].Item:SetHeight(30)
			self.Mainframe.Objective.Block[3].Item:SetPoint("LEFT",0,0)

		self.Mainframe.Objective.Block[3].Item.Font = self.Mainframe.Objective.Block[3].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[3].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Objective.Block[3].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Objective.Block[3].Item.Font:SetWidth(70)
			self.Mainframe.Objective.Block[3].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Objective.Block[3].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[3].Item.Font:SetText("99")
			self.Mainframe.Objective.Block[3].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[3].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Objective.Block[3].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[3])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Objective.Block[3].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[3].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Objective.Block[3].TextBackground:SetWidth(70)
			self.Mainframe.Objective.Block[3].TextBackground:SetHeight(30)
			self.Mainframe.Objective.Block[3].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Objective.Block[3].TextFont = self.Mainframe.Objective.Block[3].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[3].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Objective.Block[3].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Objective.Block[3].TextFont:SetWidth(70)
			self.Mainframe.Objective.Block[3].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Objective.Block[3].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[3].TextFont:SetText("TEST")
			self.Mainframe.Objective.Block[3].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[3].TextFont:SetShadowOffset(1, -1)

	self.Mainframe.Objective.Block[4] = CreateFrame("Frame",nil,self.Mainframe.Objective)
		self.Mainframe.Objective.Block[4]:SetWidth(100)
		self.Mainframe.Objective.Block[4]:SetHeight(30)
		self.Mainframe.Objective.Block[4]:SetPoint("TOPLEFT",15,-85)

		self.Mainframe.Objective.Block[4].Item = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[4])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Objective.Block[4].Item:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[4].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Objective.Block[4].Item:SetWidth(30)
			self.Mainframe.Objective.Block[4].Item:SetHeight(30)
			self.Mainframe.Objective.Block[4].Item:SetPoint("LEFT",0,0)

		self.Mainframe.Objective.Block[4].Item.Font = self.Mainframe.Objective.Block[4].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[4].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Objective.Block[4].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Objective.Block[4].Item.Font:SetWidth(70)
			self.Mainframe.Objective.Block[4].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Objective.Block[4].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[4].Item.Font:SetText("99")
			self.Mainframe.Objective.Block[4].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[4].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Objective.Block[4].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[4])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Objective.Block[4].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[4].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Objective.Block[4].TextBackground:SetWidth(70)
			self.Mainframe.Objective.Block[4].TextBackground:SetHeight(30)
			self.Mainframe.Objective.Block[4].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Objective.Block[4].TextFont = self.Mainframe.Objective.Block[4].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[4].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Objective.Block[4].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Objective.Block[4].TextFont:SetWidth(70)
			self.Mainframe.Objective.Block[4].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Objective.Block[4].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[4].TextFont:SetText("TEST")
			self.Mainframe.Objective.Block[4].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[4].TextFont:SetShadowOffset(1, -1)

	self.Mainframe.Objective.Block[5] = CreateFrame("Frame",nil,self.Mainframe.Objective)
		self.Mainframe.Objective.Block[5]:SetWidth(100)
		self.Mainframe.Objective.Block[5]:SetHeight(30)
		self.Mainframe.Objective.Block[5]:SetPoint("TOPLEFT",120,-85)

		self.Mainframe.Objective.Block[5].Item = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[5])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Objective.Block[5].Item:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[5].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Objective.Block[5].Item:SetWidth(30)
			self.Mainframe.Objective.Block[5].Item:SetHeight(30)
			self.Mainframe.Objective.Block[5].Item:SetPoint("LEFT",0,0)

		self.Mainframe.Objective.Block[5].Item.Font = self.Mainframe.Objective.Block[5].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[5].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Objective.Block[5].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Objective.Block[5].Item.Font:SetWidth(70)
			self.Mainframe.Objective.Block[5].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Objective.Block[5].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[5].Item.Font:SetText("99")
			self.Mainframe.Objective.Block[5].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[5].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Objective.Block[5].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[5])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Objective.Block[5].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[5].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Objective.Block[5].TextBackground:SetWidth(70)
			self.Mainframe.Objective.Block[5].TextBackground:SetHeight(30)
			self.Mainframe.Objective.Block[5].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Objective.Block[5].TextFont = self.Mainframe.Objective.Block[5].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[5].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Objective.Block[5].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Objective.Block[5].TextFont:SetWidth(70)
			self.Mainframe.Objective.Block[5].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Objective.Block[5].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[5].TextFont:SetText("TEST")
			self.Mainframe.Objective.Block[5].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[5].TextFont:SetShadowOffset(1, -1)

	self.Mainframe.Objective.Block[6] = CreateFrame("Frame",nil,self.Mainframe.Objective)
		self.Mainframe.Objective.Block[6]:SetWidth(100)
		self.Mainframe.Objective.Block[6]:SetHeight(30)
		self.Mainframe.Objective.Block[6]:SetPoint("TOPLEFT",225,-85)

		self.Mainframe.Objective.Block[6].Item = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[6])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Objective.Block[6].Item:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[6].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Objective.Block[6].Item:SetWidth(30)
			self.Mainframe.Objective.Block[6].Item:SetHeight(30)
			self.Mainframe.Objective.Block[6].Item:SetPoint("LEFT",0,0)

		self.Mainframe.Objective.Block[6].Item.Font = self.Mainframe.Objective.Block[6].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[6].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Objective.Block[6].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Objective.Block[6].Item.Font:SetWidth(70)
			self.Mainframe.Objective.Block[6].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Objective.Block[6].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[6].Item.Font:SetText("99")
			self.Mainframe.Objective.Block[6].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[6].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Objective.Block[6].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Objective.Block[6])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Objective.Block[6].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Objective.Block[6].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Objective.Block[6].TextBackground:SetWidth(70)
			self.Mainframe.Objective.Block[6].TextBackground:SetHeight(30)
			self.Mainframe.Objective.Block[6].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Objective.Block[6].TextFont = self.Mainframe.Objective.Block[6].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Objective.Block[6].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Objective.Block[6].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Objective.Block[6].TextFont:SetWidth(70)
			self.Mainframe.Objective.Block[6].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Objective.Block[6].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Objective.Block[6].TextFont:SetText("TEST")
			self.Mainframe.Objective.Block[6].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Objective.Block[6].TextFont:SetShadowOffset(1, -1)

	-- Req. Fonts
	self.Mainframe.Objective.Font = {}
	self.Mainframe.Objective.Font[1] = self.Mainframe.Objective:CreateFontString(nil, "OVERLAY")
		self.Mainframe.Objective.Font[1]:SetPoint("TOP", 0, -50)
		self.Mainframe.Objective.Font[1]:SetFont("Fonts\\FRIZQT__.TTF", 12)
		self.Mainframe.Objective.Font[1]:SetWidth(320)
		self.Mainframe.Objective.Font[1]:SetHeight(50)
		self.Mainframe.Objective.Font[1]:SetJustifyH("LEFT")
		self.Mainframe.Objective.Font[1]:SetJustifyV("TOP")
		self.Mainframe.Objective.Font[1]:SetText("TEST")
		self.Mainframe.Objective.Font[1]:SetTextColor(0.95,0.95,0.95)
		self.Mainframe.Objective.Font[1]:SetShadowOffset(1, -1)

	self.Mainframe.Objective.Font[2] = self.Mainframe.Objective:CreateFontString(nil, "OVERLAY")
		self.Mainframe.Objective.Font[2]:SetPoint("TOP", 0, -65)
		self.Mainframe.Objective.Font[2]:SetFont("Fonts\\FRIZQT__.TTF", 12)
		self.Mainframe.Objective.Font[2]:SetWidth(320)
		self.Mainframe.Objective.Font[2]:SetHeight(50)
		self.Mainframe.Objective.Font[2]:SetJustifyH("LEFT")
		self.Mainframe.Objective.Font[2]:SetJustifyV("TOP")
		self.Mainframe.Objective.Font[2]:SetText("TEST")
		self.Mainframe.Objective.Font[2]:SetTextColor(0.95,0.95,0.95)
		self.Mainframe.Objective.Font[2]:SetShadowOffset(1, -1)

	self.Mainframe.Objective.Font[3] = self.Mainframe.Objective:CreateFontString(nil, "OVERLAY")
		self.Mainframe.Objective.Font[3]:SetPoint("TOP", 0, -80)
		self.Mainframe.Objective.Font[3]:SetFont("Fonts\\FRIZQT__.TTF", 12)
		self.Mainframe.Objective.Font[3]:SetWidth(320)
		self.Mainframe.Objective.Font[3]:SetHeight(50)
		self.Mainframe.Objective.Font[3]:SetJustifyH("LEFT")
		self.Mainframe.Objective.Font[3]:SetJustifyV("TOP")
		self.Mainframe.Objective.Font[3]:SetText("TEST")
		self.Mainframe.Objective.Font[3]:SetTextColor(0.95,0.95,0.95)
		self.Mainframe.Objective.Font[3]:SetShadowOffset(1, -1)

	self.Mainframe.Objective.Font[4] = self.Mainframe.Objective:CreateFontString(nil, "OVERLAY")
		self.Mainframe.Objective.Font[4]:SetPoint("TOP", 0, -95)
		self.Mainframe.Objective.Font[4]:SetFont("Fonts\\FRIZQT__.TTF", 12)
		self.Mainframe.Objective.Font[4]:SetWidth(320)
		self.Mainframe.Objective.Font[4]:SetHeight(50)
		self.Mainframe.Objective.Font[4]:SetJustifyH("LEFT")
		self.Mainframe.Objective.Font[4]:SetJustifyV("TOP")
		self.Mainframe.Objective.Font[4]:SetText("TEST")
		self.Mainframe.Objective.Font[4]:SetTextColor(0.95,0.95,0.95)
		self.Mainframe.Objective.Font[4]:SetShadowOffset(1, -1)

	self.Mainframe.Objective.Font[5] = self.Mainframe.Objective:CreateFontString(nil, "OVERLAY")
		self.Mainframe.Objective.Font[5]:SetPoint("TOP", 0, -110)
		self.Mainframe.Objective.Font[5]:SetFont("Fonts\\FRIZQT__.TTF", 12)
		self.Mainframe.Objective.Font[5]:SetWidth(320)
		self.Mainframe.Objective.Font[5]:SetHeight(50)
		self.Mainframe.Objective.Font[5]:SetJustifyH("LEFT")
		self.Mainframe.Objective.Font[5]:SetJustifyV("TOP")
		self.Mainframe.Objective.Font[5]:SetText("TEST")
		self.Mainframe.Objective.Font[5]:SetTextColor(0.95,0.95,0.95)
		self.Mainframe.Objective.Font[5]:SetShadowOffset(1, -1)

	self.Mainframe.Objective.Font[6] = self.Mainframe.Objective:CreateFontString(nil, "OVERLAY")
		self.Mainframe.Objective.Font[6]:SetPoint("TOP", 0, -125)
		self.Mainframe.Objective.Font[6]:SetFont("Fonts\\FRIZQT__.TTF", 12)
		self.Mainframe.Objective.Font[6]:SetWidth(320)
		self.Mainframe.Objective.Font[6]:SetHeight(50)
		self.Mainframe.Objective.Font[6]:SetJustifyH("LEFT")
		self.Mainframe.Objective.Font[6]:SetJustifyV("TOP")
		self.Mainframe.Objective.Font[6]:SetText("TEST")
		self.Mainframe.Objective.Font[6]:SetTextColor(0.95,0.95,0.95)
  	self.Mainframe.Objective.Font[6]:SetShadowOffset(1, -1)

end

function storyline.QuestComplete:ConfigureFrame()

	-- Quest Complete Mainframe Buttons
	self.Mainframe = CreateFrame("Frame",nil,storyline.Background.layer5)
		self.Mainframe:SetWidth(350)
		self.Mainframe:SetHeight(400)
		self.Mainframe:SetPoint("CENTER",0,30)

	-- Center Items
	self.Mainframe.CenterItem = CreateFrame("Frame",nil,self.Mainframe)
		local backdrop = {bgFile = "Interface\\Icons\\INV_Box_02"}
		self.Mainframe.CenterItem:SetBackdrop(backdrop)
		self.Mainframe.CenterItem:SetBackdropColor(1,1,1,1)
		self.Mainframe.CenterItem:SetWidth(40)
		self.Mainframe.CenterItem:SetHeight(40)
		self.Mainframe.CenterItem:SetPoint("CENTER",0,70)

	self.Mainframe.CenterItem.Frame = CreateFrame("Frame",nil,self.Mainframe.CenterItem)
		local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\UI-Achievement-IconFrame"}
		self.Mainframe.CenterItem.Frame:SetBackdrop(backdrop)
		self.Mainframe.CenterItem.Frame:SetBackdropColor(1,1,1,1)
		self.Mainframe.CenterItem.Frame:SetWidth(105)
		self.Mainframe.CenterItem.Frame:SetHeight(105)
		self.Mainframe.CenterItem.Frame:SetPoint("TOPLEFT",-8,8)

	self.Mainframe.CenterRing = CreateFrame("Frame",nil,self.Mainframe.CenterItem)
		local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\GarrZoneAbility-TradingPost"}
		self.Mainframe.CenterRing:SetBackdrop(backdrop)
		self.Mainframe.CenterRing:SetBackdropColor(1,1,1,1)
		self.Mainframe.CenterRing:SetWidth(256)
		self.Mainframe.CenterRing:SetHeight(128)
		self.Mainframe.CenterRing:SetPoint("CENTER",0,0)

	self.Mainframe.CenterFlash = CreateFrame("Frame",nil,self.Mainframe.CenterItem)
		self.Mainframe.CenterFlash:SetWidth(256)
		self.Mainframe.CenterFlash:SetHeight(256)
		self.Mainframe.CenterFlash:SetPoint("CENTER",0,0)
		self.Mainframe.CenterFlash.Flash = self.Mainframe.CenterFlash:CreateTexture()
		self.Mainframe.CenterFlash.Flash:SetAllPoints()
		self.Mainframe.CenterFlash.Flash:SetTexture("Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\PandarenTrainingLarge_Circular_Flash")
		self.Mainframe.CenterFlash.Flash:SetTexCoord(1,0,1,0)
		self.Mainframe.CenterFlash.Flash:SetBlendMode("ADD")

	-- Reward Frame
	self.Mainframe.Reward = CreateFrame("Frame",nil,self.Mainframe)
		local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\UI-GuildAchievement-Parchment-Horizontal", edgeFile="Interface\\GLUES\\COMMON\\TextPanel-Border", tile=false,tileSize = 16, edgeSize = 36, insets = { left = 6, right = 6, top = 6, bottom = 6 }}
		self.Mainframe.Reward:SetBackdrop(backdrop)
		self.Mainframe.Reward:SetBackdropColor(1,1,1,0.5)
		self.Mainframe.Reward:SetBackdropBorderColor(1,1,0,1)
		self.Mainframe.Reward:SetWidth(350)
		self.Mainframe.Reward:SetHeight(150)
		self.Mainframe.Reward:SetPoint("CENTER",0,-50)

	self.Mainframe.Reward.Headline = self.Mainframe.Reward:CreateFontString(nil, "OVERLAY")
		self.Mainframe.Reward.Headline:SetPoint("TOP", 0, -10)
		self.Mainframe.Reward.Headline:SetFont("Fonts\\FRIZQT__.TTF", 16)
		self.Mainframe.Reward.Headline:SetWidth(470)
		self.Mainframe.Reward.Headline:SetHeight(70)
		self.Mainframe.Reward.Headline:SetJustifyH("CENTER")
		self.Mainframe.Reward.Headline:SetJustifyV("TOP")
		self.Mainframe.Reward.Headline:SetText("Rewards")
		self.Mainframe.Reward.Headline:SetTextColor(1,0.75,0)
		self.Mainframe.Reward.Headline:SetShadowOffset(1, -1)

	self.Mainframe.Reward.ReceiveText = self.Mainframe.Reward:CreateFontString(nil, "OVERLAY")
		self.Mainframe.Reward.ReceiveText:SetPoint("TOP", 0, -30)
		self.Mainframe.Reward.ReceiveText:SetFont("Fonts\\FRIZQT__.TTF", 14)
		self.Mainframe.Reward.ReceiveText:SetWidth(320)
		self.Mainframe.Reward.ReceiveText:SetHeight(50)
		self.Mainframe.Reward.ReceiveText:SetJustifyH("LEFT")
		self.Mainframe.Reward.ReceiveText:SetJustifyV("TOP")
		self.Mainframe.Reward.ReceiveText:SetText("You will Receive:")
		self.Mainframe.Reward.ReceiveText:SetTextColor(1,1,1)
		self.Mainframe.Reward.ReceiveText:SetShadowOffset(1, -1)

-- gold reward frame, the shitty blizzard frametemplate doesnt work!
	self.Mainframe.Reward.Money = CreateFrame("Frame",nil,self.Mainframe.Reward)
		self.Mainframe.Reward.Money:SetPoint("TOPLEFT",170,-23)
		self.Mainframe.Reward.Money:SetWidth(100)
		self.Mainframe.Reward.Money:SetHeight(28)
			self.Mainframe.Reward.Money.Copper = CreateFrame("Frame",nil,self.Mainframe.Reward.Money)
			self.Mainframe.Reward.Money.Copper:SetPoint("RIGHT",0,0)
			self.Mainframe.Reward.Money.Copper:SetWidth(19)
			self.Mainframe.Reward.Money.Copper:SetHeight(19)
			local Copper = self.Mainframe.Reward.Money.Copper:CreateTexture()
			Copper:SetAllPoints()
			Copper:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
			Copper:SetTexCoord(0.5,0.75,0,1)
			self.Mainframe.Reward.Money.Copper.Font = self.Mainframe.Reward.Money.Copper:CreateFontString(nil, "OVERLAY","NumberFontNormalLarge")
			self.Mainframe.Reward.Money.Copper.Font:SetPoint("RIGHT",-19,0)
			self.Mainframe.Reward.Money.Copper.Font:SetText("??")
			self.Mainframe.Reward.Money.Silver = CreateFrame("Frame",nil,self.Mainframe.Reward.Money)
			self.Mainframe.Reward.Money.Silver:SetPoint("CENTER",0,0)
			self.Mainframe.Reward.Money.Silver:SetWidth(19)
			self.Mainframe.Reward.Money.Silver:SetHeight(19)
			local Silver = self.Mainframe.Reward.Money.Silver:CreateTexture()
			Silver:SetAllPoints()
			Silver:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
			Silver:SetTexCoord(0.25,0.5,0,1)
			self.Mainframe.Reward.Money.Silver.Font = self.Mainframe.Reward.Money.Silver:CreateFontString(nil, "OVERLAY","NumberFontNormalLarge")
			self.Mainframe.Reward.Money.Silver.Font:SetPoint("CENTER",-19,0)
			self.Mainframe.Reward.Money.Silver.Font:SetText("??")
			self.Mainframe.Reward.Money.Gold = CreateFrame("Frame",nil,self.Mainframe.Reward.Money)
			self.Mainframe.Reward.Money.Gold:SetPoint("LEFT",0,0)
			self.Mainframe.Reward.Money.Gold:SetWidth(19)
			self.Mainframe.Reward.Money.Gold:SetHeight(19)
			local Gold = self.Mainframe.Reward.Money.Gold:CreateTexture()
			Gold:SetAllPoints()
			Gold:SetTexture("Interface\\MoneyFrame\\UI-MoneyIcons")
			Gold:SetTexCoord(0.,0.25,0,1)
			self.Mainframe.Reward.Money.Gold.Font = self.Mainframe.Reward.Money.Gold:CreateFontString(nil, "OVERLAY","NumberFontNormalLarge")
			self.Mainframe.Reward.Money.Gold.Font:SetPoint("LEFT",-19,0)
			self.Mainframe.Reward.Money.Gold.Font:SetText("??")

	-- Reward Items Blocks
	self.Mainframe.Reward.Block = {}

	self.Mainframe.Reward.Block[1] = CreateFrame("Frame",nil,self.Mainframe.Reward)
		local backdrop = {bgFile = "Interface\\ChatFrame\\ChatFrameBackground"}
		self.Mainframe.Reward.Block[1]:SetBackdrop(backdrop)
		self.Mainframe.Reward.Block[1]:SetBackdropColor(0.8,0.8,0.8,0)
		self.Mainframe.Reward.Block[1]:SetBackdropBorderColor(1,1,1,0)
		self.Mainframe.Reward.Block[1]:SetWidth(100)
		self.Mainframe.Reward.Block[1]:SetHeight(30)
		self.Mainframe.Reward.Block[1]:SetPoint("TOPLEFT",15,-50)

		self.Mainframe.Reward.Block[1].Item = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[1])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Reward.Block[1].Item:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[1].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Reward.Block[1].Item:SetWidth(30)
			self.Mainframe.Reward.Block[1].Item:SetHeight(30)
			self.Mainframe.Reward.Block[1].Item:SetPoint("LEFT",0,0)

		self.Mainframe.Reward.Block[1].Item.Button = CreateFrame("Button",nil,self.Mainframe.Reward.Block[1])
			self.Mainframe.Reward.Block[1].Item.Button:SetWidth(100)
			self.Mainframe.Reward.Block[1].Item.Button:SetHeight(30)
			self.Mainframe.Reward.Block[1].Item.Button:SetPoint("LEFT",0,0)

		self.Mainframe.Reward.Block[1].Item.Font = self.Mainframe.Reward.Block[1].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[1].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Reward.Block[1].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Reward.Block[1].Item.Font:SetWidth(70)
			self.Mainframe.Reward.Block[1].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Reward.Block[1].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[1].Item.Font:SetText("99")
			self.Mainframe.Reward.Block[1].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[1].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Reward.Block[1].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[1])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Reward.Block[1].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[1].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Reward.Block[1].TextBackground:SetWidth(70)
			self.Mainframe.Reward.Block[1].TextBackground:SetHeight(30)
			self.Mainframe.Reward.Block[1].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Reward.Block[1].TextFont = self.Mainframe.Reward.Block[1].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[1].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Reward.Block[1].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Reward.Block[1].TextFont:SetWidth(70)
			self.Mainframe.Reward.Block[1].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Reward.Block[1].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[1].TextFont:SetText("TEST")
			self.Mainframe.Reward.Block[1].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[1].TextFont:SetShadowOffset(1, -1)

	self.Mainframe.Reward.Block[2] = CreateFrame("Frame",nil,self.Mainframe.Reward)
		local backdrop = {bgFile = "Interface\\ChatFrame\\ChatFrameBackground"}
		self.Mainframe.Reward.Block[2]:SetBackdrop(backdrop)
		self.Mainframe.Reward.Block[2]:SetBackdropColor(0.8,0.8,0.8,0)
		self.Mainframe.Reward.Block[2]:SetBackdropBorderColor(1,1,1,0)
		self.Mainframe.Reward.Block[2]:SetWidth(100)
		self.Mainframe.Reward.Block[2]:SetHeight(30)
		self.Mainframe.Reward.Block[2]:SetPoint("TOPLEFT",120,-50)

		self.Mainframe.Reward.Block[2].Item = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[2])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Reward.Block[2].Item:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[2].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Reward.Block[2].Item:SetWidth(30)
			self.Mainframe.Reward.Block[2].Item:SetHeight(30)
			self.Mainframe.Reward.Block[2].Item:SetPoint("LEFT",0,0)

		self.Mainframe.Reward.Block[2].Item.Button = CreateFrame("Button",nil,self.Mainframe.Reward.Block[2])
			self.Mainframe.Reward.Block[2].Item.Button:SetWidth(100)
			self.Mainframe.Reward.Block[2].Item.Button:SetHeight(30)
			self.Mainframe.Reward.Block[2].Item.Button:SetPoint("LEFT",0,0)

		self.Mainframe.Reward.Block[2].Item.Font = self.Mainframe.Reward.Block[2].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[2].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Reward.Block[2].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Reward.Block[2].Item.Font:SetWidth(70)
			self.Mainframe.Reward.Block[2].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Reward.Block[2].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[2].Item.Font:SetText("99")
			self.Mainframe.Reward.Block[2].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[2].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Reward.Block[2].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[2])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Reward.Block[2].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[2].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Reward.Block[2].TextBackground:SetWidth(70)
			self.Mainframe.Reward.Block[2].TextBackground:SetHeight(30)
			self.Mainframe.Reward.Block[2].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Reward.Block[2].TextFont = self.Mainframe.Reward.Block[2].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[2].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Reward.Block[2].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Reward.Block[2].TextFont:SetWidth(70)
			self.Mainframe.Reward.Block[2].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Reward.Block[2].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[2].TextFont:SetText("TEST")
			self.Mainframe.Reward.Block[2].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[2].TextFont:SetShadowOffset(1, -1)

	self.Mainframe.Reward.Block[3] = CreateFrame("Frame",nil,self.Mainframe.Reward)
		local backdrop = {bgFile = "Interface\\ChatFrame\\ChatFrameBackground"}
		self.Mainframe.Reward.Block[3]:SetBackdrop(backdrop)
		self.Mainframe.Reward.Block[3]:SetBackdropColor(0.8,0.8,0.8,0)
		self.Mainframe.Reward.Block[3]:SetBackdropBorderColor(1,1,1,0)
		self.Mainframe.Reward.Block[3]:SetWidth(100)
		self.Mainframe.Reward.Block[3]:SetHeight(30)
		self.Mainframe.Reward.Block[3]:SetPoint("TOPLEFT",225,-50)

		self.Mainframe.Reward.Block[3].Item = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[3])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Reward.Block[3].Item:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[3].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Reward.Block[3].Item:SetWidth(30)
			self.Mainframe.Reward.Block[3].Item:SetHeight(30)
			self.Mainframe.Reward.Block[3].Item:SetPoint("LEFT",0,0)

		self.Mainframe.Reward.Block[3].Item.Button = CreateFrame("Button",nil,self.Mainframe.Reward.Block[3])
			self.Mainframe.Reward.Block[3].Item.Button:SetWidth(100)
			self.Mainframe.Reward.Block[3].Item.Button:SetHeight(30)
			self.Mainframe.Reward.Block[3].Item.Button:SetPoint("LEFT",0,0)

		self.Mainframe.Reward.Block[3].Item.Font = self.Mainframe.Reward.Block[3].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[3].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Reward.Block[3].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Reward.Block[3].Item.Font:SetWidth(70)
			self.Mainframe.Reward.Block[3].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Reward.Block[3].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[3].Item.Font:SetText("99")
			self.Mainframe.Reward.Block[3].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[3].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Reward.Block[3].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[3])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Reward.Block[3].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[3].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Reward.Block[3].TextBackground:SetWidth(70)
			self.Mainframe.Reward.Block[3].TextBackground:SetHeight(30)
			self.Mainframe.Reward.Block[3].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Reward.Block[3].TextFont = self.Mainframe.Reward.Block[3].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[3].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Reward.Block[3].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Reward.Block[3].TextFont:SetWidth(70)
			self.Mainframe.Reward.Block[3].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Reward.Block[3].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[3].TextFont:SetText("TEST")
			self.Mainframe.Reward.Block[3].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[3].TextFont:SetShadowOffset(1, -1)

	self.Mainframe.Reward.Block[4] = CreateFrame("Frame",nil,self.Mainframe.Reward)
		local backdrop = {bgFile = "Interface\\ChatFrame\\ChatFrameBackground"}
		self.Mainframe.Reward.Block[4]:SetBackdrop(backdrop)
		self.Mainframe.Reward.Block[4]:SetBackdropColor(0.8,0.8,0.8,0)
		self.Mainframe.Reward.Block[4]:SetBackdropBorderColor(1,1,1,0)
		self.Mainframe.Reward.Block[4]:SetWidth(100)
		self.Mainframe.Reward.Block[4]:SetHeight(30)
		self.Mainframe.Reward.Block[4]:SetPoint("TOPLEFT",15,-85)

		self.Mainframe.Reward.Block[4].Item = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[4])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Reward.Block[4].Item:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[4].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Reward.Block[4].Item:SetWidth(30)
			self.Mainframe.Reward.Block[4].Item:SetHeight(30)
			self.Mainframe.Reward.Block[4].Item:SetPoint("LEFT",0,0)

	self.Mainframe.Reward.Block[4].Item.Button = CreateFrame("Button",nil,self.Mainframe.Reward.Block[4])
			self.Mainframe.Reward.Block[4].Item.Button:SetWidth(100)
			self.Mainframe.Reward.Block[4].Item.Button:SetHeight(30)
			self.Mainframe.Reward.Block[4].Item.Button:SetPoint("LEFT",0,0)

		self.Mainframe.Reward.Block[4].Item.Font = self.Mainframe.Reward.Block[4].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[4].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Reward.Block[4].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Reward.Block[4].Item.Font:SetWidth(70)
			self.Mainframe.Reward.Block[4].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Reward.Block[4].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[4].Item.Font:SetText("99")
			self.Mainframe.Reward.Block[4].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[4].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Reward.Block[4].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[4])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Reward.Block[4].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[4].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Reward.Block[4].TextBackground:SetWidth(70)
			self.Mainframe.Reward.Block[4].TextBackground:SetHeight(30)
			self.Mainframe.Reward.Block[4].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Reward.Block[4].TextFont = self.Mainframe.Reward.Block[4].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[4].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Reward.Block[4].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Reward.Block[4].TextFont:SetWidth(70)
			self.Mainframe.Reward.Block[4].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Reward.Block[4].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[4].TextFont:SetText("TEST")
			self.Mainframe.Reward.Block[4].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[4].TextFont:SetShadowOffset(1, -1)

	self.Mainframe.Reward.Block[5] = CreateFrame("Frame",nil,self.Mainframe.Reward)
		local backdrop = {bgFile = "Interface\\ChatFrame\\ChatFrameBackground"}
		self.Mainframe.Reward.Block[5]:SetBackdrop(backdrop)
		self.Mainframe.Reward.Block[5]:SetBackdropColor(0.8,0.8,0.8,0)
		self.Mainframe.Reward.Block[5]:SetBackdropBorderColor(1,1,1,0)
		self.Mainframe.Reward.Block[5]:SetWidth(100)
		self.Mainframe.Reward.Block[5]:SetHeight(30)
		self.Mainframe.Reward.Block[5]:SetPoint("TOPLEFT",120,-85)

		self.Mainframe.Reward.Block[5].Item = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[5])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Reward.Block[5].Item:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[5].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Reward.Block[5].Item:SetWidth(30)
			self.Mainframe.Reward.Block[5].Item:SetHeight(30)
			self.Mainframe.Reward.Block[5].Item:SetPoint("LEFT",0,0)

	self.Mainframe.Reward.Block[5].Item.Button = CreateFrame("Button",nil,self.Mainframe.Reward.Block[5])
			self.Mainframe.Reward.Block[5].Item.Button:SetWidth(100)
			self.Mainframe.Reward.Block[5].Item.Button:SetHeight(30)
			self.Mainframe.Reward.Block[5].Item.Button:SetPoint("LEFT",0,0)

		self.Mainframe.Reward.Block[5].Item.Font = self.Mainframe.Reward.Block[5].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[5].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Reward.Block[5].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Reward.Block[5].Item.Font:SetWidth(70)
			self.Mainframe.Reward.Block[5].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Reward.Block[5].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[5].Item.Font:SetText("99")
			self.Mainframe.Reward.Block[5].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[5].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Reward.Block[5].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[5])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Reward.Block[5].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[5].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Reward.Block[5].TextBackground:SetWidth(70)
			self.Mainframe.Reward.Block[5].TextBackground:SetHeight(30)
			self.Mainframe.Reward.Block[5].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Reward.Block[5].TextFont = self.Mainframe.Reward.Block[5].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[5].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Reward.Block[5].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Reward.Block[5].TextFont:SetWidth(70)
			self.Mainframe.Reward.Block[5].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Reward.Block[5].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[5].TextFont:SetText("TEST")
			self.Mainframe.Reward.Block[5].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[5].TextFont:SetShadowOffset(1, -1)

	self.Mainframe.Reward.Block[6] = CreateFrame("Frame",nil,self.Mainframe.Reward)
		local backdrop = {bgFile = "Interface\\ChatFrame\\ChatFrameBackground"}
		self.Mainframe.Reward.Block[6]:SetBackdrop(backdrop)
		self.Mainframe.Reward.Block[6]:SetBackdropColor(0.8,0.8,0.8,0)
		self.Mainframe.Reward.Block[6]:SetBackdropBorderColor(1,1,1,0)
		self.Mainframe.Reward.Block[6]:SetWidth(100)
		self.Mainframe.Reward.Block[6]:SetHeight(30)
		self.Mainframe.Reward.Block[6]:SetPoint("TOPLEFT",225,-85)

		self.Mainframe.Reward.Block[6].Item = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[6])
			local backdrop = {bgFile = "Interface\\Icons\\INV_Misc_QuestionMark"}
			self.Mainframe.Reward.Block[6].Item:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[6].Item:SetBackdropColor(1,1,1,1)
			self.Mainframe.Reward.Block[6].Item:SetWidth(30)
			self.Mainframe.Reward.Block[6].Item:SetHeight(30)
			self.Mainframe.Reward.Block[6].Item:SetPoint("LEFT",0,0)

	self.Mainframe.Reward.Block[6].Item.Button = CreateFrame("Button",nil,self.Mainframe.Reward.Block[6])
			self.Mainframe.Reward.Block[6].Item.Button:SetWidth(100)
			self.Mainframe.Reward.Block[6].Item.Button:SetHeight(30)
			self.Mainframe.Reward.Block[6].Item.Button:SetPoint("LEFT",0,0)

		self.Mainframe.Reward.Block[6].Item.Font = self.Mainframe.Reward.Block[6].Item:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[6].Item.Font:SetPoint("BOTTOMRIGHT", -2, 2)
			self.Mainframe.Reward.Block[6].Item.Font:SetFont("Fonts\\FRIZQT__.TTF", 10)
			self.Mainframe.Reward.Block[6].Item.Font:SetWidth(70)
			self.Mainframe.Reward.Block[6].Item.Font:SetJustifyH("RIGHT")
			self.Mainframe.Reward.Block[6].Item.Font:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[6].Item.Font:SetText("99")
			self.Mainframe.Reward.Block[6].Item.Font:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[6].Item.Font:SetShadowOffset(1, -1)

		self.Mainframe.Reward.Block[6].TextBackground = CreateFrame("Frame",nil,self.Mainframe.Reward.Block[6])
			local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"}
			self.Mainframe.Reward.Block[6].TextBackground:SetBackdrop(backdrop)
			self.Mainframe.Reward.Block[6].TextBackground:SetBackdropColor(1,1,1,0.3)
			self.Mainframe.Reward.Block[6].TextBackground:SetWidth(70)
			self.Mainframe.Reward.Block[6].TextBackground:SetHeight(30)
			self.Mainframe.Reward.Block[6].TextBackground:SetPoint("LEFT",30,0)

		self.Mainframe.Reward.Block[6].TextFont = self.Mainframe.Reward.Block[6].TextBackground:CreateFontString(nil, "OVERLAY")
			self.Mainframe.Reward.Block[6].TextFont:SetPoint("LEFT", 0, 0)
			self.Mainframe.Reward.Block[6].TextFont:SetFont("Fonts\\FRIZQT__.TTF", 8)
			self.Mainframe.Reward.Block[6].TextFont:SetWidth(70)
			self.Mainframe.Reward.Block[6].TextFont:SetJustifyH("LEFT")
			self.Mainframe.Reward.Block[6].TextFont:SetJustifyV("CENTER")
			self.Mainframe.Reward.Block[6].TextFont:SetText("TEST")
			self.Mainframe.Reward.Block[6].TextFont:SetTextColor(0.95,0.95,0.95)
			self.Mainframe.Reward.Block[6].TextFont:SetShadowOffset(1, -1)

end

function storyline.OptionsFrame:ConfigureFrame()
	local backdrop = {bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", tile=true,tileSize = 16, edgeSize = 16, insets = { left = 3, right = 3, top = 3, bottom = 3 }}
   self:SetBackdrop(backdrop)
   self:SetBackdropColor(1,1,1,1)
	 self:SetWidth(680)
 	 self:SetHeight(100)
	 self:SetPoint("BOTTOM",0,-(self:GetHeight()))

	 self.SpeedFont = self:CreateFontString(nil, "OVERLAY")
		 self.SpeedFont:SetPoint("TOPLEFT", 10, -10)
		 self.SpeedFont:SetFont("Fonts\\FRIZQT__.TTF", 12)
		 self.SpeedFont:SetWidth(200)
		 self.SpeedFont:SetJustifyH("LEFT")
		 self.SpeedFont:SetJustifyV("TOP")
		 self.SpeedFont:SetText("Textspeed:")
		 self.SpeedFont:SetTextColor(1,1,1)

		 self.SpeedSlider = CreateFrame("Slider","StorylineSpeedSlider",self,"OptionsSliderTemplate")
		 self.SpeedSlider:SetPoint("TOPLEFT", 10, -40)
     self.SpeedSlider:SetWidth(132)
		 self.SpeedSlider:SetHeight(17)
		 self.SpeedSlider:SetOrientation("HORIZONTAL")
		 self.SpeedSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
		 self.SpeedSlider:SetMinMaxValues(1,100)
		 self.SpeedSlider:SetValueStep(1)
		 self.SpeedSlider:SetValue(storyline.Options.TextSpeed*10)
		 getglobal("StorylineSpeedSlider" .. 'Low'):SetText("1")
		 getglobal("StorylineSpeedSlider" .. 'High'):SetText("10")
		 getglobal("StorylineSpeedSlider" .. 'Text'):SetText(storyline.Options.TextSpeed)
		 self.SpeedSlider:SetScript("OnValueChanged", function()
			 										storyline.Options.TextSpeed = storyline.OptionsFrame.SpeedSlider:GetValue()/10; StorylineOptions.TextSpeed = storyline.Options.TextSpeed
	 												getglobal("StorylineSpeedSlider" .. 'Text'):SetText(storyline.Options.TextSpeed)
	 											end)

		 self.MoveFont = self:CreateFontString(nil, "OVERLAY")
			 self.MoveFont:SetPoint("TOPLEFT", 200, -10)
			 self.MoveFont:SetFont("Fonts\\FRIZQT__.TTF", 12)
			 self.MoveFont:SetWidth(200)
			 self.MoveFont:SetJustifyH("LEFT")
			 self.MoveFont:SetJustifyV("TOP")
			 self.MoveFont:SetText("Moveable:")
			 self.MoveFont:SetTextColor(1,1,1)

			 self.MoveButton = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
			 self.MoveButton:SetWidth(24)
			 self.MoveButton:SetHeight(24)
			 self.MoveButton:SetPoint("TOPLEFT",270,-5)
			 self.MoveButton:SetScript("OnClick", function ()
				 									PlaySound("igMainMenuOptionCheckBoxOn")
													if self.MoveButton:GetChecked() then storyline.Background:EnableMouse(1)
													else storyline.Background:EnableMouse(0) end
													end)

			self.HideFont = self:CreateFontString(nil, "OVERLAY")
				self.HideFont:SetPoint("TOPLEFT", 200, -30)
				self.HideFont:SetFont("Fonts\\FRIZQT__.TTF", 12)
				self.HideFont:SetWidth(200)
				self.HideFont:SetJustifyH("LEFT")
				self.HideFont:SetJustifyV("TOP")
				self.HideFont:SetText("Hide Blizzard Frames:")
				self.HideFont:SetTextColor(1,1,1)

			self.HideButton = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
				self.HideButton:SetWidth(24)
				self.HideButton:SetHeight(24)
				self.HideButton:SetPoint("TOPLEFT",330,-25)
				self.HideButton:SetScript("OnClick", function ()
													 PlaySound("igMainMenuOptionCheckBoxOn")
													 if self.HideButton:GetChecked() then storyline.Options.HideBlizzardFrames = 1; StorylineOptions.HideBlizzardFrames = 1
 													 else storyline.Options.HideBlizzardFrames = 0; StorylineOptions.HideBlizzardFrames = 0; DeclineQuest() end
													 storyline:HideBlizzard()
													 end)
			if storyline.Options.HideBlizzardFrames == 1 then self.HideButton:SetChecked(1)
			else self.HideButton:SetChecked(0) end

		self.SpeedFont = self:CreateFontString(nil, "OVERLAY")
		 self.SpeedFont:SetPoint("Bottom", 0, 10)
		 self.SpeedFont:SetFont("Fonts\\FRIZQT__.TTF", 12)
		 self.SpeedFont:SetWidth(800)
		 self.SpeedFont:SetJustifyH("CENTER")
		 self.SpeedFont:SetJustifyV("BOTTOM")
		 self.SpeedFont:SetText("Version: "..storyline.Options.Version.." by Renew @ Nostalrius.org")
		 self.SpeedFont:SetTextColor(1,1,1,0.5)

		 -- hide
		 self:Hide()

end

function storyline.Player:ConfigureFrame()

	self.Background = CreateFrame("Frame",nil,storyline.Background.layer3)
		local backdrop = {bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground"}
		self.Background:SetBackdrop(backdrop)
		self.Background:SetBackdropColor(1,1,1,0) -- alpha = 0
		self.Background:SetWidth(300)
		self.Background:SetHeight(400)
		self.Background:SetPoint("TOP",-200,-60)

	self.PlayerFrame = CreateFrame("PlayerModel", nil, storyline.Background.layer3)
		self.PlayerFrame:SetPoint("TOP",self.Background)
		self.PlayerFrame:SetWidth(300)
		self.PlayerFrame:SetHeight(400)
		self.PlayerFrame:SetUnit("player")
		self.PlayerFrame:SetFacing(0.8)
end

function storyline.NPC:ConfigureFrame()

	self.Background = CreateFrame("Frame",nil,storyline.Background.layer3)
		local backdrop = {bgFile = "Interface\\TutorialFrame\\TutorialFrameBackground"}
		self.Background:SetBackdrop(backdrop)
		self.Background:SetBackdropColor(1,1,1,0) -- alpha = 0
		self.Background:SetWidth(300)
		self.Background:SetHeight(400)
		self.Background:SetPoint("TOP",200,-60)

	self.PlayerFrame = CreateFrame("PlayerModel", nil, storyline.Background.layer3)
		self.PlayerFrame:SetPoint("TOP",self.Background)
		self.PlayerFrame:SetWidth(300)
		self.PlayerFrame:SetHeight(400)
		self.PlayerFrame:SetUnit("target")
		self.PlayerFrame:SetFacing(-0.8)

end

function storyline.Text:ConfigureFrame()

	-- Banner Font
	self.Banner = storyline.Background.layer4.Banner:CreateFontString(nil, "OVERLAY")
		self.Banner:SetPoint("CENTER", 0, 5)
		self.Banner:SetFont("Fonts\\FRIZQT__.TTF", 20)
		self.Banner:SetWidth(280)
		self.Banner:SetJustifyH("CENTER")
		self.Banner:SetJustifyV("TOP")
		self.Banner:SetText("Quest Title")
		self.Banner:SetTextColor(0.95,0.95,0.95)
		self.Banner:SetShadowOffset(1, -1)

	-- NPC Name Font
	self.NPCName = storyline.Background.layer5.Questtext:CreateFontString(nil, "OVERLAY")
		self.NPCName:SetPoint("TOPRIGHT", -70, 15)
		self.NPCName:SetFont("Fonts\\FRIZQT__.TTF", 16)
		self.NPCName:SetWidth(300)
		self.NPCName:SetJustifyH("RIGHT")
		self.NPCName:SetJustifyV("TOP")
		self.NPCName:SetText("NPC Name")
		self.NPCName:SetTextColor(1,0.75,0)
		self.NPCName:SetShadowOffset(1, -1)

	-- Questtext Font
	self.Questtext = {}
	self.Questtext.Font = storyline.Background.layer5.Questtext.Scrollframe.Content:CreateFontString(nil, "OVERLAY")
		self.Questtext.Font:SetPoint("TOPLEFT", 15, -10)
		self.Questtext.Font:SetFont("Fonts\\FRIZQT__.TTF", 14)
		self.Questtext.Font:SetWidth(600)
		self.Questtext.Font:SetHeight(300)
		self.Questtext.Font:SetJustifyH("LEFT")
		self.Questtext.Font:SetJustifyV("TOP")
		self.Questtext.Font:SetText("TEST")
		self.Questtext.Font:SetTextColor(1,1,0.4)

	-- Continue Font
	self.Questtext.Continue = storyline.Background.layer5.Questtext:CreateFontString(nil, "OVERLAY")
		self.Questtext.Continue:SetPoint("BOTTOM", 0, 0)
		self.Questtext.Continue:SetFont("Fonts\\FRIZQT__.TTF", 10)
		self.Questtext.Continue:SetWidth(100)
		self.Questtext.Continue:SetHeight(20)
		self.Questtext.Continue:SetJustifyH("LEFT")
		self.Questtext.Continue:SetJustifyV("TOP")
		self.Questtext.Continue:SetText("continue")
		self.Questtext.Continue:SetTextColor(1,1,0.4)

	-- Complete Font
	self.Questtext.Complete = storyline.Background.layer5.Questtext:CreateFontString(nil, "OVERLAY")
		self.Questtext.Complete:SetPoint("BOTTOM", 0, 0)
		self.Questtext.Complete:SetFont("Fonts\\FRIZQT__.TTF", 10)
		self.Questtext.Complete:SetWidth(100)
		self.Questtext.Complete:SetHeight(20)
		self.Questtext.Complete:SetJustifyH("LEFT")
		self.Questtext.Complete:SetJustifyV("TOP")
		self.Questtext.Complete:SetText("Complete quest")
		self.Questtext.Complete:SetTextColor(1,1,0.4)

end

function storyline:AcceptQuest()
	-- hide and show
	storyline:HideAll()
        UIFrameFadeIn(storyline.QuestDetail.GetQuest,0.5)

	-- open clicking
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnEnter",function()
                                                                            storyline.Background.layer5.Questtext:SetBackdropBorderColor(0,1,0,1)
                                                                            end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnLeave",function() storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1) end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnClick",function() storyline:AcceptQuestOnClick() end)
	storyline.Text.Questtext.Continue:Show()
	storyline.Text.Questtext.Complete:Hide()

	-- Update PlayerFrames
	storyline:UpdateModels()

	-- Set Questtext
	local QuestText = GetQuestText()
	storyline:ShowNPCText(QuestText)

	--Update Text
	storyline.Text.NPCName:SetText(UnitName("target"))
	local QuestTitel = GetTitleText()
	storyline.Text.Banner:SetText(QuestTitel)

	-- show
	storyline.Background:Show()

end

function storyline:AcceptQuestOnClick()
	-- close clicking
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnEnter",function()
											storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1)
                                                                            end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnLeave",function() storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1) end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnClick",function() end)
	storyline.Text.Questtext.Continue:Hide()

	local ObjectiveText = GetObjectiveText()
	storyline:ShowNPCText("Quest Objectives: "..ObjectiveText,0)
end

function storyline:ProgressQuest()
	-- hide and show
	storyline:HideAll()
	UIFrameFadeIn(storyline.QuestProgress.Mainframe,0.5)

	-- point to Quest
	storyline:GetObjectiveText()
	storyline:UpdateReqItems()

	-- close clicking
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnEnter",function()
											storyline.Background.layer5.Questtext:SetBackdropBorderColor(0,1,0,1)
											end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnLeave",function() storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1) end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnClick",function() storyline:ProgressQuestObjectives() end)
	storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1)
	storyline.Text.Questtext.Continue:Show()
	storyline.Text.Questtext.Complete:Hide()

	-- Update PlayerFrames
	storyline:UpdateModels()

	--Update Text
	storyline.Text.NPCName:SetText(UnitName("target"))
	local QuestTitel = GetTitleText()
	local ProgressText = GetProgressText()

	storyline.Text.Banner:SetText(QuestTitel)
	storyline:ShowNPCText(ProgressText)

	-- completeable?
	if IsQuestCompletable() then
		storyline.QuestProgress.Mainframe.State:SetBackdrop({bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\ReadyCheck-Ready"})
	else
		storyline.QuestProgress.Mainframe.State:SetBackdrop({bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\ReadyCheck-NotReady"})
	end

	-- show
	storyline.Background:Show()
end

function storyline:ProgressQuestObjectives()
	-- close clicking
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnEnter",function()
											storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1)
											end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnLeave",function() storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1) end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnClick",function() end)
	storyline.Text.Questtext.Continue:Hide()

	local ObjectiveText = storyline:GetObjectiveText()
	storyline:ShowNPCText("Quest Objectives: "..ObjectiveText,0)

	-- completeable?
	if IsQuestCompletable() then
		storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnEnter",function()
											storyline.Background.layer5.Questtext:SetBackdropBorderColor(0,1,0,1)
											end)
		storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnLeave",function() storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1) end)
		storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnClick",function() CompleteQuest() end)
		storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1)
		storyline.Text.Questtext.Complete:Show()
		storyline.QuestProgress.Mainframe.State:SetBackdrop({bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\ReadyCheck-Ready"})
	else
		storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnEnter",function() end)
		storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnLeave",function() end)
		storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnClick",function() end)
		storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1)
		storyline.Text.Questtext.Complete:Hide()
		storyline.QuestProgress.Mainframe.State:SetBackdrop({bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\ReadyCheck-NotReady"})
	end

end

function storyline:CompleteQuest()
	-- hide and show
	storyline:HideAll()
	UIFrameFadeIn(storyline.QuestComplete.Mainframe,0.5)
	storyline:UpdateRewardItems()
	for i=1,6 do storyline.QuestComplete.Mainframe.Reward.Block[i]:SetBackdropColor(0.8,0.8,0.8,0) end

	-- close clicking
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnEnter",function()
													storyline.Background.layer5.Questtext:SetBackdropBorderColor(0,1,0,1)
													end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnLeave",function() storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1) end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnClick",function() QuestRewardCompleteButton_OnClick(); DressUpFrame:Hide() end)
	storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1)
	storyline.Text.Questtext.Continue:Hide()
	storyline.Text.Questtext.Complete:Show()

	-- Update PlayerFrames
	storyline:UpdateModels()

	--Update Text
	storyline.Text.NPCName:SetText(UnitName("target"))
	local QuestTitel = GetTitleText()
	local RewardText = GetRewardText()

	storyline.Text.Banner:SetText(QuestTitel)
	storyline:ShowNPCText(RewardText)


	-- show
	storyline.Background:Show()
end

-- Get Objective Text from QuestLog : Devlivers Objective Text from quest
function storyline:GetObjectiveText()
	local QuestID = 0
	local QuestTitel = GetTitleText()
	local QuestLogTitel = ""
	local QuestLogTitelLevel
	local numEntries = GetNumQuestLogEntries()
	local ObjectiveText

	-- check if EQL3 (Extended Quest Log Addon) is active - EQL3 adds a [lvl] into text
	if EQL3_QuestLogFrame then
		for i=1, numEntries do
			QuestLogTitel,QuestLogTitelLevel = GetQuestLogTitle(i)
			if "["..QuestLogTitelLevel.."] "..QuestLogTitel == QuestTitel then
				QuestID = i
			end
		end
	else
		for i=1, numEntries do
			if GetQuestLogTitle(i) == QuestTitel then
				QuestID = i
			end
		end
	end

	if QuestID > 0 then
		QuestLog_SetSelection(QuestID)
		_,ObjectiveText = GetQuestLogQuestText()
	else ObjectiveText = "" end

	return ObjectiveText
end

-- Updates the Req. Items for Progress Frame
function storyline:UpdateReqItems()

	-- hide all frames
	for i=1,6 do storyline.QuestProgress.Mainframe.Objective.Block[i]:Hide() end
	for i=1,6 do storyline.QuestProgress.Mainframe.Objective.Font[i]:Hide() end

	-- Items and money
	local numRequiredItems = GetNumQuestItems()
	local numRequiredMoney = GetQuestMoneyToGet()/10000
	local startCounter = 1
	if numRequiredItems > 6 then numRequiredItems = 6 end -- max display of 6 items
	local questItemName = "QuestProgressItem"

	if numRequiredItems > 0 then
		-- check for gold req.
		if numRequiredMoney > 0 then
			storyline.QuestProgress.Mainframe.Objective.Block[1].Item:SetBackdrop({bgFile = "Interface\\Icons\\INV_Misc_Coin_02"})
			storyline.QuestProgress.Mainframe.Objective.Block[1].Item.Font:SetText(numRequiredMoney)
			storyline.QuestProgress.Mainframe.Objective.Block[1].TextFont:SetText("Gold")
			storyline.QuestProgress.Mainframe.Objective.Block[1]:Show()
			startCounter = 2
		end

		for i=startCounter,numRequiredItems do

			local name, texture, numItems = GetQuestItemInfo("required", i)
			if numItems == 1 then numItems = " " end -- dont show 1 item

			storyline.QuestProgress.Mainframe.Objective.Block[i].Item:SetBackdrop({bgFile = texture})
			storyline.QuestProgress.Mainframe.Objective.Block[i].Item.Font:SetText(numItems)
			storyline.QuestProgress.Mainframe.Objective.Block[i].TextFont:SetText(name)
			storyline.QuestProgress.Mainframe.Objective.Block[i]:Show()
		end

		else
		-- Text
		local numObjectives = GetNumQuestLeaderBoards()
		for i=1, numObjectives do
			local reqText
			local reqtype
			local finished
			reqText, reqtype, finished = GetQuestLogLeaderBoard(i);

			if ( finished ) then
				storyline.QuestProgress.Mainframe.Objective.Font[i]:SetTextColor(0,1,0)
			else
				storyline.QuestProgress.Mainframe.Objective.Font[i]:SetTextColor(1,0,0)
			end
			storyline.QuestProgress.Mainframe.Objective.Font[i]:SetText(reqText)
			storyline.QuestProgress.Mainframe.Objective.Font[i]:Show()
		end
	end
end

-- Updates the Reward Items for Complete Frame
function storyline:UpdateRewardItems()
	-- hide all frames
	for i=1,6 do storyline.QuestComplete.Mainframe.Reward.Block[i]:Hide() end

	local numQuestChoices = GetNumQuestChoices()
	local numQuestRewards = GetNumQuestRewards()
	local numQuestSpellRewards = 0
	if GetRewardSpell() then numQuestSpellRewards = 1 end
	local money = GetRewardMoney()
	local totalRewards = numQuestRewards + numQuestChoices + numQuestSpellRewards
	local counter = 0

	-- display gold
	local gold = floor(money/10000)
	local silver = floor((money-(gold*10000))/100)
	local copper = (money-(gold*10000)-(silver*100))

	if gold == 0 then storyline.QuestComplete.Mainframe.Reward.Money.Gold:Hide() else storyline.QuestComplete.Mainframe.Reward.Money.Gold:Show() end
	if gold == 0 and silver == 0 then storyline.QuestComplete.Mainframe.Reward.Money.Silver:Hide() else storyline.QuestComplete.Mainframe.Reward.Money.Silver:Show() end


	if money > 0 then
		storyline.QuestComplete.Mainframe.Reward.Money:Show()
		storyline.QuestComplete.Mainframe.Reward.Money.Gold.Font:SetText(gold)
		storyline.QuestComplete.Mainframe.Reward.Money.Silver.Font:SetText(silver)
		storyline.QuestComplete.Mainframe.Reward.Money.Copper.Font:SetText(copper)
	else storyline.QuestComplete.Mainframe.Reward.Money:Hide()
	end

  for i=1,numQuestChoices do
		local IDnum = i
		local name, texture, numItems, quality, isUsable = GetQuestItemInfo("choice", i)
		if numItems == 1 then numItems = " " end -- dont show 1 item

		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item:SetBackdrop({bgFile = texture})
		if not isUsable then storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item:SetBackdropColor(1,0,0,1)
                else storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item:SetBackdropColor(1,1,1,1) end
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Font:SetText(numItems)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].TextFont:SetText(name)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetID(IDnum)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button.type = "choice"
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetScript("OnEnter",function()
													GameTooltip:SetOwner(storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item,"TOPLEFT")
													GameTooltip:SetQuestItem("choice", this:GetID())
													end)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetScript("OnLeave",function() GameTooltip:Hide(); ResetCursor() end)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetScript("OnClick",function() storyline:QuestReward_OnClick() end)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum]:Show()

    counter = i
	end

	-- display Rewards
	for i=(counter+1),numQuestRewards do
		local IDnum = i
		local name, texture, numItems, quality, isUsable = GetQuestItemInfo("reward", i)
		if numItems == 1 then numItems = " " end -- dont show 1 item

		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item:SetBackdrop({bgFile = texture})
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Font:SetText(numItems)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].TextFont:SetText(name)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetID(IDnum)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button.type = "reward"
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetScript("OnEnter",function()
													GameTooltip:SetOwner(storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item,"TOPLEFT")
													GameTooltip:SetQuestItem("reward", this:GetID())
													end)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetScript("OnLeave",function() GameTooltip:Hide(); ResetCursor() end)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetScript("OnClick",function() end)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum]:Show()

    counter = i
	end

  if GetRewardSpell() then

    local IDnum =  counter + 1
		local name, texture, numItems, quality, isUsable = GetQuestItemInfo("spell", 1)
		if numItems == 1 then numItems = " " end -- dont show 1 item

		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item:SetBackdrop({bgFile = texture})
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Font:SetText(numItems)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].TextFont:SetText(name)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetID(IDnum)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button.type = "spell"
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetScript("OnEnter",function()
													GameTooltip:SetOwner(storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item,"TOPLEFT")
													GameTooltip:SetQuestItem("spell", this:GetID())
													end)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetScript("OnLeave",function() GameTooltip:Hide(); ResetCursor() end)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum].Item.Button:SetScript("OnClick",function() end)
		storyline.QuestComplete.Mainframe.Reward.Block[IDnum]:Show()
  end
	-- hide if no rewards
	if totalRewards == 0 then storyline.QuestComplete.Mainframe:Hide() end
end

-- Update 3D Models
function storyline:UpdateModels()
	if UnitExists("target") then storyline.NPC.PlayerFrame:SetUnit("target")
	else storyline.NPC.PlayerFrame:SetModel("Creature\\Snowman\\SnowMan.m2"); storyline.NPC.PlayerFrame:SetModelScale(2) end
	storyline.Player.PlayerFrame:SetUnit("player")
end

-- Fill the Scrollframe + Fade
function storyline:ShowNPCText(Text,Offset)

	-- set text offset
	if not Offset then storyline.Options.Offset = 0
	else storyline.Options.Offset = Offset end

	-- refresh Variables
	storyline.Options.Fading = 0
	storyline.Variables.fadingProgress = 0
	storyline.Variables.ModelProgress = 0
	storyline.Variables.SliderProgress = 0
	storyline.Variables.QuesttextLength = 0
	storyline.Variables.LastTime = 0
	storyline.Variables.Time = 0

	storyline.Variables.QuesttextLength = string.len(Text)
	storyline.Text.Questtext.Font:SetText(Text)
	storyline.Background.layer5.Questtext.Slider:SetMinMaxValues(0, storyline.Variables.QuesttextLength/5)

	if QUEST_FADING_DISABLE == "1" then
		storyline.Options.Fading = 0
	elseif QUEST_FADING_DISABLE == "0" then
		storyline.Options.Fading = 1
	end

end

-- hide frames after Eventcall
function storyline:HideAll()
	-- Hide Quest Detail
	storyline.QuestDetail.GetQuest:Hide()

	-- Hide Progress Frame
	storyline.QuestProgress.Mainframe:Hide()

	-- Hide Complete Frame
	storyline.QuestComplete.Mainframe:Hide()

	-- Hide Options
	storyline.OptionsFrame:Hide()
end

-- Hide Blizzards Frames
function storyline:HideBlizzard()

	if storyline.Options.HideBlizzardFrames == 1 then
		-- Accept Quest Interact
		QuestFrameDetailPanel:Hide()
		QuestNpcNameFrame:Hide()
		QuestFramePortrait:Hide()
		QuestFrameCloseButton:Hide()
		-- Progress Quest Interact
		QuestFrameProgressPanel:Hide()
		-- Reward Quest Interact
		QuestFrameRewardPanel:Hide()
	else

	end
end

function storyline:QuestReward_OnClick()

	if ( IsControlKeyDown() ) then
		if ( this.rewardType ~= "spell" ) then
			DressUpItemLink(GetQuestItemLink(this.type, this:GetID()));
			DressUpFrame:SetPoint("TOPLEFT",storyline.Background,"TOPRIGHT")
		end
	elseif ( IsShiftKeyDown() ) then
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:Insert(GetQuestItemLink(this.type, this:GetID()));
		end
	elseif ( this.type == "choice" ) then
		for i=1,6 do storyline.QuestComplete.Mainframe.Reward.Block[i]:SetBackdropColor(0.8,0.8,0.8,0) end
		storyline.QuestComplete.Mainframe.Reward.Block[this:GetID()]:SetBackdropColor(0.8,0.8,0.8,0.3)
		QuestFrameRewardPanel.itemChoice = this:GetID();
	end
end
