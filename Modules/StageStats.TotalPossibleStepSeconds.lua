return function()
    local fSecs = 0
    for i = 1, 1 do
        local s = STATSMAN:GetPlayedStageStats(i)
        -- lua.ReportScriptError( tostring(s:GetPlayedSongs()[1]) )
        for a = 1, #s:GetPlayedSongs() do
            fSecs = fSecs + s:GetPlayedSongs()[a]:GetStepsSeconds()
        end
    end

    local songoptions = GAMESTATE:GetSongOptionsObject("ModsLevel_Song")

    if not songoptions then
        return fSecs
    end

    return fSecs / songoptions:MusicRate()
end