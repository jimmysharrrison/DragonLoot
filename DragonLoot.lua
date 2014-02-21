--[[

Author:		@Qwexton
File:			DragonLoot.lua
Version:	Alpha 1.2
Date:		2-21-2014

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
	version = 1.2
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
		["Gold"]			= true,
		["Group"]			= true,
		["Trash"]		= true,
		["Normal"]		= true,
		["Magic"]		= true,
		["Legendary"]	= true,
		["Artifact"]		= true,
		["Arcane"]		= true,
	}
	
	DL.savedVars = ZO_SavedVars:New( "DragonLoot_Variables", math.floor(version * 10 ), nil , DL.defaultVar, nil) --Method for adding persistent variables	
	
	DragonLoot:RegisterForEvent(EVENT_MONEY_UPDATE, CashMoney) -- Registers for gold change events then calls the CashMoney function.
	DragonLoot:RegisterForEvent(EVENT_LOOT_RECEIVED, OnLootedItem)  -- Registers for the loot received event then calls the OnLootedItem function.
	SLASH_COMMANDS[command] = commandHandler -- The slash command handler for chat commands.
	
	end

end


--Function that handles chat commands from /dl in the chat window.
function commandHandler( text )

-- Create a lookup table for evaluating "text" functions that control variables, _G is the global function table
	local funct = {
	
	["help"] = _G["ShowHelp"],
	["gold"] = _G["ToggleGold"],
	["group"] = _G["ToggleGroup"],
	["trash"] = _G["ToggleTrash"],
	["normal"] = _G["ToggleNormal"],
	["magic"] = _G["ToggleMagic"],
	["legendary"] = _G["ToggleLegendary"],
	["artifact"] = _G["ToggleArtifact"],
	["arcane"] = _G["ToggleArcane"],
	["settings"] = _G["ShowDLSettings"],
	
	
	}
	
	--Check to see if we recognize the command.
	if (funct[text] == nil) then 
		
		d( "Dragon Loot: Unrecognised Command use /dl \"help\" for commands" )
		
	else
		
		funct[text]() -- Run the function called from the funct table.
		
	end 
	
	
end



--Player asked for help we list the commands:
function ShowHelp()

		d( "Dragon Loot:  Help Summary ...." )
		d( "Commands: " )
		d( "type:    /dl gold          -- Toggles Gold off and on" )
		d( "type:    /dl group        -- Toggles Group Loot off and on")
		d( "type:    /dl trash         -- Toggles Trash Loot off and on")
		d( "type:    /dl normal      -- Toggles Normal Loot off and on")
		d( "type:    /dl magic        -- Toggles Magic Loot off and on")
		d( "type:    /dl legendary  -- Toggles Legendary Loot off and on")
		d( "type:    /dl artifact      -- Toggles Artifact Loot off and on")
		d( "type:    /dl arcane      -- Toggles Arcane Loot off and on")
		d( "type:    /dl settings     -- Lets you see your current settings")

end


function ShowDLSettings()

-- Table of Variable names / there is probably a better way to do this without the table.
	local settings = 
	{
		"Gold",
		"Group",
		"Trash",
		"Normal",
		"Magic",
		"Legendary",
		"Artifact",
		"Arcane",
	}

	d("-----------------DL Settings ------------------")
	-- Loops through settings table and checks each variable for it's value.
	for _, setting in ipairs(settings) do

		local message = "Dragon Loot: ".. setting .. " Loot  -- ".. ((DL.savedVars[setting]) and "Enabled" or "Disabled")
		d(message)

	end

end


function ToggleNormal()
	
	DL.savedVars.Normal = (not DL.savedVars.Normal)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Normal Loot -- " .. ((DL.savedVars.Normal) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	d(message) -- Let the player know if it's enabled or disabled.

end

function ToggleMagic()
	
	DL.savedVars.Magic = (not DL.savedVars.Magic)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Magic Loot -- " .. ((DL.savedVars.Magic) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	d(message) -- Let the player know if it's enabled or disabled.

end

function ToggleLegendary()
	
	DL.savedVars.Legendary = (not DL.savedVars.Legendary)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Legendary Loot -- " .. ((DL.savedVars.Legendary) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	d(message) -- Let the player know if it's enabled or disabled.

end

function ToggleArtifact()
	
	DL.savedVars.Artifact = (not DL.savedVars.Artifactl)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Artifact Loot -- " .. ((DL.savedVars.Artifact) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	d(message) -- Let the player know if it's enabled or disabled.

end

function ToggleArcane()
	
	DL.savedVars.Arcane = (not DL.savedVars.Arcane)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Arcane Loot -- " .. ((DL.savedVars.Arcane) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	d(message) -- Let the player know if it's enabled or disabled.

end

-- Toggles Trash loot.
function ToggleTrash()
	
	DL.savedVars.Trash = (not DL.savedVars.Trash)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Trash Loot -- " .. ((DL.savedVars.Trash) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	d(message) -- Let the player know if it's enabled or disabled.

end

--Used to toggle the Gold variable.
function ToggleGold()

	DL.savedVars.Gold = (not DL.savedVars.Gold)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Gold -- " .. ((DL.savedVars.Gold) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	d(message) -- Let the player know if it's enabled or disabled.
		  
end

--Used to toggle the Group variable
function ToggleGroup()

	DL.savedVars.Group = (not DL.savedVars.Group)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Group Loot -- " .. ((DL.savedVars.Group) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	d(message) -- Let the player know if it's enabled or disabled.
	
	
end

--Function called when an item loot event is triggered from EVENT_LOOT_RECIEVED
function OnLootedItem (numID, lootedBy, itemName, quantity, itemSound, lootType, self, argA)

  if (self)  then -- Checking to see if the player looted it or if someone in the party did.
  
		if (DetermineLootType(itemName)) then  --Check to see if player wants to see the loot
		
			itemName = itemName:gsub("%^%a+","") -- The item names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
			local message = "You Received ["..quantity.."] " .. itemName -- Concatenating the quantity with the item name into a new variable.
			d(message) -- Telling the player what they received.
			
		end
		
  elseif (not self) then  -- Checking to see if it is not the player that looted the item.
 
	  if (DL.savedVars.Group) then  -- Checking to see if we are displaying group loot to the player
	  
		if (DetermineLootType(itemName)) then  -- Check to see if the player wants to see the loot.
		
			lootedBy = lootedBy:gsub("%^%a+","")  -- The character names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
			itemName = itemName:gsub("%^%a+","") -- The item names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
			local message = lootedBy .. " Received ["..quantity.."] " .. itemName -- Concatenating the quantity with the item name into a new variable.
			d(message) -- Telling the player what they received.
			
		end
		
	  end
	  
  end 
	
end

--Function called when a money event is triggered from EVENT_MONEY_UPDATE
function CashMoney (reason, newMoney, oldMoney)

	if (DL.savedVars.Gold) then -- check if we are supposed to show gold
	
		if (newMoney > oldMoney) then  -- Is the new amount of gold larger than the old amount (did we gain money?)
	
			local goldgained = (newMoney - oldMoney)  -- Math to find out how much gold was obtained.
			d("You have gained [+".. goldgained .. "] gold") -- Telling the player how much gold they gained.
			
	  
		end
		

		if (oldMoney > newMoney) then  -- Is the old amount of money larger than the new amount (did we spend money?)
	
			local goldspent = (oldMoney - newMoney)  -- Math to figure out how much gold was spent.
			d("You have spent [-".. goldspent .. "] gold") -- Telling the player how much gold they spent.
	  
		end
		
	end

end


-- Factory function for determining what kind of loot the player wants to see.
function DetermineLootType(itemName)

	if (lootType == ITEM_QUALITY_TRASH) and (DL.savedVars.Trash) then
	
	return true
	
	elseif (lootType == ITEM_QUALITY_NORMAL) and (DL.savedVars.Normal) then
	
	return true
	
	elseif (lootType == ITEM_QUALITY_MAGIC) and (DL.savedVars.Magic) then
	
	return true
	
	elseif (lootType == ITEM_QUALITY_LEGENDARY) and (DL.savedVars.Legendary) then
	
	return true
	
	elseif (lootType == ITEM_QUALITY_ARTIFACT) and (DL.savedVars.Artifact) then
	
	return true
	
	elseif (lootType == ITEM_QUALITY_ARCANE) and (DL.savedVars.Arcane) then
	
	return true
	
	else
	
	return false
	
   end
   
   --ZO_LinkHandler_ParseLink 

end





--[[

function ZO_LinkHandler_ParseLink(link) 
	if type(link) == "string" then 
		local color, data, text = link:match("|H(.-):(.-)|h(.-)|h") 
		return text, color, zo_strsplit(':', data) 
	end 
end

]]--

--[[
These match to lootType 

LOOT_TYPE_ANY  
LOOT_TYPE_ITEM  
LOOT_TYPE_MONEY
LOOT_TYPE_QUEST_ITEM

]]








