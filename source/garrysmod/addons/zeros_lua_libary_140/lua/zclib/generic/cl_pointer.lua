if SERVER then return end

zclib = zclib or {}
zclib.PointerSystem = zclib.PointerSystem or {}

/*

    This system handles the Left / Right Mouse Click logic and displays a 2d colored rope from one Point to another
         Gets used by: Extinguisher(Extinguish Object), PointerSystem(MoveLiquid), Equipment(Build,Move,Remove,Repair)

*/

zclib.PointerSystem.Data = {
    // Stores what entity is the liquid comming from
    From = nil,

    // Will Later be filled with the DummyClientModel
    PreviewModel = nil,

    // The position we are currently aiming at
    Pos = nil,

    // The entity we are currently aiming at
    HitEntity = nil,

    // A valid found target, can be a entity or a position
    Target = nil,

    // Displays on the screen what action is currently active
    ActionName = "Test",

    CancelName = zclib.Language["Cancel"],
}


local IsLeftClickDown = false
local IsRightClickDown = false

local function ClearDummy()
    if IsValid(zclib.PointerSystem.Data.PreviewModel) then
        zclib.ClientModel.Remove(zclib.PointerSystem.Data.PreviewModel)
        zclib.PointerSystem.Data.PreviewModel = nil
    end
end

local function CreateDummy(pos, model)
    ClearDummy()
    local ent = zclib.ClientModel.AddProp()
    if not IsValid(ent) then return end
    ent:SetPos(pos)
    ent:SetModel(model)
    ent:SetAngles(angle_zero)
    ent:Spawn()

    ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
    zclib.PointerSystem.Data.PreviewModel = ent
end

// Starts the pointer system
function zclib.PointerSystem.Start(Machine,OnInit,OnLeftClick,MainLogic,HUDLogic,OnRightClick,PostDrawTranslucentRenderables,OnClose)
    zclib.Debug("zclib.PointerSystem.Start")

    if zclib.PointerSystem.Data.CancelName == nil then zclib.PointerSystem.Data.CancelName = zclib.Language["Cancel"] end

    ClearDummy()

    zclib.PointerSystem.Data.From = Machine

    // Can be used to add something on the hud
    zclib.PointerSystem.Data.HUDLogic = HUDLogic

    // Can be used to setup some main data like (Default Rope color)
    pcall(OnInit)

    // What should happen when the player left clicks (Confirms a action)
    zclib.PointerSystem.Data.OnLeftClick = OnLeftClick

    zclib.PointerSystem.Data.OnRightClick = OnRightClick

	zclib.PointerSystem.Data.OnClose = OnClose

	zclib.PointerSystem.Data.PostDrawTranslucentRenderables = PostDrawTranslucentRenderables

    // This function will later run some core logic of what data should be stored etc
    zclib.PointerSystem.Data.MainLogic = MainLogic

    zclib.PointerSystem.StartHook()
end

// Stops the pointer system
function zclib.PointerSystem.Stop()
    zclib.Debug("zclib.PointerSystem.Stop")

    ClearDummy()

	if zclib.PointerSystem.Data.OnClose then pcall(zclib.PointerSystem.Data.OnClose) end

	zclib.PointerSystem.FinishHook()

    zclib.PointerSystem.Data = {}
end

function zclib.PointerSystem.StartHook()

    local ply = LocalPlayer()

    zclib.Hook.Remove("Think", "PointerSystem")
    zclib.Hook.Add("Think", "PointerSystem", function(depth, skybox)
        zclib.PointerSystem.MainLogic(ply)
        IsLeftClickDown = input.IsMouseDown(MOUSE_LEFT)
        IsRightClickDown = input.IsMouseDown(MOUSE_RIGHT)
    end)

    zclib.Hook.Remove(zclib.PointerSystem.Data.RenderHook2D or "HUDPaint", "PointerSystem")
    zclib.Hook.Add(zclib.PointerSystem.Data.RenderHook2D or "HUDPaint", "PointerSystem", function()
        zclib.PointerSystem.Paint()
    end)

    zclib.Hook.Remove("PostDrawTranslucentRenderables", "PointerSystem")
    zclib.Hook.Add("PostDrawTranslucentRenderables", "PointerSystem", function(depth, bDrawingSkybox,isDraw3DSkybox )
        if isDraw3DSkybox == false then zclib.PointerSystem.PostDrawTranslucentRenderables() end
    end)
end

function zclib.PointerSystem.FinishHook()
    zclib.Hook.Remove("Think", "PointerSystem")
    zclib.Hook.Remove(zclib.PointerSystem.Data.RenderHook2D or "HUDPaint", "PointerSystem")
    zclib.Hook.Remove("PostDrawTranslucentRenderables", "PointerSystem")
end



// Draws the indicator line for the pointer system and also handles the trace for detecting the entity the player is left click on to
local LinePoints = nil
local gravity = Vector(0, 0, -3)
local damping = 0.9
local Length = 10
function zclib.PointerSystem.Paint()
    if zclib.PointerSystem.Data.From then

        // Render the rope
        if zclib.PointerSystem.Data.Pos then

            local r_start = zclib.PointerSystem.Data.RopeStart

			if IsValid(zclib.PointerSystem.Data.From) then
				if isentity(zclib.PointerSystem.Data.From) then
					r_start = zclib.PointerSystem.Data.RopeStart or zclib.PointerSystem.Data.From:GetPos()
				else
					r_start = zclib.PointerSystem.Data.RopeStart or zclib.PointerSystem.Data.From
				end
			end

            // Create rope points
            if LinePoints == nil then
                LinePoints = zclib.Rope.Setup(Length, r_start)
            end

            // Updates the Rope points to move physicly
            if LinePoints and table.Count(LinePoints) > 0 then
                zclib.Rope.Update(LinePoints, r_start, zclib.PointerSystem.Data.Pos, Length, gravity, damping)
            end

            // Draw the rope
            zclib.Rope.Draw(LinePoints, r_start, zclib.PointerSystem.Data.Pos, Length, zclib.Materials.Get("beam01"), zclib.Materials.Get("glow01"), zclib.PointerSystem.Data.MainColor)
        else
            LinePoints = nil
        end
    else
        LinePoints = nil
    end

    // Draw Action Hud indicator
    draw.SimpleText(zclib.PointerSystem.Data.ActionName, zclib.GetFont("zclib_font_big"), zclib.wM *  650, zclib.hM * 895, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(zclib.Materials.Get("icon_mouse_left"))
    surface.DrawTexturedRect(zclib.wM * 560, zclib.hM * 860,zclib.wM * 80, zclib.hM * 80)

    draw.SimpleText(zclib.PointerSystem.Data.CancelName, zclib.GetFont("zclib_font_big"), zclib.wM * 1350, zclib.hM * 895, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    surface.SetDrawColor(color_white)
    surface.SetMaterial( zclib.Materials.Get("icon_mouse_right"))
    surface.DrawTexturedRect(zclib.wM * 1360, zclib.hM * 860,zclib.wM * 80, zclib.hM * 80)

    if zclib.PointerSystem.Data.HUDLogic then pcall(zclib.PointerSystem.Data.HUDLogic) end
end

function zclib.PointerSystem.PostDrawTranslucentRenderables()
    // Render Remove Material
    if zclib.PointerSystem.Data and IsValid(zclib.PointerSystem.Data.PreviewModel) and zclib.PointerSystem.Data.PreviewModel:GetNoDraw() == false then
        render.MaterialOverride(zclib.Materials.Get("highlight"))
        render.SetColorModulation((1 / 255) * zclib.PointerSystem.Data.MainColor.r, (1 / 255) * zclib.PointerSystem.Data.MainColor.g, (1 / 255) * zclib.PointerSystem.Data.MainColor.b)
        zclib.PointerSystem.Data.PreviewModel:DrawModel()
        render.MaterialOverride()
        render.SetColorModulation(1, 1, 1)
    end

	if zclib.PointerSystem.Data.PostDrawTranslucentRenderables then pcall(zclib.PointerSystem.Data.PostDrawTranslucentRenderables) end
end


local NextAction = CurTime()
function zclib.PointerSystem.Wait()
    NextAction = CurTime() + 0.25
end

local function LeftClick(func)
    if IsLeftClickDown == false and input.IsMouseDown(MOUSE_LEFT) == true then
        IsLeftClickDown = true

        pcall(func)

        zclib.PointerSystem.Wait()
    end
end

local function RightClick(func)
    if IsRightClickDown == false and input.IsMouseDown(MOUSE_RIGHT) == true then
        IsRightClickDown = true

        if zclib.PointerSystem.Data.OnRightClick then pcall(zclib.PointerSystem.Data.OnRightClick) end

        pcall(func)

        zclib.PointerSystem.Wait()
    end
end

function zclib.PointerSystem.MainLogic(ply)

    // Stop if the player is dead
    if not IsValid(ply) or ply:Alive() == false then
        zclib.PointerSystem.Stop()
        return
    end

    // Stop if the start entity got invalid
    if not zclib.PointerSystem.Data.From then
        zclib.PointerSystem.Stop()
        return
    end

    // Execute right click function, is mostlikely just cancel
    RightClick(function()

        zclib.PointerSystem.Stop()
        surface.PlaySound("UI/buttonclickrelease.wav")
        return
    end)

    // Trace for data
    local c_trace = zclib.util.TraceLine({
        start = ply:EyePos(),
        endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
        filter = {ply,zclib.PointerSystem.Data.Ignore}
    }, "PointerSystemPointer")

    zclib.PointerSystem.Data.Hit = c_trace.Hit

    if c_trace.Hit then

        zclib.PointerSystem.Data.Pos = c_trace.HitPos
        zclib.PointerSystem.Data.HitEntity = c_trace.Entity
        zclib.PointerSystem.Data.HitNormal = c_trace.HitNormal

        if c_trace.HitNormal then
            zclib.PointerSystem.Data.Ang = c_trace.HitNormal:Angle()
            zclib.PointerSystem.Data.Ang:RotateAroundAxis(zclib.PointerSystem.Data.Ang:Right(),-90)
        end
    else
        zclib.PointerSystem.Data.Pos = nil
        zclib.PointerSystem.Data.HitEntity = nil
    end

    // If we have to wait then stop
    if NextAction > CurTime() then return end

    // Create Preview Model if none exist yet
    if not IsValid(zclib.PointerSystem.Data.PreviewModel) and zclib.PointerSystem.Data.Pos then
        CreateDummy(zclib.PointerSystem.Data.Pos, zclib.PointerSystem.Data.ModelOverwrite or "models/props_junk/PopCan01a.mdl")
        return
    end

    if zclib.PointerSystem.Data.Pos == nil then return end
    if zclib.PointerSystem.Data.Ang == nil then return end

    // Runs the main logic of the pointer system
    pcall(zclib.PointerSystem.Data.MainLogic)

    // Check if the user left clicked on a machine who wants the liquid
    LeftClick(function()
        pcall(zclib.PointerSystem.Data.OnLeftClick)
    end)
end
