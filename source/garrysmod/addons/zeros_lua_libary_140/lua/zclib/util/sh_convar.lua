zclib = zclib or {}
zclib.Convar = zclib.Convar or {}
zclib.Convars = zclib.Convars or {}

function zclib.Convar.Get(convar)
    return tonumber(zclib.Convars[convar] or 0, 10)
end

function zclib.Convar.GetBool(convar)
    return tonumber(zclib.Convars[convar] or 0, 10) == 1
end

function zclib.Convar.Set(convar, val)
    zclib.Convars[convar] = val
end

function zclib.Convar.Create(convar, val, data)
    CreateConVar(convar, val, data)
    zclib.Convars[convar] = GetConVar(convar):GetString()

    local identifier = "convar_" .. convar
    cvars.RemoveChangeCallback(convar, identifier)
    cvars.AddChangeCallback(convar, function(convar_name, value_old, value_new)
        zclib.Convar.Set(convar, value_new)
    end, identifier)
end

if CLIENT then
    zclib.Convar.Create("zclib_cl_vfx_dynamiclight", "1", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zclib_cl_sfx_volume", "1", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zclib_cl_drawui", "1", {FCVAR_ARCHIVE})
    zclib.Convar.Create("zclib_cl_particleeffects", "1", {FCVAR_ARCHIVE})
end
