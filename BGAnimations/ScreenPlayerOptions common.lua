local af = Def.ActorFrame{}

local originalpos = SCREEN_CENTER_Y + THEME:GetMetric("Player","ReceptorArrowsYStandard")

for pn in ivalues( GAMESTATE:GetHumanPlayers() ) do
	local a = Def.ActorFrame{
		InitCommand=function(self)
			self:xy( _screen.cx - (clamp(_screen.w, 640, 854) * 0.25) * (pn == PLAYER_1 and 1 or -1), originalpos )
			:diffusealpha(0)
		end,
		UpdateNoteFieldPreviewMessageCommand=function(self,param)
			if param.Player == pn then
				self:stoptweening():y( originalpos + param.Val ):diffusealpha(1)
				:sleep(1):linear(1):diffusealpha(0)
			end
		end,
	}

	for i=1,GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() do
		-- Check if the noteskin actually exists, otherwise warn, and use the first noteskin
		-- available on the array.
		local tcol = GAMESTATE:GetCurrentStyle():GetColumnInfo( pn, i )
		a[#a+1] = Def.ActorFrame{
			InitCommand=function(self)
				self:x( tcol["XOffset"] )
			end,
			NOTESKIN:LoadActorForNoteSkin( tcol["Name"], "Receptor", SL[ToEnumShortString(pn)].ActiveModifiers.NoteSkin )
		}
	end

	af[#af+1] = a
end

-- this is broadcast from [OptionRow] TitleGainFocusCommand in metrics.ini
-- we use it to color the active OptionRow's title appropriately by PlayerColor()
af.OptionRowChangedMessageCommand=function(self, params)
	local CurrentRowIndex = {"P1", "P2"}

	-- There is always the possibility that a diffuseshift is still active;
	-- cancel it now (and re-apply below, if applicable).
	params.Title:stopeffect()

	-- get the index of PLAYER_1's current row
	if GAMESTATE:IsPlayerEnabled(PLAYER_1) then
		CurrentRowIndex.P1 = SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_1)
	end

	-- get the index of PLAYER_2's current row
	if GAMESTATE:IsPlayerEnabled(PLAYER_2) then
		CurrentRowIndex.P2 = SCREENMAN:GetTopScreen():GetCurrentRowIndex(PLAYER_2)
	end

	local optionRow = params.Title:GetParent():GetParent()

	-- color the active optionrow's title appropriately
	if optionRow:HasFocus(PLAYER_1) then
		params.Title:diffuse(PlayerColor(PLAYER_1))
	end

	if optionRow:HasFocus(PLAYER_2) then
		params.Title:diffuse(PlayerColor(PLAYER_2))
	end

	if CurrentRowIndex.P1 and CurrentRowIndex.P2 then
		if CurrentRowIndex.P1 == CurrentRowIndex.P2 then
			params.Title:diffuseshift()
			params.Title:effectcolor1(PlayerColor(PLAYER_1))
			params.Title:effectcolor2(PlayerColor(PLAYER_2))
		end
	end

end

return af