local player, side = unpack(...)

local pn = ToEnumShortString(player)
local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(pn)

local f = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini")
local tns_string = f

local firstToUpper = function(str)
    return (str:gsub("^%l", string.upper))
end

local getStringFromTheme = function( arg )
	return THEME:GetString(tns_string, arg);
end

--Values above 0 means the user wants to be shown or told they are nice.
local nice = ThemePrefs.Get("nice") > 0 and SL.Global.GameMode ~= "Casual"

-- Iterating through the enum isn't worthwhile because the sequencing is so bizarre...
local Name, Length = LoadModule("Options.SmartTapNoteScore.lua")()
local CurPrefTiming = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini")
table.sort(Name)
Length = Length + 1
Name[#Name+1] = "Miss"

local TapNoteScores = {}
TapNoteScores.Types = Name

local RadarCategories = {
	THEME:GetString("ScreenEvaluation", 'Holds'),
	THEME:GetString("ScreenEvaluation", 'Mines'),
	THEME:GetString("ScreenEvaluation", 'Hands'),
	THEME:GetString("ScreenEvaluation", 'Rolls')
}

local EnglishRadarCategories = {
	[THEME:GetString("ScreenEvaluation", 'Holds')] = "Holds",
	[THEME:GetString("ScreenEvaluation", 'Mines')] = "Mines",
	[THEME:GetString("ScreenEvaluation", 'Hands')] = "Hands",
	[THEME:GetString("ScreenEvaluation", 'Rolls')] = "Rolls",
}

local scores_table = {}
for index, window in ipairs(TapNoteScores.Types) do
	local number = stats:GetTapNoteScores( "TapNoteScore_"..window )
	scores_table[window] = number
end

local t = Def.ActorFrame{
	InitCommand=function(self)
		self:xy(50 * (side==PLAYER_1 and 1 or -1), _screen.cy-24)
	end,
}

local windows = SL.Global.ActiveModifiers.TimingWindows
local coloring = LoadModule("SL/SL.JudgmentColor.lua"):GetGameModeColor()
--  labels: W1 ---> Miss
lua.ReportScriptError( Length )
local yscaleset = Length > 6 and scale( Length, 6, 11, 28, 15 ) or 28
local zoomscale = Length > 6 and scale( Length, 6, 11, 0.833, 0.5 ) or 0.833
for i=1, #TapNoteScores.Types do
	-- no need to add BitmapText actors for TimingWindows that were turned off
	if true then

		local window = TapNoteScores.Types[i]
		local label = getStringFromTheme( "Judgment"..window )

		t[#t+1] = LoadFont("Common Normal")..{
			Text=(nice and scores_table[window] == 69) and 'NICE' or label:upper(),
			InitCommand=function(self) self:zoom(zoomscale):horizalign(right):maxwidth(76) end,
			BeginCommand=function(self)
				self:x( (side == PLAYER_1 and 28) or -28 )
				self:y((i-1)*yscaleset -16)
				-- diffuse the JudgmentLabels the appropriate colors for the current GameMode
				self:diffuse( coloring["TapNoteScore_"..window] )
			end
		}
	end
end

-- labels: holds, mines, hands, rolls
for index, label in ipairs(RadarCategories) do

	local performance = stats:GetRadarActual():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )
	local possible = stats:GetRadarPossible():GetValue( "RadarCategory_"..firstToUpper(EnglishRadarCategories[label]) )

	t[#t+1] = LoadFont("Common Normal")..{
		-- lua ternary operators are adorable -ian5v
		Text=(nice and (performance == 69 or possible == 69)) and 'nice' or label,
		InitCommand=function(self) self:zoom(0.833):horizalign(right) end,
		BeginCommand=function(self)
			self:x( (side == PLAYER_1 and -160) or 90 )
			self:y((index-1)*28 + 41)
		end
	}
end

return t
