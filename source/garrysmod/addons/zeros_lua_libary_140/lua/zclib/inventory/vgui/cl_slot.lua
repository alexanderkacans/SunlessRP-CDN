local VGUIItem = {}

function VGUIItem:Init()
    self.LastHoveredByDragPanel = CurTime()
end

function VGUIItem:DoClick()
    zclib.vgui.PlaySound("UI/buttonclick.wav")
    self:OnClick()
    if self:CanSelect() == false then return end
    self:OnSelect()
end

function VGUIItem:OnClick()
end

function VGUIItem:PostDraw(w, h)
end

function VGUIItem:PreDraw(w, h)
end

function VGUIItem:CanSelect()
end

function VGUIItem:CanHover()
end

function VGUIItem:OnSelect()
end

function VGUIItem:GotSelected()
end

function VGUIItem:Paint(w, h)
	zclib.BMASKS.BeginMask("mask_roundbox")
	    if self:CanSelect() then
	        draw.RoundedBox(5, 0, 0, w, h, ( self:IsHovered() or self:GotSelected() ) and zclib.colors["ui_highlight"] or zclib.colors["ui00"])
	    else
	        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui00"])
	    end

		if self.ItemData and self.ItemData.BG_Image then
			surface.SetDrawColor(self.ItemData.BG_Color or color_white)
	        surface.SetMaterial(self.ItemData.BG_Image)
	        surface.DrawTexturedRect(0, 0, w, h)
	    end

	    // Recreates the hover effect when a item gets dragged over it
	    if (CurTime() - self.LastHoveredByDragPanel) <= 0 then
	        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["ui_highlight"])
	    end

	    // Draw before the image
	    self:PreDraw(w, h)
	zclib.BMASKS.EndMask("mask_roundbox", 0, 0 , w, h, 255)
end

function VGUIItem:PaintOver(w, h)

    /*
    local mat = self:GetMaterial()
    if mat then
        self.DropScale = math.Clamp((self.DropScale or 1) - FrameTime() * 1,1,1.5)
        surface.SetDrawColor(color_white)
        surface.SetMaterial(mat)
        surface.DrawTexturedRect(0, 0, w * self.DropScale, h * self.DropScale)
    end
    */

    // Draw the name
    if self.ItemData then

		self.XPos = 1

		if not self:CanHover() then

		else

	        if self:IsHovered() then
	            self.YPos = Lerp(FrameTime() * 15,self.YPos or 1,1)
	            self.XPos = Lerp(FrameTime() * 15,self.XPos or 1,1)
	        else
	            self.YPos = Lerp(FrameTime() * 15,self.YPos or 1.45,1.45)
	            self.XPos = Lerp(FrameTime() * 15,self.XPos or 1.5,1.5)
	        end

	        if self.ItemData.Name then
	            draw.RoundedBox(0, 0, (h * 0.7) * self.YPos, w, h * 0.32, zclib.colors["black_a100"])
	            // Welp thats one way to figure out which font to use
	            if self.font_name == nil then self.font_name = zclib.GetFont("zclib_font_mediumsmall") end
	            local txtW = zclib.util.GetTextSize(self.ItemData.Name, self.font_name)
	            if txtW > w * 0.9 then
	                if self.font_name == zclib.GetFont("zclib_font_mediumsmall") then
	                    self.font_name = zclib.GetFont("zclib_font_small")
	                elseif self.font_name == zclib.GetFont("zclib_font_small") then
	                    self.font_name = zclib.GetFont("zclib_font_tiny")
	                elseif self.font_name == zclib.GetFont("zclib_font_tiny") then
	                    self.font_name = zclib.GetFont("zclib_font_nano")
	                end
	            end
	            draw.SimpleText(self.ItemData.Name, self.font_name, w / 2, (h * 0.85) * self.YPos, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	        end

			if self.ItemData.Health and self.ItemData.Health > 0 and (self.ItemData.MaxHealth and self.ItemData.MaxHealth > 0) then
				local fract = (1 / (self.ItemData.MaxHealth or 100)) * self.ItemData.Health
				draw.RoundedBox(0, 0, (h * 0.8) * self.YPos - h * 0.08, w, h * 0.08, zclib.colors["black_a100"])
				draw.RoundedBox(0, 0, (h * 0.8) * self.YPos - h * 0.08, w * fract, h * 0.08, zclib.util.LerpColor(fract, zclib.colors["red01"], zclib.colors["green01"]))
			end
		end

        if self.ItemData.Amount and self.ItemData.Amount > 1 then
            //draw.RoundedBox(5, (w * 0.7) * self.XPos, 0, w * 0.3, h * 0.2, zclib.colors["black_a100"])
            draw.SimpleText("x" .. self.ItemData.Amount, zclib.GetFont("zclib_font_small"), (w * 0.93) * self.XPos, h * 0.12, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    end

    /*
    if self.slot_id then
        draw.SimpleText(self.slot_id,zclib.GetFont("zclib_font_medium"), w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    */

    // Draw after the image
    self:PostDraw(w, h)

    /*
    // Draw the hover
    if self:CanSelect() == true and self:IsHovered() then
        draw.RoundedBox(5, 0, 0, w, h, zclib.colors["white_a2"])
    end
    */
    return true
end

function VGUIItem:Update(ItemData)

    self.ItemData = ItemData

    if self:IsEmpty() then
        self:SetTooltip(false)
        self:SetImage("nil")
        self:SetImageVisible(false)
        return
    end
    self:SetImageVisible(true)

    if ItemData.Name then
        self:SetTooltip(ItemData.Name)
    end

    local ItemClass = ItemData.Class

	local mdl = zclib.ItemDefinition.GetModel(ItemClass,ItemData)

	self.ItemData.BG_Image = zclib.ItemDefinition.GetBG_Image(ItemData.Class,ItemData)

	self.ItemData.BG_Color = zclib.ItemDefinition.GetBG_Color(ItemData.Class,ItemData)

    local DefinitionData = zclib.ItemDefinition.Get(ItemClass)
	if DefinitionData and DefinitionData.GetAmount then
		self.ItemData.Amount = DefinitionData.GetAmount(ItemData)
	end

    if DefinitionData and DefinitionData.Image then
        self:SetImage(DefinitionData.Image)
        return
    end

	local RenderData = {
		data = ItemData.Data,
		class = ItemData.Class,
		model = mdl,
		model_color = zclib.ItemDefinition.GetColor(ItemClass, ItemData),
		model_material = zclib.ItemDefinition.GetMaterial(ItemClass, ItemData),
		model_skin = zclib.ItemDefinition.GetSkin(ItemClass, ItemData),
		model_bg = zclib.ItemDefinition.GetBodyGroups(ItemClass, ItemData),
	}

	local img = zclib.Snapshoter.Get(RenderData, self)

	if img then
		self:SetImage(img)
	else
		self:SetImage("materials/zerochain/zerolib/ui/icon_loading.png")
	end
end

function VGUIItem:IsEmpty()
    return self.ItemData == nil or table.Count(self.ItemData) <= 0
end

// Gets called when the slot getting dropped somewhere
function VGUIItem:OnDrop()
    // Play drop sound
    zclib.Sound.EmitFromEntity("inv_add", LocalPlayer())

    // Play drop animation
    self.DropScale = 1.5
end

derma.DefineControl("zclib_inventory_slot", "A inventory slot panel", VGUIItem, "DImageButton")
