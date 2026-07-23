zclib = zclib or {}
zclib.Animation = zclib.Animation or {}

function zclib.Animation.Play(ent,anim, speed)
	if not IsValid(ent) then return end
	local sequence = ent:LookupSequence(anim)
	ent:SetCycle(0)
	ent:ResetSequence(sequence)
	ent:SetPlaybackRate(speed)
	ent:SetCycle(0)
end

function zclib.Animation.PlayTransition(ent,anim01, speed01,anim02,speed02)

	zclib.Animation.Play(ent,anim01, speed01)

	local time = ent:SequenceDuration() or 0
	local timerid = "zclib_anim_transition_" .. ent:EntIndex()
	zclib.Timer.Remove(timerid)

	zclib.Timer.Create(timerid, time, 1, function()
		zclib.Timer.Remove(timerid)
		zclib.Animation.Play(ent, anim02, speed02)
	end)
end
