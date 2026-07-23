zclib = zclib or {}
zclib.PanelNotify = zclib.PanelNotify or {}

/*

	Creates a notify box over the currently opend zclib window, otherwise creates a normal notify

*/

if SERVER then
	util.AddNetworkString("zclib.Notify.Create")
	function zclib.PanelNotify.Create(ply,msg,msgType)
		net.Start("zclib.Notify.Create")
		net.WriteString(msg)
		net.WriteUInt(msgType,10)
		net.Send(ply)
	end
else
	net.Receive("zclib.Notify.Create", function(len,ply)
		zclib.Debug_Net("zclib.Notify.Create", len)

		local msg = net.ReadString()
		local msgType = net.ReadUInt(10)

		if IsValid(zclib_main_panel) then
			zclib.PanelNotify.Create(LocalPlayer(),msg,msgType)
		else
			zclib.vgui.Notify(msg,msgType)
		end
	end)

	function zclib.PanelNotify.Create(ply,msg,msgtype)

		local dur = 4
		local pnl = zclib_main_panel

		if not IsValid(pnl) then return end

	    if IsValid(pnl.NotifyPanel) then
	        pnl.NotifyPanel:Remove()
	    end

	    local s_sound = "common/bugreporter_succeeded.wav"
	    local mat_icon = zclib.Materials.Get("info")
		local mat_color = color_white
	    if msgtype == NOTIFY_GENERIC then
	        s_sound = "common/bugreporter_succeeded.wav"
	        mat_icon = zclib.Materials.Get("info")
	    elseif msgtype == NOTIFY_ERROR then
	        s_sound = "common/warning.wav"
	        mat_icon = zclib.Materials.Get("close")
			mat_color = zclib.colors["red01"]
	    elseif msgtype == NOTIFY_HINT then
	        s_sound = "buttons/button15.wav"
	        mat_icon = zclib.Materials.Get("info")
	    end
	    zclib.vgui.PlaySound(s_sound)

	    local x,y = pnl:GetPos()

	    local p = vgui.Create("DPanel")

		// come from behind, go up
		p:SetPos(x,y)
		p:MoveTo(x,y - 55 * zclib.hM,0.25,0,1,function()
			if IsValid(p) then p:AlphaTo(0,1,dur,function() if IsValid(p) then p:Remove() end end) end
		end)

	    p:SetSize(600 * zclib.wM,50 * zclib.hM)
	    p:SetAutoDelete(true)
	    p:ParentToHUD()
	    p:SetDrawOnTop(false)
	    p.Paint = function(s, w, h)
	        draw.RoundedBox(0, 0, 0, w, h, zclib.colors["ui02"])
	        zclib.util.DrawOutlinedBox(0, 0, w, h, 3, zclib.colors["black_a100"])
	    end


	    local p_icon = vgui.Create("DPanel", p)
	    p_icon:SetPos(0 * zclib.wM,0 * zclib.hM)
	    p_icon:SetSize(50 * zclib.wM,50 * zclib.hM)
	    p_icon.Paint = function(s, w, h)
	        surface.SetDrawColor(mat_color)
	        surface.SetMaterial(mat_icon)
	        surface.DrawTexturedRectRotated(w/2, h/2, w * 0.9, w * 0.9,0)
	    end
	    p_icon:Dock(LEFT)

	    local p_lbl = vgui.Create("DLabel", p)
	    p_lbl:SetPos(0 * zclib.wM,0 * zclib.hM)
	    p_lbl:SetSize(600 * zclib.wM,50 * zclib.hM)
	    p_lbl.Paint = function(s, w, h) end
	    p_lbl:SetText(msg)
	    p_lbl:SetTextColor(zclib.colors["text01"])
	    p_lbl:SetFont(zclib.GetFont("zclib_font_medium"))
	    p_lbl:SetContentAlignment(4)
	    p_lbl:SizeToContentsX( 15 * zclib.wM )
	    p_lbl:Dock(LEFT)

	    p:InvalidateChildren(true)
	    p:SizeToChildren(true,false)

	    pnl.NotifyPanel = p

	    // Here we attach the notify to the on remove function, so it gets cleaned up
	    if pnl.NotifyCleanup == nil then
	        pnl.NotifyCleanup = function()
	            local oldRemove = pnl.OnRemove
	            function pnl:OnRemove()
	                pcall(oldRemove)
	                if IsValid(self.NotifyPanel) then self.NotifyPanel:Remove() end
	            end
	        end
	        pnl.NotifyCleanup()
	    end
	end
end
