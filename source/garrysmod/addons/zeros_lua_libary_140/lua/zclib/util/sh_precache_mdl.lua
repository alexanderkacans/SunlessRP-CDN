zclib = zclib or {}


////////////////////////////////////////////
/////////// PRECACHE - MODELS //////////////
////////////////////////////////////////////
// Precaches the Model before it gets used, isntead of precaching all models at once
zclib.CachedModels = {}
function zclib.CacheModel(path)
    if zclib.CachedModels[path] then
        return path
    else
        util.PrecacheModel(path)
        zclib.CachedModels[path] = true

        zclib.Print("Model " .. path .. " cached!")

        return path
    end
end
////////////////////////////////////////////
////////////////////////////////////////////

if SERVER then return end

////////////////////////////////////////////
///////////// ClientModels /////////////////
////////////////////////////////////////////
/*

	This system Creates / Removes and keeps track on ClientModels

*/

zclib.ClientModel = zclib.ClientModel or {}
if zclib_ClientModelList == nil then
    zclib_ClientModelList = {}
end

function zclib.ClientModel.PrintAll()
    for k, v in pairs(zclib_ClientModelList) do
        if not IsValid(v) then
            zclib_ClientModelList[k] = nil
        end
    end

    PrintTable(zclib_ClientModelList)
end

function zclib.ClientModel.Add(mdl_path, rendermode)
    zclib.CacheModel(mdl_path)
    local ent = ClientsideModel(mdl_path, rendermode)
    if not IsValid(ent) then return end

    table.insert(zclib_ClientModelList, ent)

    return ent
end

function zclib.ClientModel.AddProp(mdl_path)
    local ent = nil

    if mdl_path then
        zclib.CacheModel(mdl_path)
        ent = ents.CreateClientProp(mdl_path)
    else
        ent = ents.CreateClientProp()
    end
	if not IsValid(ent) then return end
	if not ent.SetModel then return end

    table.insert(zclib_ClientModelList, ent)

    return ent
end

function zclib.ClientModel.Remove(ent)
    if not IsValid(ent) then return end
    table.RemoveByValue(zclib_ClientModelList, ent)

    // Stop moving if you have physics
    if ent.PhysicsDestroy then ent:PhysicsDestroy() end

    // Hide entity
    if ent.SetNoDraw then ent:SetNoDraw(true) end

    // This got taken from a Physcollide function but maybe its needed to prevent a crash
    local deltime = FrameTime() * 2
    if not game.SinglePlayer() then deltime = FrameTime() * 6 end
    SafeRemoveEntityDelayed(ent, deltime)
end
////////////////////////////////////////////
////////////////////////////////////////////
