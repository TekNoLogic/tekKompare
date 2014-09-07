
-- Force the CVar to the setting we want
SetCVar("alwaysCompareItems", 1)


local orig2 = ItemRefTooltip:GetScript("OnTooltipSetItem")
ItemRefTooltip:SetScript("OnTooltipSetItem", function(self, ...)
	GameTooltip_ShowCompareItem(self, 1)
	self.comparing = true
	if orig2 then return orig2(self, ...) end
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
	GameTooltip_ShowCompareItem(self, 1)
end)
