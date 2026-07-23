if SERVER then return end
zclib = zclib or {}
zclib.vgui = zclib.vgui or {}

zclib.hM = ScrH() / 1080
zclib.wM = zclib.hM

// Lets update the WindowSize Multiplicator if teh ScreenSize got changed
zclib.Hook.Add("OnScreenSizeChanged", "VGUIScaleReset", function(oldWidth, oldHeight)
	zclib.hM = ScrH() / 1080
	zclib.wM = zclib.hM

	zclib.Print("ScreenSize changed, Recalculating ScreenSize values.")
end)

// Plays a interface sound
function zclib.vgui.PlaySound(sound)
	surface.PlaySound(sound)
end

// Creates a notify + sound according to what view the player currntly has
function zclib.vgui.Notify(msg,msgType)
	local s_sound = nil

	if msgType == NOTIFY_GENERIC then
		s_sound = "common/bugreporter_succeeded.wav"
	elseif msgType == NOTIFY_ERROR then
		s_sound = "common/warning.wav"
	elseif msgType == NOTIFY_HINT then
		s_sound = "buttons/button15.wav"
	end

	zclib.vgui.PlaySound(s_sound)

	if msg and string.len(msg) > 0 then
		local dur = 0.2 * string.len(msg)
		notification.AddLegacy(msg, msgType, dur)
	end
end

function zclib.vgui.TextButton(_x,_y,_w,_h,parent,data,action,IsLocked,IsSelected)
	/*
		data = {
			Text01 = "Off"
			color
			txt_color
			locked
		}
	*/
	local button_pnl = vgui.Create("DButton", parent)
	button_pnl:SetPos(_x * zclib.wM, _y * zclib.hM)
	button_pnl:SetSize(_w * zclib.wM, _h * zclib.hM)
	button_pnl:SetAutoDelete(true)
	button_pnl:SetText("")

	button_pnl.Text01 = data.Text01
	button_pnl.color = data.color or zclib.colors["ui01"]
	button_pnl.txt_color = data.txt_color or zclib.colors["text01"]
	button_pnl.txt_font = data.txt_font or zclib.GetFont("zclib_font_big")
	button_pnl.locked = false

	local txtW,txtH = zclib.util.GetTextSize(button_pnl.Text01,button_pnl.txt_font)
	button_pnl.txt_length = txtW
	button_pnl.txt_height = txtH

	local round = 5

	button_pnl.Paint = function(s, w, h)

		draw.RoundedBox(round, 0, 0, w, h, s.color)

		if IsSelected then
			local _, result = xpcall(IsSelected, function() end, nil)

			if result then
				draw.RoundedBox(8, 0, 0, 8 * zclib.wM, h, zclib.colors["green01"])
			end
		end

		if s.Text01 then
			draw.SimpleText(s.Text01, s.txt_font, w / 2, h / 2, s.txt_color, TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end

		if s.locked == true then
			draw.RoundedBox(round, 0, 0, w, h, zclib.colors["black_a100"])
		else
			if IsLocked then
				local _, varg = xpcall(IsLocked, function() end, s)
				if varg then
					draw.RoundedBox(round, 0, 0, w, h, zclib.colors["black_a100"])
				else
					if s:IsHovered() then
						draw.RoundedBox(round, 0, 0, w, h, zclib.colors["white_a15"])
					end
				end
			else
				if s:IsHovered() then
					draw.RoundedBox(round, 0, 0, w, h, zclib.colors["white_a15"])
				end
			end
		end
	end

	button_pnl.DoClick = function(s)
		if s.locked == true then return end
		local _, varg = xpcall(IsLocked, function() end, nil)
		if varg == true then return end
		zclib.vgui.PlaySound("UI/buttonclick.wav")
		pcall(action,button_pnl)
	end
	return button_pnl
end

function zclib.vgui.Slider(parent,text,start_val,onChange)

	local p = vgui.Create("DButton", parent)
	p:SetSize(200 * zclib.wM,50 * zclib.hM )
	p.locked = false
	p.slideValue = start_val
	p:SetAutoDelete(true)
	p:SetText("")
	p.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, zclib.colors["black_a50"])

		draw.SimpleText(text, zclib.GetFont("zclib_font_medium"),5 * zclib.wM, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

		draw.SimpleText(math.Round(s.slideValue * 100), zclib.GetFont("zclib_font_medium"),w - 5 * zclib.wM, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

		local AreaW = w * 0.5
		local AreaX = w * 0.35
		draw.RoundedBox(4, AreaX, h * 0.5, AreaW, 2 * zclib.hM, color_black)


		local boxHeight = h * 0.5
		local boxPosX = AreaW * s.slideValue
		draw.RoundedBox(4, (AreaX - (boxHeight / 2)) + boxPosX, boxHeight / 2, boxHeight, boxHeight, zclib.colors["ui01"])

		if p.locked == true then
			draw.RoundedBox(4, 0, 0, w, h, zclib.colors["black_a100"])
		end

		if s:IsDown() then
			local x,_ = s:CursorPos()
			local min = AreaX
			local max = min + AreaW

			x = math.Clamp(x, min, max)

			local val = (1 / AreaW) * (x - min)

			s.slideValue = math.Round(val,2)

			if s.slideValue ~= s.LastValue then
				s.LastValue = s.slideValue

				if s.locked == true then return end
				pcall(onChange,s.slideValue)
			end
			// 60 = 0
			// 230 = 1
		end
	end
	return p
end

function zclib.vgui.CheckBox(parent,text,state,onclick)

	local p = vgui.Create("DButton", parent)
	p:SetSize(200 * zclib.wM,50 * zclib.hM )
	p.locked = false
	p.state = state
	p.slideValue = 0
	p:SetAutoDelete(true)
	p:SetText("")
	p.Paint = function(s, w, h)
		//draw.RoundedBox(0, 0, 0, w, h, zclib.colors["ui01"])

		draw.RoundedBox(4, 0, 0, w, h, zclib.colors["black_a100"])

		//draw.SimpleText(text, zclib.GetFont("zclib_font_medium"),5 * zclib.wM, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)


		local BoxWidth = w
		local BoxHeight = h
		local BoxPosY = 0
		local BoxPosX = 0

		//draw.SimpleText(text, zclib.GetFont("zclib_font_medium"),w / 2, BoxHeight * 0.8, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		draw.RoundedBox(4, BoxPosX, BoxPosY, BoxWidth, BoxHeight, zclib.colors["black_a100"])

		if s.state then
			s.slideValue = Lerp(5 * FrameTime(), s.slideValue, 1)
		else
			s.slideValue = Lerp(5 * FrameTime(), s.slideValue, 0)
		end

		local col = zclib.util.LerpColor(s.slideValue, zclib.colors["ui01"], zclib.colors["green01"])
		draw.RoundedBox(4, BoxPosX + (BoxWidth-BoxHeight) * s.slideValue, BoxPosY, BoxHeight, BoxHeight, col)

		if p.locked == true then
			draw.RoundedBox(4, BoxPosX, BoxPosY, BoxWidth, BoxHeight, zclib.colors["black_a100"])
		end
	end
	p.DoClick = function(s)
		if p.locked == true then return end
		zclib.vgui.PlaySound("UI/buttonclick.wav")
		s.state = not s.state
		pcall(onclick,s.state)
	end
	return p
end

function zclib.vgui.ImageButton(_x,_y,_w,_h,parent,image,OnClick,IsLocked,SoundOverwrite)
	local Button = vgui.Create("DButton", parent)
	Button:SetPos(_x , _y )
	Button:SetSize(_w, _h)
	Button:SetText("")
	Button.IconColor = zclib.colors["text01"]
	Button.NoneHover_IconColor = zclib.colors["ui01"]
	Button.Sound = SoundOverwrite or "UI/buttonclick.wav"
	Button.IconImage = image
	Button.Paint = function(s, w, h)
		if IsLocked then
			local _, varg = xpcall(IsLocked, function() end, nil)
			if varg or s:IsEnabled() == false then
				zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2, zclib.colors["black_a50"])
				surface.SetDrawColor(zclib.colors["black_a50"])
				surface.SetMaterial(s.IconImage)
				surface.DrawTexturedRect(0, 0,w, h)
			else
				if s:IsHovered() then
					zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2, zclib.colors["text01"])
					surface.SetDrawColor(s.IconColor)
					surface.SetMaterial(s.IconImage)
					surface.DrawTexturedRect(0, 0,w, h)
				else
					zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2, s.NoneHover_IconColor)
					surface.SetDrawColor(s.NoneHover_IconColor)
					surface.SetMaterial(s.IconImage)
					surface.DrawTexturedRect(0, 0,w, h)
				end
			end
		else
			if s:IsHovered() then
				zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2, zclib.colors["text01"])
				surface.SetDrawColor(s.IconColor)
				surface.SetMaterial(s.IconImage)
				surface.DrawTexturedRect(0, 0,w, h)
			else
				zclib.util.DrawOutlinedBox(0 * zclib.wM, 0 * zclib.hM, w, h, 2, s.NoneHover_IconColor)
				surface.SetDrawColor(s.NoneHover_IconColor)
				surface.SetMaterial(s.IconImage)
				surface.DrawTexturedRect(0, 0,w, h)
			end
		end
	end
	Button.DoClick = function(s)

		local _, varg = xpcall(IsLocked, function() end, nil)
		if varg == true then return end

		zclib.vgui.PlaySound(s.Sound)

		s:SetEnabled(false)

		timer.Simple(0.25, function() if IsValid(s) then s:SetEnabled(true) end end)

		pcall(OnClick,s)
	end
	return Button
end

function zclib.vgui.TextEntry(parent, emptytext,onchange,hasrefreshbutton,onRefresh)
	local p = vgui.Create("DTextEntry", parent)
	p:SetSize(200 * zclib.wM,50 * zclib.hM )
	p:SetPaintBackground(false)
	p:SetAutoDelete(true)
	p:SetUpdateOnType(true)
	p.font = zclib.GetFont("zclib_font_small")
	p.bg_color = zclib.colors["ui01"]
	p.Emptytext = emptytext
	p.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, s.bg_color)
		//draw.RoundedBox(4, 0, 0, w, h, zclib.colors["red01"])

		if s:GetText() == "" and not s:IsEditing() then
			draw.SimpleText(s.Emptytext, s.font, 5 * zclib.wM, h / 2, zclib.colors["white_a15"], 0, 1)
		end

		s:DrawTextEntryText(color_white, zclib.colors["textentry"], color_white)
	end
	p:SetDrawLanguageID(false)
	p.OnValueChange = function(s,val)
		pcall(onchange,val)
	end

	function p:PerformLayout(width, height)
		self:SetFontInternal(self.font)
	end

	if hasrefreshbutton then
		local b = vgui.Create("DButton",p)
		b:SetText("")
		b:SetSize(50 * zclib.wM, 50 * zclib.hM )
		b:Dock(RIGHT)
		b.DoClick = function()
			onRefresh(p:GetText())
		end
		b.Paint = function(s, w, h)
			surface.SetDrawColor(zclib.colors["textentry"])
			surface.SetMaterial(zclib.Materials.Get("refresh"))
			surface.DrawTexturedRect(5 * zclib.wM, 5 * zclib.hM, h - 10 * zclib.hM,h - 10 * zclib.hM)
		end

		p.b = b

		timer.Simple(0,function()
			if IsValid(b) and IsValid(p) then
				b:SetPos(p:GetWide() - 50 * zclib.wM,0 * zclib.hM  )
			end
		end)
	end

	return p
end

function zclib.vgui.ModelPanel(data)
	local model_pnl = vgui.Create("DModelPanel")
	model_pnl:SetPos(0 * zclib.wM, 0 * zclib.hM)
	model_pnl:SetSize(50 * zclib.wM, 50 * zclib.hM)
	model_pnl:SetVisible(false)
	model_pnl:SetAutoDelete(true)
	model_pnl.LayoutEntity = function(self) end

	if data and data.model then

		model_pnl:SetModel(zclib.CacheModel(data.model))

		if not IsValid(model_pnl.Entity) then
			model_pnl:SetVisible(true)
			zclib.Print("Could not create DModel Panel, Clientmodel Limit reached?")
			return model_pnl
		end

		local min, max = model_pnl.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(min.x) + math.abs(max.x))
		size = math.max(size, math.abs(min.y) + math.abs(max.y))
		size = math.max(size, math.abs(min.z) + math.abs(max.z))

		// Force the model to look good, aka no lod reduction
		model_pnl.Entity:SetLOD( 0 )

		local rData = data.render

		local FOV = 35
		local x = 0
		local y = 0
		local z = 0
		local ang = Angle(0, 25, 0)
		local pos = vector_origin

		if rData then
			FOV = rData.FOV or 35
			x = rData.X or 0
			y = rData.Y or 0
			z = rData.Z or 0
			ang = rData.Angles or angle_zero
			pos = rData.Pos or vector_origin
		end

		model_pnl:SetFOV(FOV)
		model_pnl:SetCamPos(Vector(size + x, size + 30 + y, size + 5 + z))
		model_pnl:SetLookAt((min + max) * 0.5)

		if ang then
			model_pnl.Entity:SetAngles(ang)
		end

		if pos then
			model_pnl.Entity:SetPos(pos)
		end

		if data.color then
			model_pnl:SetColor(data.color)
		end

		if data.skin then
			model_pnl.Entity:SetSkin(data.skin)
		end

		if data.material then
			model_pnl.Entity:SetMaterial(data.material)
		end

		if data.anim then
			model_pnl:SetAnimated(true)
			model_pnl.Entity:SetSequence(data.anim)
			model_pnl:SetPlaybackRate(data.speed)
			model_pnl:RunAnimation()
		end

		if data.bodygroup then
			for k,v in pairs(data.bodygroup) do
				model_pnl.Entity:SetBodygroup(k,v)
			end
		end

		model_pnl:SetVisible(true)
	end

	return model_pnl
end

function zclib.vgui.DAdjustableModelPanel(data)
	local model_pnl = vgui.Create("DAdjustableModelPanel")
	model_pnl:SetPos(0 * zclib.wM, 0 * zclib.hM)
	model_pnl:SetSize(50 * zclib.wM, 50 * zclib.hM)
	model_pnl:SetVisible(false)
	model_pnl:SetAutoDelete(true)
	model_pnl.LayoutEntity = function(self) end

	if data and data.model then

		model_pnl:SetModel(zclib.CacheModel(data.model))

		if not IsValid(model_pnl.Entity) then
			model_pnl:SetVisible(true)
			zclib.Print("Could not create DModel Panel, Clientmodel Limit reached?")
			return model_pnl
		end

		local min, max = model_pnl.Entity:GetRenderBounds()
		local size = 0
		size = math.max(size, math.abs(min.x) + math.abs(max.x))
		size = math.max(size, math.abs(min.y) + math.abs(max.y))
		size = math.max(size, math.abs(min.z) + math.abs(max.z))

		// Force the model to look good, aka no lod reduction
		model_pnl.Entity:SetLOD( 0 )

		local rData = data.render

		local FOV = 35
		local x = 0
		local y = 0
		local z = 0
		local ang = Angle(0, 25, 0)
		local pos = vector_origin

		if rData then
			FOV = rData.FOV or 35
			x = rData.X or 0
			y = rData.Y or 0
			z = rData.Z or 0
			ang = rData.Angles or angle_zero
			pos = rData.Pos or vector_origin
		end

		model_pnl:SetFOV(FOV)
		model_pnl:SetCamPos(Vector(size + x, size + 30 + y, size + 5 + z))
		model_pnl:SetLookAt((min + max) * 0.5)

		if ang then
			model_pnl.Entity:SetAngles(ang)
		end

		if pos then
			model_pnl.Entity:SetPos(pos)
		end

		if data.color then
			model_pnl:SetColor(data.color)
		end

		if data.skin then
			model_pnl.Entity:SetSkin(data.skin)
		end

		if data.material then
			model_pnl.Entity:SetMaterial(data.material)
		end

		if data.anim then
			model_pnl:SetAnimated(true)
			model_pnl.Entity:SetSequence(data.anim)
			model_pnl:SetPlaybackRate(data.speed)
			model_pnl:RunAnimation()
		end

		if data.bodygroup then
			for k,v in pairs(data.bodygroup) do
				model_pnl.Entity:SetBodygroup(k,v)
			end
		end

		model_pnl:SetVisible(true)
	end

	return model_pnl
end



function zclib.vgui.Panel(parent, name)
	local m = vgui.Create("DPanel", parent)
	m:SetSize(600 * zclib.wM, 600 * zclib.hM)
	m:DockMargin(50 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)

	if name then
		m:DockPadding(0, 50 * zclib.hM, 0, 0)
	else
		m:DockPadding(0, 0 , 0, 0)
	end

	m:Dock(TOP)

	m.Title_text = name
	m.Title_font = zclib.GetFont("zclib_font_medium")
	m.Title_color = zclib.colors["orange01"]
	m.BG_color = zclib.colors["ui01"]

	m.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, s.BG_color)
		if s.Title_text then
			draw.SimpleText(s.Title_text, s.Title_font, 10 * zclib.wM, 10 * zclib.hM, s.Title_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end

	m:InvalidateLayout(true)
	m:InvalidateParent(true)

	return m
end

function zclib.vgui.ComboBox(parent,default,OnSelect)

    local DComboBox = vgui.Create( "DComboBox", parent )
    DComboBox:SetSize(200 * zclib.wM, 50 * zclib.hM)
    DComboBox:DockMargin(240 * zclib.wM,0 * zclib.hM,0 * zclib.wM,0 * zclib.hM)
    DComboBox:Dock(FILL)
    if default then DComboBox:SetValue(default) end
    DComboBox:SetColor(zclib.colors["text01"] )
    DComboBox.Paint = function(s, w, h) draw.RoundedBox(4, 0, 0, w, h, zclib.colors["black_a50"]) end
    DComboBox.OnSelect = function( s, index, value ,data_val) pcall(OnSelect,index,value,DComboBox,data_val) end

    return DComboBox
end

function zclib.vgui.Colormixer(parent,default,OnChange,OnValueChangeStop)
    local colmix = vgui.Create("DColorMixer", parent)
    colmix:SetSize(240 * zclib.wM, 100 * zclib.hM)
    colmix:DockMargin(10 * zclib.wM,40 * zclib.hM,10 * zclib.wM,0 * zclib.hM)
    colmix:Dock(FILL)
    colmix:SetPalette(false)
    colmix:SetAlphaBar(false)
    colmix:SetWangs(true)
    colmix:SetColor(default or color_white)
    colmix.ValueChanged = function(s,col)
        pcall(OnChange,col,s)

        zclib.Timer.Remove("zclib_colormixer_delay")
        zclib.Timer.Create("zclib_colormixer_delay",0.1,1,function()
            pcall(OnValueChangeStop,col,s)
        end)
    end

    return colmix
end

function zclib.vgui.Page(title, content, desc)
	if IsValid(zclib_main_panel) then zclib_main_panel:Remove() end

    local mainframe = vgui.Create("DFrame")
    mainframe:SetSize(1000 * zclib.wM, 800 * zclib.hM)
    mainframe:Center()
    mainframe:MakePopup()
    mainframe:ShowCloseButton(false)
    mainframe:SetTitle("")
    mainframe:SetDraggable(true)
    mainframe:SetSizable(false)
    mainframe:DockPadding(0, 15 * zclib.hM, 0, 30 * zclib.hM)

    mainframe.Paint = function(s, w, h)
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui02"])

        surface.SetMaterial(zclib.Materials.Get("grib_horizontal"))
        surface.SetDrawColor(zclib.colors["white_a5"])
        surface.DrawTexturedRectUV(0, 0, w, 20 * zclib.hM, 0, 0, w / (30 * zclib.hM), (20 * zclib.hM) / (20 * zclib.hM))

        if input.IsKeyDown(KEY_ESCAPE) and IsValid(mainframe) then
            mainframe:Close()
        end
    end

    zclib_main_panel = mainframe

	zclib_main_panel.Close = function()
		zclib.Inventory.RemoveSlotOptions()
		zclib.vgui.ActiveEntity = nil

		if IsValid(zclib_main_panel) then
			zclib_main_panel:Remove()
		end
	end

    local top_pnl = vgui.Create("DPanel", mainframe)
    top_pnl:SetSize(600 * zclib.wM, 80 * zclib.hM)
    top_pnl:Dock(TOP)
    top_pnl:DockPadding(10 * zclib.wM, 10 * zclib.hM, 10 * zclib.wM, 20 * zclib.hM)
    top_pnl:DockMargin(0 * zclib.wM, 0 * zclib.hM, 0 * zclib.wM, 10 * zclib.hM)
    top_pnl.Title_font = zclib.GetFont("zclib_font_big")
	top_pnl.title = title
    top_pnl.Paint = function(s, w, h)
        draw.RoundedBox(5, 50 * zclib.wM, h - 5 * zclib.hM, w, 5 * zclib.hM, zclib.colors["ui01"])

        if desc then
            draw.SimpleText(s.title, s.Title_font, 50 * zclib.wM, 30 * zclib.hM, zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(desc, zclib.GetFont("zclib_font_mediumsmall_thin"), 50 * zclib.wM, 60 * zclib.hM, zclib.colors["orange01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(s.title, s.Title_font, 50 * zclib.wM, 35 * zclib.hM, zclib.colors["text01"], TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
    end

    pcall(content, mainframe, top_pnl)

	mainframe:InvalidateLayout(true)
	mainframe:SizeToChildren(false,true)
	mainframe:Center()

	return mainframe
end

function zclib.vgui.AddSeperator(parent)
	local seperator = vgui.Create("DPanel", parent)
	seperator:SetSize(600 * zclib.wM, 5 * zclib.hM)
	seperator:Dock(TOP)
	seperator:DockMargin(50 * zclib.wM, 10 * zclib.hM, 50 * zclib.wM, 0 * zclib.hM)

	seperator.Paint = function(s, w, h)
		draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui01"])
	end

	return seperator
end

function zclib.vgui.List(parent)
	local scroll = vgui.Create("DScrollPanel", parent)
	scroll:Dock(FILL)
	scroll:DockMargin(10 * zclib.wM, 10 * zclib.hM, 10 * zclib.wM, 10 * zclib.hM)

	scroll.Paint = function(s, w, h)
		//draw.RoundedBox(0, 0, 0, w, h, zclib.colors["green01"])
	end

	local sbar = scroll:GetVBar()
	sbar:SetHideButtons(true)

	function sbar:Paint(w, h)
		draw.RoundedBox(5, w * 0.1, 0, w * 0.8, h, zclib.colors["black_a50"])
	end

	function sbar.btnUp:Paint(w, h)
	end

	function sbar.btnDown:Paint(w, h)
	end

	function sbar.btnGrip:Paint(w, h)
		draw.RoundedBox(5, w * 0.1, 0, w * 0.8, h, zclib.colors["text01"])
	end

	function scroll:JumpToChild(panel)
		self:InvalidateLayout(true)
		local _, y = self.pnlCanvas:GetChildPosition(panel)
		local _, h = panel:GetSize()
		y = y + h * 0.5
		y = y - self:GetTall() * 0.5
		self.VBar:AnimateTo(y, 0.01, 0, 0.5)
	end

	local list = vgui.Create("DIconLayout", scroll)
	list:Dock(FILL)
	list:SetSpaceY(10 * zclib.hM)
	list:SetSpaceX(10 * zclib.wM)
	list:DockMargin(10 * zclib.wM, 10 * zclib.hM, 10 * zclib.wM, 0 * zclib.hM)

	list.Paint = function(s, w, h)
		//draw.RoundedBox(0, 0, 0, w, h, zclib.colors["red01"])
	end

	list:Layout()

	return list, scroll
end
