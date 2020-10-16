return {
    Fallback = {
        TapNoteScore_ProW1 = color("#FFFFFF"),
        TapNoteScore_ProW2 = color("#AEEDF3"),
        TapNoteScore_ProW3 = color("#71DDE8"),
        TapNoteScore_ProW4 = color("#A0DBF1"),
        TapNoteScore_ProW5 = color("#7EC2D7"),
        TapNoteScore_W1 = color("#21CCE8"),
        TapNoteScore_W2 = color("#e29c18"),
        TapNoteScore_W3 = color("#66c955"),
        TapNoteScore_W4 = color("#b45cff"),
        TapNoteScore_W5 = color("#c9855e"),
        TapNoteScore_Miss = color("#ff3030")
    },
    StomperZ = {
        TapNoteScore_W1 = color("#5b2b8e"),
        TapNoteScore_W2 = color("#0073ff"),
        TapNoteScore_W3 = color("#66c955"),
        TapNoteScore_W4 = color("#e29c18"),
        TapNoteScore_Miss = color("#ff0000")
    },
    -- Function to give the colors for the particular timing mode set by the game.
    GetGameModeColor = function( this )
        local f = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini")
        return this[f] or this.Fallback
    end
}