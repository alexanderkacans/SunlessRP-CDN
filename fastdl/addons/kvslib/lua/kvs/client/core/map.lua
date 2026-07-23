local folderTarget = "kvsmap"
local formattedIP

local function formatIP( IP )
	return string.Replace( IP, ":", "_" )
end

KVS = KVS or {}
KVS.Minimap = KVS.Minimap or {}
KVS.Minimap.Config = {
	[ "rp_downtown_tits_v2" ] = {
		centerPosition = Vector( 4400, -2000, 12191 ),
		zNear = 0,
		zFar = 20000,
		zoom = 21000,
		backgroundColor = Color( 100, 200, 250 )
	},
	[ "rp_glife_rockford3" ] = {
		centerPosition = Vector( 1386.000000, 4206.481445, 1894.000000),
		zNear = 0,
		zFar = 20000,
		zoom = 30000,
		backgroundColor = Color( 100, 200, 250 )
	},
	[ "rp_newexton2_v4h" ] = {
		centerPosition = Vector(-32,96, 1066),
		zNear = 0,
		zFar = 7000,
		zoom = 30000,
		backgroundColor = Color( 100, 200, 250 )
	}
}


function KVS.Minimap.GetMapValues()
	if KVS.Minimap.Config[ game.GetMap() ] then
		local tCfg = KVS.Minimap.Config[ game.GetMap() ]

		return tCfg.backgroundColor, tCfg.centerPosition, tCfg.zNear, tCfg.zFar, tCfg.zoom
	end

	local vMin, vMax = game.GetWorld():GetModelBounds()

	local centerPosition = vMax + vMin
	centerPosition.z = vMax.z

	return Color( 100, 200, 250 ), centerPosition, 0, vMax.z, vMin:Distance( vMax )
end

function KVS.Minimap.VectorToPos( vPos, iSizeX, iSizeY )
	local cBackgroundColor, vCenter, iZnear, iZfar, iZoom = KVS.Minimap.GetMapValues()

	local min, max = vCenter + Vector( -iZoom/2, iZoom/2, 0 ), vCenter + Vector( iZoom/2, -iZoom/2, 0 )

	local pos_x = ( vPos.x - min.x ) / ( max.x - min.x )
	local pos_y = ( vPos.y - min.y ) / ( max.y - min.y )


	return iSizeX * pos_x, iSizeY * pos_y
end

concommand.Add( "manage_map", function()
	hook.Add( "PostDrawViewModel", "MapGeneration.PostDrawViewModel.ManageMap", function()
		local cBackgroundColor, vCenter, iZnear, iZfar, iZoom = KVS.Minimap.GetMapValues()
		render.Clear( cBackgroundColor.r, cBackgroundColor.g, cBackgroundColor.b, cBackgroundColor.a, true, true )

		render.SuppressEngineLighting( true )
		render.SetShadowsDisabled( true )
		render.PushFlashlightMode( false )
		render.PushFilterMag( TEXFILTER.NONE )
		render.PushFilterMin( TEXFILTER.NONE )
			
		render.RenderView( {
			origin = vCenter,
			angles = Angle( 90, 90, 0 ),
			x = 0,
			y = 0,
			w = ScrH(),
			h = ScrH(),
			znear = iZnear,
			zfar = iZfar,
			bloomtone = false,
			drawviewmodel = false,
			drawmonitors = false,
			drawhud = false,
			ortho = true,
			ortholeft = -iZoom / 2,
			orthotop = -iZoom / 2,
			orthoright = iZoom / 2,
			orthobottom = iZoom / 2,
		} )

		render.PopFilterMin()
		render.PopFilterMag()
		render.PopFlashlightMode()
		render.SetShadowsDisabled(false)
		render.SuppressEngineLighting(false)
	end )
end )

local function RebuildMapImage(w, h)
	local cBackgroundColor, vCenter, iZnear, iZfar, iZoom = KVS.Minimap.GetMapValues()
	render.Clear( cBackgroundColor.r, cBackgroundColor.g, cBackgroundColor.b, cBackgroundColor.a, true, true )

	render.SuppressEngineLighting( true )
	render.SetShadowsDisabled( true )
	render.PushFlashlightMode( false )
	render.PushFilterMag( TEXFILTER.NONE )
	render.PushFilterMin( TEXFILTER.NONE )
		
	render.RenderView( {
		origin = vCenter,
		angles = Angle( 90, 90, 0 ),
		x = 0,
		y = 0,
		w = w,
		h = h,
		znear = iZnear,
		zfar = iZfar,
		bloomtone = false,
		drawviewmodel = false,
		drawmonitors = false,
		drawhud = false,
		ortho = true,
		ortholeft = -iZoom / 2,
		orthotop = -iZoom / 2,
		orthoright = iZoom / 2,
		orthobottom = iZoom / 2,
	} )

	render.PopFilterMin()
	render.PopFilterMag()
	render.PopFlashlightMode()
	render.SetShadowsDisabled(false)
	render.SuppressEngineLighting(false)

	local tbl = render.Capture( {
		format = "jpeg",
		quality = 100,
		w = w, 
		h = h,
		x = 0,
		y = 0
	} )

	local image = file.Open( folderTarget .. "/" .. formattedIP .. "/" .. game.GetMap() .. ".jpg", "wb", "DATA" )
	if not image then return false end
	image:Write( tbl )
	image:Close()

	return true 
end

local function GenerateMap()
	if not file.IsDir( folderTarget, "DATA") then
		file.CreateDir( folderTarget )
	end
	if not file.IsDir( folderTarget .. "/" .. formattedIP, "DATA") then
		file.CreateDir( folderTarget .. "/" .. formattedIP )
	end

	hook.Add( "PostDrawViewModel", "MapGeneration.PostDrawViewModel", function()
		if not hook.GetTable()[ "PreDrawOpaqueRenderables" ] or not hook.GetTable()[ "PreDrawOpaqueRenderables" ][ "MapGeneration.PreDrawOpaqueRenderables" ] then
			-- Hide evrything on the map with these hooks
			hook.Add( "PreDrawOpaqueRenderables", "MapGeneration.PreDrawOpaqueRenderables", function() 
				return true 
			end )
			hook.Add( "PreDrawTranslucentRenderables", "MapGeneration.PreDrawTranslucentRenderables", function() 
				return true
			end )
		else
			local minSize = math.min( ScrW(), ScrH() )
			local buildMap = RebuildMapImage( minSize, minSize )

			if buildMap then
				hook.Remove( "PostDrawViewModel", "MapGeneration.PostDrawViewModel" )
				hook.Remove( "PreDrawOpaqueRenderables", "MapGeneration.PreDrawOpaqueRenderables" )
				hook.Remove( "PreDrawTranslucentRenderables", "MapGeneration.PreDrawTranslucentRenderables" )
			end
		end
	end )
end

local mapImage = nil
function KVS.Minimap.GetGameMapImage()
	formattedIP = formattedIP or formatIP( game.GetIPAddress() )

	if not formattedIP then timer.Simple( 1, function() KVS.Minimap.GetGameMapImage() end ) return end

	if mapImage then
		return mapImage
	elseif file.Exists( folderTarget .. "/" .. formattedIP .. "/" .. game.GetMap() .. ".jpg", "DATA" ) then
		local mapPath = "data/" .. folderTarget .. "/" .. formattedIP .. "/" .. game.GetMap() .. ".jpg"
		mapImage = Material( mapPath )
		return mapImage
	else
		GenerateMap()
		return false
	end
end

KVS.Minimap.GetGameMapImage()