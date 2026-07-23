local function HandleAirboatAnimation( vehicle, ply )
	return ply:SelectWeightedSequence( ACT_DRIVE_AIRBOAT ) 
end

local V = {
			Name = "Adder", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Adder by TheDanishMaster",
				Model = "models/tdmcars/gtav/adder.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/adder.txt"
							}
			}
list.Set("Vehicles", "addergtav", V)

local V = {
			Name = "Ambulance", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Ambulance by TheDanishMaster",
				Model = "models/tdmcars/gtav/ambulance.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/ambulance.txt"
							}
			}
list.Set("Vehicles", "ambulancegtav", V)

local V = {
			Name = "Bale Trailer", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A Bale Trailer by TheDanishMaster",
				Model = "models/tdmcars/gtav/baletrailer.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/baletrailer.txt"
							}
			}
list.Set("Vehicles", "baletrailergtav", V)

local V = {
			Name = "Camper Trailer", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A Camper Trailer by TheDanishMaster",
				Model = "models/tdmcars/gtav/camper_trailer.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/trailer_camper.txt"
							}
			}
list.Set("Vehicles", "campertrailergtav", V)

local V = {
			Name = "Bus", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Bus by TheDanishMaster",
				Model = "models/tdmcars/gtav/bus.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/bus.txt"
							}
			}
list.Set("Vehicles", "busgtav", V)

local V = {
			Name = "Camper", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Camper by TheDanishMaster",
				Model = "models/tdmcars/gtav/camper.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/camper.txt"
							}
			}
list.Set("Vehicles", "campergtav", V)

local V = {
			Name = "Futo", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Futo by TheDanishMaster",
				Model = "models/tdmcars/gtav/futo.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/futo.txt"
							}
			}
list.Set("Vehicles", "futogtav", V)

local V = {
			Name = "Gauntlet", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Gauntlet by TheDanishMaster",
				Model = "models/tdmcars/gtav/gauntlet.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/gauntlet.txt"
							}
			}
list.Set("Vehicles", "gauntletgtav", V)

local V = {
			Name = "Mesa 3", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Mesa 3 by TheDanishMaster",
				Model = "models/tdmcars/gtav/mesa3.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/mesa3.txt"
							}
			}
list.Set("Vehicles", "mesa3gtav", V)

local V = {
			Name = "Patriot 2", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Patriot 2 by TheDanishMaster",
				Model = "models/tdmcars/gtav/patriot2.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/patriot2.txt"
							}
			}
list.Set("Vehicles", "patriot2gtav", V)

local V = {
			Name = "Police Bike", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Police Bike by TheDanishMaster",
				Model = "models/tdmcars/gtav/policeb.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/policeb.txt"
							},
			Members = {
				HandleAnimation = HandleAirboatAnimation,
			}
			}
list.Set("Vehicles", "policebgtav", V)

local V = {
			Name = "BMX Bike", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable BMX Bike by TheDanishMaster",
				Model = "models/tdmcars/gtav/bmx.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/bmx.txt"
							},
			Members = {
				HandleAnimation = HandleAirboatAnimation,
			}
			}
list.Set("Vehicles", "bmxgtav", V)

local V = {
			Name = "Bati", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Bati by TheDanishMaster",
				Model = "models/tdmcars/gtav/bati.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/bati.txt"
							},
			Members = {
				HandleAnimation = HandleAirboatAnimation,
			}
			}
list.Set("Vehicles", "batigtav", V)

local V = {
			Name = "Nemesis", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Nemesis by TheDanishMaster",
				Model = "models/tdmcars/gtav/nemesis.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/nemesis.txt"
							},
			Members = {
				HandleAnimation = HandleAirboatAnimation,
			}
			}
list.Set("Vehicles", "nemesisgtav", V)

local V = {
			Name = "Triathlon Bike", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Triathlon Bike by TheDanishMaster",
				Model = "models/tdmcars/gtav/tribike.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/tribike.txt"
							},
			Members = {
				HandleAnimation = HandleAirboatAnimation,
			}
			}
list.Set("Vehicles", "tribikegtav", V)

local V = {
			Name = "Police Cruiser", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Police Cruiser by TheDanishMaster",
				Model = "models/tdmcars/gtav/police.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/police.txt"
							}
			}
list.Set("Vehicles", "policegtav", V)

local V = {
			Name = "Police Cruiser Unmarked", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Police Cruiser Unmarked by TheDanishMaster",
				Model = "models/tdmcars/gtav/police4.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/police.txt"
							}
			}
list.Set("Vehicles", "police4gtav", V)

local V = {
			Name = "Police Cruiser", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Police Cruiser by TheDanishMaster",
				Model = "models/tdmcars/gtav/police3.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/police3.txt"
							}
			}
list.Set("Vehicles", "police3gtav", V)

local V = {
			Name = "Rebel", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Rebel by TheDanishMaster",
				Model = "models/tdmcars/gtav/rebel.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/rebel.txt"
							}
			}
list.Set("Vehicles", "rebelgtav", V)

local V = {
			Name = "Riot", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Riot by TheDanishMaster",
				Model = "models/tdmcars/gtav/riot.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/riot.txt"
							}
			}
list.Set("Vehicles", "riotgtav", V)

local V = {
			Name = "Tractor", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Tractor by TheDanishMaster",
				Model = "models/tdmcars/gtav/tractor.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/tractor.txt"
							}
			}
list.Set("Vehicles", "tractorgtav", V)

local V = {
			Name = "Utillity Truck", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Utillity Truck by TheDanishMaster",
				Model = "models/tdmcars/gtav/utillitruck.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/utillitruck.txt"
							}
			}
list.Set("Vehicles", "utillitruckgtav", V)

local V = {
			Name = "Zentorno", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Zentorno by TheDanishMaster",
				Model = "models/tdmcars/gtav/zentorno.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/zentorno.txt"
							}
			}
list.Set("Vehicles", "zentornogtav", V)

local V = {
			Name = "Turismo R", 
			Class = "prop_vehicle_jeep",
			Category = "TDM Cars - GTA V",
			Author = "TheDanishMaster, R*",
			Information = "A drivable Turismo R by TheDanishMaster",
				Model = "models/tdmcars/gtav/turismor.mdl",
							KeyValues = {
							vehiclescript	=	"scripts/vehicles/TDMCars/gtav/turismor.txt"
							}
			}
list.Set("Vehicles", "turismorgtav", V)



 if SERVER then
	hook.Add("Think", "TDMGTAV_BusDoorFront", function()
		for _, ent in pairs(ents.FindByClass("prop_vehicle_jeep*")) do
				if ent:GetModel() == "models/tdmcars/gtav/bus.mdl" then
				local FrontDoor = 0
				local RearDoor = 0
			if IsValid(ent:GetDriver()) then
				if ent:GetDriver():KeyDown(IN_ATTACK) then FrontDoor = 1 end
				if ent:GetDriver():KeyDown(IN_ATTACK2) then RearDoor = 1 end
			end
			ent.BusDoorF = Lerp(0.02, ent.BusDoorF or 0, FrontDoor)
			ent:SetPoseParameter("door_front", ent.BusDoorF)
			ent.BusDoorR = Lerp(0.02, ent.BusDoorR or 0, RearDoor)
			ent:SetPoseParameter("door_rear", ent.BusDoorR)


			end
		end
	end)
end


if CLIENT then
surface.CreateFont( "GTAVUtilTruckFont", {
	font = "Arial",
	size = 200,
	weight = 100,
	scanlines = 1,
	antialias = true,

} )

hook.Add( "PostDrawOpaqueRenderables", "GTAVDigitalSpeedo", function()

    local Vehicle = LocalPlayer():GetVehicle()
		if IsValid( Vehicle ) and Vehicle:GetClass() == "prop_vehicle_jeep" then
			if Vehicle:GetModel() == "models/tdmcars/gtav/utillitruck.mdl" then
				local speed = math.Round(Vehicle:GetVelocity():Length() / (63360/3600),0)
				cam.Start3D2D(Vehicle:LocalToWorld(Vector(-31.55,107.73,87.78)),Vehicle:LocalToWorldAngles(Angle(0,6,85)),0.006)
					surface.SetDrawColor(0,255,0)
					draw.SimpleText( speed , "GTAVUtilTruckFont", 0, 0, Color(50,255,50), TEXT_ALIGN_RIGHT, 0)
				cam.End3D2D()
				cam.Start3D2D(Vehicle:LocalToWorld(Vector(-31.2,108.55,84)),Vehicle:LocalToWorldAngles(Angle(0,0,60)),0.009)
					surface.SetDrawColor(0,255,0)
					draw.SimpleText( speed , "GTAVUtilTruckFont", 0, 0, Color(50,255,50), TEXT_ALIGN_LEFT, 0)
				cam.End3D2D()
			end
		end
end )
end
