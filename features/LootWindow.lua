--[[

Author:		@Qwexton
File:			LootWindow.lua
Version:	Alpha 1.6
Date:		3-06-2014

]]--

-- The loot window which displays loot for the player gets made when our addon is loaded, we hide it if they don't want to see it.
function DL.ShowLootWindow()

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
		
		dl_lootWindow:SetHandler( "OnMouseExit" , function() DL.MouseExit(dl_lootWindow) end)
		dl_lootWindow:SetHandler( "OnMouseEnter", function() DL.ShowFaded() end) --If mouse goes in window call function to show faded text and background.
		--dl_lootWindow:SetHandler("OnMouseDown", function() dl_lootBuffer:AddMessage("Move Me .........................",255,165,0,1) end)
		dl_lootWindow:SetHandler("OnMouseDown", function() DL.ShowResizeBox() end)
		dl_lootWindow:SetHandler("OnMouseUP", function() DL.HideResizeBox() end)
		dl_lootWindow:SetHandler("OnMouseWheel", function(self,delta)  -- Handles the mousewheel scrolling in the window
		 -- Call function when mouse exits window

			dl_lootBuffer:MoveScrollPosition(delta) --changes scroll position of  text window based on mouse delta

		end)		
		
		dl_lootWindow:SetDimensions( DL.savedVars.LWWidth, DL.savedVars.LWHeight )
		dl_lootWindow:SetResizeHandleSize(8)
		dl_lootWindow:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, DL.savedVars.lwX, DL.savedVars.lwY )
		
		--Set a background to make the window look nice and have a definite shape when moused over.
		dl_lootWindow_BG = WINDOW_MANAGER:CreateControl("dlLootWindowBG",dlLootWindow,CT_BACKDROP)
		dl_lootWindow_BG:SetHidden( true )
		dl_lootWindow_BG:SetCenterColor(0,0,0,0.5)
		dl_lootWindow_BG:SetEdgeColor(.1,.1,.1,1)
		dl_lootWindow_BG:SetEdgeTexture("",8,1,2)
		dl_lootWindow_BG:SetAnchorFill(dlLootWindow)
		
		--Set another background to show when resizing or moving the window because the mouse over BG doesn't hold state on click.
		dl_lootResize_BG = WINDOW_MANAGER:CreateControl("dlLootResizeBG",dlLootWindow,CT_BACKDROP)
		dl_lootResize_BG:SetHidden( true )
		dl_lootResize_BG:SetEdgeColor(.1,.1,.1,1)
		dl_lootResize_BG:SetCenterColor(0,0,0,0.5)
		dl_lootResize_BG:SetEdgeTexture("",8,1,2)
		dl_lootResize_BG:SetAnchorFill(dlLootWindow)

		--This control buffers text and handles all text related data being sent to it. Every time we want to send a message we call the :AddMessage attribute.
		dl_lootBuffer = WINDOW_MANAGER:CreateControl("lootedBuffer", dlLootWindow, CT_TEXTBUFFER)
 		dl_lootBuffer:SetLinkEnabled( true )
 		dl_lootBuffer:SetFont("ZoFontChat")
 		dl_lootBuffer:SetHidden(false)
		dl_lootBuffer:SetClearBufferAfterFadeout(true)
 		dl_lootBuffer:SetLineFade(8,3) -- Sets fade timers for text- Time until fade, time to fade. 
 		dl_lootBuffer:SetMaxHistoryLines(40)
 		dl_lootBuffer:AddMessage("Welcome To Dragon Loot \n Type \"/dl help\" for help!",255,255,0,1)
		dl_lootBuffer:SetAnchorFill(dlLootWindow)
	
	else
	
		dlLootWindow:SetHidden(false) -- If the window has already been created then show it.
		
	end

end

--This function now handles all displays to the user including chat and the loot window.
function DL.LootWindowHandler(message)
	
	--[[We dont check if the player wants loot to go to the loot window because we are assuming
	     if they do not want to see it then the window is hidden.  Loot still goes to the window so if they turn it back on
	     the history will be there.]]
	dl_lootBuffer:AddMessage(message,255,165,0,1) -- Sends text to loot window
	
	if (DL.savedVars.ChatLoot) then --Check if we want to see it in chat.
		d(message)	--Sends Loot to Chat
	end
	
end

--Handles what happens when the mouse exits the loot window.
function DL.MouseExit(window)

	DL.savedVars.lwX = window:GetLeft() -- Set player variables for window position
	DL.savedVars.lwY = window:GetTop() -- Set player variables for window position
		
	dl_lootWindow_BG:SetHidden( true ) -- Hide the background again
	dl_lootBuffer:SetScrollPosition(0) --Set the scroll position to the bottom of the text box.
	
end

--Shows the background and faded text lines when the mouse enters the window.
function DL.ShowFaded()

	dl_lootWindow_BG:SetHidden( false )
	dl_lootBuffer:ShowFadedLines()	

end

--Probably unnecessary function but wanted to keep the window creation tidy
function DL.ShowResizeBox()

	dl_lootResize_BG:SetHidden( false )

end

--Saves size of window after mouse lifts up, also hides the resize background.
function DL.HideResizeBox()

	DL.savedVars.LWWidth, DL.savedVars.LWHeight = dl_lootWindow:GetDimensions()
	dl_lootResize_BG:SetHidden( true )

end