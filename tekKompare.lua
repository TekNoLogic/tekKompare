
local tekKompareTooltip1, tekKompareTooltip2, tekKompareTooltip3, tekKompareTooltip4
local ShoppingTooltip1 = ShoppingTooltip1
local slots = {
	INVTYPE_AMMO           = 0,
	INVTYPE_GUNPROJECTILE  = 0,
	INVTYPE_BOWPROJECTILE  = 0,
	INVTYPE_HEAD           = 1,
	INVTYPE_NECK           = 2,
	INVTYPE_SHOULDER       = 3,
	INVTYPE_BODY           = 4,
	INVTYPE_CHEST          = 5,
	INVTYPE_ROBE           = 5,
	INVTYPE_WAIST          = 6,
	INVTYPE_LEGS           = 7,
	INVTYPE_FEET           = 8,
	INVTYPE_WRIST          = 9,
	INVTYPE_HAND           = 10,
	INVTYPE_FINGER         = {11,12},
	INVTYPE_TRINKET        = {13,14},
	INVTYPE_CLOAK          = 15,
	INVTYPE_WEAPON         = {16,17},
	INVTYPE_2HWEAPON       = {16,17},
	INVTYPE_WEAPONMAINHAND = 16,
	INVTYPE_WEAPONOFFHAND  = 17,
	INVTYPE_SHIELD         = 17,
	INVTYPE_HOLDABLE       = 17,
	INVTYPE_RANGED         = 18,
	INVTYPE_RANGEDRIGHT    = 18,
	INVTYPE_RELIC          = 18,
	INVTYPE_GUN            = 18,
	INVTYPE_CROSSBOW       = 18,
	INVTYPE_WAND           = 18,
	INVTYPE_THROWN         = 18,
	INVTYPE_TABARD         = 19,
}
--~ local validator = IsShiftKeyDown
local validator = function() return true end

local function CreateTip(name, parent)
	local t = CreateFrame("GameTooltip", name, parent, "ShoppingTooltipTemplate")
	t:SetFrameStrata("TOOLTIP")
	t:SetClampedToScreen(true)

	local _G = getfenv(0)
	local L1, R1, L2 = _G[name.."TextLeft1"], _G[name.."TextRight1"], _G[name.."TextLeft2"]
	L1:SetFontObject(GameFontNormal)
	R1:SetFontObject(GameFontNormal)
	L2:SetFontObject(GameFontHighlightSmall)

	local ce = t:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	ce:SetText("|cff808080".. CURRENTLY_EQUIPPED)

	ce:SetPoint("TOPLEFT", t, "TOPLEFT", 10, -10)
	L1:SetPoint("TOPLEFT", ce, "BOTTOMLEFT", 0, -2)
	return t
end


local function GetInventorySlot(tooltip)
	local _, link = tooltip:GetItem()
	if not link then return end
	local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(link)

	local s = slots[itemEquipLoc]
	if type(s) == "table" then return unpack(s)
	else return s end
end


local function SetTip(frame, slot, owner, anchor1, anchor2)
	if not slot or not GetInventoryItemLink("player", slot) or not validator() then return end

	frame:SetOwner(owner, "ANCHOR_NONE")
	frame:SetInventoryItem("player", slot)
	frame:AddLine(" ") -- Makes the backdrop compensate for the header, I don't know a cleaner way to do this...
	frame:ClearAllPoints()
	frame:SetPoint(anchor1, owner, anchor2)
	frame:Show()
end


local function SetTips(frame, tooltip1, tooltip2)
	--bypass these frame, WorldFrame, player's paperdoll, weapon enchants
	local f = GetMouseFocus() and GetMouseFocus():GetName() or ""
	if f == "WorldFrame" or string.find(f, "^Character.*Slot$") or string.find(f, "^TempEnchant%d+$") then return end

	--check if any matched inventory items
	local slot1, slot2 = GetInventorySlot(frame)
	if slot2 and not slot1 then slot1, slot2 = slot2, slot1
	elseif not slot1 then return end

	local anchor1, anchor2, tipmid = "TOPLEFT", "TOPRIGHT", (frame:GetLeft()+frame:GetRight())/2
	if tipmid and (tipmid * frame:GetScale()) >= (UIParent:GetRight()/2) then anchor1, anchor2 = anchor2, anchor1 end

	SetTip(tooltip1, slot1, frame, anchor1, anchor2)
	SetTip(tooltip2, slot2, tooltip1, anchor1, anchor2)
end


local orig1 = GameTooltip:GetScript("OnTooltipSetItem")
GameTooltip:SetScript("OnTooltipSetItem", function(frame, ...)
	if not tekKompareTooltip1 then
		tekKompareTooltip1 = CreateTip("tekKompareTooltip1", GameTooltip)
		tekKompareTooltip2 = CreateTip("tekKompareTooltip2", GameTooltip)
	end

	if not ShoppingTooltip1:IsVisible() then SetTips(frame, tekKompareTooltip1, tekKompareTooltip2) end
	if orig1 then return orig1(frame, ...) end
end)


local orig2 = ItemRefTooltip:GetScript("OnTooltipSetItem")
ItemRefTooltip:SetScript("OnTooltipSetItem", function(frame, ...)
	if not tekKompareTooltip3 then
		tekKompareTooltip3 = CreateTip("tekKompareTooltip3", ItemRefTooltip)
		tekKompareTooltip4 = CreateTip("tekKompareTooltip4", ItemRefTooltip)
	end

	SetTips(frame, tekKompareTooltip3, tekKompareTooltip4)
	if orig2 then return orig2(frame, ...) end
end)


local orig3 = ShoppingTooltip1:GetScript("OnShow")
ShoppingTooltip1:SetScript("OnTooltipSetItem", function(...)
	tekKompareTooltip1:Hide()
	tekKompareTooltip2:Hide()
	if orig3 then return orig3(...) end
end)
