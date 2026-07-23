zclib = zclib or {}
zclib.RenderData = zclib.RenderData or {}
zclib.Snapshoter = zclib.Snapshoter or {}

/*

    A advanced system which renders png images from models

*/

function zclib.RenderData.Add(class,data)
	zclib.RenderData[class] = data
end

function zclib.RenderData.Get(class)
	return zclib.RenderData[class]
end


// Keeps track on which items getting currently rendered
zclib.Snapshoter.RenderQueu = zclib.Snapshoter.RenderQueu or {}
zclib.Snapshoter.Cache = zclib.Snapshoter.Cache or {}
zclib.Snapshoter.Paths = zclib.Snapshoter.Paths or {}

function zclib.Snapshoter.SetPath(class,func)
	zclib.Snapshoter.Paths[class] = func
end

if CLIENT then
	file.CreateDir("zclib")
	file.CreateDir("zclib/img")

	function zclib.Snapshoter.GetPath(ItemData)
		local path
		local class = ItemData.Class or ItemData.class
		if zclib.Snapshoter.Paths[class] then
			path = zclib.Snapshoter.Paths[class](ItemData)
		else
			path = hook.Run("zclib_GetImagePath",ItemData)
		end
		return path or (ItemData.model .. "_" .. (ItemData.model_skin or 0))
	end

	local THUMBNAIL_IMAGE_CACHE_EXPIRES = 86400 -- 1 day, in seconds

	// Returns the snapshot from the model or adds the request to the render queu
	function zclib.Snapshoter.Get(ItemData, Panel)
		if ItemData == nil then return end
		if ItemData.model == nil then return end

		// Get the image path
		local img_path = zclib.Snapshoter.GetPath(ItemData)

		// Remove file extension
		img_path = string.Replace(img_path, ".mdl", "")

		// Do we already have this image cached?
		if zclib.Snapshoter.Cache[img_path] then
			//zclib.Debug("[CustomRenderSystem] Image already cached! [" .. tostring(img_path) .. "]")

			return "data/" .. zclib.Snapshoter.Cache[img_path]
		end

		// If the player does not have the model then lets display a error symbol
		if util.IsValidModel(ItemData.model) == false then
			zclib.Debug("[CustomRenderSystem] Model not precached! [" .. tostring(ItemData.model) .. "]")
			return "materials/zerochain/zerolib/ui/invalid.png"
		end

		// Does the image exist in the data folder? "data/zclib/img"
		if file.Exists("zclib/img/" .. img_path .. ".png", "DATA") then

			// If the file is older then this then remove it
			if os.time() - file.Time("zclib/img/" .. img_path .. ".png", "DATA") > THUMBNAIL_IMAGE_CACHE_EXPIRES then
				zclib.Snapshoter.DeleteFile(img_path)
			else
				zclib.Debug("[CustomRenderSystem] Image file already exists! [" .. tostring(img_path) .. "]")

				// Cache and return
				zclib.Snapshoter.Cache[img_path] = "zclib/img/" .. img_path .. ".png"

				return "data/" .. zclib.Snapshoter.Cache[img_path]
			end
		end

		// Add to render queue
		zclib.Snapshoter.Add(img_path, ItemData, Panel)
	end

	// Adds a new render job to the queue
	function zclib.Snapshoter.Add(img_path, ItemData, Panel)

		// Is the image already in the render queue?
		if zclib.Snapshoter.RenderQueu[img_path] then

			// Lets add the panel so it gets updated too
			table.insert(zclib.Snapshoter.RenderQueu[img_path].img_pnls, Panel)
			return
		end

		zclib.Snapshoter.RenderQueu[img_path] = {
			ItemData = ItemData,
			img_pnls = {Panel}
		}

		if zclib.Hook.Exist("PreDrawHUD", "zclib_RenderManager") then return end
		zclib.Snapshoter.Start()
	end

	// Assigns the finished rendered images from the last job to the panels who requested it
	function zclib.Snapshoter.AssignLastJob(LastJob)
		zclib.Debug("[CustomRenderSystem] [Finished Job] [" .. tostring(LastJob.img_path) .. "]")

		// Set the last rendered image to the provided panel if its still valid
		if LastJob.pnls and LastJob.img_path then
			for k, v in pairs(LastJob.pnls) do
				if not IsValid(v) then continue end
				local path = "data/zclib/img/" .. tostring(LastJob.img_path) .. ".png"
				timer.Simple(0, function()
					if IsValid(v) then
						v:SetMaterial(Material(path, "noclamp smooth"))
					end
				end)
			end
		end

		zclib.Debug("[CustomRenderSystem] [Assigning Image] [" .. tostring(LastJob.img_path) .. "]")

		// Cache the last rendered image
		if LastJob.img_path then
			zclib.Snapshoter.Cache[LastJob.img_path] = "zclib/img/" .. LastJob.img_path .. ".png"
		end

		// Reset
		LastJob = {}
	end

	// Start the render system
	function zclib.Snapshoter.Start()
		zclib.Debug("[CustomRenderSystem] Started!")
		local nextRender = CurTime() + 0.1
		local LastJob = {}

		// PreDrawHUD
		zclib.Hook.Add("PreDrawHUD", "zclib_RenderManager", function()
			//cam.Start3D()
			if CurTime() > nextRender then
				if zclib.Snapshoter.RenderQueu == nil then
					zclib.Snapshoter.Stop()
				end

				//Assigns the finished rendered images from the last job to the panels who requested it
				if LastJob and table.Count(LastJob) > 0 then
					zclib.Snapshoter.AssignLastJob(LastJob)
				end

				if table.Count(zclib.Snapshoter.RenderQueu) <= 0 then
					zclib.Snapshoter.Stop()
				end

				// Render the next item in the list
				for k, v in pairs(zclib.Snapshoter.RenderQueu) do

					// Store the current Render Job for next round
					LastJob.pnls = table.Copy(v.img_pnls)
					LastJob.img_path = k

					hook.Run("zclib_PreRenderStartProductImage",v.ItemData)

					// Render the image
					zclib.Snapshoter.Render(k, v.ItemData)

					// Delete the item from the queue
					zclib.Snapshoter.RenderQueu[k] = nil

					zclib.Debug("[CustomRenderSystem] [Started Job] [" .. k .. "]")

					nextRender = CurTime() + 0.1
					break
				end
			end
			//cam.End3D()
		end)
	end

	// Stop the render system
	function zclib.Snapshoter.Stop()
		zclib.Debug("[CustomRenderSystem] Stopped!")
		zclib.Hook.Remove("PreDrawHUD", "zclib_RenderManager")
	end

	// Give the RT a size
	local TEX_SIZE = 256
	local MaterialCache = {}
	function zclib.Snapshoter.DrawScene(TheEnt,ItemData)

	    local mul = 0.25

	    // Set up the lighting. This is over-bright on purpose - to make the ents pop
	    render.ResetModelLighting( 2 * mul, 2 * mul, 2 * mul )

	    render.SetModelLighting(0, 3 * mul, 3 * mul, 3 * mul)
	    render.SetModelLighting(1, 2 * mul, 2 * mul, 2 * mul)
	    render.SetModelLighting(2, 2 * mul, 2 * mul, 2 * mul)
	    render.SetModelLighting(3, 2 * mul, 2 * mul, 2 * mul)
	    render.SetModelLighting(4, 2 * mul, 2 * mul, 2 * mul)
	    render.SetModelLighting(5, 2 * mul, 2 * mul, 2 * mul)

		// Runs a custom hook to allow the rendered scene to be modified
	    hook.Run("zclib_RenderProductImage",TheEnt,ItemData)

	    if ItemData.model_color then
	        render.SetColorModulation(ItemData.model_color.r / 255, ItemData.model_color.g / 255, ItemData.model_color.b / 255, 255)
	    end

		if ItemData.model_material and ItemData.model_material ~= "" and ItemData.model_material ~= " " then
			if MaterialCache[ItemData.model_material] == nil then
				MaterialCache[ItemData.model_material] = Material(ItemData.model_material)
			end
			render.MaterialOverride(MaterialCache[ItemData.model_material])
		end

	    if ItemData.model_skin then
	        TheEnt:SetSkin(ItemData.model_skin)
	    end

	    if ItemData.model_bg then
	        for k, v in pairs(ItemData.model_bg) do
	            TheEnt:SetBodygroup(k, v)
	        end
	    end

	    local renderdata = zclib.RenderData.Get(ItemData.Class or ItemData.class)
	    local apos = Vector(0, 0, 0) - TheEnt:LocalToWorld(TheEnt:OBBCenter())
	    local ang = Angle(0, 0, 0)

		if renderdata then
			if renderdata.pos then
				apos = renderdata.pos
			end

			if renderdata.ang then
				ang = renderdata.ang
			end
		end

	    render.Model({
	        model = TheEnt:GetModel(),
	        pos = apos,
	        angle = ang
	    }, TheEnt)

	    // Runs a custom hook to allow the rendered scene to be modified
	    hook.Run("zclib_PostRenderProductImage",TheEnt,ItemData)
	end

	local pureBlack = Color(0,0,0,255)
	function zclib.Snapshoter.Render(img_path,ItemData)

		//render.Clear( 0,0,0, 255, true,true )

		// No engine lightning on the model please
		render.SuppressEngineLighting(true)

		// Disable alpha writing
		render.SetWriteDepthToDestAlpha( false )

		// https://wiki.facepunch.com/gmod/Enums/TEXTUREFLAGS
		local textureFlags = 0

		// TEXTUREFLAGS_TRILINEAR
		//textureFlags = textureFlags + 2

		// TEXTUREFLAGS_EIGHTBITALPHA
		//textureFlags = textureFlags + 8192

		// TEXTUREFLAGS_NOLOD
		//textureFlags = textureFlags + 512

		// TEXTUREFLAGS_CLAMPS
		//textureFlags = textureFlags + 4

		// TEXTUREFLAGS_CLAMPT
		//textureFlags = textureFlags + 8

		// TEXTUREFLAGS_NOMIP
		//textureFlags = textureFlags + 256

		// TEXTUREFLAGS_RENDERTARGET
		textureFlags = textureFlags + 32768

	    // Create / get the RT
	    local rt = GetRenderTargetEx("zclib_product_render", TEX_SIZE, TEX_SIZE, RT_SIZE_OFFSCREEN, MATERIAL_RT_DEPTH_ONLY, bit.bor(2,8192,512,4,8,256,32768), 0, IMAGE_FORMAT_RGBA8888) //[[IMPORTANT]]

	    render.ClearRenderTarget(rt, pureBlack)
		--render.Clear(255, 255, 255, 0, true, true)
		render.ClearDepth()

	    //
	    // Create a model
	    //
	    local TheEnt = zclib.ClientModel.Add(ItemData.model, RENDERGROUP_BOTH)
		if not IsValid(TheEnt) then return end
		TheEnt:SetLOD( 0 )

	    local min, max = TheEnt:GetRenderBounds()

	    local FOV = 10

	    //
	    // This is gonna take some cunning to look awesome!
	    //

	    local Size = max - min
	    local Radius = Size:Length() * 0.5
	    local CamDist = Radius / math.sin(math.rad(FOV) / 2) // Works out how far the camera has to be away based on radius + fov!
	    local Center = LerpVector(0.5, min, max)
	    local CamPos = Center + Vector(1,1, 0.5):GetNormal() * CamDist
	    local EyeAng = (Center - CamPos):GetNormal():Angle()

		local renderdata = zclib.RenderData.Get(ItemData.Class or ItemData.class)
		if renderdata then
			if renderdata.FOV then
				FOV = renderdata.FOV
			end

			if renderdata.CamPosOverwrite then
				CamPos = renderdata.CamPosOverwrite
			end
			if renderdata.EyeAngOverwrite then
				EyeAng = renderdata.EyeAngOverwrite
			end
		end

		local fov_overwrite = hook.Run("zclib_Snapshoter_Overwrite_FOV",ItemData)
		if fov_overwrite then
			FOV = fov_overwrite
		end

		local campos_overwrite = hook.Run("zclib_Snapshoter_Overwrite_CamPos",ItemData)
		if campos_overwrite then
			CamPos = campos_overwrite
		end

	    //
	    // The base view
	    //
	    local view = {
	        type = "3D",
	        origin = CamPos,
	        angles = EyeAng,
	        x = 0,
	        y = 0,
	        w = 256,
	        h = 256,
	        aspect = 1,
	        fov = FOV
	    }

	    // Lets define the render target
	    render.PushRenderTarget( rt )

			// Clear everything
			render.ClearDepth()
			render.Clear( 0, 0, 0, 0 )

	        // Dont ask why, this needs to be set to support alpha
	        render.OverrideAlphaWriteEnable( true, true )

	            //render.UpdateRefractTexture()

	            cam.Start(view)
				zclib.Snapshoter.DrawScene(TheEnt,ItemData)
	            cam.End()

				//render.UpdateRefractTexture()

	        render.OverrideAlphaWriteEnable( false )
		render.PopRenderTarget()

	    // Lets put the render target in to our current render call (whatever that means)
	    render.SetRenderTarget(rt)

	    local png_final = render.Capture({
	        format = "png",
	        x = 0,
	        y = 0,
	        w = TEX_SIZE,
	        h = TEX_SIZE,
	        alpha = true
	    })

	    // Remove the filename from the path
	    local segments = string.Explode( "/", img_path )
	    segments[#segments] = nil
	    segments = string.Implode("/",segments)

	    // Save image to file
	    file.CreateDir("zclib/img/" .. segments)
	    file.Write("zclib/img/" .. img_path .. ".png", png_final )

	    // Enable lighting again (or it will affect outside of this loop!)
	    render.SuppressEngineLighting(false)
	    render.SetWriteDepthToDestAlpha( true )
	    render.SetColorModulation(1, 1, 1, 1)
		render.MaterialOverride()
		render.MaterialOverrideByIndex()

	    // Remove the client ent again
	    TheEnt:Remove()
	end

	/*
		Deletes a single file from the machine and cache
	*/
	function zclib.Snapshoter.DeleteFile(path)
		file.Delete("zclib/img/" .. path .. ".png")
		zclib.Snapshoter.Cache[path] = nil
	end

	/*
		Deletes all files from the machine and cache
	*/
	function zclib.Snapshoter.DeleteAllFiles(path)
	    local files, directs = file.Find(path .. "/*", "DATA")
	    // Remove files
	    for k, v in pairs(files) do
	        if file.Exists(path .. "/" .. v, "DATA") then
	            file.Delete(path .. "/" .. v)
	        end
	    end

	    // Remove directory
	    file.Delete(path)

	    for k, v in pairs(directs) do
	        zclib.Snapshoter.DeleteAllFiles(path .. "/" .. v)
	    end

		zclib.Snapshoter.RenderQueu = {}
		zclib.Snapshoter.Cache = {}
	end

	concommand.Add("zclib_delete_thumbnails", function(ply, cmd, args)

	    // Delete any item thumbnails
	    zclib.Snapshoter.DeleteAllFiles("zclib/img")

	    timer.Simple(1, function()
	        notification.AddLegacy("Thumbnails removed!", NOTIFY_GENERIC, 4)
	        surface.PlaySound("common/bugreporter_succeeded.wav")
	    end)
	end)
end

if SERVER then
	// A system to force delete a certain image path or all files inside the folder
	util.AddNetworkString("zclib_snapshoter_Delete")
	net.Receive("zclib_snapshoter_Delete", function(len,ply)
		zclib.Debug_Net("zclib_snapshoter_Delete", len)

		// Only admins can force the clients to delete a image thumbnails
		if not zclib.Player.IsAdmin(ply) then return end

		local path = net.ReadString()
		zclib.Snapshoter.Delete(path)
	end)

	function zclib.Snapshoter.Delete(path)
		net.Start("zclib_snapshoter_Delete")
		net.WriteString(path)
		net.Broadcast()
	end
else

	// Lets remove any file older then 1 month
	local THUMBNAIL_IMAGE_CACHE_CLEANUP = 2678400
	zclib.Hook.Add("zclib_PlayerInitialized", "zclib_PlayerInitialized_filecleanup", function() zclib.Snapshoter.Cleanup("zclib/img") end)
	function zclib.Snapshoter.Cleanup(path)
		local files, directs = file.Find(path .. "/*", "DATA")
		// Remove files
		for k, v in pairs(files) do
			if file.Exists(path .. "/" .. v, "DATA") and os.time() - file.Time(path .. "/" .. v, "DATA") > THUMBNAIL_IMAGE_CACHE_CLEANUP then
				file.Delete(path .. "/" .. v)
			end
		end

		for k, v in pairs(directs) do
			zclib.Snapshoter.Cleanup(path .. "/" .. v)
		end
	end

	net.Receive("zclib_snapshoter_Delete", function(len)
		zclib.Debug_Net("zclib_snapshoter_Delete", len)
		local path = net.ReadString()

		zclib.Snapshoter.Delete(path)
	end)

	// Deletes the png on the specified path
	function zclib.Snapshoter.Delete(path,SendToServer)

		if file.IsDir( "zclib/img/" .. path, "DATA" ) then
			// Delete all files in that folder
			for k, v in pairs(file.Find("zclib/img/" .. path .. "/*", "DATA")) do
				local itm = string.sub(v, 1, string.len(v) - 4)
				zclib.Snapshoter.DeleteFile(path .. "/" .. itm)
			end
		else
			// Delete this single file
			zclib.Snapshoter.DeleteFile(path)
		end

		if SendToServer then
			net.Start("zclib_snapshoter_Delete")
			net.WriteString(path)
			net.SendToServer()
		end
	end
end
