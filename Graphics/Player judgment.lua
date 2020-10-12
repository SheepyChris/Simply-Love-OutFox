local sPlayer = Var "Player"

local function GetTexture()
	if THEME:GetMetric("Common","UseAdvancedJudgments") then 
		return LoadModule("Options.SmartJudgments.lua")()[
			LoadModule("Options.ChoiceToValue.lua")(
				LoadModule("Options.SmartJudgments.lua")("Show"),
				LoadModule("Config.Load.lua")("SmartJudgments",CheckIfUserOrMachineProfile(string.sub(sPlayer,-1)-1).."/OutFoxPrefs.ini")
				or THEME:GetMetric("Common","DefaultJudgment")
			)
		] 
	else
		return THEME:GetPathG("Judgment","Normal")
	end
end

local Name,Length = LoadModule("Options.SmartTapNoteScore.lua")()
table.sort(Name)
Name[#Name+1] = "Miss"

return Def.ActorFrame {
	Def.Sprite{
		Name="Judgment",
		Texture=GetTexture(),
		InitCommand=function(self) self:pause():visible(false) end,
		OnCommand=THEME:GetMetric("Judgment","JudgmentOnCommand"),
		ResetCommand=function(self) self:finishtweening():stopeffect():visible(false) end
	},
	JudgmentMessageCommand=function(self, params)
		local Judg = self:GetChild("Judgment")
		if params.Player ~= sPlayer then return end
		if params.HoldNoteScore then return end
		if string.find(params.TapNoteScore, "Mine") then return end

		-- SCREENMAN:SystemMessage( params.TapNoteScore )

		local jPath = string.match(Judg:GetTexture():GetPath(), ".*/(.*)")
		local iFrame

		for i = 1,#Name do
			if params.TapNoteScore == "TapNoteScore_"..Name[i] then iFrame = i-1 end
		end

		if not iFrame then return end
		if string.find(jPath, "%[double%]")then
			iFrame = iFrame * 2
			if not params.Early then
				iFrame = iFrame + 1
			end
		end

		self:playcommand("Reset")

		Judg:visible( not bHideJudgment )
		Judg:setstate( iFrame )
		Judg:zoom(0.8):decelerate(0.1):zoom(0.75):sleep(0.6):accelerate(0.2):zoom(0)
	end
}
