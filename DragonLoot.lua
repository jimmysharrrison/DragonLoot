--[[

Author:		@Qwexton
File:			DragonLoot.lua
Version:	Alpha 1.6
Date:		3-06-2014

]]--

--[[

TODO:
	
	Figure out how to get loot links working in the loot window.
	
	--Created Buy Back function for store buy backs.
	--Created Crafting function to handle crafting items.
	--Made Loot Window Re-sizable.
	--Fixed some behavior issues with the loot window.
	--After loot window lines fade they are erased so they only keep a current history of loot.
	--Fixed variable scoping in a number of places to keep addon from colliding with other addons.
	--General house keeping to make dealing with the size of the addon easier.

]]--

--Setting Global Constants
DL = {}
DL.command = "/dl"
DL.version = 1.6

	
--Set default Variables:	
	
DL.defaultVar =
{
	["Gold"]			= true,
	["Group"]			= true,
	["Trash"]			= true,
	["Normal"]			= true,
	["Magic"]			= true,
	["Quest"]			= true,
	["Sell"]				= true,
	["Buy"]				= true,
	["AutoSell"]		= true,
	["settingsY"] 		= 300,
	["settingsX"]		= 500,
	["lwY"]				= 670,
	["lwX"]				= 270,
	["LootWindow"]		= true,
	["LWWidth"]			= 450,
	["LWHeight"]			= 89, 
	["ChatLoot"]			=true
}

--Initialized function called from DragonLoot.xml in the addon folder
function DragonLootLoad()

	
	--Register events with the API for Looted Items Gold received and commands in the chat window.
	EVENT_MANAGER:RegisterForEvent("DragonLoot", EVENT_ADD_ON_LOADED, DL.OnAddOnLoaded) -- Register for event of loading our addon.
	
	
end

--Loads our Addon - Maybe redundant but whatever........
function DL.OnAddOnLoaded(eventCode, addOnName)

--Check if our addon is loaded:

	if (addOnName == "DragonLoot") then		

		DL.savedVars = ZO_SavedVars:New( "DragonLoot_Variables", math.floor(DL.version * 10 ), nil , DL.defaultVar, nil) --Method for adding persistent variables	
	
		DragonLoot:RegisterForEvent(EVENT_MONEY_UPDATE, DL.CashMoney) -- Registers for gold change events then calls the CashMoney function.
		DragonLoot:RegisterForEvent(EVENT_LOOT_RECEIVED, DL.OnLootedItem)  -- Registers for the loot received event then calls the OnLootedItem function.
		DragonLoot:RegisterForEvent(EVENT_OPEN_STORE, DL.SellTrash) -- Registers for player opening a store, then sells trash/grey items.
		DragonLoot:RegisterForEvent(EVENT_SELL_RECEIPT, DL.StoreSellReceipt) -- Registers for Selling items to vendors.
		DragonLoot:RegisterForEvent(EVENT_BUY_RECEIPT, DL.StoreBuyReceipt) -- Registers for Buying items from vendor.
		DragonLoot:RegisterForEvent(EVENT_CRAFT_COMPLETED, DL.CraftedItem) -- Registers for Crafted Items.
		DragonLoot:RegisterForEvent(EVENT_BUYBACK_RECEIPT, DL.BuyBackReceipt)
		SLASH_COMMANDS[DL.command] = DL.commandHandler -- The slash command handler for chat commands.
		DL.ShowLootWindow()
	
	end

end

--Function that handles chat commands from /dl in the chat window.
function DL.commandHandler( text )

-- Create a lookup table for evaluating "text" functions that control variables, _G is the global function table
	local funct = {
	
	["help"] = _G["DL"]["ShowHelp"],
	["settings"] = _G["DL"]["ShowSettings"],
	
	}
	
	--Check to see if we recognize the command.
	if (funct[text] == nil) then 
		
		d( "Dragon Loot: Unrecognised Command use /dl \"help\" for commands" )
		
	else
		
		funct[text]() -- Run the function called from the funct table.
		
	end 
	
end

--Player asked for help we list the commands:
function DL.ShowHelp()

		d( "Dragon Loot:  Help Summary v"..DL.version.."...." )
		d( "Commands: " )
		d( "type:    /dl help           -- This Help Menu." )
		d( "type:    /dl settings     -- Lets you see and change current settings and filters.")
		
end

--Function called when an item loot event is triggered from EVENT_LOOT_RECIEVED
function DL.OnLootedItem (numID, lootedBy, itemName, quantity, itemSound, lootType, self)
  
  if (self)  then -- Checking to see if the player looted it or if someone in the party did.
  
		if (DL.DetermineLootType(itemName, lootType)) then  --Check to see if player wants to see the loot
		
			local itemName = itemName:gsub("%^%a+","") -- The item names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
			local message = "You received " .. itemName.. " x"..quantity -- Concatenating the quantity with the item name into a new variable.
			DL.LootWindowHandler(message) -- Tell Player what they recieved.
						
		end
		
  elseif (not self) then  -- Checking to see if it is not the player that looted the item.
 
	  if (DL.savedVars.Group) then  -- Checking to see if we are displaying group loot to the player
	  
		if (DL.DetermineLootType(itemName, lootType)) then  -- Check to see if the player wants to see the loot based on quality.
		
			local lootedBy = lootedBy:gsub("%^%a+","")  -- The character names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
			local itemName = itemName:gsub("%^%a+","") -- The item names have some weird characters in them so we are using a regex substitution to get rid of the weird characters.
			local message = lootedBy .. " received ".. itemName.. " x"..quantity -- Concatenating the quantity with the item name into a new variable.
			DL.LootWindowHandler(message) -- Telling the player what they received.
			
		end
		
	  end
	  
  end 
	
end

-- Factory function for determining what kind of loot the player wants to see we do this by cheating and looking at the color of the link from the item.
function DL.DetermineLootType(itemName, lootType)

local colorwheel =
{
	Green = "2DC50E",
	White = "FFFFFF",
	Grey = "C3C3C3",
}	

local color
local text
local split

	-- Calling a function to take apart the link and get the color for us, so we can use the color to figure out how rare the item is.
	if (lootType == LOOT_TYPE_ITEM) then	  
	
		text, color, split = ZO_LinkHandler_ParseLink (itemName)  -- getting the color of the item.
		--d("Color Code:  "..color.. "  LootType:  " ..lootType)  --Debugging code.
	
	elseif (lootType == LOOT_TYPE_QUEST_ITEM) then --Check to see if it's a quest item.
	
		if (DL.savedVars.Quest) then return true -- Check to see if player wants to see quest items.
		end
	
	end	  
  
	if(not DL.InTable(colorwheel, color)) then return true -- Check to see if we know the color, if we don't we want to display it, it could be EPIC!
	
			
	else
	
			if (color == colorwheel.Grey) and (DL.savedVars.Trash) then return true--Check for Grey items and see if the player wants to see grey items.
			elseif (color == colorwheel.White) and (DL.savedVars.Normal) then return true --Check for White items and see if the player wants to see white items.
			elseif (color == colorwheel.Green) and (DL.savedVars.Magic) then return true --Check for Green items and see if the player wants to see green items.
			else return false
			
			end
			
	end
   
end

-- Simple table value lookup function
function DL.InTable(tbl, item)

	for key, value in pairs(tbl) do 
		if (value == item) then return true end
	end
	
	return false
	
end

--Sells trash items when store window is opened evoked from EVENT_OPEN_STORE.
function DL.SellTrash()

	if (DL.savedVars.AutoSell) then
	
		SellAllJunk() --Sell Junk marked by the player.
	
		local icon, bagslots = GetBagInfo(BAG_BACKPACK) -- Get the number of bag slots from the backpack using the BAG_BACKPACK constant. GetBagInfo returns Icon and # of slots integer
		
		for i=1 , bagslots, 1  do -- Look through the bag to sell all the trash items
		
			local itemType = GetItemType(BAG_BACKPACK, i) -- Get the item type from GetItemType()
			
			if (itemType == ITEMTYPE_TRASH) then -- if the itemType is trash then
		
				local stackcount = GetItemTotalCount(BAG_BACKPACK, i) --Get the number of items in the stack
				SellInventoryItem(BAG_BACKPACK, i, stackcount) -- Sell the whole stack.
				
			end
		
		end
		
	end

end

--Store Receipt for selling items.
function DL.StoreSellReceipt(numid, itemName, itemQuantity, money) 

	if (DL.savedVars.Sell) then
	
		local itemName = itemName:gsub("%^%a+","") --Fix the name because of weird characters.
		local message = "You have sold ".. itemName.." x"..itemQuantity.." for "..money.. " gold."  --Create Message
		DL.LootWindowHandler(message)
		
	end

end

--Store Receipt for buying items.

function DL.StoreBuyReceipt(numID, itemName, entryType, itemQuantity, money, specialCurrencyType1, specialCurrencyInfo1, specialCurrencyQuantity1, specialCurrencyType2, specialCurrencyInfo2, specialCurrencyQuantity2, itemSoundCategory)

	if (DL.savedVars.Buy) then
	
		if (money > 0) then
	
			local itemName = itemName:gsub("%^%a+","") --Fix the name because of weird characters.
			local message = "You have bought ".. itemName.." x"..itemQuantity.." for "..money.. " gold." --Create Message
			DL.LootWindowHandler(message) --Send Message
			
		end
		
	end
	
end

--Handles Items bought Back from Vendor
function DL.BuyBackReceipt(numID, itemLink, quantity, money, sound)

	if (DL.savedVars.Buy) then
	
		local itemName = itemLink:gsub("%^%a+","")
		local message = "You bought back " ..itemName.. " x" .. quantity .." for "..money.." gold."
		DL.LootWindowHandler(message)
		
	end
	
end


function DL.CraftedItem()

	--local craftedName, icon, stack, sellPrice, usageRequirement, equipType, itemType, itemStyle, quality, sound, itemInstanceID = GetLastCraftingResultItemInfo()
	local itemInfo = {GetLastCraftingResultItemInfo()} -- Get the last crafting result and put it into the table itemInfo
	local icon, bagslots = GetBagInfo(BAG_BACKPACK) -- Get the number of bag slots in the backpack.
	
	--Go through the backpack and match up the item name from the last crafted item with an item in the bag so we can get the link.
	for i=1 , bagslots, 1  do
		
		local itemName = GetItemName(BAG_BACKPACK, i) 
			
		if (itemName == itemInfo[1]) then 
		
			local itemLink = GetItemLink(BAG_BACKPACK, i, LINK_STYLE_DEFAULT) 
			itemLink = itemLink:gsub("%^%a+","")
			local message = "You have crafted ".. itemLink .." x"..itemInfo[3]
			DL.LootWindowHandler(message)
			break
				
		end
		
	end

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
