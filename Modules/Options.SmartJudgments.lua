return function(Mode)
	local Dir = {FILEMAN:GetDirListing("Appearance/Judgments/",false,true)}
	local NewDir = {}
	for k,a in pairs(Dir) do
		for _,v in pairs( a ) do
			if Mode == "Show" then
				NewDir[#NewDir+1] = string.match(v,".+/(.-) %d")
			else
				NewDir[#NewDir+1] = v
			end
		end
	end
	return NewDir
end