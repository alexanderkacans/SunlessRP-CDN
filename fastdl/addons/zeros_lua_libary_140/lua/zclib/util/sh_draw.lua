zclib = zclib or {}
zclib.util = zclib.util or {}

if CLIENT then
	function zclib.util.GetTextSize(txt,font)
		surface.SetFont(font)
		return surface.GetTextSize(txt)
	end

	function zclib.util.FontSwitch(txt,len,font01,font02)
		if zclib.util.GetTextSize(txt,font01) > len then
			return font02
		else
			return font01
		end
	end

	function zclib.util.DrawOutlinedBox(x, y, w, h, thickness, clr)
		surface.SetDrawColor(clr)

		for i = 0, thickness - 1 do
			surface.DrawOutlinedRect(x + i, y + i, w - i * 2, h - i * 2)
		end
	end

	function zclib.util.DrawBlur(p, a, d)
		local x, y = p:LocalToScreen(0, 0)

		surface.SetDrawColor(color_white)
		surface.SetMaterial(zclib.Materials.Get("blur"))

		for i = 1, d do
			zclib.Materials.Get("blur"):SetFloat("$blur", (i / d) * a)
			zclib.Materials.Get("blur"):Recompute()
			render.UpdateScreenEffectTexture()
			surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
		end
	end

	function zclib.util.DrawCircle( x, y, radius, seg )
		local cir = {}

		table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
		for i = 0, seg do
			local a = math.rad( ( i / seg ) * -360 )
			table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
		end

		local a = math.rad( 0 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

		surface.DrawPoly( cir )
	end

	function zclib.util.DrawCircleAdv(x, y, ang, seg, p, rad, color)
		local cirle = {}

		table.insert(cirle, {
			x = x,
			y = y
		})

		for i = 0, seg do
			local a = math.rad((i / seg) * -p + ang)

			table.insert(cirle, {
				x = x + math.sin(a) * rad,
				y = y + math.cos(a) * rad
			})
		end

		surface.SetDrawColor(color)
		draw.NoTexture()
		surface.DrawPoly(cirle)
	end

	// Draws a nice little info box at the specified position
	local InfoBox_offset = Vector(-250,40)
	function zclib.util.DrawInfoBox(pos,data)
		local lenght = 0
	    local txt

	    if data.txt01 and string.len(data.txt01) > lenght then
	        lenght = string.len(data.txt01)
	        txt = data.txt01
	    end

	    if data.txt02 and string.len(data.txt02) > lenght then
	        lenght = string.len(data.txt02)
	        txt = data.txt02
	    end

	    if data.txt03 and string.len(data.txt03) > lenght then
	        lenght = string.len(data.txt03)
	        txt = data.txt03
	    end

	    local tw, _ = zclib.util.GetTextSize(txt, zclib.GetFont("zclib_font_medium")) + 20 * zclib.wM
	    draw.RoundedBox(5, pos.x - (tw / 2) - (InfoBox_offset.x * zclib.wM), pos.y - (35 * zclib.hM) - (InfoBox_offset.y * zclib.hM), tw, 70 * zclib.hM, zclib.colors["black_a200"])

	    draw.SimpleText(data.txt01, zclib.GetFont("zclib_font_medium"), pos.x - (InfoBox_offset.x * zclib.wM), pos.y - (15 * zclib.hM) - (InfoBox_offset.y * zclib.hM), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

	    if data.txt02 then
	        draw.SimpleText(data.txt02, zclib.GetFont("zclib_font_medium"), pos.x - (InfoBox_offset.x * zclib.wM), pos.y + (15 * zclib.hM) - (InfoBox_offset.y * zclib.hM), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	    end

	    if data.txt03 then
	        draw.RoundedBox(5, pos.x + (tw / 2 + 10 * zclib.wM) - (InfoBox_offset.x * zclib.wM), pos.y - (20 * zclib.hM) - (InfoBox_offset.y * zclib.hM), 50 * zclib.wM, 40 * zclib.hM, zclib.colors["black_a200"])
	        draw.SimpleText(data.txt03, zclib.GetFont("zclib_font_medium"), pos.x - (InfoBox_offset.x * zclib.wM) + (tw / 2 + 10 * zclib.wM + 25 * zclib.wM), pos.y - (InfoBox_offset.y * zclib.hM), data.txt03_color or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	    end

	    if data.bar_fract then
	        draw.RoundedBox(5, pos.x - (tw / 2) - (InfoBox_offset.x * zclib.wM), pos.y - (50 * zclib.hM) - (InfoBox_offset.y * zclib.hM), tw, 10 * zclib.hM, zclib.colors["black_a200"])
	        draw.RoundedBox(5, pos.x - (tw / 2) - (InfoBox_offset.x * zclib.wM), pos.y - (50 * zclib.hM) - (InfoBox_offset.y * zclib.hM), tw * data.bar_fract, 10 * zclib.hM, zclib.util.LerpColor(data.bar_fract, data.bar_col01, data.bar_col02))
	    end

	    surface.SetDrawColor(data.color)
	    surface.SetMaterial(zclib.Materials.Get("infopointer"))
	    surface.DrawTexturedRect(pos.x - 10 * zclib.wM, pos.y, zclib.wM * 350, zclib.hM * 50)
	end
end

function zclib.util.ColorToVector(col)
	return Vector((1 / 255) * col.r, (1 / 255) * col.g, (1 / 255) * col.b)
end

function zclib.util.VectorToColor(vec)
	return Color((255 / 1) * vec.x, (255 / 1) * vec.y, (255 / 1) * vec.z)
end

function zclib.util.LerpColor(t, c1, c2)
	local c3 = Color(0, 0, 0)
	c3.r = Lerp(t, c1.r, c2.r)
	c3.g = Lerp(t, c1.g, c2.g)
	c3.b = Lerp(t, c1.b, c2.b)
	c3.a = Lerp(t, c1.a, c2.a)
	return c3
end
