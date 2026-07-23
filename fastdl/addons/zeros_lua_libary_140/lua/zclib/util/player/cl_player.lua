if SERVER then return end
// Sends a net msg to the server that the player has fully initialized and removes itself
zclib.Hook.Add("HUDPaint", "PlayerInit", function()

	// Tell the server that we just initialized
	net.Start("zclib_Player_Initialize")
	net.SendToServer()

	// I like to believe this var is used somewhere
	LocalPlayer().zclib_HasInitialized = true

	// Run a custom hook to inform any other clientside script that the players is now initialized
	hook.Run("zclib_PlayerInitialized")

	// Add the player himself to the player list
	zclib.Player.Add(LocalPlayer())

	// Forces zeros libary to reload its image service module
	timer.Simple(1,function() zclib.Imgur.Init() end)

	// Delete this hook now
	zclib.Hook.Remove("HUDPaint", "PlayerInit")
end)
