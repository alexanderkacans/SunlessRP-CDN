local V = {
			Name = "Tow Truck", 
			Class = "prop_vehicle_jeep",
			Category = "Sickness Vehicle",
			Author = "SgtSgt, Rockstar Games",
			Information = "GTA4 Tow Truck upload for OtherGaming.eu",
			Model = "models/sickness/towtruckdr.mdl",	
			SeatType = "jeep_seat",
				
			Horn = {Sound = "vu_horn_double.wav", Pitch = 90},
			Customexits = { Vector(-90,36,22), Vector(82,36,22), Vector(22,24,90) ,Vector(2,100,30) },
			ModView = { FirstPerson = Vector(4,0,2) },
			
			KeyValues = {
				vehiclescript	=	"scripts/vehicles/tow.txt"
			}
}
list.Set("Vehicles", "sicknesstowtruck", V)