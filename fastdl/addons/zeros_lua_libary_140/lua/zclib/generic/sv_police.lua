if not SERVER then return end
zclib = zclib or {}
zclib.Police = zclib.Police or {}

function zclib.Police.Add(Job)
    zclib.config.Police.Jobs[Job] = true
end

// Returns the first valid police player it can find
function zclib.Police.Get()
    local police

    for k, v in pairs(zclib.Player.List) do
        if IsValid(v) and v:IsPlayer() and v:Alive() and zclib.config.Police.Jobs[zclib.Player.GetJob(v)] then
            police = v
            break
        end
    end
    return police
end

function zclib.Police.MakeWanted(ply,reason,time)

    local police = zclib.Police.Get()

    if IsValid(police) then
        ply:wanted(police, reason, time)
    end
end
