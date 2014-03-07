--[[

Author:		@Qwexton
File:			Gold.lua
Version:	Alpha 1.6
Date:		3-06-2014

]]--

--Function called when a money event is triggered from EVENT_MONEY_UPDATE
function DL.CashMoney (numId, newMoney, oldMoney, reason)

	if (reason ~= CURRENCY_CHANGE_REASON_VENDOR) then
	
		if (DL.savedVars.Gold) then -- check if we are supposed to show gold
		
			if (newMoney > oldMoney) then  -- Is the new amount of gold larger than the old amount (did we gain money?)
		
				local goldgained = (newMoney - oldMoney)  -- Math to find out how much gold was obtained.
				local message = "You have gained ".. goldgained .. " gold." -- Create Message
				DL.LootWindowHandler(message)
				
			end
			
			--[[if (oldMoney > newMoney) then  -- Is the old amount of money larger than the new amount (did we spend money?)
		
				local goldspent = (oldMoney - newMoney)  -- Math to figure out how much gold was spent.
				d("You have spent [-".. goldspent .. "] gold.") -- Telling the player how much gold they spent.
		
			end]]--
			
		end
		
	end

end