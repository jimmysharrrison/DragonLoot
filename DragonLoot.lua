--[[

Author:		@Qwexton
File:			DragonLoot.lua
Version:	Alpha 1.1
Date:		2-19-2014

]]--



--[[

TODO:
	Add Item Quality Check for Looting
	Create function to handle store buy receipts and buy back receipts ( EVENT_BUY_RECEIPT and EVENT_BUYBACK_RECEIPT )
	Create XML frame for settings

]]--


--Initialized function called from DragonLoot.xml in the addon folder
function DragonLootLoad()

--Setting Global Constants
	command = "/dl"
	version = 1.1
	DL = {}

	--Register events with the API for Looted Items Gold received and commands in the chat window.
	EVENT_MANAGER:RegisterForEvent("DragonLoot", EVENT_ADD_ON_LOADED, OnAddOnLoaded) -- Register for event of loading our addon.


end

function OnAddOnLoaded(eventCode, addOnName)

--Check if our addon is loaded:

	if (addOnName == "DragonLoot") then
	
		--Set default Variables:	
		
		DL.defaultVar =
	{
		["showgold"]		= true,
		["grouploot"]		= true,
	}
	
	DL.savedVars = ZO_SavedVars:New( "DragonLoot_Variables", math.floor(version * 10 ), nil , DL.defaultVar, nil) --Method for adding persistent variables	
	
	DragonLoot:RegisterForEvent(EVENT_MONEY_UPDATE, CashMoney) -- Registers for gold change events then calls the CashMoney function.
	DragonLoot:RegisterForEvent(EVENT_LOOT_RECEIVED, OnLootedItem)  -- Registers for the loot received event then calls the OnLootedItem function.
	SLASH_COMMANDS[command] = commandHandler -- The slash command handler for chat commands.
	
	end

end


--Function that handles chat commands from /dl in the chat window.
function commandHandler( text )

	if ( text == "" )  then  -- Checking for blank commands
	
		d( "Dragon Loot: No Command Entered use /dl \"help\" for commands" )
		
	elseif ( text == "help" ) then -- Someone asking for help
	
		d( "Dragon Loot:  Help Summary ...." )
		d( "Commands: " )
		d( "type:    /dl gold    -- Toggles Gold off and on" )
		d( "type:    /dl group  -- Toggles Group Loot off and on")
		
	elseif ( text == "gold") then
	
		ToggleGold() -- Toggle the gold display variable.
		
	elseif (text == "group") then
	
		ToggleGroup() -- Toggle the DL.savedVars.grouploot display variable.
		
	else
	
		d( "Dragon Loot: Unrecognised Command use /dl \"help\" for commands" )
		
	end
	
end

--Used to toggle the showgold variable.
function ToggleGold()

	if (DL.savedVars.showgold) then
	
	  DL.savedVars.showgold = false
	  d("Dragon Loot: Gold Disabled")
	  
	else
	
	  DL.savedVars.showgold = true
	  d("Dragon Loot: Gold Enabled")
	  
	end
	  
end

--Used to toggle the DL.savedVars.grouploot variable
function ToggleGroup()

	if (DL.savedVars.grouploot) then
	
	  DL.savedVars.grouploot = false
	  d("Dragon Loot: Group Loot Disabled")
	  
	else
	
	  DL.savedVars.grouploot = true
	  d("Dragon Loot: Group Loot Enabled")
	  
	end
	
end

--Function called when an item loot event is triggered from EVENT_LOOT_RECIEVED
function OnLootedItem(numID, lootedBy, itemName, quantity, itemSound, lootType, self)

  if (self)  then -- Checking to see if the player looted it or if someone in the party did.
  
	  itemName = itemName:gsub("%^%a+","") -- The item names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
	  message = "You Received ["..quantity.."] " .. itemName -- Concatenating the quantity with the item name into a new variable.
	  d(message) -- Telling the player what they received.
	  
  elseif (not self) then  -- Checking to see if it is not the player that looted the item.
 
	  if (DL.savedVars.grouploot) then  -- Checking to see if we are displaying group loot to the player
	  
		lootedBy = lootedBy:gsub("%^%a+","")  -- The character names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
		itemName = itemName:gsub("%^%a+","") -- The item names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
		message = lootedBy .. " Received ["..quantity.."] " .. itemName -- Concatenating the quantity with the item name into a new variable.
		d(message) -- Telling the player what they received.
		
	  end
	  
  end
	
end

--Function called when a money event is triggered from EVENT_MONEY_UPDATE
function CashMoney (reason, newMoney, oldMoney)

	if (DL.savedVars.showgold) then -- check if we are supposed to show gold
	
		if (newMoney > oldMoney) then  -- Is the new amount of gold larger than the old amount (did we gain money?)
	
		goldgained = (newMoney - oldMoney)  -- Math to find out how much gold was obtained.
		d("You have gained [+".. goldgained .. "] gold") -- Telling the player how much gold they gained.
	  
		end
		

		if (oldMoney > newMoney) then  -- Is the old amount of money larger than the new amount (did we spend money?)
	
		goldspent = (oldMoney - newMoney)  -- Math to figure out how much gold was spent.
		d("You have spent [-".. goldspent .. "] gold") -- Telling the player how much gold they spent.
	  
		end
		
	end

end


