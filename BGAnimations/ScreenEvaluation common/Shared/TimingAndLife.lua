-- don't bother showing the timing and life difficulties in Casual mode
if SL.Global.GameMode == "Casual" then return end

return Def.ActorFrame{
	LoadFont("Common Normal")..{
		Text=GetTimingDifficulty();
		AltText="";
		BeginCommand=function(self)
			self:settext( THEME:GetString("ScreenEvaluation", 'TimingDifficulty') .. ": " .. GetTimingDifficulty() );
			self:x(_screen.cx-145):y(175);
			self:maxwidth(230):horizalign(left);
			self:diffuse(color("#FFFFFF")):zoom(0.6);
		end;
	},
	
	LoadFont("Common Normal")..{
		Text=GetLifeDifficulty();
		AltText="";
		BeginCommand=function(self)
			self:settext( THEME:GetString("ScreenEvaluation", 'LifeDifficulty') .. ": " .. GetLifeDifficulty() );
			self:x(_screen.cx+145):y(175);
			self:maxwidth(180):horizalign(right);
			self:diffuse(color("#FFFFFF")):zoom(0.6);
		end;
	}
}
