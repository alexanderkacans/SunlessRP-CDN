zclib = zclib or {}
zclib.config = zclib.config or {}

// Used for debugging the script
zclib.config.Debug = false

zclib.config.NoPrint = true

// By default i disable the net track system since if it doesent find any supported script hook then its gonna overwrite the net.Incoming function which could cause problems for other scripts who overwrite this too.
// Currently Supported Scripts: eProtect(eP:PreNetworking)
zclib.config.NetTrack = false

// The Currency
zclib.config.Currency = "$"

// Should the Currency symbol be in front or after the money value?
zclib.config.CurrencyInvert = true

// These Ranks are admins
// If xAdmin, sAdmin or SAM is installed then this table can be ignored
zclib.config.AdminRanks = {
	["owner"] = true,
	["superadmin"] = true,
	["Super Admin"] = true,
}


// The path from which we try to download the uploaded image
// Examble https://i.imgur.com/ == https://i.imgur.com/imageid.png
zclib.config.ImageSizeLimit = 5000
zclib.config.ImageServices = {
	["imgur"] = "https://i.imgur.com/",
	["imgpile"] = "https://imgpile.com/images/"
}

// zclib.config.ImageServices["folder"] = "https://AdresseToImage/"
/*
	Examble:
		Addresse to a imagefile: > https://imgpile.com/images/nnHvi2.jpg
		ImageService would be that > zclib.config.ImageServices["imgpile"] = "https://imgpile.com/images/"
		ImageID would be that > nnHvi2
*/

zclib.config.ActiveImageService = "imgur"


zclib.config.Police = {
	Jobs = {}
}

zclib.config.CleanUp = {
	SkipOnTeamChange = {}
}
//zclib.config.CleanUp.SkipOnTeamChange[TEAM_STAFF] = true

zclib.config.Inventory = {

	// If set to true then the player will get his own inventory assigned on join
	PlayerInv = false,

	// If true then items that can be picked up in the inventory will be displayed
	ShowItemPickup = false,

	// Should we drop all the players inventory in a bag once he dies?
	DropOnDeath = false,

	// What entities can be stored inside the inventory
	// NOTE Some entities will need a custom module in order to save / load all its data correctly
	AllowedItems = {
		"prop_physics",
		"weapon_",
		"weapons_",
		"durgz_",
		"drug_",
		"drugs_",
		"item_health",
		"item_battery",
		"item_ammo",
		"item_box",
		"item_rpg_round",
		"spawned_shipment",
		"spawned_weapon",
		"spawned_food",
		"food",
		"spawned_ammo",
		"m9k_",
		"ls_sniper",
		"bb_",
		"manhack_welder",
		"tfa_",
		"zss_mine",
		"combine_mine",
	},

	// Entities which we dont allow to be stored
	BannedItems = {"sent_ball"},
}


// Here you can pre define names for Classes which get used instead.
zclib.config.PredefinedNames = {
	["sent_ball"] = "Super Bouncer",
	["item_healthkit"] = "Health Kit",
	["item_ammo_357"] = "357 Ammo",
	["item_ammo_357_large"] = "357 Ammo (Large)",
	["item_ammo_ar2"] = "AR2 Ammo",
	["item_ammo_ar2_large"] = "AR2 Ammo (Large)",
	["item_ammo_ar2_altfire"] = "AR2 Orb",
	["item_ammo_crossbow"] = "Crossbow Bolts",
	["item_healthvial"] = "Health Viral",
	["item_ammo_pistol"] = "Pistol Ammo",
	["item_ammo_pistol_large"] = "Pistol Ammo (Large)",
	["item_rpg_round"] = "RPG Round",
	["item_box_buckshot"] = "Shotgun Ammo",
	["item_ammo_smg1"] = "SMG Ammo",
	["item_ammo_smg1_large"] = "SMG Ammo (Large)",
	["item_ammo_smg1_grenade"] = "SMG Grenade",
	["item_battery"] = "Suit Battery"
}
