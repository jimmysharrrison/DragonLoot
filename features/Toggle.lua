--Toggle Buy Receipts for player
function DL.ToggleBuy(buttonname)
	
	DL.savedVars.Buy = (not DL.savedVars.Buy)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Store Buy Receipt  -- " .. ((DL.savedVars.Buy) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	

		if (DL.savedVars.Buy) then
			buttonname:SetText('[X]')
		else 
			buttonname:SetText('[  ]')
		end

	d(message) -- Let the player know if it's enabled or disabled.

end

--Toggle AutoSell trash to vendor
function DL.ToggleAutoSell(buttonname)
	
	DL.savedVars.AutoSell = (not DL.savedVars.AutoSell)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Automatically Sell Trash/Junk  -- " .. ((DL.savedVars.AutoSell) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	

		if (DL.savedVars.AutoSell) then
			buttonname:SetText('[X]')
		else 
			buttonname:SetText('[  ]')
		end

	d(message) -- Let the player know if it's enabled or disabled.

end

--Toggles Quest Loot.
function DL.ToggleQuest(buttonname)
	
	DL.savedVars.Quest = (not DL.savedVars.Quest)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Quest Loot -- " .. ((DL.savedVars.Quest) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	

		if (DL.savedVars.Quest) then
			buttonname:SetText('[X]')
		else 
			buttonname:SetText('[  ]')
		end

	
	d(message) -- Let the player know if it's enabled or disabled.

end

-- Toggles Trash Loot.
function DL.ToggleTrash(buttonname)
	
	DL.savedVars.Trash = (not DL.savedVars.Trash)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Trash Loot (Grey) -- " .. ((DL.savedVars.Trash) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	

		if (DL.savedVars.Trash) then
			buttonname:SetText('[X]')
		else 
			buttonname:SetText('[  ]')
		end

	
	d(message) -- Let the player know if it's enabled or disabled.

end

--Toggles Normal Loot.
function DL.ToggleNormal(buttonname)
	
	DL.savedVars.Normal = (not DL.savedVars.Normal)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Normal Loot (White)-- " .. ((DL.savedVars.Normal) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	

		if (DL.savedVars.Normal) then
			buttonname:SetText('[X]')
		else 
			buttonname:SetText('[  ]')
		end

	
	d(message) -- Let the player know if it's enabled or disabled.

end

--Toggles Magic Loot.
function DL.ToggleMagic(buttonname)
	
	DL.savedVars.Magic = (not DL.savedVars.Magic)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Magic Loot (Green)-- " .. ((DL.savedVars.Magic) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	
	if (DL.savedVars.Magic) then
			buttonname:SetText('[X]')
	else 
			buttonname:SetText('[  ]')
	end
	
	d(message) -- Let the player know if it's enabled or disabled.

end

--Used to toggle the Gold variable.
function DL.ToggleGold(buttonname)

	DL.savedVars.Gold = (not DL.savedVars.Gold)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Gold -- " .. ((DL.savedVars.Gold) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	
	if (DL.savedVars.Gold) then
			buttonname:SetText('[X]')
	else 
			buttonname:SetText('[  ]')
	end
	
	d(message) -- Let the player know if it's enabled or disabled.
		  
end

--Used to toggle the Group variable
function DL.ToggleGroup(buttonname)

	DL.savedVars.Group = (not DL.savedVars.Group)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Group Loot -- " .. ((DL.savedVars.Group) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	
	if (DL.savedVars.Group) then
			buttonname:SetText('[X]')
	else 
			buttonname:SetText('[  ]')
	end
	
	d(message) -- Let the player know if it's enabled or disabled.
	
	
end

--You can turn the window off and on from the settings menu.
function DL.ToggleLootWindow(buttonname)

		DL.savedVars.LootWindow = (not DL.savedVars.LootWindow) --Switch values (boolean)
	
		local message = "Dragon Loot: Loot Window  -- " .. ((DL.savedVars.LootWindow) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.	
		
		if (DL.savedVars.LootWindow) then
			dl_lootWindow:SetHidden( false )
			buttonname:SetText('[X]')
		else 
			dl_lootWindow:SetHidden( true )
			buttonname:SetText('[  ]')
		end

		d(message) -- Let the player know if it's enabled or disabled.
		
end

function DL.ToggleChatLoot(buttonname)
	
	DL.savedVars.ChatLoot = (not DL.savedVars.ChatLoot)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Chat Loot -- " .. ((DL.savedVars.ChatLoot) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	

		if (DL.savedVars.ChatLoot) then
			buttonname:SetText('[X]')
		else 
			buttonname:SetText('[  ]')
		end

	d(message) -- Let the player know if it's enabled or disabled.

end

--Toggle Sell Receipts for player
function DL.ToggleSell(buttonname)
	
	DL.savedVars.Sell = (not DL.savedVars.Sell)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Store Sell Receipt -- " .. ((DL.savedVars.Sell) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	

		if (DL.savedVars.Sell) then
			buttonname:SetText('[X]')
		else 
			buttonname:SetText('[  ]')
		end

	d(message) -- Let the player know if it's enabled or disabled.

end
