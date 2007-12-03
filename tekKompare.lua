

local tekKompareTooltip1, tekKompareTooltip2
local ShoppingTooltip1, ShoppingTooltip2 = ShoppingTooltip1, ShoppingTooltip2


local function SetTips(link, owner, tooltip1, tooltip2)
	--bypass these frames: WorldFrame, player's paperdoll, weapon enchants
	local f = GetMouseFocus() and GetMouseFocus():GetName() or ""
	if not link or f == "WorldFrame" or string.find(f, "^Character.*Slot$") or string.find(f, "^TempEnchant%d+$") then return end

	tooltip1:SetOwner(owner, "ANCHOR_NONE")
	tooltip2:SetOwner(owner, "ANCHOR_NONE")
	local item1, item2 = tooltip1:SetHyperlinkCompareItem(link, 1), tooltip2:SetHyperlinkCompareItem(link, 2)
	if not item1 and not item2 then return end
	if item2 and not item1 then tooltip1, tooltip2, item1, item2 = tooltip2, tooltip1, true, nil end

	local left, right, anchor1, anchor2 = owner:GetLeft(), owner:GetRight(), "TOPLEFT", "TOPRIGHT"
	if not left or not right then return end
	if (GetScreenWidth() - right) < left then anchor1, anchor2 = anchor2, anchor1 end

	if item1 then
		tooltip1:ClearAllPoints()
		tooltip1:SetPoint(anchor1, owner, anchor2, 0, -10)
		tooltip1:Show()

		if item2 then
			tooltip2:ClearAllPoints()
			tooltip2:SetPoint(anchor1, tooltip1, anchor2)
			tooltip2:Show()
		end
	end
end


local orig1 = GameTooltip:GetScript("OnTooltipSetItem")
GameTooltip:SetScript("OnTooltipSetItem", function(frame, ...)
	assert(frame, "arg 1 is nil, someone isn't hooking correctly")

	local _, link = frame:GetItem()
	if not ShoppingTooltip1:IsVisible() then SetTips(link, frame, ShoppingTooltip1, ShoppingTooltip2) end
	if orig1 then return orig1(frame, ...) end
end)


local orig2 = ItemRefTooltip:GetScript("OnTooltipSetItem")
ItemRefTooltip:SetScript("OnTooltipSetItem", function(frame, ...)
	if not tekKompareTooltip1 then
		tekKompareTooltip1 = CreateFrame("GameTooltip", "tekKompareTooltip1", frame, "ShoppingTooltipTemplate")
		tekKompareTooltip1:SetFrameStrata("TOOLTIP")
		tekKompareTooltip1:SetClampedToScreen(true)

		tekKompareTooltip2 = CreateFrame("GameTooltip", "tekKompareTooltip2", frame, "ShoppingTooltipTemplate")
		tekKompareTooltip2:SetFrameStrata("TOOLTIP")
		tekKompareTooltip2:SetClampedToScreen(true)
	end

 	local _, link = frame:GetItem()
	SetTips(link, frame, tekKompareTooltip1, tekKompareTooltip2)
	if orig2 then return orig2(frame, ...) end
end)


-- Cowtip Condom
-- We'll let CowTip fuck us, but we don't want to catch anything
if select(2, GetAddOnInfo("CowTip")) then
	local function nullfunc() end
	ShoppingTooltip1.SetBackdrop, ShoppingTooltip2.SetBackdrop = nullfunc, nullfunc
end


