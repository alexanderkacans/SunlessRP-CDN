if not CLIENT then return end

zclib = zclib or {}
zclib.Settings = zclib.Settings or {}

local Created = false

function zclib.Settings.OptionPanel(name,desc,main_color,bg_color, CPanel, cmds)
	local panel = vgui.Create("DPanel")
	panel:Dock(FILL)
	panel.Paint = function(s, w, h)
		draw.RoundedBox(4, 0, 0, w, h, bg_color)
		zclib.util.DrawOutlinedBox( 0, 0, w, h, 4, zclib.colors["black_a100"])
	end
	panel:DockPadding(10,10,10,10)

	local title = vgui.Create("DLabel", panel)
	title:Dock(TOP)
	title:SetText(name)
	title:SetFont(zclib.GetFont("zclib_font_medium"))
	title:DockPadding(5,5,5,5)
	title:SetTextColor(color_white)
	title:SetTall(30)

	if desc then
		local desc_pnl = vgui.Create("DLabel", panel)
		desc_pnl:Dock(TOP)
		desc_pnl:SetText(desc)
		desc_pnl:SetFont(zclib.GetFont("zclib_font_small_thin"))
		desc_pnl:DockPadding(5,2,5,2)
		desc_pnl:SetTextColor(color_white)
		desc_pnl:SetContentAlignment(4)
		//desc_pnl:SetWrap(true)
		desc_pnl:SizeToContentsY( 5 )
	end

	for k, v in ipairs(cmds) do
		if v.class == "DNumSlider" then

			local item = vgui.Create("DNumSlider", panel)
			item:Dock(TOP)
			item:DockPadding(5,5,5,5)
			item:DockMargin(5,5,5,5)

			item:SetText(v.name)
			item:SetMin(v.min)
			item:SetMax(v.max)

			item:SetDecimals(v.decimal)
			item:SetDefaultValue(math.Clamp(math.Round(GetConVar(v.cmd):GetFloat(),v.decimal),v.min,v.max))
			item:ResetToDefaultValue()
			item:SetConVar( v.cmd )
			item.OnValueChanged = function(self, val)

				if v.RunOnChange then pcall(v.RunOnChange,val) end

				if Created then
					RunConsoleCommand(v.cmd, tostring(val))
				end
			end
		elseif v.class == "DCheckBoxLabel" then

			local item = vgui.Create("DCheckBoxLabel", panel)
			item:Dock(TOP)
			item:DockPadding(5,5,5,5)
			item:DockMargin(5,5,5,5)
			item:SetText( v.name )
			item:SetConVar( v.cmd )
			item.OnChange = function(self, val)

				if v.RunOnChange then pcall(v.RunOnChange,val) end

				if Created then
					if val then
						RunConsoleCommand(v.cmd, "1")
					else
						RunConsoleCommand(v.cmd, "0")
					end
				end
			end


			timer.Simple(0.1, function()
				if (item) then
					item:SetValue(GetConVar(v.cmd):GetInt())
				end
			end)
		elseif v.class == "DButton" then
			local item = vgui.Create("DButton", panel)
			item:Dock(TOP)
			item:DockMargin(0,10,0,0)
			item:SetText( v.name )
			item:SetFont(zclib.GetFont("zclib_font_small"))
			item:SetTextColor(color_white)
			item.Paint = function(s, w, h)
				draw.RoundedBox(4, 0, 0, w, h, main_color)
				if s.Hovered then
					draw.RoundedBox(4, 0, 0, w, h, zclib.colors["white_a15"])
				end
			end
			item.DoClick = function()

				// if zclib.Player.IsAdmin(LocalPlayer()) == false then return end

				LocalPlayer():EmitSound("zclib_ui_click")

				if v.notify then notification.AddLegacy(  v.notify, NOTIFY_GENERIC, 2 ) end
				LocalPlayer():ConCommand( v.cmd )
			end
		elseif v.class == "DColorMixer" then

			local main = vgui.Create("DPanel", panel)
			main:SetSize(200 * zclib.wM, 300 * zclib.hM)
			main:Dock(TOP)
			main:DockPadding(5, 5, 5, 5)
			main:DockMargin(5, 5, 5, 5)
			main.Paint = function(s, w, h)
				draw.RoundedBox(4, 0, 0, w, 5 * zclib.hM, zclib.colors["black_a100"])

				draw.RoundedBox(4, 0, h - 5 * zclib.hM, w, 5 * zclib.hM, zclib.colors["black_a100"])
			end

			local a_title = vgui.Create("DLabel", main)
			a_title:Dock(TOP)
			a_title:SetFont(zclib.GetFont("zclib_font_small"))
			a_title:SetText(v.name)
			a_title:SetTextColor(color_white)
			a_title:SetContentAlignment(4)
			a_title:SizeToContentsY( 10 )

			local Mixer = vgui.Create("DColorMixer", main)
			Mixer:SetSize(200 * zclib.wM, 200 * zclib.hM)
			Mixer:Dock(FILL)
			Mixer:DockMargin(0, 5, 0, 5)
			Mixer:SetPalette(false)
			Mixer:SetAlphaBar(true)
			Mixer:SetWangs(true)

			if v.cmd[1] then Mixer:SetConVarR(v.cmd[1]) end
			if v.cmd[2] then Mixer:SetConVarG(v.cmd[2]) end
			if v.cmd[3] then Mixer:SetConVarB(v.cmd[3]) end
			if v.cmd[4] then Mixer:SetConVarA(v.cmd[4]) end

			main:InvalidateParent(true)
			main:SizeToChildren(false,true)
		elseif v.class == "Custom" then
			pcall(v.content,panel)
		end

		if v.desc then
			local desc_pnl = vgui.Create("DLabel", panel)
			desc_pnl:Dock(TOP)
			desc_pnl:DockMargin(5,5,5,5)
			desc_pnl:SetFont(zclib.GetFont("zclib_font_small_thin"))
			desc_pnl:SetText(v.desc)
			desc_pnl:SetTextColor(color_white)
			desc_pnl:SetContentAlignment(7)
			desc_pnl:SizeToContentsY( 30 )
			desc_pnl:SetWrap(true)


			// Only create a seperation line if we got another item after this
			if cmds[k + 1] then
				local line = vgui.Create("DPanel",panel)
				line:Dock(TOP)
				line:DockMargin(5,5,5,5)
				line:SetTall(4)
				line.Paint = function(s, w, h)
					draw.RoundedBox(0, 0, 0, w, h, zclib.colors["black_a100"])
				end
			end
		end
	end


	panel:InvalidateLayout(true)
	panel:SizeToChildren(true, true)

	CPanel:AddPanel(panel)
end

hook.Add("AddToolMenuCategories", "zclib_CreateCategories", function()
	spawnmenu.AddToolCategory("Options", "zclib_options", "Zeros Libary")
end)

hook.Add("PopulateToolMenu", "zclib_PopulateMenus", function()

	timer.Simple(0.2, function()
		Created = true
	end)

	spawnmenu.AddToolMenuOption("Options", "zclib_options", "zclib_Client_Settings", "Client Settings", "", "", function(CPanel)
		zclib.Settings.OptionPanel("Thumbnail Cache", nil, Color(82, 131, 198, 255), zclib.colors["ui02"], CPanel, {
			[1] = {
				name = "Delete Thumbnail Cache",
				desc = "Deletes any model thumbnails found at garrysmod/data/zclib/img",
				class = "DButton",
				cmd = "zclib_delete_thumbnails"
			}
		})

		zclib.Settings.OptionPanel("Imgur Cache", nil, Color(82, 131, 198, 255), zclib.colors["ui02"], CPanel, {
			[1] = {
				name = "Delete Imgur Cache",
				desc = "Deletes any images found at garrysmod/data/zclib/imgur",
				class = "DButton",
				cmd = "zclib_delete_imgur"
			}
		})

		zclib.Settings.OptionPanel("Other", nil, Color(82, 131, 198, 255), zclib.colors[ "ui02" ], CPanel, {
			[ 1 ] = {
				name = "Particle Effects",
				class = "DCheckBoxLabel",
				cmd = "zclib_cl_particleeffects"
			},
			[ 2 ] = {
				name = "Draw UI",
				class = "DCheckBoxLabel",
				cmd = "zclib_cl_drawui"
			},
			[ 3 ] = {
				name = "Dynamic Light",
				class = "DCheckBoxLabel",
				cmd = "zclib_cl_vfx_dynamiclight"
			},
			[ 4 ] = {
				name = "Volume",
				class = "DNumSlider",
				min = 0,
				max = 1,
				decimal = 2,
				cmd = "zclib_cl_sfx_volume"
			},
		})
	end)
end)
