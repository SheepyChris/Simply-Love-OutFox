return Def.ActorFrame{
	InitCommand=function(self) self:draworder(200) end,

	Def.Quad{
		InitCommand=function(self) self:diffuse(0,0,0,0):FullScreen():cropbottom(1):fadebottom(0.5) end,
		OffCommand=function(self) self:linear(0.3):cropbottom(-0.5):diffusealpha(1) end
	},

	LoadFont("Common Bold")..{
		Text=ToUpper(THEME:GetString("ScreenSelectMusic", "Press Start for Options")),
		InitCommand=function(self) self:visible(false):Center() end,
		ShowPressStartForOptionsCommand=function(self) self:visible(true) end,
		ShowEnteringOptionsCommand=function(self) self:finishtweening():linear(0.125):diffusealpha(0):playcommand("NewText") end,
		NewTextCommand=function(self) self:settext(ToUpper(THEME:GetString("ScreenSelectMusic", "Entering Options..."))):linear(0.125):diffusealpha(1):sleep(1) end
	}
}