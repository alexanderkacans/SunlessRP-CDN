local PANEL = {}

function PANEL:Init()
	self.avatar = vgui.Create( "AvatarImage", self )
	self.avatar:SetPaintedManually( true )
end

function PANEL:PerformLayout()
	self.avatar:SetSize( self:GetWide(), self:GetTall() )
end

function PANEL:SetPlayer( ply, size )
	self.avatar:SetPlayer( ply, size )
end

function PANEL:SetSteamID( steamID, size )
	self.avatar:SetSteamID( steamID, size )
end

-- Credits: https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/draw.lua, https://gist.github.com/MysteryPancake/e8d367988ef05e59843f669566a9a59f

local whiteColor = Color( 255, 255, 255 )
local renderTarget, previousRenderTarget
function PANEL:Paint( w, h )
	if( not renderTarget ) then
		renderTarget = GetRenderTargetEx( "BRS_GRADIENT_ROUNDEDAVATAR", ScrW(), ScrH(), RT_SIZE_FULL_FRAME_BUFFER, MATERIAL_RT_DEPTH_NONE, 2, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888 )
	end

	if( not previousRenderTarget ) then
		previousRenderTarget = render.GetRenderTarget() 
	end

	render.PushRenderTarget( renderTarget )
	render.OverrideAlphaWriteEnable( true, true )
	render.Clear( 0, 0, 0, 0 ) 

	self.avatar:PaintManual()

	--Draw the mask
	render.OverrideBlendFunc( true, BLEND_ZERO, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLEND_ZERO )
	draw.RoundedBox( (self.rounded or 0), 0, 0, w, h, whiteColor )
	render.OverrideBlendFunc( false )
	render.OverrideAlphaWriteEnable( false )
	render.PopRenderTarget() 

	--Update material
	BRICKS_SERVER.MaskMaterial:SetTexture( "$basetexture", renderTarget )

	--Clear material for upcoming draw calls
	draw.NoTexture()

	surface.SetDrawColor( 255, 255, 255, 255 ) 
	surface.SetMaterial( BRICKS_SERVER.MaskMaterial ) 
	render.SetMaterial( BRICKS_SERVER.MaskMaterial )
	render.DrawScreenQuad() 
end
 
vgui.Register( "bricks_server_rounded_avatar", PANEL )