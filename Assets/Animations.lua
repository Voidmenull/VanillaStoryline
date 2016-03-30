-- original source: https://github.com/Lanrutcon/Backport-Storyline/blob/master/structures.lua

local EXCLAME_ID = "64" -- EmoteTalkExclamation
local QUESTION_ID = "65" -- EmoteTalkQuestion
local TALK_ID = "60" -- EmoteTalk
local YES_ID = "185" -- EmoteYes
local NOPE_ID = "186" -- EmoteNo
local ACLAIM_ID = "68" -- EmoteCheer
local BOW_ID = "66" -- EmoteBow
local WAVE_ID = "67" -- EmoteWave
local LAUGH_ID = "70" -- EmoteLaugh
local SALUTE_ID = "113" -- EmoteSalute

Storyline_ANIMATION_SEQUENCE_DURATION_BY_MODEL = {
	-- NIGHT ELVES
	["Character\\NightElf\\Female\\NightElfFemale"] = { -- readout
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1600,
		[TALK_ID] = 2100,
		[YES_ID] = 2000,
		[NOPE_ID] = 1600,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 2400,
		[SALUTE_ID] = 2000,
	},
	["Character\\NightElf\\Male\\NightElfMale"] = { -- readout
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 2000,
		[TALK_ID] = 2000,
		[YES_ID] = 1200,
		[NOPE_ID] = 1500,
		[ACLAIM_ID] = 2000,
		[BOW_ID] = 2000,
		[WAVE_ID] = 1300,
		[LAUGH_ID] = 2300,
		[SALUTE_ID] = 1700,
	},
	-- DWARF
	["Character\\Dwarf\\Male\\DwarfMale"] = { -- readout
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1800,
		[TALK_ID] = 2000,
		[YES_ID] = 2000,
		[NOPE_ID] = 2000,
		[ACLAIM_ID] = 3000,
		[BOW_ID] = 2000,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 3000,
		[SALUTE_ID] = 1700,
	},
	["Character\\Dwarf\\Female\\DwarfFemale"] = { -- readout
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1800,
		[TALK_ID] = 2000,
		[YES_ID] = 2000,
		[NOPE_ID] = 2000,
		[ACLAIM_ID] = 2000,
		[BOW_ID] = 2000,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 3300,
		[SALUTE_ID] = 2000,
	},
	-- GNOMES
	["Character\\Gnome\\Male\\GnomeMale"] = { -- readout
		[EXCLAME_ID] = 1867,
		[QUESTION_ID] = 2300,
		[TALK_ID] = 4000,
		[YES_ID] = 1000,
		[NOPE_ID] = 1000,
		[ACLAIM_ID] = 2000,
		[BOW_ID] = 2000,
		[WAVE_ID] = 2840,
		[LAUGH_ID] = 3200,
		[SALUTE_ID] = 1500,
	},
	["Character\\Gnome\\Female\\GnomeFemale"] = { -- readout
		[EXCLAME_ID] = 1867,
		[QUESTION_ID] = 2300,
		[TALK_ID] = 4000,
		[YES_ID] = 1000,
		[NOPE_ID] = 1660,
		[ACLAIM_ID] = 2000,
		[BOW_ID] = 2000,
		[WAVE_ID] = 2840,
		[LAUGH_ID] = 2300,
		[SALUTE_ID] = 1500,
	},
	-- HUMAN
	["Character\\Human\\Male\\HumanMale"] = {-- readout
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1800,
		[TALK_ID] = 2000,
		[YES_ID] = 2667,
		[NOPE_ID] = 3300,
		[ACLAIM_ID] = 2500,
		[BOW_ID] = 2167,
		[WAVE_ID] = 2667,
		[LAUGH_ID] = 3300,
		[SALUTE_ID] = 1533,
	},
	["Character\\Human\\Female\\HumanFemale"] = { -- readout
		[EXCLAME_ID] = 2833,
		[QUESTION_ID] = 1800,
		[TALK_ID] = 2667,
		[YES_ID] = 2000,
		[NOPE_ID] = 1600,
		[ACLAIM_ID] = 2330,
		[BOW_ID] = 2667,
		[WAVE_ID] = 2667,
		[LAUGH_ID] = 3333,
		[SALUTE_ID] = 2000,
	},
	-- ORCS
	["Character\\Orc\\Female\\OrcFemale"] = { -- readout
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1800,
		[TALK_ID] = 2000,
		[YES_ID] = 1466,
		[NOPE_ID] = 1466,
		[ACLAIM_ID] = 1333,
		[BOW_ID] = 1134,
		[WAVE_ID] = 1333,
		[LAUGH_ID] = 3300,
		[SALUTE_ID] = 1667,
	},

	["Character\\Orc\\Male\\OrcMale"] = { --readout
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1800,
		[TALK_ID] = 2000,
		[YES_ID] = 2000,
		[NOPE_ID] = 2000,
		[ACLAIM_ID] = 2766,
		[BOW_ID] = 1200,
		[WAVE_ID] = 1667,
		[LAUGH_ID] = 3000,
		[SALUTE_ID] = 1833,
	},
	-- GOBLIN
	["Character\\Goblin\\Male\\GoblinMale"] = { -- readout
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1800,
		[ACLAIM_ID] = 3000,
		[BOW_ID] = 2000,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 3300,
		[SALUTE_ID] = 1667,
	},
	["Character\\Goblin\\Female\\GoblinFemale"] = { -- readout
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1800,
		[ACLAIM_ID] = 3000,
		[BOW_ID] = 2000,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 3300,
		[SALUTE_ID] = 1667,
	},
--local EXCLAME_ID = "64" -- EmoteTalkExclamation
--local QUESTION_ID = "65" -- EmoteTalkQuestion
--local TALK_ID = "60" -- EmoteTalk
--local YES_ID = "185" -- EmoteYes
--local NOPE_ID = "186" -- EmoteNo
---local ACLAIM_ID = "68" -- EmoteCheer
--local BOW_ID = "66" -- EmoteBow
--local WAVE_ID = "67" -- EmoteWave
--local LAUGH_ID = "70" -- EmoteLaugh
--local SALUTE_ID = "113" -- EmoteSalute
	-- Tauren
	["Character\\Tauren\\Female\\TaurenFemale"] = {
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1600,
		[TALK_ID] = 2100,
		[YES_ID] = 2000,
		[NOPE_ID] = 1600,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 2400,
		[SALUTE_ID] = 2000,
	},
	["Character\\Tauren\\Male\\TaurenMale"] = {
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1600,
		[TALK_ID] = 2100,
		[YES_ID] = 2000,
		[NOPE_ID] = 1600,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 2400,
		[SALUTE_ID] = 2000,
	},
	-- Troll
	["Character\\Troll\\Female\\TrollFemale"] = {
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1600,
		[TALK_ID] = 2100,
		[YES_ID] = 2000,
		[NOPE_ID] = 1600,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 2400,
		[SALUTE_ID] = 2000,
	},
	["Character\\Troll\\Male\\TrollMale"] = {
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1600,
		[TALK_ID] = 2100,
		[YES_ID] = 2000,
		[NOPE_ID] = 1600,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 2400,
		[SALUTE_ID] = 2000,
	},
	-- Scourge
	["Character\\Scourge\\Male\\ScourgeMale"] = {
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1600,
		[TALK_ID] = 2100,
		[YES_ID] = 2000,
		[NOPE_ID] = 1600,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 2400,
		[SALUTE_ID] = 2000,
	},
	["Character\\Scourge\\Female\\ScourgeFemale"] = {
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1600,
		[TALK_ID] = 2100,
		[YES_ID] = 2000,
		[NOPE_ID] = 1600,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 2400,
		[SALUTE_ID] = 2000,
	},

	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- NPC
	--*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
	-- Blood Elfes
	["Creature\\HighElf\\HighElfFemale_Mage"] = {
		[TALK_ID] = 2100,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
	},
	["Creature\\HighElf\\HighElfFemale_Hunter"] = {
		[TALK_ID] = 2100,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
	},
	["Creature\\HighElf\\HighElfFemale_Priest"] = {
		[TALK_ID] = 2100,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
	},
	["Creature\\HighElf\\HighElfFemale_Warrior"] = {
		[TALK_ID] = 2100,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
	},
	["Creature\\HighElf\\HighElfMale_Hunter"] = {
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1600,
		[TALK_ID] = 2100,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 2400,
	},
	["Creature\\HighElf\\HighElfMale_Mage"] = {
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1600,
		[TALK_ID] = 2100,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 2400,
	},
	["Creature\\HighElf\\HighElfMale_Priest"] = {
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1600,
		[TALK_ID] = 2100,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 2400,
	},
	["Creature\\HighElf\\HighElfMale_Warrior"] = {
		[EXCLAME_ID] = 2000,
		[QUESTION_ID] = 1600,
		[TALK_ID] = 2100,
		[ACLAIM_ID] = 800,
		[BOW_ID] = 2300,
		[WAVE_ID] = 2000,
		[LAUGH_ID] = 2400,
	},
}
