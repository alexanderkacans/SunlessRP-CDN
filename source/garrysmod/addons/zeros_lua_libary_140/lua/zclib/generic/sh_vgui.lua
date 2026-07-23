zclib = zclib or {}
zclib.vgui = zclib.vgui or {}

if SERVER then
    // Forces the interface to be closed
    util.AddNetworkString("zclib_vgui_forceclose")
    function zclib.vgui.ForceClose(ply,identifier)
        // Only DFrames which have this value will be removed > identifier
    	net.Start("zclib_vgui_forceclose")
        net.WriteUInt(identifier,32)
    	net.Send(ply)
    end

    function zclib.vgui.ForceCloseAll(identifier)
        net.Start("zclib_vgui_forceclose")
        net.WriteUInt(identifier,32)
        net.Broadcast()
    end
else
    function zclib.vgui.ForceClose(identifier)
        if IsValid(zclib_main_panel) then

            // If this interace doesent have the same identifier then stop
            if identifier and zclib_main_panel[identifier] == nil then return end

            zclib_main_panel:Close()
        end
    end

    net.Receive("zclib_vgui_forceclose", function(len)
        local identifier = net.ReadUInt(32)
        zclib.vgui.ForceClose(identifier)
    end)
end
