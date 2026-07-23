zclib = zclib or {}
zclib.ItemDefinition = zclib.ItemDefinition or {}
zclib.ItemDefinition.List = zclib.ItemDefinition.List or {}

/*
zclib.ItemDefinition.Register({
    class = "ent_class",

    // Overwrites the Items name
    Name = function(ItemData) return "name" end,
    or Name = "name",

    // Specifies the money value of the item
    Price = function(ItemData)
        local ItemID = isentity(ItemData) and ItemData:GetItemID() or ItemData.Data.ItemID
        local ItemAmount = isentity(ItemData) and ItemData:GetItemAmount() or ItemData.Amount
        return zmb.Item.GetPrice(ItemID) * ItemAmount
    end,

    // Gets called when the entity being picked up
    GetData = function(ent)
        return {ItemID = ent:GetItemID()}
    end,

    // Gets called when the entity being spawned in the world
    SetData = function(ItemData, ent)
        ent:SetItemID(ItemData.Data.ItemID)
        ent:SetItemAmount(ItemData.Amount)
    end,

    // Returns the value which makes the item identify between other items of the same class
    GetUniqueID = function(ItemData)
        return ItemData.Data.ItemID
    end,

    // Gets used to figure out the Amount var
    GetAmount = function(ItemData)
        return isentity(ItemData) and ItemData:GetItemAmount() or ItemData.Amount
    end,

    // Returns how many of those item classes which have the same GetUniqueID can be stacked
    GetStackLimit = function(ItemData)
        return 50
    end,

    // If defined overwrites the model
    Image = "materials/image.png",

    // Overwrites the Items model data
    Model = "model path",
    Skin = 0,
    BodyG = {},
    Color = Color(),
    Material = "",

    // This can be used to give the Item a custom background and color
    BG_Image = zclib.Materials.Get("star01"),
    BG_Color = color_red,

    // Gets called when the item being picked up
    OnPickup = function(ent,ply)

    end,

    // This will add the Drop/throw option in the optionbox
    OnDrop = function()
    end,

    // This will add the destroy option in the optionbox
    OnDestroy = function()
    end,

    // This will add the use option in the optionbox
    // NOTE This gets called on CLIENT first and returning will prevent it being called on SERVER afterwards
    OnUse = function(ply)

    end,
})
*/

// Registers a item definition
function zclib.ItemDefinition.Register(data)
    // Precache the model so util.IsValidModel works correctly for clients
    if data.Model and not isfunction(data.Model) then util.PrecacheModel(data.Model) end

    zclib.ItemDefinition.List[data.Class] = data
    //table.insert(zclib.ItemDefinition.List,data)
end

// Returns the Item definition by ID
function zclib.ItemDefinition.Get(class)
    return zclib.ItemDefinition.List[class]
end

// Only allow entity classes which have a
function zclib.ItemDefinition.IsAllowed(class)
    return zclib.ItemDefinition.List[class] ~= nil
end



function zclib.ItemDefinition.GetModel(Class,SlotData)
    local dat = zclib.ItemDefinition.Get(Class)
    if dat == nil then return SlotData.Model or "error.mdl" end

	if dat.Model and isfunction(dat.Model) then return dat.Model(Class,SlotData) or "error.mdl" end

    return dat.Model or SlotData.Model or "error.mdl"
end

function zclib.ItemDefinition.GetSkin(Class,SlotData)
    local dat = zclib.ItemDefinition.Get(Class)
    if dat == nil then return SlotData.Skin or 0 end

	if dat.Skin and isfunction(dat.Skin) then return dat.Skin(Class,SlotData) or 0 end

    return dat.Skin or SlotData.Skin or 0
end

function zclib.ItemDefinition.GetBodyGroups(Class,SlotData)
    local dat = zclib.ItemDefinition.Get(Class)

    if dat == nil then return SlotData.BodyG or {} end

	if dat.BodyG and isfunction(dat.BodyG) then return dat.BodyG(Class,SlotData) or {} end

    return dat.BodyG or SlotData.BodyG or {}
end

function zclib.ItemDefinition.GetColor(Class,SlotData)
    local dat = zclib.ItemDefinition.Get(Class)

    if dat == nil then return SlotData.Color or color_white end

	if dat.Color and isfunction(dat.Color) then return dat.Color(Class,SlotData) or color_white end

    return dat.Color or SlotData.Color or color_white
end

function zclib.ItemDefinition.GetMaterial(Class,SlotData)
    local dat = zclib.ItemDefinition.Get(Class)

    if dat == nil then return SlotData.Material or "" end

	if dat.Material and isfunction(dat.Material) then return dat.Material(Class,SlotData) or "" end

    return dat.Material or SlotData.Material or ""
end



function zclib.ItemDefinition.GetName(Class,SlotData)
    if zclib.config.PredefinedNames[Class] then return zclib.config.PredefinedNames[Class] end

    if SlotData and SlotData.Name then
        return SlotData.Name
    end

    // Is there a Item definition for that class and does it want to overwrite the name
    local DefinitionData = zclib.ItemDefinition.Get(Class)
    if DefinitionData and DefinitionData.Name then
        // The name can be defined as a function or as a string
        return isfunction(DefinitionData.Name) and DefinitionData.Name(SlotData) or DefinitionData.Name
    end

    return Class
end

function zclib.ItemDefinition.GetAmount(Class,SlotData)
    local DefinitionData = zclib.ItemDefinition.Get(Class)
    if DefinitionData and DefinitionData.GetAmount then return DefinitionData.GetAmount(SlotData) end
    return 1
end

function zclib.ItemDefinition.GetData(Class,SlotData)
    local DefinitionData = zclib.ItemDefinition.Get(Class)
    if DefinitionData and DefinitionData.GetData then return DefinitionData.GetData(SlotData) end
    return {}
end

function zclib.ItemDefinition.SetData(ent,SlotData)
    local DefinitionData = zclib.ItemDefinition.Get(ent:GetClass())
    if DefinitionData and DefinitionData.SetData then return DefinitionData.SetData(SlotData,ent) end
    return {}
end

function zclib.ItemDefinition.GetStackLimit(Class,SlotData)
    local DefinitionData = zclib.ItemDefinition.Get(Class)
    if DefinitionData and DefinitionData.GetStackLimit then return DefinitionData.GetStackLimit(SlotData) end
end

function zclib.ItemDefinition.GetUniqueID(Class,SlotData)
    local DefinitionData = zclib.ItemDefinition.Get(Class)
    if DefinitionData and DefinitionData.GetUniqueID then
        return DefinitionData.GetUniqueID(SlotData)
    end
end

// Compares two items and returns true if they are the same
function zclib.ItemDefinition.Compare(ItemData01, ItemData02)
    if ItemData01.Class ~= ItemData02.Class then return false end
    if zclib.ItemDefinition.GetUniqueID(ItemData01.Class, ItemData01) ~= zclib.ItemDefinition.GetUniqueID(ItemData02.Class, ItemData02) then return false end
    return true
end

function zclib.ItemDefinition.GetPrice(class,SlotData)

    // Is there a Item definition for that class and does it want to overwrite the name
    local DefinitionData = zclib.ItemDefinition.Get(class)
    if DefinitionData and DefinitionData.Price then
        // The name can be defined as a function or as a string
        return isfunction(DefinitionData.Price) and DefinitionData.Price(SlotData) or DefinitionData.Price
    end

    return SlotData.Price or 10
end

// Specifies if the Item has a body and can be dropped in the world if its just some lua funciton in Item form
function zclib.ItemDefinition.IsObject(Class)
    local DefinitionData = zclib.ItemDefinition.Get(Class)

    // A weapon is just a diffrent type of object
    if zclib.ItemDefinition.IsWeapon(Class) then return true end

    // We dont have this item registrated so it only can be a entity since powers need to be predefined
    if DefinitionData == nil then return true end

    return DefinitionData.IsObject == true
end

// Specifies that the entity class is of type weapon
function zclib.ItemDefinition.IsWeapon(Class,SlotData)
    local DefinitionData = zclib.ItemDefinition.Get(Class)
    if DefinitionData and DefinitionData.IsWeapon ~= nil then return DefinitionData.IsWeapon end
    if SlotData then return SlotData.IsWeapon == true end
    return false
end

/*
	Returns the background image of the item slot
*/
function zclib.ItemDefinition.GetBG_Image(Class,SlotData)

    // Is there a Item definition for that class and does it want to overwrite the BG_Image
    local DefinitionData = zclib.ItemDefinition.Get(Class)
	if not DefinitionData then return end
	if not DefinitionData.BG_Image then return end

    // The BG_Image can be defined as a function or as a string
	if isfunction(DefinitionData.BG_Image) then
		return DefinitionData.BG_Image(SlotData)
	end

    return DefinitionData.BG_Image
end

/*
	Returns the background image color of the item slot
*/
function zclib.ItemDefinition.GetBG_Color(Class,SlotData)

    // Is there a Item definition for that class and does it want to overwrite the BG_Color
    local DefinitionData = zclib.ItemDefinition.Get(Class)
	if not DefinitionData then return end
	if not DefinitionData.BG_Color then return end

	// The BG_Color can be defined as a function or as a string
	if isfunction(DefinitionData.BG_Color) then
		return DefinitionData.BG_Color(SlotData)
	end

    return DefinitionData.BG_Color
end
