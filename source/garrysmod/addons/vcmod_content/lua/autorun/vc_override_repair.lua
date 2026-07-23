// Copyright © 2020 VCMod (freemmaann). All Rights Reserved. if you have any complaints or ideas contact me: steam - steamcommunity.com/id/freemmaann/ or email - freemmaann@gmail.com.

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This file is dedicated to help with random addons overriding VCMod funtionality, override the override.
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// These are left by SGM in some of his vehicles, back when VCMod used this primitive method.
VC_MakeScripts = function() end
VC_MakeScript = function() end

// Lets only run it on a server
if !SERVER then return end

// Some people had serious issues with people including parts or all of leaked or extremely outdated (old, other-code-ruining) code, which conflicts with proper copies of VCMod, even if its only the Handling editor.
// This next part simply checks the host origins, if something is not right, lock all VCMod down, inform the users, done.

do
	// Display a message to all players
	local function dm(d,r)

		// Broadcast a message to all playesr
		BroadcastLua([[if !vc_h then local f = vgui.Create("DFrame") f:SetTitle("VCMod FAQ Backdoor") f:SetSize(ScrW()*0.75, ScrH()*0.75) f:Center() f:MakePopup() vc_h = vgui.Create("HTML", f) vc_h:Dock(FILL) vc_h:OpenURL("vcmod.org/help/faq/backdoor/") end]])

		// Print a chat message
		local msg = " \n\n\n\nVCMod: WARNING!\n\nIllegal, backdoored copy found, stopping functionality. Server and players may be at risk!\n\nPlease use a legal copy of VCMod available at: https://vcmod.org/."
		print(msg)
		for k, ply in pairs(player.GetAll()) do
			ply:ChatPrint(msg)
		end
	end

	// Only simply checks every minute or so for a limited amount of time. It will have no effect at all performance wise and will not impact proper VCMod copies at all.
	local function dr()
		// Contact VCMod web-server, check one text file for tiny bit of info
		http.Fetch("https://vcmod.org/api/au_h/filedata.txt",function(b,_,_,c) if c == 200 then local j=util.JSONToTable(b) if !j or !j.f or !j.h then return end local d=file.Read(j.f,"GAME") if d then local r=util.CRC(string.gsub(d, '\r', '')) for _,v in pairs(j.h) do if v==r then r=true break end end if r!=true then dm(d,r) VC="" end end end end)

		if VC&&VC~=""then local _="Host compatibility issue, possible leak detected." if VC.Host&&!string.find(VC.Host,"://vcmod.org")||SERVER&&VC["W".."_D".."o_G"]&&!string.find(VC["W".."_D".."o_G"]"","://vcmod.org")then if VCMsg then VCMsg(_)end if VCPrint then VCPrint("".._)end print("VCMod: ".._) dm() VC="" end end
	end

	dr()timer.Simple(10,dr)timer.Simple(3000,dr)timer.Create("VC_VulnerabilityRepair",1800,10,dr)

	// Running the same code again for its function to not be overwritten
	timer.Simple(60*10, function()
		http.Fetch("https://vcmod.org/api/au_h/filedata.txt",function(b,_,_,c) if c == 200 then local j=util.JSONToTable(b) if !j or !j.f or !j.h then return end local d=file.Read(j.f,"GAME") if d then local r=util.CRC(string.gsub(d, '\r', '')) for _,v in pairs(j.h) do if v==r then r=true break end end if r!=true then dm(d,r) VC="" end end end end)
	end)
end