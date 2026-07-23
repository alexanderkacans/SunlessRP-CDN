if SERVER then return end
zclib = zclib or {}
zclib.Rope = zclib.Rope or {}

function zclib.Rope.Setup(Length, v_start, v_end)
	local RopePoints = {}

	if v_end then
		for point = 1, Length do
			RopePoints[point] = {
				position = LerpVector((1 / Length) * point, v_start, v_end),
				velocity = vector_origin
			}
		end
	else
		for point = 1, Length do
			RopePoints[point] = {
				position = v_start,
				velocity = vector_origin
			}
		end
	end

	return RopePoints
end

local RopeOffset = Vector(0,0,10)
function zclib.Rope.Update(RopePoints, v_start, v_end, length, gravity, damping)
	// Updates the Rope points to move physicly

	if not v_end then return end
	if not v_start then return end

	// This fixes the rope breaking when both start and end are the same
	if v_end == v_start then
		v_end = v_start + RopeOffset
	end

	if isentity(v_end) then v_end = v_end:GetPos() end
	if isentity(v_start) then v_start = v_start:GetPos() end

	local dist = v_end:DistToSqr(v_start)
	dist = (dist / length) * 0.1


	for point = 1, length do
		local position1 = (RopePoints[math.Clamp(point - 1, 1, length)].position or vector_origin) - (RopePoints[point].position or vector_origin)
		local length1 = math.max(position1:Length(), dist)

		local position2 = (RopePoints[math.Clamp(point + 1, 1, length)].position or vector_origin) - (RopePoints[point].position or vector_origin)
		local length2 = math.max(position2:Length(), dist)

		local velocity = (position1 / length1) + (position2 / length2) + (gravity * 0.001)

		RopePoints[point].velocity = (RopePoints[point].velocity * damping) + velocity * (dist * 0.01)

		RopePoints[point].position = (RopePoints[point].position or vector_origin) + RopePoints[point].velocity
	end

	RopePoints[1].position = v_start
	RopePoints[length].position = v_end
end

function zclib.Rope.Draw(RopePoints, v_start, v_end, length, LineMaterial, MatSprite, color , width)
	if not v_end then return end
	if not v_start then return end

	if isentity(v_end) then v_end = v_end:GetPos() end
	if isentity(v_start) then v_start = v_start:GetPos() end

	local dist = v_end:DistToSqr(v_start)
	dist = (dist / length) * 0.1

	cam.Start3D()
		render.SetMaterial(LineMaterial)
		render.StartBeam(length)
			local tex_repeat = math.floor(dist / 50)
			tex_repeat = math.Clamp(tex_repeat, 10, 50)

			for point = 1, length do
				if RopePoints[point] then
					local tex = (tex_repeat / length) * point
					render.AddBeam(RopePoints[point].position, width or 10, tex, color)
				end
			end
		render.EndBeam()

		if MatSprite then
			render.SetMaterial(MatSprite)
			render.DrawSprite(RopePoints[length].position, 15, 15, color)
		end

	cam.End3D()
end
