local storyline = CreateFrame("Frame",nil); -- Event Frame
	storyline.Background = CreateFrame("Frame","StorylineFrame",UIParent) -- Background Frame
	storyline.Player = CreateFrame("Frame",nil,storyline.Background) -- Player Frame
	storyline.NPC = CreateFrame("Frame",nil,storyline.Background) -- NPC Frame
	storyline.Text = CreateFrame("Frame",nil,storyline.Background) -- Text Frame
	storyline.Gossip = CreateFrame("Frame",nil,storyline.Background) -- Gossip Frame
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
storyline:RegisterEvent("GOSSIP_SHOW")
storyline:RegisterEvent("GOSSIP_CLOSED")

tinsert(UISpecialFrames, "StorylineFrame")

-- Fill Variables and Options
storyline.Options.Fading = 0
storyline.Options.GradientLength = 30
storyline.Options.Offset = 0 -- text offset for max. scroll frame
storyline.Options.Delay = 0.03 -- 30 fps update
storyline.Options.FrameStrata = {[1]="BACKGROUND",[2]="LOW",[3]="MEDIUM",[4]="HIGH",[5]="DIALOG",[6]="FULLSCREEN",[7]="FULLSCREEN_DIALOG",[8]="TOOLTIP"}
storyline.Options.Version = "1.0.1" -- version

-- onupdate text
storyline.Variables.fadingProgress = 0
storyline.Variables.SliderProgress = 0
storyline.Variables.SliderStop = 0
storyline.Variables.QuesttextLength = 0
storyline.Variables.GreetingsFlag = 0
storyline.Variables.LastTime = 0
storyline.Variables.Time = 0
storyline.Variables.FontSize = 14
storyline.Variables.FontHeight = 0

-- unopdate animations
storyline.Animation = {}
storyline.Animation.NPC = 0
storyline.Animation.Player = 0
storyline.Animation.Greetings = {"64","65","66","67","70","113"}
storyline.Animation.Database = Storyline_ANIMATION_SEQUENCE_DURATION_BY_MODEL

-- Localisation
local V = StorylineTrans

-- Event Function
function storyline:OnEvent()
	if event == "QUEST_DETAIL" then
		storyline:UpdateZone()
		storyline:HideBlizzard()
		storyline:AcceptQuest()
	elseif event == "QUEST_PROGRESS" then
		storyline:UpdateZone()
		storyline:HideBlizzard()
		storyline:ProgressQuest()
	elseif event == "QUEST_COMPLETE" then
		storyline:UpdateZone()
		storyline:HideBlizzard()
		storyline:CompleteQuest()
	elseif event == "QUEST_GREETING" then
		storyline:UpdateZone()
		storyline.Variables.GreetingsFlag = 1
		storyline:HideBlizzard()
		storyline:GossipStart()
	elseif event == "QUEST_FINISHED" then
		DeclineQuest()
		storyline:ResetModels()
		storyline.Background:Hide()
	elseif event == "QUEST_ITEM_UPDATE" then -- no update impleted - reload frame instead
		DeclineQuest()
		storyline.Background:Hide()
		storyline:ResetModels()
	elseif event == "GOSSIP_SHOW" then
		storyline:ResetModels()
		storyline:UpdateZone()
		storyline.Variables.GreetingsFlag = 0
		storyline:HideBlizzard()
		storyline:GossipStart()
	elseif event == "GOSSIP_CLOSED" then
		storyline:ResetModels()
		storyline.Background:Hide()
		
	elseif event == "ADDON_LOADED" and arg1 == "VanillaStoryline" then
		-- set Options for first start
		if not StorylineOptions then
			StorylineOptions = {}
			StorylineOptions.HideBlizzardFrames = 1
			StorylineOptions.TextSpeed = 2
			StorylineOptions.WindowScale = 1
			StorylineOptions.WindowLevel = 4
			StorylineOptions.FontSize = 14
		end
		-- compability to old version
		if not StorylineOptions.WindowScale then StorylineOptions.WindowScale = 1 end
		if not StorylineOptions.WindowLevel then StorylineOptions.WindowLevel = 4 end
		if not StorylineOptions.FontSize then StorylineOptions.FontSize = 14 end
		
		storyline.Options.TextSpeed = StorylineOptions.TextSpeed
		storyline.Options.WindowScale = StorylineOptions.WindowScale
		storyline.Options.WindowLevel = StorylineOptions.WindowLevel
		storyline.Options.HideBlizzardFrames = StorylineOptions.HideBlizzardFrames

		-- Create UI
		storyline.Background:ConfigureFrame() -- configure Background Frame
		storyline.Player:ConfigureFrame() -- configure player 3d Frame
		storyline.NPC:ConfigureFrame() -- configure the NPC 3d frame
		storyline.Text:ConfigureFrame() -- configure fonts
		storyline.Gossip:ConfigureFrame() -- configure Gossip Frame
		storyline.QuestDetail:ConfigureFrame() -- configure Quest Detail Frame
		storyline.QuestProgress:ConfigureFrame() -- configure Quest Progress Frame
		storyline.QuestComplete:ConfigureFrame() -- configure Quest complete frame
		storyline.OptionsFrame:ConfigureFrame() -- configure Options Frame
		storyline:SetFrameStrata() -- set FrameStrata
		storyline.Background:Hide()
		
		-- questie fix
		local childrenTable = {UIParent:GetChildren()}
		for num, frame in pairs (childrenTable) do
			if(frame:GetName() == "Questie") then
				frame:UnregisterEvent("QUEST_PROGRESS")
			end
		end
	end

end

function storyline:OnUpdate()
	storyline.Variables.Time = GetTime()

	-- this ticks every Delay in sec.!
	if storyline.Options.Fading == 1 and storyline.Variables.LastTime + storyline.Options.Delay <= storyline.Variables.Time then
	
		-- Set Font Fading Progress
		storyline.Variables.fadingProgress = storyline.Variables.fadingProgress + storyline.Options.TextSpeed
		storyline.Variables.SliderProgress = storyline.Variables.SliderProgress + ((storyline.Variables.FontSize/14)*storyline.Options.TextSpeed/3)

		-- set Slider Progression
		if storyline.Variables.SliderStop == 0 then storyline.Background.layer5.Questtext.Slider:SetValue(storyline.Variables.SliderProgress-50) end

		-- Set Font Fading
		storyline.Text.Questtext.Font:SetAlphaGradient(storyline.Variables.fadingProgress,storyline.Options.GradientLength)

		-- get new time
		storyline.Variables.LastTime = storyline.Variables.Time

		-- quit OpUpdate
		if storyline.Variables.fadingProgress >= storyline.Variables.QuesttextLength + storyline.Options.Offset then storyline.Options.Fading = 0 end
	end
	
	-- Talk animation
	if storyline.Options.Fading == 1 and storyline.Animation.NPC == 0 then storyline:TalkAnimation() end
	
end

storyline:SetScript("OnEvent", storyline.OnEvent)
storyline.Background:SetScript("OnUpdate", storyline.OnUpdate)

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
	self:SetFrameStrata("HIGH")
	self:SetWidth(700)
	self:SetHeight(450)
	self:SetPoint("CENTER",0,0)
	self:SetMovable(1)
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
	local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\question-background"} 
	self.layer2.Background:SetBackdrop(backdrop)
	self.layer2.Background:SetBackdropColor(1,1,1,1)
	
	-- background for 6-picture systems
	self.layer2.Background[1] = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background[1]:SetFrameStrata("BACKGROUND")
	self.layer2.Background[1]:SetWidth(220)
	self.layer2.Background[1]:SetHeight(205)
	self.layer2.Background[1]:SetPoint("TOPLEFT",20,-20)
	self.layer2.Background[1].Bg = self.layer2.Background[1]:CreateTexture()
	self.layer2.Background[1].Bg:SetAllPoints()
	self.layer2.Background[1].Bg:SetTexture("")
	
	self.layer2.Background[2] = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background[2]:SetFrameStrata("BACKGROUND")
	self.layer2.Background[2]:SetWidth(220)
	self.layer2.Background[2]:SetHeight(205)
	self.layer2.Background[2]:SetPoint("TOP", 0,-20)
	self.layer2.Background[2].Bg = self.layer2.Background[2]:CreateTexture()
	self.layer2.Background[2].Bg:SetAllPoints()
	self.layer2.Background[2].Bg:SetTexture("")
	
	self.layer2.Background[3] = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background[3]:SetFrameStrata("BACKGROUND")
	self.layer2.Background[3]:SetWidth(220)
	self.layer2.Background[3]:SetHeight(205)
	self.layer2.Background[3]:SetPoint("TOPRIGHT", -20,-20)
	self.layer2.Background[3].Bg = self.layer2.Background[3]:CreateTexture()
	self.layer2.Background[3].Bg:SetAllPoints()
	self.layer2.Background[3].Bg:SetTexture("")
	
	self.layer2.Background[4] = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background[4]:SetFrameStrata("BACKGROUND")
	self.layer2.Background[4]:SetWidth(220)
	self.layer2.Background[4]:SetHeight(205)
	self.layer2.Background[4]:SetPoint("BOTTOMLEFT", 20,20)
	self.layer2.Background[4].Bg = self.layer2.Background[4]:CreateTexture()
	self.layer2.Background[4].Bg:SetAllPoints()
	self.layer2.Background[4].Bg:SetTexture("")
	
	self.layer2.Background[5] = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background[5]:SetFrameStrata("BACKGROUND")
	self.layer2.Background[5]:SetWidth(220)
	self.layer2.Background[5]:SetHeight(205)
	self.layer2.Background[5]:SetPoint("BOTTOM", 0,20)
	self.layer2.Background[5].Bg = self.layer2.Background[5]:CreateTexture()
	self.layer2.Background[5].Bg:SetAllPoints()
	self.layer2.Background[5].Bg:SetTexture("")
	
	self.layer2.Background[6] = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background[6]:SetFrameStrata("BACKGROUND")
	self.layer2.Background[6]:SetWidth(220)
	self.layer2.Background[6]:SetHeight(205)
	self.layer2.Background[6]:SetPoint("BOTTOMRIGHT", -20,20)
	self.layer2.Background[6].Bg = self.layer2.Background[6]:CreateTexture()
	self.layer2.Background[6].Bg:SetAllPoints()
	self.layer2.Background[6].Bg:SetTexture("")
	
	-- Backgrounds for 4-picture system
	self.layer2.Background[7] = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background[7]:SetFrameStrata("BACKGROUND")
	self.layer2.Background[7]:SetWidth(330)
	self.layer2.Background[7]:SetHeight(205)
	self.layer2.Background[7]:SetPoint("TOPLEFT", 20,-20)
	self.layer2.Background[7].Bg = self.layer2.Background[7]:CreateTexture()
	self.layer2.Background[7].Bg:SetAllPoints()
	self.layer2.Background[7].Bg:SetTexture("")

	self.layer2.Background[8] = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background[8]:SetFrameStrata("BACKGROUND")
	self.layer2.Background[8]:SetWidth(330)
	self.layer2.Background[8]:SetHeight(205)
	self.layer2.Background[8]:SetPoint("TOPRIGHT", -20,-20)
	self.layer2.Background[8].Bg = self.layer2.Background[8]:CreateTexture()
	self.layer2.Background[8].Bg:SetAllPoints()
	self.layer2.Background[8].Bg:SetTexture("")
	
	self.layer2.Background[9] = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background[9]:SetFrameStrata("BACKGROUND")
	self.layer2.Background[9]:SetWidth(330)
	self.layer2.Background[9]:SetHeight(205)
	self.layer2.Background[9]:SetPoint("BOTTOMLEFT", 20,20)
	self.layer2.Background[9].Bg = self.layer2.Background[9]:CreateTexture()
	self.layer2.Background[9].Bg:SetAllPoints()
	self.layer2.Background[9].Bg:SetTexture("")
	
	self.layer2.Background[10] = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background[10]:SetFrameStrata("BACKGROUND")
	self.layer2.Background[10]:SetWidth(330)
	self.layer2.Background[10]:SetHeight(205)
	self.layer2.Background[10]:SetPoint("BOTTOMRIGHT", -20,20)
	self.layer2.Background[10].Bg = self.layer2.Background[10]:CreateTexture()
	self.layer2.Background[10].Bg:SetAllPoints()
	self.layer2.Background[10].Bg:SetTexture("")
	
	-- 1-picture system
	self.layer2.Background[11] = CreateFrame("Frame",nil,self.layer2)
	self.layer2.Background[11]:SetFrameStrata("BACKGROUND")
	self.layer2.Background[11]:SetWidth(660)
	self.layer2.Background[11]:SetHeight(410)
	self.layer2.Background[11]:SetPoint("CENTER", 0,0)
	self.layer2.Background[11].Bg = self.layer2.Background[11]:CreateTexture()
	self.layer2.Background[11].Bg:SetAllPoints()
	self.layer2.Background[11].Bg:SetTexture("")

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
	self.layer3.Background:SetBackdropColor(1,1,1,0.35)
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
		  storyline.Variables.SliderStop = 1
		end)

	-- Scrollframe
	self.layer5.Questtext.Scrollframe = CreateFrame("ScrollFrame", nil, self.layer5.Questtext)
		self.layer5.Questtext.Scrollframe:SetPoint("TOPLEFT", 0, -10)
		self.layer5.Questtext.Scrollframe:SetPoint("BOTTOMRIGHT", -15, 10)

	self.layer5.Questtext.Slider = CreateFrame("Slider", nil, self.layer5.Questtext, "UIPanelScrollBarTemplate")
		self.layer5.Questtext.Slider:SetOrientation('VERTICAL')
		self.layer5.Questtext.Slider:SetWidth(16)
		self.layer5.Questtext.Slider:SetHeight(50)
		self.layer5.Questtext.Slider:SetPoint("RIGHT",-8,0)
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
	self.CloseButton = CreateFrame("Button",nil,self.layer5)
		self.CloseButton:SetPoint("TOPRIGHT",-8,-8)
		self.CloseButton:SetWidth(32)
		self.CloseButton:SetHeight(32)
		self.CloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
		self.CloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
		self.CloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
		self.CloseButton:SetScript("OnClick",function() PlaySound("igMainMenuOptionCheckBoxOn")
																						DeclineQuest(); CloseGossip(); PlaySound("igQuestCancel");storyline:HideAll(); storyline.Background:Hide()
																					end)

	-- Options button
	self.OptionsButton = CreateFrame("Button",nil,self.layer5)
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

function storyline.Gossip:ConfigureFrame()
	-- GetQuest Buttons
	self.Frame = CreateFrame("Frame",nil,storyline.Background.layer5)
		self.Frame:SetWidth(300)
		self.Frame:SetHeight(200)
		self.Frame:SetPoint("CENTER",0,50)
		local backdrop = {bgFile = "Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\UI-GuildAchievement-Parchment-Horizontal", edgeFile="Interface\\GLUES\\COMMON\\TextPanel-Border", tile=false,tileSize = 16, edgeSize = 36, insets = { left = 6, right = 6, top = 6, bottom = 6 }}  -- path to the background texture
		self.Frame:SetBackdrop(backdrop)
		self.Frame:SetBackdropColor(1,1,1,0.5)
		self.Frame:SetBackdropBorderColor(1,1,0,1)
		self.Frame:EnableMouseWheel(1)
		
		self.Frame:SetScript("OnMouseWheel", function()
			local value = self.Frame.Slider:GetValue()
			self.Frame.Slider:SetValue(value-(arg1*10))
		end)

	-- Scrollframe
	self.Frame.Scrollframe = CreateFrame("ScrollFrame", nil, self.Frame)
		self.Frame.Scrollframe:SetPoint("TOPLEFT", 0, -10)
		self.Frame.Scrollframe:SetPoint("BOTTOMRIGHT", -15, 10)

	self.Frame.Slider = CreateFrame("Slider", nil, self.Frame, "UIPanelScrollBarTemplate")
		self.Frame.Slider:SetOrientation('VERTICAL')
		self.Frame.Slider:SetWidth(16)
		self.Frame.Slider:SetHeight(self.Frame:GetHeight()-55)
		self.Frame.Slider:SetPoint("RIGHT",-10,0)
		self.Frame.Slider:SetMinMaxValues(0, 400)
		self.Frame.Slider:SetValueStep(1)
		self.Frame.Slider:SetScript("OnValueChanged", function()
																	local value = self.Frame.Slider:GetValue()
																	self.Frame.Scrollframe:SetVerticalScroll(value)
																end)

	self.Frame.Scrollframe.Content = CreateFrame("Frame", nil, self.Frame.Scrollframe)
		self.Frame.Scrollframe.Content:SetWidth(300)
		self.Frame.Scrollframe.Content:SetHeight(400)
		self.Frame.Scrollframe:SetScrollChild(self.Frame.Scrollframe.Content)


	-- Create 32 Buttons
	self.Frame.Scrollframe.Content.Block = {}
	for i=1,32 do
		local counter = i
		if i == 1 then 	self.Frame.Scrollframe.Content.Block[i] = CreateFrame("Frame", nil, self.Frame.Scrollframe.Content)
										self.Frame.Scrollframe.Content.Block[i]:SetPoint("TOPLEFT",15,-2)
		else 	self.Frame.Scrollframe.Content.Block[i] = CreateFrame("Frame", nil, self.Frame.Scrollframe.Content.Block[i-1])
					self.Frame.Scrollframe.Content.Block[i]:SetPoint("BOTTOMLEFT",0,-18) end

			self.Frame.Scrollframe.Content.Block[i]:SetWidth(255)
			self.Frame.Scrollframe.Content.Block[i]:SetHeight(16)


		self.Frame.Scrollframe.Content.Block[i].Button = CreateFrame("Button",nil,self.Frame.Scrollframe.Content.Block[i])
			self.Frame.Scrollframe.Content.Block[i].Button:SetWidth(255)
			self.Frame.Scrollframe.Content.Block[i].Button:SetHeight(16)
			self.Frame.Scrollframe.Content.Block[i].Button:SetPoint("TOPLEFT",0,0)
			self.Frame.Scrollframe.Content.Block[i].Button:SetHighlightTexture("Interface\\Questframe\\UI-QuestTitleHighlight")
			self.Frame.Scrollframe.Content.Block[i].Button:SetScript("OnClick",function() PlaySound("igMainMenuOptionCheckBoxOn"); end)

			self.Frame.Scrollframe.Content.Block[i].Icon = CreateFrame("Frame", nil, self.Frame.Scrollframe.Content.Block[i])
				self.Frame.Scrollframe.Content.Block[i].Icon:SetWidth(16)
				self.Frame.Scrollframe.Content.Block[i].Icon:SetHeight(16)
				self.Frame.Scrollframe.Content.Block[i].Icon:SetPoint("LEFT",0,0)
				self.Frame.Scrollframe.Content.Block[i].Icon.Texture = self.Frame.Scrollframe.Content.Block[i].Icon:CreateTexture()
				self.Frame.Scrollframe.Content.Block[i].Icon.Texture:SetAllPoints()
				self.Frame.Scrollframe.Content.Block[i].Icon.Texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

			self.Frame.Scrollframe.Content.Block[i].Font = self.Frame.Scrollframe.Content.Block[i]:CreateFontString(nil, "OVERLAY")
					self.Frame.Scrollframe.Content.Block[i].Font:SetPoint("LEFT", 20, 0)
					self.Frame.Scrollframe.Content.Block[i].Font:SetFont("Fonts\\FRIZQT__.TTF", 12)
					self.Frame.Scrollframe.Content.Block[i].Font:SetWidth(255)
					self.Frame.Scrollframe.Content.Block[i].Font:SetHeight(16)
					self.Frame.Scrollframe.Content.Block[i].Font:SetJustifyH("LEFT")
					self.Frame.Scrollframe.Content.Block[i].Font:SetJustifyV("CENTER")
					self.Frame.Scrollframe.Content.Block[i].Font:SetText("TEST")
					self.Frame.Scrollframe.Content.Block[i].Font:SetTextColor(1,1,1)
					self.Frame.Scrollframe.Content.Block[i].Font:SetShadowOffset(1, -1)
			self.Frame.Scrollframe.Content.Block[i]:Hide()
	end
end

function storyline:GossipStart()
	-- hide and show
	storyline:HideAll()
	UIFrameFadeIn(storyline.Gossip.Frame,0.5)
	storyline.Background.layer4.Banner:Hide()
	storyline.Gossip.Frame.Slider:SetValue(0)

	-- close clicking
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnEnter",function()  end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnLeave",function() end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnClick",function()  end)
	storyline.Text.Questtext.Continue:Hide()
	storyline.Text.Questtext.Complete:Hide()

	-- Set GossipText
	local GossipText = ""
	if storyline.Variables.GreetingsFlag == 1 then GossipText =  GetGreetingText()
	else GossipText = GetGossipText() end
	storyline:ShowNPCText(GossipText)

	--Update Text
	storyline.Text.NPCName:SetText(UnitName("npc"))
	local QuestTitel = ""
	storyline.Text.Banner:SetText(QuestTitel)
	
	-- start greenings animation
	storyline.Variables.Greetings = 0

	-- update click Panels
	storyline:updateGossip()

	-- show
	storyline.Background:Show()
	
	-- Update PlayerFrames
	storyline:UpdateModels()
	
	-- play Animation
	storyline:GreetingsAnimation()
end

function storyline:updateGossip()
	-- hide all buttons
	for i=1,32 do storyline.Gossip.Frame.Scrollframe.Content.Block[i]:Hide() end

	local counter = 0 -- counts the number of dialog options
	local ID = 0 -- ID Button Counter
	-- local functions -> API delivers unknown/variable num of arguments
	local function setQuests(...)
		for i=1,arg.n,2 do
			counter = counter + 1
			ID = ID + 1
			local ChooseID = ID
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Icon.Texture:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon")
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Font:SetText(arg[i])
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button:SetID(ChooseID)
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button.type = "Available"
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button:SetScript("OnClick",function() PlaySound("igMainMenuOptionCheckBoxOn"); GossipTitleButton_OnClick() end)
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter]:Show()
		end
 	end

	local function setActiveQuests(...)
		for i=1,arg.n,2 do
			counter = counter + 1
			ID = ID + 1
			local ChooseID = ID
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Icon.Texture:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon")
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Font:SetText(arg[i])
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button:SetID(ChooseID)
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button.type = "Active"
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button:SetScript("OnClick",function() PlaySound("igMainMenuOptionCheckBoxOn"); GossipTitleButton_OnClick() end)
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter]:Show()
		end
 	end

	local function setOptions(...)
		for i=1,arg.n,2 do
			counter = counter + 1
			ID = ID + 1
			local ChooseID = ID
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Icon.Texture:SetTexture("Interface\\GossipFrame\\" .. arg[i+1] .. "GossipIcon")
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Font:SetText(arg[i])
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button:SetID(ChooseID)
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button.type = "Option"
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button:SetScript("OnClick",function() PlaySound("igMainMenuOptionCheckBoxOn"); GossipTitleButton_OnClick() end)
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter]:Show()
		end
 	end

	-- do for gossip
	if storyline.Variables.GreetingsFlag == 0 then
		ID = 0; setQuests(GetGossipAvailableQuests())
		ID = 0; setActiveQuests(GetGossipActiveQuests())
		ID = 0; setOptions(GetGossipOptions())
	end

	-- do for greetings
	if storyline.Variables.GreetingsFlag == 1 then
		counter = 0
		local numActiveQuests = GetNumActiveQuests()
		local numAvailableQuests = GetNumAvailableQuests()

		for i=1,numActiveQuests do
			counter = counter + 1
			local ChooseID = i
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Icon.Texture:SetTexture("Interface\\GossipFrame\\ActiveQuestIcon")
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Font:SetText(GetActiveTitle(i))
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button:SetID(ChooseID)
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button.isActive = 1
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button:SetScript("OnClick",function() PlaySound("igMainMenuOptionCheckBoxOn"); QuestTitleButton_OnClick() end)
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter]:Show()
		end

		for i=(numActiveQuests + 1), (numActiveQuests + numAvailableQuests) do
			counter = counter + 1
			local ChooseID = i - numActiveQuests
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Icon.Texture:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon")
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Font:SetText(GetAvailableTitle(i - numActiveQuests))
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button:SetID(ChooseID)
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button.isActive = 0
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter].Button:SetScript("OnClick",function() PlaySound("igMainMenuOptionCheckBoxOn"); QuestTitleButton_OnClick() end)
			storyline.Gossip.Frame.Scrollframe.Content.Block[counter]:Show()
		end
	end

	-- set height of Scrollframe
	if counter < 3 and counter ~= 0 then counter = 2 end -- heightfix
	if counter == 0 then storyline.Gossip.Frame:Hide()
	elseif counter < 9 then
		storyline.Gossip.Frame.Slider:SetMinMaxValues(0, 0)
		storyline.Gossip.Frame.Scrollframe.Content:SetHeight(200)
		storyline.Gossip.Frame:SetHeight((counter*18) + 25)
		storyline.Gossip.Frame.Slider:Hide()
	else
		storyline.Gossip.Frame.Slider:SetMinMaxValues(0, (counter*5)-16)
		storyline.Gossip.Frame.Scrollframe.Content:SetHeight(counter*5)
		storyline.Gossip.Frame:SetHeight(200)
		storyline.Gossip.Frame.Slider:Show()
	end

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
	self.GetQuest.Decline.Button:SetScript("OnClick",function() storyline:DeclineQuest();PlaySound("igQuestCancel"); end)

	self.GetQuest.CenterItem = CreateFrame("Frame",nil,self.GetQuest)
	local backdrop = {bgFile = "Interface\\FriendsFrame\\FriendsFrameScrollIcon"}
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
		local backdrop = {bgFile = "Interface\\FriendsFrame\\FriendsFrameScrollIcon"}
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
 	 self:SetHeight(150)
	 self:SetPoint("BOTTOM",0,-(self:GetHeight()))

		-- testspeed
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
												
		self.SpeedFont = self.SpeedSlider:CreateFontString(nil, "OVERLAY")
		 self.SpeedFont:SetPoint("TOPLEFT", 0, 30)
		 self.SpeedFont:SetFont("Fonts\\FRIZQT__.TTF", 12)
		 self.SpeedFont:SetWidth(200)
		 self.SpeedFont:SetJustifyH("LEFT")
		 self.SpeedFont:SetJustifyV("TOP")
		 self.SpeedFont:SetText("Textspeed:")
		 self.SpeedFont:SetTextColor(1,1,1)
		 
		 -- scale Frame
		 self.ScaleSlider = CreateFrame("Slider","StorylineScaleSlider",self,"OptionsSliderTemplate")
		 self.ScaleSlider:SetPoint("TOPLEFT", 180, -40)
		self.ScaleSlider:SetWidth(132)
		 self.ScaleSlider:SetHeight(17)
		 self.ScaleSlider:SetOrientation("HORIZONTAL")
		 self.ScaleSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
		 self.ScaleSlider:SetMinMaxValues(50,150)
		 self.ScaleSlider:SetValueStep(10)
		 self.ScaleSlider:SetValue(storyline.Options.WindowScale*100)
		 getglobal("StorylineScaleSlider" .. 'Low'):SetText("50%")
		 getglobal("StorylineScaleSlider" .. 'High'):SetText("150%")
		 getglobal("StorylineScaleSlider" .. 'Text'):SetText(storyline.Options.WindowScale*100 .. " %")
		 self.ScaleSlider:SetScript("OnValueChanged", function()
			 										storyline.Options.WindowScale = storyline.OptionsFrame.ScaleSlider:GetValue()/100; StorylineOptions.WindowScale = storyline.Options.WindowScale
	 												getglobal("StorylineScaleSlider" .. 'Text'):SetText(storyline.Options.WindowScale*100 .. " %")
	 											end)
		storyline.Background:SetScale(storyline.Options.WindowScale)
		
		 self.ScaleButton = CreateFrame("Button",nil,self.ScaleSlider ,"UIPanelButtonTemplate")
		 self.ScaleButton:SetPoint("BOTTOMRIGHT", 50, 0)
		self.ScaleButton:SetWidth(40)
		 self.ScaleButton:SetHeight(20)
		 self.ScaleButton:SetText("Set!")
		 self.ScaleButton:SetScript("OnClick",function() storyline.Background:SetScale(storyline.Options.WindowScale) end)
		
		self.ScaleFont = self.ScaleSlider:CreateFontString(nil, "OVERLAY")
		 self.ScaleFont:SetPoint("TOPLEFT", 0, 30)
		 self.ScaleFont:SetFont("Fonts\\FRIZQT__.TTF", 12)
		 self.ScaleFont:SetWidth(200)
		 self.ScaleFont:SetJustifyH("LEFT")
		 self.ScaleFont:SetJustifyV("TOP")
		 self.ScaleFont:SetText("Window Scale:")
		 self.ScaleFont:SetTextColor(1,1,1)
		 
		 -- StorylineOptions.FontSize
		 
		  self.FontSizeSlider = CreateFrame("Slider","StorylineFontSizeSlider",self,"OptionsSliderTemplate")
		 self.FontSizeSlider:SetPoint("TOPLEFT", 10, -110)
     self.FontSizeSlider:SetWidth(132)
		 self.FontSizeSlider:SetHeight(17)
		 self.FontSizeSlider:SetOrientation("HORIZONTAL")
		 self.FontSizeSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
		 self.FontSizeSlider:SetMinMaxValues(10,20)
		 self.FontSizeSlider:SetValueStep(1)
		 self.FontSizeSlider:SetValue(StorylineOptions.FontSize)
		 getglobal("StorylineFontSizeSlider" .. 'Low'):SetText("10")
		 getglobal("StorylineFontSizeSlider" .. 'High'):SetText("20")
		 getglobal("StorylineFontSizeSlider" .. 'Text'):SetText(StorylineOptions.FontSize)
		 self.FontSizeSlider:SetScript("OnValueChanged", function()
													StorylineOptions.FontSize = storyline.OptionsFrame.FontSizeSlider:GetValue()
													storyline.Text.Questtext.Font:SetFont("Fonts\\FRIZQT__.TTF", StorylineOptions.FontSize)
	 												getglobal("StorylineFontSizeSlider" .. 'Text'):SetText(StorylineOptions.FontSize)
	 											end)
												
		self.FontSizeFont = self.FontSizeSlider:CreateFontString(nil, "OVERLAY")
		 self.FontSizeFont:SetPoint("TOPLEFT", 0, 30)
		 self.FontSizeFont:SetFont("Fonts\\FRIZQT__.TTF", 12)
		 self.FontSizeFont:SetWidth(200)
		 self.FontSizeFont:SetJustifyH("LEFT")
		 self.FontSizeFont:SetJustifyV("TOP")
		 self.FontSizeFont:SetText("Font Size:")
		 self.FontSizeFont:SetTextColor(1,1,1)
		 
		-- move Frame
		self.MoveButton = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
			 self.MoveButton:SetWidth(24)
			 self.MoveButton:SetHeight(24)
			 self.MoveButton:SetPoint("TOPLEFT",650,-5)
			 self.MoveButton:SetScript("OnClick", function ()
				 									PlaySound("igMainMenuOptionCheckBoxOn")
													if self.MoveButton:GetChecked() then storyline.Background:EnableMouse(1)
													else storyline.Background:EnableMouse(0) end
													end)

		 self.MoveFont = self.MoveButton:CreateFontString(nil, "OVERLAY")
			 self.MoveFont:SetPoint("LEFT", -210, 0)
			 self.MoveFont:SetFont("Fonts\\FRIZQT__.TTF", 12)
			 self.MoveFont:SetWidth(200)
			 self.MoveFont:SetJustifyH("RIGHT")
			 self.MoveFont:SetJustifyV("CENTER")
			 self.MoveFont:SetText("Moveable:")
			 self.MoveFont:SetTextColor(1,1,1)
		
		-- hide blizzard frames
		self.HideButton = CreateFrame("CheckButton", nil, self, "UICheckButtonTemplate")
				self.HideButton:SetWidth(24)
				self.HideButton:SetHeight(24)
				self.HideButton:SetPoint("TOPLEFT",650,-25)
				self.HideButton:SetScript("OnClick", function ()
													 PlaySound("igMainMenuOptionCheckBoxOn")
													 if self.HideButton:GetChecked() then storyline.Options.HideBlizzardFrames = 1; StorylineOptions.HideBlizzardFrames = 1
 													 else storyline.Options.HideBlizzardFrames = 0; StorylineOptions.HideBlizzardFrames = 0; DeclineQuest(); PlaySound("igQuestCancel"); end
													 storyline:HideBlizzard()
													 end)

			self.HideFont = self.HideButton:CreateFontString(nil, "OVERLAY")
				self.HideFont:SetPoint("LEFT", -210, 0)
				self.HideFont:SetFont("Fonts\\FRIZQT__.TTF", 12)
				self.HideFont:SetWidth(200)
				self.HideFont:SetJustifyH("RIGHT")
				self.HideFont:SetJustifyV("CENTER")
				self.HideFont:SetText("Hide Blizzard Frames:")
				self.HideFont:SetTextColor(1,1,1)

			
			if storyline.Options.HideBlizzardFrames == 1 then self.HideButton:SetChecked(1)
			else self.HideButton:SetChecked(0) end
			
		-- Frame Level
		
		local function configLevelDropdown()
			local info = {}
			
			info.text = "Level 1"
			info.func = function()
				UIDropDownMenu_SetSelectedID(GlobalLevelDropDownID, this:GetID(), 0)
				StorylineOptions.WindowLevel = 1
				storyline:SetFrameStrata()
			end
			UIDropDownMenu_AddButton(info)
			info.checked = false
			
			info.text = "Level 2"
			info.func = function()
				UIDropDownMenu_SetSelectedID(GlobalLevelDropDownID, this:GetID(), 0)
				StorylineOptions.WindowLevel = 2
				storyline:SetFrameStrata()
			end
			UIDropDownMenu_AddButton(info)
			info.checked = false
			
			info.text = "Level 3"
			info.func = function()
				UIDropDownMenu_SetSelectedID(GlobalLevelDropDownID, this:GetID(), 0)
				StorylineOptions.WindowLevel = 3
				storyline:SetFrameStrata()
			end
			UIDropDownMenu_AddButton(info)
			info.checked = false
			
			info.text = "Level 4"
			info.func = function()
				UIDropDownMenu_SetSelectedID(GlobalLevelDropDownID, this:GetID(), 0)
				StorylineOptions.WindowLevel = 4
				storyline:SetFrameStrata()
			end
			UIDropDownMenu_AddButton(info)
			info.checked = false
			
			info.text = "Level 5"
			info.func = function()
				UIDropDownMenu_SetSelectedID(GlobalLevelDropDownID, this:GetID(), 0)
				StorylineOptions.WindowLevel = 5
				storyline:SetFrameStrata()
			end
			UIDropDownMenu_AddButton(info)
			info.checked = false
			
			info.text = "Level 6"
			info.func = function()
				UIDropDownMenu_SetSelectedID(GlobalLevelDropDownID, this:GetID(), 0)
				StorylineOptions.WindowLevel = 6
				storyline:SetFrameStrata()
			end
			UIDropDownMenu_AddButton(info)
			info.checked = false
			
			info.text = "Level 7"
			info.func = function()
				UIDropDownMenu_SetSelectedID(GlobalLevelDropDownID, this:GetID(), 0)
				StorylineOptions.WindowLevel = 7
				storyline:SetFrameStrata()
			end
			UIDropDownMenu_AddButton(info)
			info.checked = false
			
			info.text = "Level 8"
			info.func = function()
				UIDropDownMenu_SetSelectedID(GlobalLevelDropDownID, this:GetID(), 0)
				StorylineOptions.WindowLevel = 8
				storyline:SetFrameStrata()
			end
			UIDropDownMenu_AddButton(info)
			info.checked = false
		end
		
		local function populateLevelDropdown(DropDownID)
			GlobalLevelDropDownID = DropDownID -- feed global
			UIDropDownMenu_Initialize(DropDownID, configLevelDropdown)
		end
		
		self.LevelDropdown = CreateFrame("Button","StorylineLevelDropdown", self, "UIDropDownMenuTemplate")
		self.LevelDropdown:SetPoint("TOPLEFT", 350, -30)
		self.LevelDropdown:SetWidth(500)
		
		getglobal(self.LevelDropdown:GetName().."Button"):SetScript("OnClick", function()
								local DropDownID = getglobal(self.LevelDropdown:GetName())
								populateLevelDropdown(DropDownID)
								ToggleDropDownMenu(); -- inherit UIDropDownMenuTemplate functions
								PlaySound("igMainMenuOptionCheckBoxOn"); -- inherit UIDropDownMenuTemplate functions
								end)
		getglobal(self.LevelDropdown:GetName().."Text"):SetText("Level "..storyline.Options.WindowLevel)
		
		self.HideFont = self.LevelDropdown:CreateFontString(nil, "OVERLAY")
				self.HideFont:SetPoint("TOP", -250, 20)
				self.HideFont:SetFont("Fonts\\FRIZQT__.TTF", 12)
				self.HideFont:SetWidth(200)
				self.HideFont:SetJustifyH("RIGHT")
				self.HideFont:SetJustifyV("CENTER")
				self.HideFont:SetText("Frame Level:")
				self.HideFont:SetTextColor(1,1,1)

		-- version
		self.VersionFont = self:CreateFontString(nil, "OVERLAY")
		 self.VersionFont:SetPoint("Bottom", 0, 10)
		 self.VersionFont:SetFont("Fonts\\FRIZQT__.TTF", 12)
		 self.VersionFont:SetWidth(800)
		 self.VersionFont:SetJustifyH("CENTER")
		 self.VersionFont:SetJustifyV("BOTTOM")
		 self.VersionFont:SetText("Version: "..storyline.Options.Version.." by Renew @ Nostalrius.org")
		 self.VersionFont:SetTextColor(1,1,1,0.5)

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
		self.Background:SetWidth(500)
		self.Background:SetHeight(400)
		self.Background:SetPoint("TOPRIGHT",-30,-30)

	self.PlayerFrame = CreateFrame("PlayerModel", nil, storyline.Background.layer3)
		self.PlayerFrame:SetPoint("TOPRIGHT",self.Background)
		self.PlayerFrame:SetWidth(500)
		self.PlayerFrame:SetHeight(400)
		self.PlayerFrame:SetModel("Interface\\Buttons\\talktomequestionmark.mdx") -- modelfix: set random model first, so GetModel will be avalible for "npc" later
		self.PlayerFrame:SetFacing(-0.8)
		
	storyline.NPC.PlayerFrame:SetModelScale(1)
	storyline.NPC.PlayerFrame:SetPosition(0,0,0)
	storyline.NPC.PlayerFrame:SetFacing(-0.8)

end

function storyline.Text:ConfigureFrame()

	-- Banner Font
	self.Banner = storyline.Background.layer4.Banner:CreateFontString(nil, "OVERLAY")
		self.Banner:SetPoint("CENTER", 0, 5)
		self.Banner:SetFont("Fonts\\FRIZQT__.TTF", 16)
		self.Banner:SetWidth(260)
		self.Banner:SetJustifyH("CENTER")
		self.Banner:SetJustifyV("CENTER")
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
		self.Questtext.Font:SetFont("Fonts\\FRIZQT__.TTF", StorylineOptions.FontSize)
		self.Questtext.Font:SetWidth(600)
		self.Questtext.Font:SetHeight(0)
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
	storyline.Background.layer4.Banner:Show()

	-- open clicking
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnEnter",function()
                                                                            storyline.Background.layer5.Questtext:SetBackdropBorderColor(0,1,0,1)
                                                                            end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnLeave",function() storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1) end)
	storyline.Background.layer5.Questtext.Fade.Button:SetScript("OnClick",function() storyline:AcceptQuestOnClick() end)
	storyline.Text.Questtext.Continue:Show()
	storyline.Text.Questtext.Complete:Hide()

	-- play sound
	PlaySound("WriteQuest")

	-- Set Questtext
	local QuestText = GetQuestText()
	storyline:ShowNPCText(QuestText)

	--Update Text
	storyline.Text.NPCName:SetText(UnitName("npc"))
	local QuestTitel = GetTitleText()
	storyline.Text.Banner:SetText(QuestTitel)

	-- show
	storyline.Background:Show()
	
	-- Update PlayerFrames
	storyline:UpdateModels()

end

function storyline:AcceptQuestOnClick()
	-- close clicking
	storyline.Background.layer5.Questtext:SetBackdropBorderColor(1,1,1,1)
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
	storyline.Background.layer4.Banner:Show()

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

	--Update Text
	storyline.Text.NPCName:SetText(UnitName("npc"))
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
	
	-- Update PlayerFrames
	storyline:UpdateModels()
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
	storyline.Background.layer4.Banner:Show()
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

	--Update Text
	storyline.Text.NPCName:SetText(UnitName("npc"))
	local QuestTitel = GetTitleText()
	local RewardText = GetRewardText()

	storyline.Text.Banner:SetText(QuestTitel)
	storyline:ShowNPCText(RewardText)


	-- show
	storyline.Background:Show()
	
	-- Update PlayerFrames
	storyline:UpdateModels()
end

-- Get Objective Text from QuestLog : Devlivers Objective Text from quest
function storyline:GetObjectiveText()
	local QuestID = 0
	local QuestTitel = GetTitleText()
	local QuestLogTitel = ""
	local QuestLogTitelLevel
	local numEntries = GetNumQuestLogEntries()
	local ObjectiveText
	
	-- buggy for few quests
	for i=1, numEntries do
		QuestLogTitel = GetQuestLogTitle(i)
		if string.find(QuestTitel, QuestLogTitel) then -- find doesnt accept functions as arguments
			QuestID = i
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
	local counter = 0

	if numRequiredItems > 0 then
		-- check for gold req.
		if numRequiredMoney > 0 then
			counter = counter + 1
			storyline.QuestProgress.Mainframe.Objective.Block[counter].Item:SetBackdrop({bgFile = "Interface\\Icons\\INV_Misc_Coin_02"})
			storyline.QuestProgress.Mainframe.Objective.Block[counter].Item.Font:SetText(numRequiredMoney)
			storyline.QuestProgress.Mainframe.Objective.Block[counter].TextFont:SetText("Gold")
			storyline.QuestProgress.Mainframe.Objective.Block[counter]:Show()

		end

		for i=1,numRequiredItems do
			counter = counter + 1
			local name, texture, numItems = GetQuestItemInfo("required", i)
			if numItems == 1 then numItems = " " end -- dont show 1 item

			storyline.QuestProgress.Mainframe.Objective.Block[counter].Item:SetBackdrop({bgFile = texture})
			storyline.QuestProgress.Mainframe.Objective.Block[counter].Item.Font:SetText(numItems)
			storyline.QuestProgress.Mainframe.Objective.Block[counter].TextFont:SetText(name)
			storyline.QuestProgress.Mainframe.Objective.Block[counter]:Show()
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
	
	-- reset center item
	storyline.QuestComplete.Mainframe.CenterItem:SetBackdrop({bgFile = "Interface\\Icons\\INV_Box_02"})

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
		counter = counter + 1
		local IDnum = i
		local name, texture, numItems, quality, isUsable = GetQuestItemInfo("choice", i)
		if numItems == 1 then numItems = " " end -- dont show 1 item

		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item:SetBackdrop({bgFile = texture})
		if not isUsable then storyline.QuestComplete.Mainframe.Reward.Block[counter].Item:SetBackdropColor(1,0,0,1)
                else storyline.QuestComplete.Mainframe.Reward.Block[counter].Item:SetBackdropColor(1,1,1,1) end
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Font:SetText(numItems)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].TextFont:SetText(name)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetID(IDnum)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button.type = "choice"
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetScript("OnEnter",function()
													GameTooltip:SetOwner(storyline.QuestComplete.Mainframe.Reward.Block[counter].Item,"TOPLEFT")
													GameTooltip:SetQuestItem("choice", this:GetID())
													end)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetScript("OnLeave",function() GameTooltip:Hide(); ResetCursor() end)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetScript("OnClick",function() storyline:QuestReward_OnClick() end)
		storyline.QuestComplete.Mainframe.Reward.Block[counter]:Show()
	end

	-- display Rewards
	for i=1,numQuestRewards do
		counter = counter + 1
		local IDnum = i
		local name, texture, numItems, quality, isUsable = GetQuestItemInfo("reward", i)
		if i == 1 then storyline.QuestComplete.Mainframe.CenterItem:SetBackdrop({bgFile = texture}) end
		if numItems == 1 then numItems = " " end -- dont show 1 item
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item:SetBackdrop({bgFile = texture})
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Font:SetText(numItems)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].TextFont:SetText(name)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetID(IDnum)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button.type = "reward"
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetScript("OnEnter",function()
													GameTooltip:SetOwner(storyline.QuestComplete.Mainframe.Reward.Block[counter].Item,"TOPLEFT")
													GameTooltip:SetQuestItem("reward", this:GetID())
													end)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetScript("OnLeave",function() GameTooltip:Hide(); ResetCursor() end)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetScript("OnClick",function() end)
		storyline.QuestComplete.Mainframe.Reward.Block[counter]:Show()
	end

  if GetRewardSpell() then
		counter = counter + 1
    local IDnum =  1
		local numItems = 1
		local texture, name, isTradeskillSpell = GetRewardSpell()
		if numItems == 1 then numItems = " " end -- dont show 1 item
		storyline.QuestComplete.Mainframe.CenterItem:SetBackdrop({bgFile = texture})
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item:SetBackdrop({bgFile = texture})
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Font:SetText(numItems)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].TextFont:SetText(name)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetID(IDnum)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button.type = "spell"
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetScript("OnEnter",function()
													GameTooltip:SetOwner(storyline.QuestComplete.Mainframe.Reward.Block[counter].Item,"TOPLEFT")
													GameTooltip:SetQuestRewardSpell()
													end)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetScript("OnLeave",function() GameTooltip:Hide(); ResetCursor() end)
		storyline.QuestComplete.Mainframe.Reward.Block[counter].Item.Button:SetScript("OnClick",function() end)
		storyline.QuestComplete.Mainframe.Reward.Block[counter]:Show()
  end
	-- hide if no rewards
	if totalRewards == 0 then storyline.QuestComplete.Mainframe:Hide() end
end

-- Update 3D Models
function storyline:UpdateModels()
	
	if UnitExists("npc") then storyline.NPC.PlayerFrame:SetUnit("npc")
	else storyline.NPC.PlayerFrame:SetModel("Interface\\Buttons\\talktomequestionmark.mdx") end
	
	
	-- set players scale
	storyline.Player.PlayerFrame:SetUnit("player")
	storyline.Player.PlayerFrame:SetModelScale(1)
	
	local model = storyline.Player.PlayerFrame:GetModel()
	if model == "Character\\Dwarf\\Female\\DwarfFemale" then storyline.Player.PlayerFrame:SetModelScale(0.9)
	elseif model == "Character\\Dwarf\\Male\\DwarfMale" then storyline.Player.PlayerFrame:SetModelScale(0.9)
	elseif model == "Character\\Gnome\\Female\\GnomeFemale" then storyline.Player.PlayerFrame:SetModelScale(0.75)
	elseif model == "Character\\Gnome\\Male\\GnomeMale" then storyline.Player.PlayerFrame:SetModelScale(0.75)
	elseif model == "Character\\Human\\Female\\HumanFemale" then storyline.Player.PlayerFrame:SetModelScale(0.95)
	elseif model == "Character\\Human\\Male\\HumanMale" then storyline.Player.PlayerFrame:SetModelScale(1.02)
	elseif model == "Character\\NightElf\\Male\\NightElfMale" then storyline.Player.PlayerFrame:SetModelScale(1.07)
	elseif model == "Character\\Orc\\Female\\OrcFemale" then storyline.Player.PlayerFrame:SetModelScale(0.95)
	elseif model == "Character\\Orc\\Male\\OrcMale" then storyline.Player.PlayerFrame:SetModelScale(0.97)
	elseif model == "Character\\Scourge\\Female\\ScourgeFemale" then storyline.Player.PlayerFrame:SetModelScale(1.02)
	elseif model == "Character\\Scourge\\Male\\ScourgeMale" then storyline.Player.PlayerFrame:SetModelScale(0.97)
	elseif model == "Character\\Tauren\\Female\\TaurenFemale" then storyline.Player.PlayerFrame:SetModelScale(1.12)
	elseif model == "Character\\Tauren\\Male\\TaurenMale" then storyline.Player.PlayerFrame:SetModelScale(1.14)
	elseif model == "Character\\Troll\\Female\\TrollFemale" then storyline.Player.PlayerFrame:SetModelScale(1.05)
	end
	
	-- set default parameters
	storyline.NPC.PlayerFrame:SetModelScale(0.75)
	storyline.NPC.PlayerFrame:SetPosition(0,0.6,0.05)
	storyline.NPC.PlayerFrame:SetFacing(-0.8)

	-- Model scale Fixes for uncommon creatures
	local model = storyline.NPC.PlayerFrame:GetModel()
	
	-- individual model position fix
	if model == "Interface\\Buttons\\talktomequestionmark" then storyline.NPC.PlayerFrame:SetPosition(0,0.9,0);storyline.NPC.PlayerFrame:SetModelScale(2) -- ok with scalebug
	elseif model == "Character\\Gnome\\Male\\GnomeMale" then storyline.NPC.PlayerFrame:SetPosition(0,0.4,0);storyline.NPC.PlayerFrame:SetModelScale(0.6) -- ok
	elseif model == "Character\\Gnome\\Female\\GnomeFemale" then storyline.NPC.PlayerFrame:SetPosition(0,0.3,0);storyline.NPC.PlayerFrame:SetModelScale(0.6) -- ok
	elseif model == "Character\\Dwarf\\Male\\DwarfMale" then storyline.NPC.PlayerFrame:SetPosition(0,0.5,0);storyline.NPC.PlayerFrame:SetModelScale(0.7) -- ok
	elseif model == "Character\\Dwarf\\Female\\DwarfFemale" then storyline.NPC.PlayerFrame:SetPosition(0,0.5,0);storyline.NPC.PlayerFrame:SetModelScale(0.7) -- ok
	elseif model == "Character\\NightElf\\Male\\NightElfMale" then storyline.NPC.PlayerFrame:SetPosition(0,0.8,0);storyline.NPC.PlayerFrame:SetModelScale(0.85) -- ok
	elseif model == "Character\\NightElf\\Female\\NightElfFemale" then storyline.NPC.PlayerFrame:SetPosition(0,0.7,0);storyline.NPC.PlayerFrame:SetModelScale(0.8) -- ok
	elseif model == "Character\\Tauren\\Male\\TaurenMale" then storyline.NPC.PlayerFrame:SetPosition(0,0.6,0.05);storyline.NPC.PlayerFrame:SetModelScale(0.9) -- ok
	elseif model == "Character\\Tauren\\Female\\TaurenFemale" then storyline.NPC.PlayerFrame:SetPosition(0,0.6,0.05);storyline.NPC.PlayerFrame:SetModelScale(0.9) -- ok
	elseif model == "Character\\Troll\\Female\\TrollFemale" then storyline.NPC.PlayerFrame:SetModelScale(0.8) -- ok
	elseif model == "Character\\Human\\Female\\HumanFemale" then storyline.NPC.PlayerFrame:SetModelScale(0.72) -- ok
	elseif model == "Character\\Scourge\\Female\\ScourgeFemale" then storyline.NPC.PlayerFrame:SetModelScale(0.8) -- ok
	
	-- npc models
	elseif model == "Creature\\HighElf\\HighElfMale_Hunter" then storyline.NPC.PlayerFrame:SetFacing(-1.5); storyline.NPC.PlayerFrame:SetPosition(-2,2.4,0.7) -- ok
	elseif model == "Creature\\HighElf\\HighElfMale_Mage" then storyline.NPC.PlayerFrame:SetFacing(-1.5); storyline.NPC.PlayerFrame:SetPosition(-2,2.4,0.7) -- ok
	elseif model == "Creature\\HighElf\\HighElfMale_Priest" then storyline.NPC.PlayerFrame:SetFacing(-1.5); storyline.NPC.PlayerFrame:SetPosition(-2,2.4,0.7) -- ok
	elseif model == "Creature\\HighElf\\HighElfMale_Warrior" then storyline.NPC.PlayerFrame:SetFacing(-1.5); storyline.NPC.PlayerFrame:SetPosition(-2,2.4,0.7) -- ok
	elseif model == "Creature\\HighElf\\HighElfFemale_Hunter" then storyline.NPC.PlayerFrame:SetPosition(-0.9,0.8,0) -- ok
	elseif model == "Creature\\HighElf\\HighElfFemale_Mage" then storyline.NPC.PlayerFrame:SetPosition(-0.9,0.8,0) -- ok
	elseif model == "Creature\\HighElf\\HighElfFemale_Priest" then storyline.NPC.PlayerFrame:SetPosition(-0.9,0.8,0) -- ok
	elseif model == "Creature\\HighElf\\HighElfFemale_Warrior" then storyline.NPC.PlayerFrame:SetPosition(-0.9,0.8,0) -- ok
	elseif model == "Character\\Goblin\\Female\\GoblinFemale" then storyline.NPC.PlayerFrame:SetPosition(0,0.4,0.05);storyline.NPC.PlayerFrame:SetModelScale(0.5) --ok
	elseif model == "Character\\Goblin\\Male\\GoblinMale" then storyline.NPC.PlayerFrame:SetPosition(0,0.4,0.05);storyline.NPC.PlayerFrame:SetModelScale(0.5) -- ok
	elseif model == "Creature\\Ghost\\Ghost" then storyline.NPC.PlayerFrame:SetPosition(0,0.5,1.9);storyline.NPC.PlayerFrame:SetModelScale(0.8) -- ok with scalebug
	elseif model == "Creature\\LostOne\\LostOne" then storyline.NPC.PlayerFrame:SetPosition(0,0,0.7);storyline.NPC.PlayerFrame:SetModelScale(0.95) -- ok with scalebug
	elseif model == "Creature\\FleshGolem\\FleshGolem" then storyline.NPC.PlayerFrame:SetPosition(0,0.4,2);storyline.NPC.PlayerFrame:SetModelScale(0.85-(StorylineOptions.WindowScale-1))-- ok with scalebug
	elseif model == "Creature\\Dreadlord\\DreadLord" then storyline.NPC.PlayerFrame:SetPosition(0,1.5,6.2);storyline.NPC.PlayerFrame:SetModelScale(1-(StorylineOptions.WindowScale-1)) -- ok with big scalebug
	elseif model == "Creature\\WaterElemental\\WaterElemental" then storyline.NPC.PlayerFrame:SetPosition(0,0,1.5)
	elseif model == "Creature\\Banshee\\Banshee" then storyline.NPC.PlayerFrame:SetPosition(0,0,0.2)
	elseif model == "Creature\\GolemHarvestStage2\\GolemHarvestStage2" then storyline.NPC.PlayerFrame:SetPosition(0,0.5,1.8); storyline.NPC.PlayerFrame:SetModelScale(0.7)
	elseif model == "Creature\\Goblin\\GoblinShredder" then storyline.NPC.PlayerFrame:SetPosition(0,0.5,2.5);storyline.NPC.PlayerFrame:SetModelScale(0.7)
	elseif model == "Creature\\OrcMaleKid\\OrcMaleKid" then storyline.NPC.PlayerFrame:SetPosition(0,0.2,-0.2);storyline.NPC.PlayerFrame:SetModelScale(1.5)
	elseif model == "Creature\\OrcFemaleKid\\OrcFemaleKid" then storyline.NPC.PlayerFrame:SetPosition(0,0.2,-0.2);storyline.NPC.PlayerFrame:SetModelScale(1.5)
	elseif model == "Creature\\Quillboar\\QuillBoar" then storyline.NPC.PlayerFrame:SetPosition(0,0,0.4);storyline.NPC.PlayerFrame:SetModelScale(1.2)
	elseif model == "Creature\\Ogre\\Ogre" then storyline.NPC.PlayerFrame:SetPosition(0,0.6,0.2) -- ok
	elseif model == "Creature\\HumanMalePirateCaptain\\HumanMalePirateCaptain" then storyline.NPC.PlayerFrame:SetPosition(0,0.8,0.8);storyline.NPC.PlayerFrame:SetModelScale(1.2-(StorylineOptions.WindowScale-1)) --ok with scalebug
	elseif model == "Creature\\Gnoll\\gnoll" then storyline.NPC.PlayerFrame:SetPosition(0,0.5,0.2);storyline.NPC.PlayerFrame:SetModelScale(0.95) -- ok
	elseif model == "Creature\\Infernal\\Infernal" then storyline.NPC.PlayerFrame:SetPosition(0,0.6,1.2	);storyline.NPC.PlayerFrame:SetModelScale(0.8-(StorylineOptions.WindowScale-1)) -- ok	with scalebug
	elseif model == "Creature\\Kodobeast\\KodoBeastPack" then storyline.NPC.PlayerFrame:SetPosition(0,0.2,2.6);storyline.NPC.PlayerFrame:SetModelScale(0.4) -- ok with scalebug
	elseif model == "Creature\\DragonSpawn\\DragonSpawn" then storyline.NPC.PlayerFrame:SetPosition(0,2,1);storyline.NPC.PlayerFrame:SetModelScale(0.9-(StorylineOptions.WindowScale-1)) -- ok with scalebug
	end
	
end

function storyline:ResetModels()
	-- Reset parameter
	storyline.NPC.PlayerFrame:SetModelScale(1)
	storyline.NPC.PlayerFrame:SetPosition(0,0,0)
	storyline.NPC.PlayerFrame:SetFacing(-0.8)
	
	storyline.Player.PlayerFrame:SetModelScale(1)
end

-- Fill the Scrollframe + Fade
function storyline:ShowNPCText(Text,Offset)

	-- set text offset
	if not Offset then storyline.Options.Offset = 50
	else storyline.Options.Offset = Offset end

	-- refresh Variables
	storyline.Options.Fading = 0
	storyline.Variables.fadingProgress = 0
	storyline.Variables.SliderProgress = 0
	storyline.Variables.SliderStop = 0
	storyline.Variables.QuesttextLength = 0
	storyline.Variables.LastTime = 0
	storyline.Variables.Time = 0
	

	storyline.Variables.QuesttextLength = string.len(Text)
	storyline.Text.Questtext.Font:SetText(Text)
	_,storyline.Variables.FontSize = storyline.Text.Questtext.Font:GetFont()
	storyline.Variables.FontHeight = storyline.Text.Questtext.Font:GetHeight()
	if storyline.Variables.FontHeight < 50 then storyline.Variables.FontHeight  = 50 end
	storyline.Background.layer5.Questtext.Slider:SetMinMaxValues(0, storyline.Variables.FontHeight -50) -- -50 offset at end of scrollframe

	if QUEST_FADING_DISABLE == "1" then
		storyline.Options.Fading = 0
		storyline.Background.layer5.Questtext.Slider:SetValue(0)
	elseif QUEST_FADING_DISABLE == "0" then
		storyline.Options.Fading = 1
	end
end

-- hide frames after Eventcall
function storyline:HideAll()
	-- Hide Gossip Frame
	storyline.Gossip.Frame:Hide()
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
		-- Greetings Frames
		QuestFrameGreetingPanel:Hide()
		-- Gossip Frame
		GossipFrameGreetingPanel:Hide()
		GossipNpcNameFrame:Hide()
		GossipFrameCloseButton:Hide()
		GossipFramePortrait:SetTexture()
		-- Accept Quest Interact
		QuestFrameDetailPanel:Hide()
		QuestNpcNameFrame:Hide()
		QuestFramePortrait:Hide()
		QuestFrameCloseButton:Hide()
		-- Progress Quest Interact
		QuestFrameProgressPanel:Hide()
		-- Reward Quest Interact
		QuestFrameRewardPanel:Hide()
		-- if Adapt addon is active
		if Adapt and Adapt.Textures and Adapt.Textures["GossipFramePortrait"] then Adapt.Textures["GossipFramePortrait"]:Hide() end
		if Adapt and Adapt.Textures and Adapt.Textures["GossipFramePortrait"] and Adapt.Textures["GossipFramePortrait"].modelLayer then Adapt.Textures["GossipFramePortrait"].modelLayer:Hide() end
		if Adapt and Adapt.Textures and Adapt.Textures["QuestFramePortrait"] then Adapt.Textures["QuestFramePortrait"]:Hide() end
		if Adapt and Adapt.Textures and Adapt.Textures["QuestFramePortrait"] and Adapt.Textures["QuestFramePortrait"].modelLayer then Adapt.Textures["QuestFramePortrait"].modelLayer:Hide() end
		
	else
		GossipFrameGreetingPanel:Show()
		GossipNpcNameFrame:Show()
		GossipFrameCloseButton:Show()

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
		storyline.QuestComplete.Mainframe.Reward.Block[this:GetID()]:SetBackdropColor(0,0.8,0,0.3)
		QuestFrameRewardPanel.itemChoice = this:GetID();
		local _, texture= GetQuestItemInfo("choice", QuestFrameRewardPanel.itemChoice)
		storyline.QuestComplete.Mainframe.CenterItem:SetBackdrop({bgFile = texture})
	end
end

function storyline:UpdateZone()
	local zoneName = V[GetZoneText()]
	-- clear textures
	for i=1,11 do
		if self.Background.layer2.Background[i] then self.Background.layer2.Background[i].Bg:SetTexture(storyline.Area["Clear"][i]) end
	end
	
	-- Set new Textures
	if storyline.Area[zoneName] then
		for i=1,11 do
			if storyline.Area[zoneName][i] then self.Background.layer2.Background[i].Bg:SetTexture(storyline.Area[zoneName][i]) end
		end
	else -- standard picture if unusual area
		self.Background.layer2.Background[11].Bg:SetTexture(storyline.Area["Standard"][11])
	end
end

function storyline:SetFrameStrata()
	storyline.Background:SetFrameStrata(storyline.Options.FrameStrata[StorylineOptions.WindowLevel])
end

-- Animation Functions --
--------------------------
-- play PlayerFrame
function storyline:playPlayerAnimation(event,maxTime)
	storyline.Player.PlayerFrame:SetScript("OnUpdate",function()
		storyline.Player.PlayerFrame:SetSequenceTime(event,storyline.Animation.Player)
		storyline.Animation.Player = storyline.Animation.Player+(arg1*1000)	
		if storyline.Animation.Player > maxTime then storyline.Player.PlayerFrame:SetScript("OnUpdate", nil); storyline.Animation.Player = 0 end
	end)
end

-- play NPCFrame
function storyline:playNPCAnimation(event,maxTime)
	storyline.Animation.NPC = - 200 -- delay
	storyline.NPC.PlayerFrame:SetScript("OnUpdate",function()
		if storyline.Animation.NPC >= 0 then
			storyline.NPC.PlayerFrame:SetSequenceTime(event,storyline.Animation.NPC)
		end
		storyline.Animation.NPC = storyline.Animation.NPC+(arg1*1000)	
		if storyline.Animation.NPC > maxTime then storyline.NPC.PlayerFrame:SetScript("OnUpdate", nil); storyline.Animation.NPC = 0 end
	end)
end

-- from http://stackoverflow.com/questions/2705793/how-to-get-number-of-entries-in-a-lua-table
function storyline:tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

-- play greetings animation
function storyline:GreetingsAnimation()
	if storyline.Animation.Database[storyline.NPC.PlayerFrame:GetModel()] then
		local randAnimation = math.random(1,storyline:tablelength(storyline.Animation.Database[storyline.NPC.PlayerFrame:GetModel()]))
		local counter = 0
		for key,value in pairs(storyline.Animation.Database[storyline.NPC.PlayerFrame:GetModel()]) do 
			counter = counter + 1
			if counter == randAnimation then storyline:playNPCAnimation(key,storyline.Animation.Database[storyline.NPC.PlayerFrame:GetModel()][key]);break; end
		end
	end
end

-- play talk animation
function storyline:TalkAnimation()
	local emoteNum =  "60"
	if storyline.Animation.Database[storyline.NPC.PlayerFrame:GetModel()] and storyline.Animation.Database[storyline.NPC.PlayerFrame:GetModel()][emoteNum] then
		storyline:playNPCAnimation(emoteNum,storyline.Animation.Database[storyline.NPC.PlayerFrame:GetModel()][emoteNum])
	end
end

-- chat inputs
local function TextMenu(arg)
	if arg == nil or arg == "" then
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00Vanilla Storyline:|r This is help topic for |cFFFFFF00 /storyline|r",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00Vanilla Storyline:|r |cFFFFFF00 /storyline reset|r - reset scale.",1,1,1)
		DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00Vanilla Storyline:|r |cFFFFFF00 /storyline move|r - set moveable.",1,1,1)
	else
		if arg == "reset" then
			storyline.Background:SetScale(1); storyline.Options.WindowScale = 1; StorylineOptions.WindowScale = 1
		elseif arg == "move" then
			if not storyline.OptionsFrame.MoveButton:GetChecked() then storyline.Background:EnableMouse(1); storyline.OptionsFrame.MoveButton:SetChecked(true)
			else storyline.Background:EnableMouse(0);storyline.OptionsFrame.MoveButton:SetChecked(false)  end
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00Vanilla Storyline:|r unknown command",1,0.3,0.3);
		end
	end
end
-- slashcommands
SlashCmdList['VANILLA_STORYLINE'] = TextMenu
SLASH_VANILLA_STORYLINE1 = '/storyline'

-- possible Areas and their textures
storyline.Area = {}
	storyline.Area["Dun Morogh"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\DunMorogh"}
	storyline.Area["Durotar"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Durotar"}
	storyline.Area["Elwynn Forest"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\ElwynnForest"}
	storyline.Area["Mulgore"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Mulgore"}	
	storyline.Area["Teldrassil"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Teldrassil"}
	storyline.Area["Tirisfal Glades"]={[1]="Interface\\Glues\\Credits\\TirisfallGlades1",
								[2]="Interface\\Glues\\Credits\\TirisfallGlades2",
								[3]="Interface\\Glues\\Credits\\TirisfallGlades3",
								[4]="Interface\\Glues\\Credits\\TirisfallGlades4",
								[5]="Interface\\Glues\\Credits\\TirisfallGlades5",
								[6]="Interface\\Glues\\Credits\\TirisfallGlades6"}
	storyline.Area["Loch Modan"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\LochModan"}
	storyline.Area["Silverpine Forest"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\SilverpineForest"}	
	storyline.Area["Westfall"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Westfall"}
	storyline.Area["The Barrens"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\TheBarrens"}
	storyline.Area["Redridge Mountains"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\RedridgeMountains"}
	storyline.Area["Stonetalon Mountains"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\StonetalonMountains"}
	storyline.Area["Ashenvale"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Ashenvale"}
	storyline.Area["Duskwood"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Duskwood"}
	storyline.Area["Hillsbrad Foothills"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\HillsbradFoothills"}
	storyline.Area["Wetlands"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Wetlands"}	
	storyline.Area["Thousand Needles"]={[1]="Interface\\Glues\\Credits\\ThousandNeedles1",
								[2]="Interface\\Glues\\Credits\\ThousandNeedles2",
								[3]="Interface\\Glues\\Credits\\ThousandNeedles3",
								[4]="Interface\\Glues\\Credits\\ThousandNeedles4",
								[5]="Interface\\Glues\\Credits\\ThousandNeedles5",
								[6]="Interface\\Glues\\Credits\\ThousandNeedles6"}
	storyline.Area["Alterac Mountains"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\AlteracMountains"}
	storyline.Area["Arathi Highlands"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\ArathiHighlands"}
	storyline.Area["Desolace"]={[1]="Interface\\Glues\\Credits\\SouthernDesolace1",
								[2]="Interface\\Glues\\Credits\\SouthernDesolace2",
								[3]="Interface\\Glues\\Credits\\SouthernDesolace3",
								[4]="Interface\\Glues\\Credits\\SouthernDesolace4",
								[5]="Interface\\Glues\\Credits\\SouthernDesolace5",
								[6]="Interface\\Glues\\Credits\\SouthernDesolace6"}	
	storyline.Area["Stranglethorn Vale"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\StranglethornVale"}
	storyline.Area["Dustwallow Marsh"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\DustwallowMarsh"}	
	storyline.Area["Badlands"]={[1]="Interface\\Glues\\Credits\\Badlands1",
								[2]="Interface\\Glues\\Credits\\Badlands2",
								[3]="Interface\\Glues\\Credits\\Badlands3",
								[4]="Interface\\Glues\\Credits\\Badlands4",
								[5]="Interface\\Glues\\Credits\\Badlands5",
								[6]="Interface\\Glues\\Credits\\Badlands6"}
	storyline.Area["Swamp of Sorrows"]={[1]="Interface\\Glues\\Credits\\SwampofSorrows1",
								[2]="Interface\\Glues\\Credits\\SwampofSorrows2",
								[3]="Interface\\Glues\\Credits\\SwampofSorrows3",
								[4]="Interface\\Glues\\Credits\\SwampofSorrows4",
								[5]="Interface\\Glues\\Credits\\SwampofSorrows5",
								[6]="Interface\\Glues\\Credits\\SwampofSorrows6"}
	storyline.Area["Feralas"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Feralas"}
	storyline.Area["The Hinterlands"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\TheHinterlands"}	
	storyline.Area["Tanaris"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Tanaris"}	
	storyline.Area["Searing Gorge"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\SearingGorge"}	
	storyline.Area["Azshara"]={[1]="Interface\\Glues\\Credits\\Ocean1",
								[2]="Interface\\Glues\\Credits\\Ocean2",
								[3]="Interface\\Glues\\Credits\\Ocean3",
								[4]="Interface\\Glues\\Credits\\Ocean4",
								[5]="Interface\\Glues\\Credits\\Ocean5",
								[6]="Interface\\Glues\\Credits\\Ocean6"}
	storyline.Area["Blasted Lands"]={[1]="Interface\\Glues\\Credits\\BlastedLands1",
								[2]="Interface\\Glues\\Credits\\BlastedLands2",
								[3]="Interface\\Glues\\Credits\\BlastedLands3",
								[4]="Interface\\Glues\\Credits\\BlastedLands4",
								[5]="Interface\\Glues\\Credits\\BlastedLands5",
								[6]="Interface\\Glues\\Credits\\BlastedLands6"}
	storyline.Area["Un'Goro Crater"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\UngoroCrater"}
	storyline.Area["Felwood"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Felwood"}	
	storyline.Area["Burning Steppes"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\BurningSteppes"}	
	storyline.Area["Western Plaguelands"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\WesternPlaguelands"}	
	storyline.Area["Deadwind Pass"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\DeadwindPass"}
	storyline.Area["Eastern Plaguelands"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\EasternPlaguelands"}
	storyline.Area["Winterspring"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Winterspring"}
	storyline.Area["Moonglade"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Moonglade"}	
	storyline.Area["Silithus"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Silithus"}
	storyline.Area["Blackrock Mountain"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\BlackrockMountain"}
	storyline.Area["Darnassus"]={[1]="Interface\\Glues\\Credits\\Darnasis1",
								[2]="Interface\\Glues\\Credits\\Darnasis2",
								[3]="Interface\\Glues\\Credits\\Darnasis3",
								[4]="Interface\\Glues\\Credits\\Darnasis4",
								[5]="Interface\\Glues\\Credits\\Darnasis5",
								[6]="Interface\\Glues\\Credits\\Darnasis6"}
	storyline.Area["City of Ironforge"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Ironforge"}	
	storyline.Area["Orgrimmar"]={[1]="Interface\\Glues\\Credits\\Orccamp1",
								[2]="Interface\\Glues\\Credits\\Orccamp2",
								[3]="Interface\\Glues\\Credits\\Orccamp3",
								[4]="Interface\\Glues\\Credits\\Orccamp4",
								[5]="Interface\\Glues\\Credits\\Orccamp5",
								[6]="Interface\\Glues\\Credits\\Orccamp6"}
	storyline.Area["Stormwind City"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\StormwindCity"}	
	storyline.Area["Thunder Bluff"]={[1]="Interface\\Glues\\Credits\\ThunderBluff1",
								[2]="Interface\\Glues\\Credits\\ThunderBluff2",
								[3]="Interface\\Glues\\Credits\\ThunderBluff3",
								[4]="Interface\\Glues\\Credits\\ThunderBluff4",
								[5]="Interface\\Glues\\Credits\\ThunderBluff5",
								[6]="Interface\\Glues\\Credits\\ThunderBluff6"}
	storyline.Area["Undercity"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Undercity"}
							
	storyline.Area["Standard"]={[11]="Interface\\AddOns\\VanillaStoryline\\Assets\\Images\\Locations\\Standard"}
	storyline.Area["Clear"]={[1]="",
								[2]="",
								[3]="",
								[4]="",
								[5]="",
								[6]="",
								[7]="",
								[8]="",
								[9]="",
								[10]="",
								[11]=""}