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
	Add persistence settings variables.

]]--




--Initialized function called from DragonLoot.xml in the addon folder
function DragonLootLoad()

--Setting Global Variables
	showgold = true
	grouploot = true
	command = "/dl"

--Register events with the API for Looted Items Gold received and commands in the chat window.
	DragonLoot:RegisterForEvent(EVENT_LOOT_RECEIVED, OnLootedItem)  -- Registers for the loot received event then calls the OnLootedItem function.
	DragonLoot:RegisterForEvent(EVENT_MONEY_UPDATE, CashMoney) -- Registers for gold change events then calls the CashMoney function.
	SLASH_COMMANDS[command] = commandHandler -- The slash command handler for chat commands.


end


--Function that handles chat commands from /dl in the chat window.
function commandHandler( text )

	if ( text == "" )  then  -- Checking for blank commands
	
		d( "Dragon Loot: No Command Entered use \"help\" for commands" )
		
	elseif ( text == "help" ) then -- Someone asking for help
	
		d( "Dragon Loot:  Help Summary ...." )
		d( "Commands: " )
		d( "type:    /dl gold    -- Toggles Gold off and on" )
		d( "type:    /dl group  -- Toggles Group Loot off and on")
		
	elseif ( text == "gold") then
	
		ToggleGold() -- Toggle the gold display variable.
		
	elseif (text == "group") then
	
		ToggleGroup() -- Toggle the grouploot display variable.
		
	else
	
		d( "Dragon Loot: Unrecognised Command use \"help\" for commands" )
		
	end
	
end

--Used to toggle the showgold variable.
function ToggleGold()

	if (showgold) then
	  showgold = false
	  d("Dragon Loot: Gold Disabled")
	else
	  showgold = true
	  d("Dragon Loot: Gold Enabled")
	end
	  
end

--Used to toggle the grouploot variable
function ToggleGroup()

	if (grouploot) then
	  grouploot = false
	  d("Dragon Loot: Group Loot Disabled")
	else
	  grouploot = true
	  d("Dragon Loot: Group Loot Enabled")
	end
	  
end

--Function called when an item loot event is triggered from EVENT_LOOT_RECIEVED
function OnLootedItem(numID, lootedBy, itemName, quantity, itemSound, lootType, self)

  if (self == true)  then -- Checking to see if the player looted it or if someone in the party did.
  
	  itemName = itemName:gsub("%^%a+","") -- The item names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
	  message = "You Received ["..quantity.."] " .. itemName -- Concatenating the quantity with the item name into a new variable.
	  d(message) -- Telling the player what they received.
	  d(lootType)
	  
  elseif (self ~= true) then  -- Checking to see if it is not the player that looted the item.
 
	  if (grouploot) then  -- Checking to see if we are displaying group loot to the player
	  
		lootedBy = lootedBy:gsub("%^%a+","")  -- The character names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
		itemName = itemName:gsub("%^%a+","") -- The item names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
		message = lootedBy .. " Received ["..quantity.."] " .. itemName -- Concatenating the quantity with the item name into a new variable.
		d(message) -- Telling the player what they received.
		
	  end
	  
  end
	
end

--Function called when a money event is triggered from EVENT_MONEY_UPDATE
function CashMoney (reason, newMoney, oldMoney)

	if (showgold) then -- check if we are supposed to show gold
	
		if (newMoney > oldMoney) then  -- Is the new amount of gold larger than the old amount (did we gain money?)
	
		goldgained = (newMoney - oldMoney)  -- Math to find out how much gold was obtained.
		d("You have gained [+".. goldgained .. "] gold") -- Telling the player how much gold they got.
	  
		end
		

		if (oldMoney > newMoney) then  -- Is the old amount of money larger than the new amount (did we spend money?)
	
		goldspent = (oldMoney - newMoney)  -- Math to figure out how much gold was spent.
		d("You have spent [-".. goldspent .. "] gold") -- Telling the player how much gold they spent.
	  
		end
		
	end

end


