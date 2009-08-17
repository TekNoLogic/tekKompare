
local ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3 = ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3
local ItemRefShoppingTooltip1, ItemRefShoppingTooltip2, ItemRefShoppingTooltip3 = ItemRefShoppingTooltip1, ItemRefShoppingTooltip2, ItemRefShoppingTooltip3


local function SetTips(link, owner, tooltip1, tooltip2, tooltip3)
	--bypass these frames: WorldFrame, player's paperdoll, weapon enchants
	local f = GetMouseFocus() and GetMouseFocus():GetName() or ""
	if not link or f == "WorldFrame" or string.find(f, "^Character.*Slot$") or string.find(f, "^TempEnchant%d+$") then return end

	tooltip1:SetOwner(owner, "ANCHOR_NONE")
	tooltip2:SetOwner(owner, "ANCHOR_NONE")
	tooltip3:SetOwner(owner, "ANCHOR_NONE")
	local item1, item2, item3 = tooltip1:SetHyperlinkCompareItem(link, 1), tooltip2:SetHyperlinkCompareItem(link, 2), tooltip3:SetHyperlinkCompareItem(link, 3)
	if not item1 and not item2 and not item3 then return end
	if item3 and not item2 then tooltip2, tooltip3, item2, item3 = tooltip3, tooltip2, true, nil end
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

			if item3 then
				tooltip3:ClearAllPoints()
				tooltip3:SetPoint(anchor1, tooltip2, anchor2)
				tooltip3:Show()
			end
		end
	end
end


local orig1 = GameTooltip:GetScript("OnTooltipSetItem")
GameTooltip:SetScript("OnTooltipSetItem", function(frame, ...)
	assert(frame, "arg 1 is nil, someone isn't hooking correctly")

	local _, link = frame:GetItem()
	if not ShoppingTooltip1:IsVisible() then SetTips(link, frame, ShoppingTooltip1, ShoppingTooltip2, ShoppingTooltip3) end
	if orig1 then return orig1(frame, ...) end
end)


local orig2 = ItemRefTooltip:GetScript("OnTooltipSetItem")
ItemRefTooltip:SetScript("OnTooltipSetItem", function(frame, ...)
	local _, link = frame:GetItem()
	SetTips(link, frame, ItemRefShoppingTooltip1, ItemRefShoppingTooltip2, ItemRefShoppingTooltip3)
	if orig2 then return orig2(frame, ...) end
end)


-- Don't let ItemRefTooltip fuck with the compare tips
ItemRefTooltip:SetScript("OnEnter", nil)
ItemRefTooltip:SetScript("OnLeave", nil)
ItemRefTooltip:SetScript("OnDragStart", function(self)
	ItemRefShoppingTooltip1:Hide(); ItemRefShoppingTooltip2:Hide(); ItemRefShoppingTooltip3:Hide()
	self:StartMoving()
end)
ItemRefTooltip:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
	ValidateFramePosition(self)
	local _, link = self:GetItem()
	SetTips(link, self, ItemRefShoppingTooltip1, ItemRefShoppingTooltip2, ItemRefShoppingTooltip3)
end)
