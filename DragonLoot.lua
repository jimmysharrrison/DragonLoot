--[[

Author:		@Qwexton
File:			DragonLoot.lua
Version:	Alpha 1.5
Date:		2-27-2014

]]--

--[[

TODO:
	
	Create function to handle store buy back receipts ( EVENT_BUYBACK_RECEIPT )
	Create function to handle crafting completions or breakdowns.
	Figure out how to get loot links working in the loot window.
	Make loot window resizable

]]--

--Setting Global Constants

command = "/dl"
version = 1.5
DL = {}
	
--Set default Variables:	
	
DL.defaultVar =
{
	["Gold"]		= true,
	["Group"]		= true,
	["Trash"]		= true,
	["Normal"]		= true,
	["Magic"]		= true,
	["Quest"]		= true,
	["Sell"]		= true,
	["Buy"]			= true,
	["AutoSell"]		= true,
	["settingsY"] 		= 300,
	["settingsX"]		= 500,
	["lwY"]			= 670,
	["lwX"]			= 270,
	["LootWindow"]		= true,
	["ChatLoot"]		=true
}

--Initialized function called from DragonLoot.xml in the addon folder
function DragonLootLoad()

	
	--Register events with the API for Looted Items Gold received and commands in the chat window.
	EVENT_MANAGER:RegisterForEvent("DragonLoot", EVENT_ADD_ON_LOADED, OnAddOnLoaded) -- Register for event of loading our addon.
	
	
end

--Loads our Addon - Maybe redundant but whatever........
function OnAddOnLoaded(eventCode, addOnName)

--Check if our addon is loaded:

	if (addOnName == "DragonLoot") then		

		DL.savedVars = ZO_SavedVars:New( "DragonLoot_Variables", math.floor(version * 10 ), nil , DL.defaultVar, nil) --Method for adding persistent variables	
	
		DragonLoot:RegisterForEvent(EVENT_MONEY_UPDATE, CashMoney) -- Registers for gold change events then calls the CashMoney function.
		DragonLoot:RegisterForEvent(EVENT_LOOT_RECEIVED, OnLootedItem)  -- Registers for the loot received event then calls the OnLootedItem function.
		DragonLoot:RegisterForEvent(EVENT_OPEN_STORE, SellTrash) -- Registers for player opening a store, then sells trash/grey items.
		DragonLoot:RegisterForEvent(EVENT_SELL_RECEIPT, StoreSellReceipt) -- Registers for Selling items to vendors.
		DragonLoot:RegisterForEvent(EVENT_BUY_RECEIPT, StoreBuyReceipt) -- Registers for Buying items from vendor.
		DragonLoot:RegisterForEvent(EVENT_CRAFT_COMPLETED, CraftedItem) -- Registers for Crafted Items.
		SLASH_COMMANDS[command] = commandHandler -- The slash command handler for chat commands.
		ShowLootWindow()
	
	end

end

--Function that handles chat commands from /dl in the chat window.
function commandHandler( text )

-- Create a lookup table for evaluating "text" functions that control variables, _G is the global function table
	local funct = {
	
	["help"] = _G["ShowHelp"],
	["settings"] = _G["ShowSettings"],
	["lootwindow"] = _G["ToggleLootWindow"],
	
	}
	
	--Check to see if we recognize the command.
	if (funct[text] == nil) then 
		
		d( "Dragon Loot: Unrecognised Command use /dl \"help\" for commands" )
		
	else
		
		funct[text]() -- Run the function called from the funct table.
		
	end 
	
end

--Function to make the settings window, we don't make the window unless someone calls it from the chat command.
function ShowSettings()

	if (dlSettings == nil) then  -- Check to see if the window already exists

		-- Create the top level container for the window, this is what everything below it will bind to.
		dl_settings = WINDOW_MANAGER:CreateTopLevelWindow("dlSettings")
		dl_settings:SetMouseEnabled( true )
		dl_settings:SetHidden( false )
		dl_settings:SetMovable( true )
		dl_settings:SetDimensions( 400,395 )
		dl_settings:SetAnchor( TOPLEFT,GuiRoot,TOPLEFT,DL.savedVars.settingsX,DL.savedVars.settingsY )
		
		--Create the title label for the window
		dl_settings_Title = WINDOW_MANAGER:CreateControl("Title", dlSettings, CT_LABEL)
		dl_settings_Title:SetDimensions( dl_settings:GetWidth() , 36 )
		dl_settings_Title:SetFont( "ZoFontWindowTitle" )
		dl_settings_Title:SetColor(1,1,1,1)
		dl_settings_Title:SetHorizontalAlignment(1)
		dl_settings_Title:SetVerticalAlignment(0)
		dl_settings_Title:SetText( "Dragon Loot Settings")
		dl_settings_Title:SetAnchor(TOP,dl_settings,TOP,0,10)
		
		--Set the Close Button at the top of the window.
		dl_settings_clsBtn = WINDOW_MANAGER:CreateControl("Close" , dlSettings , CT_BUTTON)
		dl_settings_clsBtn:SetDimensions( 25 , 25 )
		dl_settings_clsBtn:SetFont("ZoFontGameBold")
		dl_settings_clsBtn:SetAnchor(TOPRIGHT,dlSettings,TOPRIGHT,-5,5)
		dl_settings_clsBtn:SetNormalFontColor(1,1,1,1)
		dl_settings_clsBtn:SetMouseOverFontColor(0.8,0.4,0,1)
		dl_settings_clsBtn:SetText('[X]')
		dl_settings_clsBtn:SetState( BSTATE_NORMAL )
		dl_settings_clsBtn:SetHandler( "OnClicked" , function() CloseWindow() end )
		
		--Set a background to make the window look nice and have a definite shape.
		dl_settings_BG = WINDOW_MANAGER:CreateControl("dlSettingsBG", dlSettings, CT_BACKDROP)
		dl_settings_BG:SetDimensions( dl_settings:GetWidth() , dl_settings:GetHeight() )
		dl_settings_BG:SetCenterColor(0,0,0,0.5)
		dl_settings_BG:SetEdgeColor(.1,.1,.1,1)
		dl_settings_BG:SetEdgeTexture("",8,1,2)
		dl_settings_BG:SetAnchor(CENTER,dlSettings,CENTER,0,0)
		
		--This function dynamically creates the labels and buttons.
		MakeLabels()
	
	else
	
		dlSettings:SetHidden(false) -- If the window has already been created then show it.
		
	end

end

--Dynamically creates labels and buttons on the dlSettings window.
function MakeLabels()

	local lbl_offsetX = 30
	local lbl_offsetY = 60
	
	local btn_offsetX = -30
	local btn_offsetY = 60
	local tileoffset = 30
	
		local labels = 
	{
		"Trash",
		"Normal",
		"Magic",
		"Gold",
		"Quest",
		"Group",
	}


	--:::::This for loop creates several of the item and gold filtering buttons and labels dynamically. (saves us a lot of code)
	--:::::It iterates through the list above creating each label and button based on that list.
	for  _, label in ipairs(labels) do
		
		local labelname = "dl_settings_" .. label 
	
		lablename = WINDOW_MANAGER:CreateControl(label,dlSettings,CT_LABEL)
		lablename:SetDimensions( dlSettings:GetWidth() * 0.6 , 30 )
		lablename:SetText("Show "..label.." Loot..............................................")
		lablename:SetFont("ZoFontGame")
		lablename:SetColor(1,1,1,1)
		lablename:SetVerticalAlignment(1)
		lablename:SetAnchor(TOPLEFT, dlSettings ,TOPLEFT,lbl_offsetX,lbl_offsetY)
		
		lbl_offsetY = (lbl_offsetY + tileoffset) --Increment the offset so that they tile down.
		
		--These local Variables make sure our buttons and labels have unique names.
		local buttonname = "dl_settings_btn" .. label
		local btnID = "btn_" .. label
		local toggleFunction = "Toggle" .. label
		
		buttonname = WINDOW_MANAGER:CreateControl(btnID , dlSettings , CT_BUTTON)
		buttonname:SetDimensions( 25 , 25 )
		buttonname:SetFont("ZoFontGameBold")
		buttonname:SetAnchor(TOPRIGHT,dlSettings,TOPRIGHT,btn_offsetX,btn_offsetY)
		buttonname:SetNormalFontColor(1,1,1,1)
		buttonname:SetMouseOverFontColor(0,1,0,1)
		
		if (DL.savedVars[label]) then
			buttonname:SetText('[X]')
		else 
			buttonname:SetText('[  ]')
		end
		
		buttonname:SetState( BSTATE_NORMAL )
		buttonname:SetHandler( "OnClicked" , function() _G[toggleFunction](buttonname) end)
		
		btn_offsetY = (btn_offsetY + tileoffset) -- Increment the offset so that the buttons tile with the labels.		

	end
	
		--:::::Sell Notification Label and Button
		--We don't have to increment the Y anchor because when the for loop above finishes it will have incremented it for us.
		dl_settings_sell = WINDOW_MANAGER:CreateControl("dlSell",dlSettings,CT_LABEL)
		dl_settings_sell:SetDimensions( dlSettings:GetWidth() * 0.6 , 30 )
		dl_settings_sell:SetText("Show Store Sell Receipt......................................")
		dl_settings_sell:SetFont("ZoFontGame")
		dl_settings_sell:SetColor(1,1,1,1)
		dl_settings_sell:SetVerticalAlignment(1)
		dl_settings_sell:SetAnchor(TOPLEFT, dlSettings ,TOPLEFT,lbl_offsetX,lbl_offsetY)
	
		dl_settings_sell_btn = WINDOW_MANAGER:CreateControl("dlSellbtn" , dlSettings , CT_BUTTON)
		dl_settings_sell_btn:SetDimensions( 25 , 25 )
		dl_settings_sell_btn:SetFont("ZoFontGameBold")
		dl_settings_sell_btn:SetAnchor(TOPRIGHT,dlSettings,TOPRIGHT,btn_offsetX,btn_offsetY)
		dl_settings_sell_btn:SetNormalFontColor(1,1,1,1)
		dl_settings_sell_btn:SetMouseOverFontColor(0,1,0,1)
		
		if (DL.savedVars.Sell) then
			dl_settings_sell_btn:SetText('[X]')
		else 
			dl_settings_sell_btn:SetText('[  ]')
		end
		
		dl_settings_sell_btn:SetState( BSTATE_NORMAL )
		dl_settings_sell_btn:SetHandler( "OnClicked" , function() ToggleSell(dl_settings_sell_btn) end)
		
		--:::::Buy Notification Label and Button
		--Now we have to increment Y anchor because we just created the label and button above outside the loop.
		lbl_offsetY = (lbl_offsetY + tileoffset)
		btn_offsetY = (btn_offsetY + tileoffset)
		
		dl_settings_buy = WINDOW_MANAGER:CreateControl("dlBuy",dlSettings,CT_LABEL)
		dl_settings_buy:SetDimensions( dlSettings:GetWidth() * 0.6 , 30 )
		dl_settings_buy:SetText("Show Store Buy Receipt......................................")
		dl_settings_buy:SetFont("ZoFontGame")
		dl_settings_buy:SetColor(1,1,1,1)
		dl_settings_buy:SetVerticalAlignment(1)
		dl_settings_buy:SetAnchor(TOPLEFT, dlSettings ,TOPLEFT,lbl_offsetX,lbl_offsetY)
	
		dl_settings_buy_btn = WINDOW_MANAGER:CreateControl("dlBuybtn" , dlSettings , CT_BUTTON)
		dl_settings_buy_btn:SetDimensions( 25 , 25 )
		dl_settings_buy_btn:SetFont("ZoFontGameBold")
		dl_settings_buy_btn:SetAnchor(TOPRIGHT,dlSettings,TOPRIGHT,btn_offsetX,btn_offsetY)
		dl_settings_buy_btn:SetNormalFontColor(1,1,1,1)
		dl_settings_buy_btn:SetMouseOverFontColor(0,1,0,1)
		
		if (DL.savedVars.Buy) then
			dl_settings_buy_btn:SetText('[X]')
		else 
			dl_settings_buy_btn:SetText('[  ]')
		end
		
		dl_settings_buy_btn:SetState( BSTATE_NORMAL )
		dl_settings_buy_btn:SetHandler( "OnClicked" , function() ToggleBuy(dl_settings_buy_btn) end)
		
		--:::::Auto Sell Label and Button
		--Incrementing the Y anchor again, for the next label and button.
		lbl_offsetY = (lbl_offsetY + tileoffset)
		btn_offsetY = (btn_offsetY + tileoffset)

		dl_settings_autosell = WINDOW_MANAGER:CreateControl("dlAutoSell",dlSettings,CT_LABEL)
		dl_settings_autosell:SetDimensions( dlSettings:GetWidth() * 0.6 , 30 )
		dl_settings_autosell:SetText("Automatically Sell Trash/Junk..................................")
		dl_settings_autosell:SetFont("ZoFontGame")
		dl_settings_autosell:SetColor(1,1,1,1)
		dl_settings_autosell:SetVerticalAlignment(1)
		dl_settings_autosell:SetAnchor(TOPLEFT, dlSettings ,TOPLEFT,lbl_offsetX,lbl_offsetY)
	
		dl_settings_autosell_btn = WINDOW_MANAGER:CreateControl("dlAutoSellbtn" , dlSettings , CT_BUTTON)
		dl_settings_autosell_btn:SetDimensions( 25 , 25 )
		dl_settings_autosell_btn:SetFont("ZoFontGameBold")
		dl_settings_autosell_btn:SetAnchor(TOPRIGHT,dlSettings,TOPRIGHT,btn_offsetX,btn_offsetY)
		dl_settings_autosell_btn:SetNormalFontColor(1,1,1,1)
		dl_settings_autosell_btn:SetMouseOverFontColor(0,1,0,1)
		
		if (DL.savedVars.AutoSell) then
			dl_settings_autosell_btn:SetText('[X]')
		else 
			dl_settings_autosell_btn:SetText('[  ]')
		end
		
		dl_settings_autosell_btn:SetState( BSTATE_NORMAL )
		dl_settings_autosell_btn:SetHandler( "OnClicked" , function() ToggleAutoSell(dl_settings_autosell_btn) end)
		
		--:::::Loot Window Label and Button
		--Incrementing the Y anchor again, for the next label and button.
		lbl_offsetY = (lbl_offsetY + tileoffset)
		btn_offsetY = (btn_offsetY + tileoffset)

		dl_settings_lootwindow = WINDOW_MANAGER:CreateControl("dlLootWindowlbl",dlSettings,CT_LABEL)
		dl_settings_lootwindow:SetDimensions( dlSettings:GetWidth() * 0.6 , 30 )
		dl_settings_lootwindow:SetText("Show Loot Window..................................")
		dl_settings_lootwindow:SetFont("ZoFontGame")
		dl_settings_lootwindow:SetColor(1,1,1,1)
		dl_settings_lootwindow:SetVerticalAlignment(1)
		dl_settings_lootwindow:SetAnchor(TOPLEFT, dlSettings ,TOPLEFT,lbl_offsetX,lbl_offsetY)
	
		dl_settings_lootwindow_btn = WINDOW_MANAGER:CreateControl("dlLootWindowbtn" , dlSettings , CT_BUTTON)
		dl_settings_lootwindow_btn:SetDimensions( 25 , 25 )
		dl_settings_lootwindow_btn:SetFont("ZoFontGameBold")
		dl_settings_lootwindow_btn:SetAnchor(TOPRIGHT,dlSettings,TOPRIGHT,btn_offsetX,btn_offsetY)
		dl_settings_lootwindow_btn:SetNormalFontColor(1,1,1,1)
		dl_settings_lootwindow_btn:SetMouseOverFontColor(0,1,0,1)
		
		if (DL.savedVars.LootWindow) then
			dl_settings_lootwindow_btn:SetText('[X]')
		else 
			dl_settings_lootwindow_btn:SetText('[  ]')
		end
		
		dl_settings_lootwindow_btn:SetState( BSTATE_NORMAL )
		dl_settings_lootwindow_btn:SetHandler( "OnClicked" , function() ToggleLootWindow(dl_settings_lootwindow_btn) end)	
		
		--:::::Loot Window Label and Button
		--Incrementing the Y anchor again, for the next label and button.
		lbl_offsetY = (lbl_offsetY + tileoffset)
		btn_offsetY = (btn_offsetY + tileoffset)

		dl_settings_chatloot = WINDOW_MANAGER:CreateControl("dlChatLoot",dlSettings,CT_LABEL)
		dl_settings_chatloot:SetDimensions( dlSettings:GetWidth() * 0.6 , 30 )
		dl_settings_chatloot:SetText("Show Loot in Chat Window................................")
		dl_settings_chatloot:SetFont("ZoFontGame")
		dl_settings_chatloot:SetColor(1,1,1,1)
		dl_settings_chatloot:SetVerticalAlignment(1)
		dl_settings_chatloot:SetAnchor(TOPLEFT, dlSettings ,TOPLEFT,lbl_offsetX,lbl_offsetY)
	
		dl_settings_chatloot_btn = WINDOW_MANAGER:CreateControl("dlChatLootbtn" , dlSettings , CT_BUTTON)
		dl_settings_chatloot_btn:SetDimensions( 25 , 25 )
		dl_settings_chatloot_btn:SetFont("ZoFontGameBold")
		dl_settings_chatloot_btn:SetAnchor(TOPRIGHT,dlSettings,TOPRIGHT,btn_offsetX,btn_offsetY)
		dl_settings_chatloot_btn:SetNormalFontColor(1,1,1,1)
		dl_settings_chatloot_btn:SetMouseOverFontColor(0,1,0,1)
		
		if (DL.savedVars.ChatLoot) then
			dl_settings_chatloot_btn:SetText('[X]')
		else 
			dl_settings_chatloot_btn:SetText('[  ]')
		end
		
		dl_settings_chatloot_btn:SetState( BSTATE_NORMAL )
		dl_settings_chatloot_btn:SetHandler( "OnClicked" , function() ToggleChatLoot(dl_settings_chatloot_btn) end)			

end

--Close the settings window and save the position for next time.
function CloseWindow()

	dlSettings:SetHidden(true)
	DL.savedVars.settingsY = dlSettings:GetTop()
	DL.savedVars.settingsX = dlSettings:GetLeft()

end

--Player asked for help we list the commands:
function ShowHelp()

		d( "Dragon Loot:  Help Summary v"..version.."...." )
		d( "Commands: " )
		d( "type:    /dl help           -- This Help Menu." )
		d( "type:    /dl settings     -- Lets you see and change current settings and filters.")
		
end

--Toggle Sell Receipts for player
function ToggleSell(buttonname)
	
	DL.savedVars.Sell = (not DL.savedVars.Sell)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Store Sell Receipt -- " .. ((DL.savedVars.Sell) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	

		if (DL.savedVars.Sell) then
			buttonname:SetText('[X]')
		else 
			buttonname:SetText('[  ]')
		end

	d(message) -- Let the player know if it's enabled or disabled.

end

function ToggleChatLoot(buttonname)
	
	DL.savedVars.ChatLoot = (not DL.savedVars.ChatLoot)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Chat Loot -- " .. ((DL.savedVars.ChatLoot) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	

		if (DL.savedVars.ChatLoot) then
			buttonname:SetText('[X]')
		else 
			buttonname:SetText('[  ]')
		end

	d(message) -- Let the player know if it's enabled or disabled.

end

--Toggle Buy Receipts for player
function ToggleBuy(buttonname)
	
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
function ToggleAutoSell(buttonname)
	
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
function ToggleQuest(buttonname)
	
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
function ToggleTrash(buttonname)
	
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
function ToggleNormal(buttonname)
	
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
function ToggleMagic(buttonname)
	
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
function ToggleGold(buttonname)

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
function ToggleGroup(buttonname)

	DL.savedVars.Group = (not DL.savedVars.Group)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Group Loot -- " .. ((DL.savedVars.Group) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	
	if (DL.savedVars.Group) then
			buttonname:SetText('[X]')
	else 
			buttonname:SetText('[  ]')
	end
	
	d(message) -- Let the player know if it's enabled or disabled.
	
	
end

--Function called when an item loot event is triggered from EVENT_LOOT_RECIEVED
function OnLootedItem (numID, lootedBy, itemName, quantity, itemSound, lootType, self)

	if (lootType == LOOT_TYPE_MONEY) then
		d("Money Looted")
	end
  
  
  if (self)  then -- Checking to see if the player looted it or if someone in the party did.
  
		if (DetermineLootType(itemName, lootType)) then  --Check to see if player wants to see the loot
		
			local itemName = itemName:gsub("%^%a+","") -- The item names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
			local message = "You received " .. itemName.. " x"..quantity -- Concatenating the quantity with the item name into a new variable.
			LootWindowHandler(message) -- Tell Player what they recieved.
						
		end
		
  elseif (not self) then  -- Checking to see if it is not the player that looted the item.
 
	  if (DL.savedVars.Group) then  -- Checking to see if we are displaying group loot to the player
	  
		if (DetermineLootType(itemName, lootType)) then  -- Check to see if the player wants to see the loot based on quality.
		
			local lootedBy = lootedBy:gsub("%^%a+","")  -- The character names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
			local itemName = itemName:gsub("%^%a+","") -- The item names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
			local message = lootedBy .. " received ".. itemName.. " x"..quantity -- Concatenating the quantity with the item name into a new variable.
			LootWindowHandler(message) -- Telling the player what they received.
			
		end
		
	  end
	  
  end 
	
end

--Function called when a money event is triggered from EVENT_MONEY_UPDATE
function CashMoney (numId, newMoney, oldMoney, reason)

	if (reason ~= CURRENCY_CHANGE_REASON_VENDOR) then
	
		if (DL.savedVars.Gold) then -- check if we are supposed to show gold
		
			if (newMoney > oldMoney) then  -- Is the new amount of gold larger than the old amount (did we gain money?)
		
				local goldgained = (newMoney - oldMoney)  -- Math to find out how much gold was obtained.
				local message = "You have gained ".. goldgained .. " gold." -- Create Message
				LootWindowHandler(message)
				
			end
			
			--[[if (oldMoney > newMoney) then  -- Is the old amount of money larger than the new amount (did we spend money?)
		
				local goldspent = (oldMoney - newMoney)  -- Math to figure out how much gold was spent.
				d("You have spent [-".. goldspent .. "] gold.") -- Telling the player how much gold they spent.
		
			end]]--
			
		end
		
	end

end

-- Factory function for determining what kind of loot the player wants to see we do this by cheating and looking at the color of the link from the item.
function DetermineLootType(itemName, lootType)

local colorwheel =
{
	Green = "2DC50E",
	White = "FFFFFF",
	Grey = "C3C3C3",
}	

	-- Calling a function to take apart the link and get the color for us, so we can use the color to figure out how rare the item is.
	if (lootType == LOOT_TYPE_ITEM) then	  
		
		local text, color, split = ZO_LinkHandler_ParseLink (itemName)  -- getting the color of the item.
		--d("Color Code:  "..color.. "  LootType:  " ..lootType)  --Debugging code.
	
	elseif (lootType == LOOT_TYPE_QUEST_ITEM) then --Check to see if it's a quest item.
	
		if (DL.savedVars.Quest) then return true -- Check to see if player wants to see quest items.
		end
	
	end	  
  
	if(not InTable(colorwheel, color)) then return true -- Check to see if we know the color, if we don't we want to display it, it could be EPIC!
	
			
	else
			
			if (color == colorwheel.Grey) and (DL.savedVars.Trash) then return true--Check for Grey items and see if the player wants to see grey items.
			elseif (color == colorwheel.White) and (DL.savedVars.Normal) then return true --Check for White items and see if the player wants to see white items.
			elseif (color == colorwheel.Green) and (DL.savedVars.Magic) then return true --Check for Green items and see if the player wants to see green items.
			else return false
			
			end
			
	end
   
end

-- Simple table value lookup function
function InTable(tbl, item)

	for key, value in pairs(tbl) do 
		if (value == item) then return true end
	end
	
	return false
	
end

--Sells trash items when store window is opened evoked from EVENT_OPEN_STORE.
function SellTrash()

	if (DL.savedVars.AutoSell) then
	
		SellAllJunk() --Sell Junk marked by the player.
	
		local icon, bagslots = GetBagInfo(BAG_BACKPACK) -- Get the number of bag slots from the backpack using the BAG_BACKPACK constant. GetBagInfo returns Icon and # of slots integer
		
		for i=1 , bagslots, 1  do -- Look through the bag to sell all the trash items
		
			local itemType = GetItemType(BAG_BACKPACK, i) -- Get the item type from GetItemType()
			
			if (itemType == ITEMTYPE_TRASH) then -- if the itemType is trash then
		
				local stackcount = GetItemTotalCount(BAG_BACKPACK, i) --Get the number of items in the stack
				SellInventoryItem(BAG_BACKPACK, i, stackcount) -- Sell the whole stack.
				
			end
			
			--i = (i + 1) --Increment for the bag slot index.
		
		end
		
	end

end

--Store Receipt for selling items.
function StoreSellReceipt(numid, itemName, itemQuantity, money) 

	if (DL.savedVars.Sell) then
	
		local itemName = itemName:gsub("%^%a+","") --Fix the name because of weird characters.
		local message = "You have sold ".. itemName.." x"..itemQuantity.." for "..money.. " gold."  --Create Message
		LootWindowHandler(message)
		
	end

end

--Store Receipt for bying items.

function StoreBuyReceipt(numID, itemName, entryType, itemQuantity, money, specialCurrencyType1, specialCurrencyInfo1, specialCurrencyQuantity1, specialCurrencyType2, specialCurrencyInfo2, specialCurrencyQuantity2, itemSoundCategory)

	if (DL.savedVars.Buy) then
	
		if (money > 0) then
	
			local itemName = itemName:gsub("%^%a+","") --Fix the name because of weird characters.
			local message = "You have bought ".. itemName.." x"..itemQuantity.." for "..money.. " gold." --Create Message
			LootWindowHandler(message) --Send Message
			
		end
		
	end
	
end

--[[::::::::::::::::::::::::::::::::::::::::::::
:::::::Starting Loot Window for Showing Loot::::
::::::::::::::::::::::::::::::::::::::::::::::::]]--

-- The loot window which displays loot for the player gets made when our addon is loaded, we hide it if they don't want to see it.
function ShowLootWindow()

	if (dlLootWindow == nil) then  -- Check to see if the window already exists

		-- Create the top level container for the window, this is what everything below it will bind to.
		dl_lootWindow = WINDOW_MANAGER:CreateTopLevelWindow("dlLootWindow")
		dl_lootWindow:SetMouseEnabled( true )
		
			if (DL.savedVars.LootWindow) then -- Should we show the window or not based on user settings.
				dl_lootWindow:SetHidden( false )
			else
				dl_lootWindow:SetHidden( true )
			end
			
		dl_lootWindow:SetMovable( true )
		dl_lootWindow:SetHandler( "OnMouseExit" , function() MouseExit(dl_lootWindow) end) -- Call function when mouse exits window
		dl_lootWindow:SetHandler( "OnMouseEnter", function() ShowFaded() end) --If mouse goes in window call function to show faded text and background.
		--dl_lootWindow:SetHandler( "OnMouseUp", function() MouseExit(dl_lootWindow) end)
		dl_lootWindow:SetHandler("OnMouseDown", function() dl_lootBuffer:AddMessage("Move Me .........................",255,165,0,1) end)
		dl_lootWindow:SetHandler("OnMouseWheel", function(self,delta)  -- Handles the mousewheel scrolling in the window

			dl_lootBuffer:MoveScrollPosition(delta) --changes scroll position of  text window based on mouse delta

		end)		
		
		dl_lootWindow:SetDimensions( 450,89 )
		dl_lootWindow:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, DL.savedVars.lwX, DL.savedVars.lwY )
		
		--Set a background to make the window look nice and have a definite shape when moused over.
		dl_lootWindow_BG = WINDOW_MANAGER:CreateControl("dlLootWindowBG",dlLootWindow,CT_BACKDROP)
		dl_lootWindow_BG:SetDimensions( dl_lootWindow:GetWidth() , dl_lootWindow:GetHeight() )
		dl_lootWindow_BG:SetHidden( true )
		dl_lootWindow_BG:SetCenterColor(0,0,0,0.5)
		dl_lootWindow_BG:SetEdgeColor(.1,.1,.1,1)
		dl_lootWindow_BG:SetEdgeTexture("",8,1,2)
		dl_lootWindow_BG:SetAnchor(CENTER,dlLootWindow,CENTER,0,0)
		
		--This control buffers text and handles all text related data being sent to it. Every time we want to send a message we call the :AddMessage attribute.
		dl_lootBuffer = WINDOW_MANAGER:CreateControl("lootedBuffer", dlLootWindow, CT_TEXTBUFFER)
 		dl_lootBuffer:SetLinkEnabled( true )
 		dl_lootBuffer:SetFont("ZoFontChat")
 		dl_lootBuffer:SetHidden(false)
		dl_lootBuffer:SetClearBufferAfterFadeout(true)
 		dl_lootBuffer:SetLineFade(7,3) -- Sets fade timers for text- Time until fade, time to fade. 
 		dl_lootBuffer:SetMaxHistoryLines(40)
 		dl_lootBuffer:AddMessage("Welcome To Dragon Loot \n Type \"/dl help\" for help!",255,255,0,1)
		dl_lootBuffer:SetAnchorFill(dlLootWindow)
	
	else
	
		dlLootWindow:SetHidden(false) -- If the window has already been created then show it.
		
	end

end

--You can turn the window off and on from the settings menu.
function ToggleLootWindow(buttonname)

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

--This function now handles all displays to the user including chat and the loot window.
function LootWindowHandler(message)
	
	--[[We dont check if the player wants loot to go to the loot window because we are assuming
	     if they do not want to see it then the window is hidden.  Loot still goes to the window so if they turn it back on
	     the history will be there.]]
	dl_lootBuffer:AddMessage(message,255,165,0,1) -- Sends text to loot window
	
	if (DL.savedVars.ChatLoot) then --Check if we want to see it in chat.
		d(message)	--Sends Loot to Chat
	end
	
end

--Handles what happens when the mouse exits the loot window.
function MouseExit(window)

	DL.savedVars.lwX = window:GetLeft() -- Set player variables for window position
	DL.savedVars.lwY = window:GetTop() -- Set player variables for window position
		
	dl_lootWindow_BG:SetHidden( true ) -- Hide the background again
	dl_lootBuffer:SetScrollPosition(0) --Set the scroll position to the bottom of the text box.
	
end

--Shows the background and faded text lines when the mouse enters the window.
function ShowFaded()

	dl_lootWindow_BG:SetHidden( false )
	dl_lootBuffer:ShowFadedLines()	

end

function CraftedItem()


	--local craftedName, icon, stack, sellPrice, usageRequirement, equipType, itemType, itemStyle, quality, sound, itemInstanceID = GetLastCraftingResultItemInfo()
	local itemInfo = {GetLastCraftingResultItemInfo()}

	for i=1 , bagslots, 1  do
		
		local itemName = GetItemName(BAG_BACKPACK, i) 
			
		if (itemName == itemInfo[1]) then 
		
			local itemLink = GetItemLink(BAG_BACKPACK, i, LINK_STYLE_DEFAULT) 
			break
				
		end
		
	end

	local message = "You have crafted ".. itemLink .." x"..itemInfo[3]

	LootWindowHandler(message)
	
end


--::::::::::::::::::::::::::::::::::::::::::::::: For testing colors in the chat windows.
--[[

function ColorTest()

	for r = 0, 255, 20 do
	
		for b = 0, 255, 20 do
		
			for g = 0, 255, 20 do
			
					dl_lootBuffer:AddMessage( r .. "," ..b..","..g , r,b,g,1)
					
			end
			
		end
		
	end


end]]
