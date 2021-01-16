if SL.Global.GameMode == "Casual" then return end

local player = ...
local NumPlayers = #GAMESTATE:GetHumanPlayers()

local GraphWidth  = THEME:GetMetric("GraphDisplay", "BodyWidth")
local GraphHeight = THEME:GetMetric("GraphDisplay", "BodyHeight")

return Def.ActorFrame{
	InitCommand=function(self)
		self:y(_screen.cy + 124)
		if NumPlayers == 1 then
			-- not quite an even 0.25 because we need to accomodate the extra 10px
			-- that would normally be between the left and right panes
			self:addx(GraphWidth * 0.2541)
		end
	end,

	-- Draw a Quad behind the GraphDisplay (lifebar graph) and Judgment ScatterPlot
	Def.Quad{
		InitCommand=function(self)
			self:zoomto(GraphWidth, GraphHeight):diffuse(color("#101519")):vertalign(top)
		end
	},
	
	-- the halfway mark for lifebar; only visible in StomperZ
	Def.Quad{
		Name="LifeBarGraph_MidwayQuad",
		InitCommand=function(self)
			if SL.Global.GameMode ~= "StomperZ" then
				self:visible(false)
				return
			end
			self:diffuse(0,0,0,0.75):y(GraphHeight):vertalign(bottom)
				:zoomto( GraphWidth, GraphHeight/2 )
		end
	},

	LoadActor("./ScatterPlot.lua", {player=player, GraphWidth=GraphWidth, GraphHeight=GraphHeight} ),

	LoadActor("./GraphDisplay.lua", { Pn = player, Width = GraphWidth, Height=GraphHeight/2 }),
}
