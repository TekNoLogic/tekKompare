
local orig1 = GameTooltip:GetScript("OnTooltipSetItem")
GameTooltip:SetScript("OnTooltipSetItem", function(self, ...)
	if not ShoppingTooltip1:IsVisible() and not self:IsEquippedItem() then GameTooltip_ShowCompareItem(self, 1) end
	if orig1 then return orig1(self, ...) end
end)


local orig2 = ItemRefTooltip:GetScript("OnTooltipSetItem")
ItemRefTooltip:SetScript("OnTooltipSetItem", function(self, ...)
	GameTooltip_ShowCompareItem(self, 1)
	self.comparing = true
	if orig2 then return orig2(self, ...) end
end)
