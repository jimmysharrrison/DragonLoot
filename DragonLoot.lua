--[[

Author:		@Qwexton
File:			DragonLoot.lua
Version:	Alpha 1.2
Date:		2-21-2014

]]--



--[[

TODO:
	
	Create function to handle store buy receipts and buy back receipts ( EVENT_BUY_RECEIPT and EVENT_BUYBACK_RECEIPT )
	Create XML frame for settings.
	Create seperate frame to send loot mesages to.

]]--

--Setting Global Constants

command = "/dl"
version = 1.2
DL = {}
	
--Set default Variables:	
	
DL.defaultVar =
{
	["Gold"]			= true,
	["Group"]			= true,
	["Trash"]			= true,
	["Normal"]			= true,
	["Magic"]			= true,
	["Quest"]			= true,
	["Other"]			= true,
}

--Initialized function called from DragonLoot.xml in the addon folder
function DragonLootLoad()

	
	--Register events with the API for Looted Items Gold received and commands in the chat window.
	EVENT_MANAGER:RegisterForEvent("DragonLoot", EVENT_ADD_ON_LOADED, OnAddOnLoaded) -- Register for event of loading our addon.
	
	
end

function OnAddOnLoaded(eventCode, addOnName)

--Check if our addon is loaded:

	if (addOnName == "DragonLoot") then		

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
	["settings"] = _G["ShowDLSettings"],
	["quest"] = _G["ToggleQuest"],
	["test"]	=	_G["ShowSettings"],
	
	
	}
	
	--Check to see if we recognize the command.
	if (funct[text] == nil) then 
		
		d( "Dragon Loot: Unrecognised Command use /dl \"help\" for commands" )
		
	else
		
		funct[text]() -- Run the function called from the funct table.
		
	end 
	
end



function ShowSettings()

	if (dlSettings == nil) then 

		dl_settings = WINDOW_MANAGER:CreateTopLevelWindow("dlSettings")
		dl_settings:SetMouseEnabled( true )
		dl_settings:SetHidden( false )
		dl_settings:SetMovable( true )
		dl_settings:SetDimensions( 400,400 )
		dl_settings:SetAnchor( BOTTOM,GuiRoot,BOTTOM,0,-200 )
	
		dl_settings_Title = WINDOW_MANAGER:CreateControl("Title",dlSettings,CT_LABEL)
		dl_settings_Title:SetDimensions( dl_settings:GetWidth() , 36 )
		dl_settings_Title:SetFont( "ZoFontWindowTitle" )
		dl_settings_Title:SetColor(1,1,1,1)
		dl_settings_Title:SetHorizontalAlignment(1)
		dl_settings_Title:SetVerticalAlignment(0)
		dl_settings_Title:SetText( "Dragon Loot Settings")
		dl_settings_Title:SetAnchor(TOP,dl_settings,TOP,0,10)
	
		dl_settings_clsBtn = WINDOW_MANAGER:CreateControl("Close" , dlSettings , CT_BUTTON)
		dl_settings_clsBtn:SetDimensions( 25 , 25 )
		dl_settings_clsBtn:SetFont("ZoFontGameBold")
		dl_settings_clsBtn:SetAnchor(TOPRIGHT,dlSettings,TOPRIGHT,-5,5)
		dl_settings_clsBtn:SetNormalFontColor(1,1,1,1)
		dl_settings_clsBtn:SetMouseOverFontColor(0.8,0.4,0,1)
		dl_settings_clsBtn:SetText('[X]')
		dl_settings_clsBtn:SetState( BSTATE_NORMAL )
		dl_settings_clsBtn:SetHandler( "OnClicked" , function() CloseWindow() end )
		
		dl_settings_BG = WINDOW_MANAGER:CreateControl("dlSettingsBG",dlSettings,CT_BACKDROP)
		dl_settings_BG:SetDimensions( dl_settings:GetWidth() , dl_settings:GetHeight() )
		dl_settings_BG:SetCenterColor(0,0,0,0.5)
		dl_settings_BG:SetEdgeColor(.1,.1,.1,1)
		dl_settings_BG:SetEdgeTexture("",8,1,2)
		dl_settings_BG:SetAnchor(CENTER,dlSettings,CENTER,0,0)
	
	else
	
		dlSettings:SetHidden(false)
		
	end

end


function CloseWindow()

	dlSettings:SetHidden(true)

end

--Player asked for help we list the commands:
function ShowHelp()

		d( "Dragon Loot:  Help Summary ...." )
		d( "Commands: " )
		d( "type:    /dl gold          -- Toggles Gold off and on" )
		d( "type:    /dl group        -- Toggles Group Loot off and on")
		d( "type:    /dl trash         -- Toggles Trash Loot (Grey) off and on")
		d( "type:    /dl normal      -- Toggles Normal Loot (White) off and on")
		d( "type:    /dl magic        -- Toggles Magic Loot (Green) off and on")
		d( "type:    /dl quest        -- Toggles Quest Loot off and on")
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
		"Quest",
	}

	d("-----------------DL Settings ------------------")
	-- Loops through settings table and checks each variable for it's value.
	for _, setting in ipairs(settings) do

		local message = "Dragon Loot: ".. setting .. " Loot  -- ".. ((DL.savedVars[setting]) and "Enabled" or "Disabled")
		d(message)

	end

end

function ToggleQuest()
	
	DL.savedVars.Quest = (not DL.savedVars.Quest)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Quest Loot -- " .. ((DL.savedVars.Quest) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	d(message) -- Let the player know if it's enabled or disabled.

end

-- Toggles Trash loot.
function ToggleTrash()
	
	DL.savedVars.Trash = (not DL.savedVars.Trash)  --Flip the boolean value to true or false
	local message = "Dragon Loot: Trash Loot -- " .. ((DL.savedVars.Trash) and "Enabled" or "Disabled")  -- Check the value for enabled or disabled.
	d(message) -- Let the player know if it's enabled or disabled.

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
function OnLootedItem (numID, lootedBy, itemName, quantity, itemSound, lootType, self)

  if (self)  then -- Checking to see if the player looted it or if someone in the party did.
  
		if (DetermineLootType(itemName, lootType)) then  --Check to see if player wants to see the loot
		
			itemName = itemName:gsub("%^%a+","") -- The item names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
			local message = "You Received ["..quantity.."] " .. itemName -- Concatenating the quantity with the item name into a new variable.
			d(message) -- Telling the player what they received.
						
		end
		
  elseif (not self) then  -- Checking to see if it is not the player that looted the item.
 
	  if (DL.savedVars.Group) then  -- Checking to see if we are displaying group loot to the player
	  
		if (DetermineLootType(itemName, lootType)) then  -- Check to see if the player wants to see the loot.
		
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


-- Factory function for determining what kind of loot the player wants to see we do this by cheating and looking at the color of the link from the item.
function DetermineLootType(itemName, lootType)

local colorwheel =
{
	Green = "2DC50E",
	White = "FFFFFF",
	Grey = "C3C3C3",
}	

	-- Calling a function to take apart the link and get teh color for us, so we can use the color to figure out how rare the item is.
	if (lootType == LOOT_TYPE_ITEM) then	  
		
		text, color, split = ZO_LinkHandler_ParseLink (itemName)  -- getting the color of the item.
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
