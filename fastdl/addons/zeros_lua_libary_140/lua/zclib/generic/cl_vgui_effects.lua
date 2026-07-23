if SERVER then return end
zclib = zclib or {}
zclib.vgui = zclib.vgui or {}
zclib.vgui.EffectList = zclib.vgui.EffectList or {}

/*

	This system handles particle effects on vgui

*/

function zclib.vgui.AddEffect(id,effect, sound) zclib.vgui.EffectList[id] = {effect, sound} end

zclib.vgui.AddEffect("Destroy","zmb_vgui_destroy", "weapons/explode3.wav")
zclib.vgui.AddEffect("Magic","zmb_vgui_magic", "zerolib/gas_buff01.wav")
zclib.vgui.AddEffect("Repair","zmb_vgui_repair", "zerolib/building.wav")
zclib.vgui.AddEffect("Techno","zmb_vgui_techno", "zerolib/shoot.wav")
zclib.vgui.AddEffect("Use","zmb_vgui_use", "zerolib/throw01.wav")
zclib.vgui.AddEffect("Upgrade","zmb_vgui_upgrade", "zerolib/upgrade.wav")
zclib.vgui.AddEffect("Sell","zmb_vgui_sell", "zerolib/cash.wav")

zclib.vgui.AddEffect("firework_red","zmb_vgui_firework_red", "zerolib/firework01.wav")
zclib.vgui.AddEffect("firework_green","zmb_vgui_firework_green", "zerolib/firework02.wav")
zclib.vgui.AddEffect("firework_blue","zmb_vgui_firework_blue", "zerolib/firework01.wav")
zclib.vgui.AddEffect("firework_yellow","zmb_vgui_firework_yellow", "zerolib/firework02.wav")

/*
	Lets also add every single cached effect to the screen
*/
zclib.Hook.Add("zclib_OnParticleSystemPrecached", "zst_register_effect_for_vgui", function(effect)
	zclib.vgui.AddEffect(effect, effect)
end)

local EffectCache = {}
local ang = Angle(90, 0, -90)

local function StartRendering()
	zclib.Hook.Add("DrawOverlay", "zclib_vgui_effects", function()
		local ply = LocalPlayer()

		if IsValid(ply) and EffectCache and table.Count(EffectCache) > 0 then

			local w, h = ScrW(), ScrH()

			for k, v in pairs(EffectCache) do

				if v and IsValid(v.emitter) then

					local ortho = {
						top = (-h / 2) * v.distance,
						bottom = (h / 2) * v.distance,
						left = (-w / 2) * v.distance,
						right = (w / 2) * v.distance
					}

					cam.Start( { type = "3D", ortho = ortho, angles = ang } )
						v.emitter:Render()
					cam.End3D()
				else
					EffectCache[k] = nil
				end
			end
		else
			zclib.Hook.Remove("DrawOverlay", "zclib_vgui_effects")
		end
	end)
end

function zclib.vgui.PlayEffect(id, x, y,skipSound,distance)
	distance = distance or 1

	local e_Data = zclib.vgui.EffectList[id]
	zclib.vgui.CreateEffect(e_Data[ 1 ], Vector((x - (ScrW() / 2)) * distance, (-y + (ScrH() / 2)) * distance, 0), distance)
	if e_Data[2] and not skipSound then surface.PlaySound(e_Data[2]) end
end

function zclib.vgui.PlayEffectAtPanel(id, pnl, x, y,skipSound,distance)
	distance = distance or 1

	local pX, pY = pnl:GetPos()
	local cX, cY = pnl:GetParent():LocalToScreen(pX + (pnl:GetWide() / 2) + (x or 0), pY + (pnl:GetTall() / 2) + (y or 0))
	zclib.vgui.PlayEffect(id, cX, cY,skipSound,distance)
end

function zclib.vgui.CreateEffect(effect, pos,distance)
	local ply = LocalPlayer()
	local emitter = CreateParticleSystem(ply, effect, PATTACH_WORLDORIGIN, 0, pos)
	if IsValid(emitter) then
		emitter:SetShouldDraw(false)
		emitter:SetIsViewModelEffect(true)
		emitter:StartEmission(true)
		table.insert(EffectCache, {emitter = emitter,distance = distance or 1})
		StartRendering()
	end
end
