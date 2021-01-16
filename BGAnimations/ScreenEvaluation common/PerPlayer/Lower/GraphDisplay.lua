local Args = ...
local Player = Args.Pn
local width = Args.Width
local height = Args.Height

-- Every player has data contained within the PlayerStageStats. Locate it.
local Stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(Player)
if not Stats then
    return Def.Actor{}
end

-- Now that we have stats, we need to lookup how life was throughout the stage.
-- By default, the StepMania engine performs a lookup sample of 100, we'll perform the same here.
local SampleAmmount = 100
local LastSecond = LoadModule( "StageStats.TotalPossibleStepSeconds.lua" )()
local LifeRecord = Stats:GetLifeRecord( LastSecond, SampleAmmount )

local t = Def.ActorFrame{
    OnCommand=function(self)
        self:y( height + 2 )
        local p = {}

        -- in normal gameplay (non-CourseMode), we hide the solid color but leave the white line.
        -- in CourseMode, we hide the white line (for aesthetic reasons) and leave the solid color
        -- as ScatterPlot.lua does not yet support CourseMode.

        -- in technical terms, it is possible to provide a full scatterplot with the current Scatterplot
        -- system that SL uses, but prevents itself by only using the current stage, thus not counting
        -- all stages played on the nonstop/survival sequence.
        if GAMESTATE:IsCourseMode() then
            for k,v in pairs( LifeRecord ) do
                local x = scale( k, 1, SampleAmmount, -width/2, width/2 )
                local y = scale( v, 0, 1, 0, -height )
                local absstate = scale( x, -width/2, width/2, 0, 1 )
                p[#p+1] = { {x,0,0}, lerp_color( absstate, Alpha(ColorLightTone(PlayerColor(Player)),0.35), Alpha(PlayerColor(Player), 0.5)) }
                p[#p+1] = { {x,y,0}, lerp_color( absstate, Alpha(ColorLightTone(PlayerColor(Player)),0.35), Alpha(PlayerColor(Player), 0.5)) }
            end
            self:GetChild("Body"):SetVertices(p)
        else
            for k,v in pairs( LifeRecord ) do
                local x = scale( k, 1, SampleAmmount, -width/2, width/2 )
                local y = scale( v, 0, 1, 0, -height )
                p[#p+1] = { {x,y,0}, Color.White }
            end
            self:GetChild("Line"):SetVertices(p)
        end

    end
}

-- Body
t[#t+1] = Def.ActorMultiVertex{ Name="Body", InitCommand=function(self) self:SetDrawState{ Mode="DrawMode_QuadStrip" } end }

-- Line Strip variant.
-- TODO: Figure out a formula to scale for HIDPI displays
t[#t+1] = Def.ActorMultiVertex{ Name="Line",
    InitCommand=function(self)
        local ZoomScale = 2 * (( DISPLAY:GetDisplayHeight() / SCREEN_HEIGHT ))
        self:SetDrawState{ Mode="DrawMode_LineStripM" }:SetLineWidth( ZoomScale )
    end
}

-- Barely! detection.
-- Search for the min life record to show "Just Barely!"
local fMinLifeSoFar = 1
local MinLifeSoFarAt = 0

for k,v in pairs( LifeRecord ) do
    if v <  fMinLifeSoFar then
        fMinLifeSoFar = v
        MinLifeSoFarAt = k
    end
end

local needsBarely = false

-- the Barely text is triggered when the lowest life ever achieved in the file is within 0 and 0.1.
if ( fMinLifeSoFar > 0 and fMinLifeSoFar < 0.1 ) then
    needsBarely = true
end

t[#t+1] = Def.ActorFrame{
    Name="Barely",
    Condition=needsBarely,
    InitCommand=function(self)
        self:xy(
            scale( MinLifeSoFarAt, 1, SampleAmmount, -width/2, width/2 ),
            scale( fMinLifeSoFar, 0, 1, 0, -height ) - 30
        )
    end,
	OnCommand=function(self)
        local endpos = self:GetY()
		self:addy(-20):diffusealpha(0):sleep(2):accelerate(0.2):diffusealpha(1):y( endpos + 15 )
		    :decelerate(0.2):y( endpos )
		    :accelerate(0.2):y( endpos + 15 )
	end,

	Def.BitmapText{
        Font="Common Normal",
		Text=THEME:GetString("GraphDisplay", "Barely"),
		InitCommand=function(self) self:zoom(0.75) end,
	},
	Def.Sprite{
        Texture=THEME:GetPathB("ScreenSelectMusic", "overlay/PerPlayer/arrow.png"),
		InitCommand=function(self) self:rotationz(90):zoom(0.5):y(10) end,
		OnCommand=function(self) self:sleep(0.5):diffuseshift():effectcolor1(1,1,1,1):effectcolor2(1,1,1,0.2) end
	}
}

return t