
string.concat = strconcat

local tekKompareTooltip1, tekKompareTooltip2
local slots = {
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
	INVTYPE_RELIC          = 18,
	INVTYPE_GUN            = 18,
	INVTYPE_CROSSBOW       = 18,
	INVTYPE_WAND           = 18,
	INVTYPE_THROWN         = 18,
	INVTYPE_TABARD         = 19,
}


local function GetInventorySlot(tooltip)
	local _, link = tooltip:GetItem()
	if not link then return end
	local _, _, _, _, _, _, _, _, itemEquipLoc = GetItemInfo(link)

	local s = slots[itemEquipLoc]
	if not s then return end
	if type(s) == "number" then return GetInventoryItemLink("player", s) and s
	else return GetInventoryItemLink("player", s[1]) and s[1], GetInventoryItemLink("player", s[2]) and s[2] end
end


local function SetTip(frame, slot, owner, anchor, align, scale)
	if not slot then return end

	frame:SetClampedToScreen(true)
	frame:SetOwner(owner, "ANCHOR_NONE")
	frame:SetInventoryItem("player", slot)
	frame:ClearAllPoints()
	frame:SetScale(scale)
	frame:SetPoint(anchor, owner, align)
	frame:Show()
end


local function SetTips(frame, useown)
	--bypass these frame, WorldFrame, player's paperdoll, weapon enchants
	local f = GetMouseFocus() and GetMouseFocus():GetName() or ""
	if f == "WorldFrame" or string.find(f, "^Character.*Slot$") or string.find(f, "^TempEnchant%d+$") then return end

	--check if any matched inventory items
	local slot1, slot2 = GetInventorySlot(frame)
	if slot2 and not slot1 then slot1, slot2 = slot2, slot1
	elseif not slot1 then return end

	local tooltip1 = useown and tekKompareTooltip1 or ShoppingTooltip1
	local tooltip2 = useown and tekKompareTooltip2 or ShoppingTooltip2

	local anchor1, anchor2 = "TOPLEFT", "TOPRIGHT"
	local scale, tipright = frame:GetScale(), frame:GetRight()
	if tipright and (tipright*scale) >= (UIParent:GetRight()/2) then anchor1, anchor2 = anchor2, anchor1 end

	SetTip(tooltip1, slot1, frame, anchor1, anchor2, scale)
	SetTip(tooltip2, slot2, tooltip1, anchor1, anchor2, scale)
end


local orig1 = GameTooltip:GetScript("OnTooltipSetItem")
GameTooltip:SetScript("OnTooltipSetItem", function(frame, ...)
	SetTips(frame)
	if orig1 then return orig1(frame, ...) end
end)


local orig2 = ItemRefTooltip:GetScript("OnTooltipSetItem")
ItemRefTooltip:SetScript("OnTooltipSetItem", function(frame, ...)
	if not tekKompareTooltip1 then
		tekKompareTooltip1 = CreateFrame("GameTooltip", "tekKompareTooltip1", ItemRefTooltip, "ShoppingTooltipTemplate")
		tekKompareTooltip2 = CreateFrame("GameTooltip", "tekKompareTooltip2", ItemRefTooltip, "ShoppingTooltipTemplate")
		tekKompareTooltip1:SetFrameStrata("TOOLTIP")
		tekKompareTooltip2:SetFrameStrata("TOOLTIP")
	end

	SetTips(frame, true)
	if orig2 then return orig2(frame, ...) end
end)



