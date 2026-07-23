zclib = zclib or {}

zclib.Sound = zclib.Sound or {}
zclib.Sound.List = zclib.Sound.List or {}

// This packs the requested sound Data
function zclib.Sound.Catch(id)
	local soundData = {}
	local soundTable = zclib.Sound.List[id]
	soundData.sound = soundTable.paths[math.random(#soundTable.paths)]
	soundData.lvl = soundTable.lvl
	soundData.pitch = math.Rand(soundTable.pitchMin, soundTable.pitchMax)
	soundData.volume = soundTable.volume or 1

	return soundData
end

function zclib.Sound.EmitFromPosition(pos,id)
	local soundData = zclib.Sound.Catch(id)
	sound.Play(soundData.sound, pos, soundData.lvl, soundData.pitch, soundData.volume)
end

function zclib.Sound.EmitFromEntity(id, ent)

	local cur_time = math.Round(CurTime(),2)

	// Lets make sure we dont play the same sound at the same time more then a specified amount 5
	if ent.SoundTracker and ent.SoundTracker[id] and ent.SoundTracker[id][cur_time] and ent.SoundTracker[id][cur_time] >= 5 then
		return
	else
		if ent.SoundTracker == nil then
			ent.SoundTracker = {}
		end

		if ent.SoundTracker[id] == nil then
			ent.SoundTracker[id] = {}
		end

		ent.SoundTracker[id][cur_time] = (ent.SoundTracker[id][cur_time] or 0) + 1
	end

	local soundData = zclib.Sound.Catch(id)
	ent:EmitSound(soundData.sound, soundData.lvl, soundData.pitch, soundData.volume, CHAN_STATIC, 0, 0)
end

function zclib.Sound.StopFromEntity(id, ent)
	local soundData = zclib.Sound.Catch(id)
	ent:StopSound(soundData.sound)
end


sound.Add({
	name = "zclib_ui_click",
	channel = CHAN_STATIC,
	volume = 1,
	level = 60,
	pitch = {100, 100},
	sound = {"UI/buttonclick.wav"}
})

zclib.Sound.List["throw"] = {
	paths = {
		"zerolib/throw01.wav",
		"zerolib/throw02.wav",
		"zerolib/throw03.wav",
		"zerolib/throw04.wav",
		"zerolib/throw05.wav",
	},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List["inv_add"] = {
	paths = {
		"zerolib/inv_add.wav",
	},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List["machine_explode"] = {
	paths = {
		"weapons/explode3.wav",
		"weapons/explode4.wav",
		"weapons/explode5.wav",
	},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List["gas_buff"] = {
	paths = {"zerolib/gas_buff01.wav","zerolib/gas_buff02.wav","zerolib/gas_buff03.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List["zapp"] = {
	paths = {
		"ambient/energy/spark1.wav",
		"ambient/energy/spark2.wav",
		"ambient/energy/spark3.wav",
		"ambient/energy/spark4.wav",
		"ambient/energy/spark5.wav",
		"ambient/energy/spark6.wav"
	},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}


zclib.Sound.List["cash"] = {
	paths = {"zerolib/cash.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List["shoot"] = {
	paths = {"zerolib/shoot.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List["upgrade"] = {
	paths = {"zerolib/upgrade.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}
zclib.Sound.List["building"] = {
	paths = {"zerolib/building.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100
}

zclib.Sound.List["splash"] = {
	paths = {"ambient/water/water_splash1.wav","ambient/water/water_splash2.wav","ambient/water/water_splash3.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	volume = 0.30
}

zclib.Sound.List["error"] = {
	paths = {"zerolib/error.wav"},
	lvl = 60,
	pitchMin = 100,
	pitchMax = 100,
	volume = 1,
}
