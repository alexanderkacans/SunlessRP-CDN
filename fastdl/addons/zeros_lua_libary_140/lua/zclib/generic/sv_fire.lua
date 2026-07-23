if not SERVER then return end
zclib = zclib or {}
zclib.Fire = zclib.Fire or {}

function zclib.Fire.Ignite(ent,time,radius)
    // Only way to detect vFire atm
    if CreateVFire then
        ent:Ignite(1,0)
    else
        ent:Ignite(time,radius)
    end
end
