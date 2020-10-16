local arg = ...
local player = arg[1]
local coloring = arg[2]
local pn = ToEnumShortString(player)

local Name, Length = LoadModule("Options.SmartTapNoteScore.lua")()
local CurPrefTiming = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini")
table.sort(Name)

Name[#Name+1] = "Miss"
Length = Length + 1

local TapNoteScores = { Types=Name, Names={} }
local tns_string = "TapNoteScore" .. (SL.Global.GameMode=="ITG" and "" or SL.Global.GameMode)
-- get TNS names appropriate for the current GameMode, localized to the current language
for i, judgment in ipairs(TapNoteScores.Types) do
	TapNoteScores.Names[#TapNoteScores.Names+1] = THEME:GetString( CurPrefTiming or "Original" , "Judgment"..judgment )
end

local RadarCategories = {
	THEME:GetString("ScreenEvaluation", 'Holds'),
	THEME:GetString("ScreenEvaluation", 'Mines'),
	THEME:GetString("ScreenEvaluation", 'Rolls')
}

local row_height = scale( #Name, 1, 11, 28, 24 )
local windows = SL.Global.ActiveModifiers.TimingWindows
local coloring = LoadModule("SL/SL.JudgmentColor.lua"):GetGameModeColor()

local af = Def.ActorFrame{}

--  labels: W1, W2, W3, W4, W5, Miss
for i, label in ipairs(TapNoteScores.Names) do

	-- no need to add BitmapText actors for TimingWindows that were turned off
	if true then
		af[#af+1] = LoadFont("Common Normal")..{
			Text=label:upper(),
			InitCommand=function(self) self:zoom(0.833):horizalign(right):maxwidth(72) end,
			BeginCommand=function(self)
				self:x(80):y((i-1)*row_height - 226)
				    :diffuse( coloring["TapNoteScore_"..TapNoteScores.Types[i]] )
			end
		}
	end
end

-- labels: holds, mines, rolls
for i, label in ipairs(RadarCategories) do
	af[#af+1] = LoadFont("Common Normal")..{
		Text=label,
		InitCommand=function(self) self:zoom(0.833):horizalign(right) end,
		BeginCommand=function(self)
			self:x(-94):y((i-1)*row_height - 143)
		end
	}
end

return af