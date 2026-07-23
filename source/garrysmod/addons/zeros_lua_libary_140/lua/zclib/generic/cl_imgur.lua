if SERVER then return end

zclib = zclib or {}
zclib.Imgur = {}
zclib.Imgur.CachedMaterials = {}

/*

	A system that automaticly downloads Images from Image Sharing Service sites

*/

file.CreateDir("zclib")

function zclib.Imgur.Init()
	zclib.Debug("zclib.Imgur.Init")
	if file.Exists("zclib/" .. zclib.config.ActiveImageService, "DATA") == false then
		file.CreateDir("zclib/" .. zclib.config.ActiveImageService)
	end

	// Load the cached id list, if it exists
	zclib.Imgur.CachedImages = {}
	if file.Exists("zclib/" .. zclib.config.ActiveImageService .. "_cachedids.txt", "DATA") then

		// Load imgur id list
		zclib.Imgur.CachedImages = util.JSONToTable(file.Read("zclib/" .. zclib.config.ActiveImageService .. "_cachedids.txt", "DATA")) or {}

		// Check if the image id as lowercase id exists as png and if so then load it as material
		for imgurid, _ in pairs(zclib.Imgur.CachedImages) do
			if file.Exists("zclib/" .. zclib.config.ActiveImageService .. "/" .. string.lower(imgurid) .. ".png", "DATA") then
				zclib.Imgur.CachedMaterials[imgurid] = Material("data/zclib/" .. zclib.config.ActiveImageService .. "/" .. string.lower(imgurid) .. ".png", "smooth noclamp")
			end
		end
	end
end

function zclib.Imgur.GetMaterial(id, callback,retry_format)

	if id == nil then
		callback(false)
		return
	end

	if id == "" then
		callback(false)
		return
	end

	if id == " " then
		callback(false)
		return
	end


	//Here we check if the id allready exists in our cache
	if zclib.Imgur.CachedMaterials[id] then
        //zclib.Debug("Image already loaded, returning material, " .. tostring(zclib.Imgur.CachedMaterials[id]))
		callback(zclib.Imgur.CachedMaterials[id])
	else
		//If the image done exists in the cache then we check if the file is allready on the clients machine
		if file.Exists("zclib/" .. zclib.config.ActiveImageService .. "/" .. string.lower(id) .. ".png", "DATA") then
			zclib.Debug("File found, loading material then returning")

			//If its on the machine then we load it in to our cache
			zclib.Imgur.CachedMaterials[id] = Material("data/zclib/" .. zclib.config.ActiveImageService .. "/" .. string.lower(id) .. ".png", "smooth noclamp")
			callback(zclib.Imgur.CachedMaterials[id])
		else
			zclib.Debug("Failed to find image, attempting to load from " .. zclib.config.ActiveImageService .. " > " .. "zclib/" .. zclib.config.ActiveImageService .. "/" .. id .. ".png")

			//If the file does not exist then we load it from imgur and store the result in our cache
			//print("[" .. math.Round(CurTime(), 2) .. "][IMGUR] Fetching Image: " .. id)
			http.Fetch(zclib.config.ImageServices[zclib.config.ActiveImageService] .. id .. (retry_format or ".png"), function(img, len, headers, code)
				local filesize = len / 1000
				if filesize > zclib.config.ImageSizeLimit then
					callback(false)
				else

					// This makes sure the received data is a image
					if headers["Content-Type"] == "image/png" or headers["Content-Type"] == "image/jpeg" or headers["Content-Type"] == "image/jpg"  then
						zclib.Debug("Loaded Imgur Image : " .. id .. ".png")

						//print("[" .. math.Round(CurTime(), 2) .. "][IMGUR] Saving Image: " .. id)

						// Add original upper/lower case id to list
						zclib.Imgur.AddToImageCache(id)

						// Create image file , but its gonna be lowercase automaticly, thanks garry :(
						file.Write("zclib/" .. zclib.config.ActiveImageService .. "/" .. id .. ".png", img)

						// Cache lowercase material with original id
						zclib.Imgur.CachedMaterials[id] = Material("data/zclib/" .. zclib.config.ActiveImageService .. "/" .. id .. ".png", "smooth noclamp")

						callback(zclib.Imgur.CachedMaterials[id])
					else
						if retry_format == nil then
							zclib.Imgur.GetMaterial(id, callback,".jpg")
							return
						end
						callback(false)
					end
				end
			end, function()
				callback(false)
			end)
		end
	end
end

function zclib.Imgur.AddToImageCache(id)

	// Add id to list
	zclib.Imgur.CachedImages[id] = true

	// save to file
	file.Write("zclib/" .. zclib.config.ActiveImageService .. "_cachedids.txt", util.TableToJSON(zclib.Imgur.CachedImages,true))
end

zclib.Imgur.Init()

function zclib.Imgur.DeleteAllFiles(path)
	local files, directs = file.Find(path .. "/*", "DATA")

	-- Remove files
	for k, v in pairs(files) do
		if file.Exists(path .. "/" .. v, "DATA") then
			file.Delete(path .. "/" .. v)
		end
	end

	-- Remove directory
	file.Delete(path)

	for k, v in pairs(directs) do
		zclib.Snapshoter.DeleteAllFiles(path .. "/" .. v)
	end
end

concommand.Add("zclib_delete_imgur", function(ply, cmd, args)
	zclib.Imgur.DeleteAllFiles("zclib/imgur")
	file.Delete("zclib/imgur_cachedids.txt")

	zclib.Imgur.DeleteAllFiles("zclib/imgpile")
	file.Delete("zclib/imgpile_cachedids.txt")

	zclib.Imgur.CachedMaterials = {}
	zclib.Imgur.CachedImages = {}

	timer.Simple(1, function()
		notification.AddLegacy("Imgur cache removed!", NOTIFY_GENERIC, 4)
		surface.PlaySound("common/bugreporter_succeeded.wav")
	end)
end)
