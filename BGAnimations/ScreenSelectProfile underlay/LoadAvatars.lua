local af, profile_data = unpack(...)

local textures = {}

af[#af+1] = Def.Sprite{
	InitCommand=function(self)
		for profile in ivalues(profile_data) do
			if profile.dir and profile.displayname then
				local path = GetAvatarPath(profile.dir, profile.displayname)

				if path then
					textures[profile.index] = path
				end
			end
		end
		self:visible(false)
	end
}

return textures