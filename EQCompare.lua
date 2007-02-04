
local INVTYPE_GUN="Gun"
local INVTYPE_CROSSBOW="Crossbow"
local INVTYPE_WAND="Wand"
local INVTYPE_THROWN="Thrown"
local INVTYPE_GUNPROJECTILE="Projectile"
local INVTYPE_BOWPROJECTILE="Projectile"


local slots = {
	[INVTYPE_HEAD]           = {1},
	[INVTYPE_NECK]           = {2},
	[INVTYPE_SHOULDER]       = {3},
	[INVTYPE_BODY]           = {4},
	[INVTYPE_CHEST]          = {5},
	[INVTYPE_ROBE]           = {5},
	[INVTYPE_WAIST]          = {6},
	[INVTYPE_LEGS]           = {7},
	[INVTYPE_FEET]           = {8},
	[INVTYPE_WRIST]          = {9},
	[INVTYPE_HAND]           = {10},
	[INVTYPE_FINGER]         = {11,12},
	[INVTYPE_TRINKET]        = {13,14},
	[INVTYPE_CLOAK]          = {15},
	[INVTYPE_WEAPON]         = {16,17},
	[INVTYPE_2HWEAPON]       = {16,17},
	[INVTYPE_WEAPONMAINHAND] = {16},
	[INVTYPE_WEAPONOFFHAND]  = {17},
	[INVTYPE_SHIELD]         = {17},
	[INVTYPE_HOLDABLE]       = {17},
	[INVTYPE_RANGED]         = {18},
	[INVTYPE_RELIC]          = {18},
	[INVTYPE_TABARD]         = {19},
	-- need localization for following
	[INVTYPE_GUN]={18},
	[INVTYPE_CROSSBOW]={18},
	[INVTYPE_WAND]={18},
	[INVTYPE_THROWN]={18},
	[INVTYPE_GUNPROJECTILE]={0},
	[INVTYPE_BOWPROJECTILE]={0},
}


local function GetInventorySlot(tooltip)
	--possible texts starting at 2nd line. the first line is item name
	for i=2,5 do
		local text=getglobal(tooltip:GetName().."TextLeft"..i):GetText()
		if text and slots[text] then
			local match_inv = slots[text]

			-- check used slot
			local slot = {}
			for _,v in ipairs(match_inv) do
				local item = GetInventoryItemLink("player",v)
				if item then tinsert(slot, v) end
			end
			return unpack(slot)
		end
	end
end


local orig1 = GameTooltip:GetScript("OnShow")
GameTooltip:SetScript("OnShow", function(object, ...)
	--check object if valid
	if type(object)~="table" then if orig1 then return orig1(object, ...) end end

	--call origin script hook except ItemRefTooltip
	--call this at first may fix a lot problem, and keep compat with other mods
	if object ~= ItemRefTooltip and orig1 then orig1(object, ...) end

	--bypass these frame, WorldFrame, player's paperdoll, weapon enchants
	local frame=GetMouseFocus() and GetMouseFocus():GetName() or ""
	if frame == "WorldFrame" or strfind(frame,"^Character.*Slot$") or strfind(frame,"^TempEnchant%d+$")	then return end

	--check if any matched inventory items
	local slot1, slot2 = GetInventorySlot(object)
	if not slot1 then if orig1 then return orig1(object, ...) end end

	--use custom tooltip to display compare info for ItemRefTooltip.
	--so it's stick display while mouse hover other things.
	local tooltip
	if object == ItemRefTooltip then
		tooltip = "EQCompareTooltip"
	else
		tooltip = "ShoppingTooltip"
	end

	--place code copy from QuickCompare, correct anchor if tooltip is in right half of screen
	local uibottom,uitop = UIParent:GetBottom(), UIParent:GetTop()
	local anchor, align, anchorframe = "TOPLEFT", "TOPRIGHT", object
	local scale, tipleft = object:GetScale(), object:GetLeft()
	local dy = -10*scale
	if tipleft and (tipleft*scale) >= (UIParent:GetRight()/2) then anchor, align = align, anchor end

	--display compare tooltip matched inv slot
	for i=1,2 do
		local invslot = select(i, slot1, slot2)
		local shoptip = getglobal(tooltip.. i)
		local shoptiptext = getglobal(tooltip.. i.. "TextLeft1")

		shoptip:SetOwner(object, "ANCHOR_NONE")
		shoptip:SetInventoryItem("player", invslot)
		shoptip:SetScale(scale)
		--reset tooltip point, so it can get the correct bottom and top position later.
		shoptip:ClearAllPoints()
		shoptip:SetPoint(anchor, anchorframe, align, 0, dy)

--~ 		--show Currently Equipped in lightyellow
--~ 		local oldtext = shoptiptext:GetText() or ""
--~ 		local newtext = LIGHTYELLOW_FONT_COLOR_CODE.. CURRENTLY_EQUIPPED.. FONT_COLOR_CODE_CLOSE.. "\n"
--~ 		shoptiptext:SetText(newtext.. oldtext)
--~ 		shoptiptext:SetJustifyH("LEFT")

		--place code copy from QuickCompare, correct placement, don't go off screen
		--coords get larger as move up: 0 at bottom, screen height at top
		local bottom, top = shoptip:GetBottom(), shoptip:GetTop()
		if bottom and bottom*scale-10 <= uibottom then
			--10 for padding
			dy = uibottom - bottom + (10*scale)
		elseif top and ((top+32)*scale) >= uitop then
			--32 for icon
			top = (top+32) * scale
			dy = uitop - top - 20
		end
		shoptip:ClearAllPoints()
		shoptip:SetPoint(anchor, anchorframe, align, 0, dy)
		shoptip:Show()

		--last comparison tooltip becomes anchorframe for next comparison tooltip
		anchorframe = shoptip
		dy = 0
	end
end)


--~ 	self:SecureHook("SetItemRef")
--~ --[[ Hook SetItemRef, for display compare tooltip while clicked hyperlink in ChatFrame ]]--
--~ function EQCompare:SetItemRef(link, text, button)
--~ 	--only process tooltip for item
--~ 	if strfind(link,"^item") then
--~ 		--because SetItemRef will not display item tooltip while holding shift and ctrl key

--~ 		EQCompareTooltip1:Hide()
--~ 		EQCompareTooltip2:Hide()
--~ 		self:Tooltip_OnShow(ItemRefTooltip)
--~ 	end
--~ end


--~ local orig2 = ItemRefTooltip:GetScript("OnHide")
--~ ItemRefTooltip:SetScript("OnHide", function(...)
--~ 	EQCompareTooltip1:Hide()
--~ 	EQCompareTooltip2:Hide()
--~ 	if orig2 then return orig2(...) end
--~ end

