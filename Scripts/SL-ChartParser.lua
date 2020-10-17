GetSimfileString = function(steps)

	-- steps:GetFilename() returns the filename of the sm or ssc file, including path, as it is stored in SM's cache
	local filename = steps:GetFilename()
	if not filename then return end

	-- get the file extension like "sm" or "SM" or "ssc" or "SSC" or "sSc" or etc.
	-- convert to lowercase
	local filetype = filename:match("[^.]+$"):lower()
	-- if file doesn't match "ssc" or "sm", it was (hopefully) something else (.dwi, .bms, etc.)
	-- that isn't supported by SL-ChartParser
	if not (filetype=="ssc" or filetype=="sm") then return end

	-- create a generic RageFile that we'll use to read the contents
	-- of the desired .ssc or .sm file
	local f = RageFileUtil.CreateRageFile()
	local contents

	-- the second argument here (the 1) signals
	-- that we are opening the file in read-only mode
	if f:Open(filename, 1) then
		contents = f:Read()
	end

	-- destroy the generic RageFile now that we have the contents
	f:destroy()
	return contents, filetype
end

-- ----------------------------------------------------------------
-- SOURCE: https://github.com/JonathanKnepp/SM5StreamParser

-- Which note types are counted as part of the stream?
local TapNotes = {1,2,4}


-- Utility function to replace regex special characters with escaped characters
local regexEncode = function(var)
	return (var:gsub('%%', '%%%'):gsub('%^', '%%^'):gsub('%$', '%%$'):gsub('%(', '%%('):gsub('%)', '%%)'):gsub('%.', '%%.'):gsub('%[', '%%['):gsub('%]', '%%]'):gsub('%*', '%%*'):gsub('%+', '%%+'):gsub('%-', '%%-'):gsub('%?', '%%?'))
end

-- GetSimfileChartString() accepts four arguments:
--    SimfileString - the contents of the ssc or sm file as a string
--    StepsType     - a string like "dance-single" or "pump-double"
--    Difficulty    - a string like "Beginner" or "Challenge" or "Edit"
--    Filetype      - either "sm" or "ssc"
--
-- GetSimfileChartString() returns one value:
--    NoteDataString, a substring from SimfileString that contains the just the requested note data

local GetSimfileChartString = function(SimfileString, StepsType, Difficulty, StepsDescription, Filetype)
	local NoteDataString = nil

	if Filetype == "ssc" then
		-- SSC File
		-- Loop through each chart in the SSC file
		for chart in SimfileString:gmatch("#NOTEDATA.-#NOTES:[^;]*") do
			-- Find the chart that matches our difficulty and game type
			if(chart:match("#STEPSTYPE:"..regexEncode(StepsType)) and chart:match("#DIFFICULTY:"..regexEncode(Difficulty))) then
				-- ensure that we've located the correct edit stepchart within the ssc file
				-- there can be multiple Edit stepcharts but each is guaranteed to have a unique #DESCIPTION tag
				if (Difficulty ~= "Edit") or (Difficulty=="Edit" and chart:match("#DESCRIPTION:"..regexEncode(StepsDescription))) then
					-- Find just the notes
					NoteDataString = chart:match("#NOTES:[\r\n]+([^;]*)\n?$")
					-- remove possible comments
					NoteDataString = NoteDataString:gsub("\\[^\r\n]*", "")
					NoteDataString = NoteDataString:gsub("//[^\r\n]*", "")
					-- put the semicolon back so that the line-by-line loop knows when to stop
					NoteDataString = NoteDataString .. ";"
					break
				end
			end
		end

	-- ----------------------------------------------------------------
	-- FIXME: this is likely to return the incorrect note data string from an sm file when
	--   the requested Difficulty is "Edit" and there are multiple edit difficulties available.
	--   StepMania uses each steps' "Description" attribute to unique identify Edit charts.
	--
	--   ssc files use a dedicated #DESCRIPTION for this purpose
	--   but sm files have the description as part of an inline comment like
	--
	--   //---------------dance-single - test----------------
	--
	--   that^ edit stepchart would have a description of "test"
	--
	--   For now, SL-ChartParser.lua supports ssc files with multiple edits but not sm files.
	-- ----------------------------------------------------------------
	elseif Filetype == "sm" then
		-- SM FILE
		-- Loop through each chart in the SM file
		for chart in SimfileString:gmatch("#NOTES[^;]*") do
			-- split the entire chart string into pieces on ":"
			local pieces = {}
			for str in chart:gmatch("[^:]+") do
				pieces[#pieces+1] = str
			end

			-- the pieces table should contain 7 numerically indexed items
			-- 2, 4, and 7 are the indices we care about for finding the correct chart
			-- index 2 will contain the steps_type (like "dance-single")
			-- index 4 will contain the difficulty (like "challenge")

			-- use gsub to scrub out line breaks (and other irrelevant characters?)
			local st = pieces[2]:gsub("[^%w-]", "")
			local diff = pieces[4]:gsub("[^%w]", "")

			-- if this particular chart's steps_type matches the desired StepsType
			-- and its difficulty string matches the desired Difficulty
			if (st == StepsType) and (diff == Difficulty) then
				-- then index 7 contains the notedata that we're looking for
				-- use gsub to remove comments, store the resulting string,
				-- and break out of the chart loop now
				NoteDataString = pieces[7]:gsub("//[^\r\n]*","") .. ";"
				break
			end
		end
	end

	return NoteDataString
end

-- Figure out which measures are considered a stream of notes
local getStreamMeasures = function(measuresString, notesPerMeasure)
	-- Make our stream notes array into a string for regex
	local TapNotesString = ""
	for i, v in ipairs(TapNotes) do
		TapNotesString = TapNotesString .. v
	end
	TapNotesString = "["..TapNotesString.."]"

	-- Which measures are considered a stream?
	local streamMeasures = {}

	-- Keep track of the measure and its timing (8ths, 16ths, etc)
	local measureCount = 1
	local measureTiming = 0
	-- Keep track of the notes in a measure
	local measureNotes = {}

	-- Loop through each line in our string of measures, trimming potential leading whitespace (thanks, TLOES/Mirage Garden)
	for line in measuresString:gmatch("[^%s*\r\n]+")
	do
		-- If we hit a comma or a semi-colon, then we've hit the end of our measure
		if(line:match("^[,;]%s*")) then
			-- Does this measure contain a stream of notes based on our notesPerMeasure global?
			if(#measureNotes >= notesPerMeasure) then
				table.insert(streamMeasures, measureCount)
			end

			-- Reset iterative variables
			measureTiming = 0
			measureCount = measureCount + 1
			measureNotes = {}
		else
			-- increment the measure timing
			measureTiming = measureTiming + 1

			-- Is this a note?
			if(line:match(TapNotesString)) then
				table.insert(measureNotes, measureTiming)
			end
		end
	end

	return streamMeasures, measureCount
end

-- Get the start/end of each stream and break sequence in our table of measures
local getStreamSequences = function(streamMeasures, totalMeasures)
	local streamSequences = {}
	-- Count every measure as stream/non-stream.
	-- We can then later choose how we want to display the information.
	local measureSequenceThreshold = 1

	local counter = 1
	local streamEnd = nil

	-- First add an initial break if it's larger than measureSequenceThreshold
	if #streamMeasures > 0 then
		local breakStart = 0
		local k, v = next(streamMeasures) -- first element of a table
		local breakEnd = streamMeasures[k] - 1
		if (breakEnd - breakStart >= measureSequenceThreshold) then
			table.insert(streamSequences,
				{streamStart=breakStart, streamEnd=breakEnd, isBreak=true})
		end
	end

	-- Which sequences of measures are considered a stream?
	for k,v in pairs(streamMeasures) do
		local curVal = streamMeasures[k]
		local nextVal = streamMeasures[k+1] and streamMeasures[k+1] or -1

		-- Are we still in sequence?
		if curVal + 1 == nextVal then
			counter = counter + 1
			streamEnd = curVal + 1
		else
			-- Found the first section that counts as a stream
			if(counter >= measureSequenceThreshold) then
				if streamEnd == nil then
					streamEnd = curVal
				end
				local streamStart = (streamEnd - counter)
				-- Add the current stream.
				table.insert(streamSequences,
					{streamStart=streamStart, streamEnd=streamEnd, isBreak=false})
			end

			-- Add any trailing breaks if they're larger than measureSequenceThreshold
			local breakStart = curVal
			local breakEnd = (nextVal ~= -1) and nextVal - 1 or totalMeasures
			if (breakEnd - breakStart >= measureSequenceThreshold) then
				table.insert(streamSequences,
					{streamStart=breakStart, streamEnd=breakEnd, isBreak=true})
			end
			counter = 1
			streamEnd = nil
		end
	end

	return streamSequences
end

GetStreams = function(Steps, StepsType, Difficulty, NotesPerMeasure)

	local SimfileString, Filetype = GetSimfileString( Steps )
	if not SimfileString then return end

	-- an arbitary but unique string provded by the stepartist, needed here to identify Edit charts
	local StepsDescription = Steps:GetDescription()

	-- Parse out just the contents of the notes
	local ChartString = GetSimfileChartString(SimfileString, StepsType, Difficulty, StepsDescription, Filetype)
	if not ChartString then return end

	-- Which measures have enough notes to be considered as part of a stream?
	local StreamMeasures, totalMeasures = getStreamMeasures(ChartString, NotesPerMeasure)

	-- Which sequences of measures are considered a stream?
	return (getStreamSequences(StreamMeasures, totalMeasures))
end