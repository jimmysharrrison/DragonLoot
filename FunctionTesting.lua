function ShowLootWindow()

	if (dlLootWindow == nil) then  -- Check to see if the window already exists

		-- Create the top level container for the window, this is what everything below it will bind to.
		dl_lootWindow = WINDOW_MANAGER:CreateTopLevelWindow("dlLootWindow")
			:SetMouseEnabled( true )
			:SetHidden( false )
			:SetMovable( true )
			:SetDimensions( 400,365 )
			:SetAnchor( TOPLEFT,GuiRoot,TOPLEFT,800,800 )
		.__END
		
		--Create the title label for the window
		dl_lootWindow_Title = WINDOW_MANAGER:CreateControl("lwTitle",dlLootWindow,CT_LABEL)
			:SetDimensions( dl_settings:GetWidth() , 36 )
			:SetFont( "ZoFontWindowTitle" )
			:SetColor(1,1,1,1)
			:SetHorizontalAlignment(1)
			:SetVerticalAlignment(0)
			:SetText( "Loot Window")
			:SetAnchor(TOP,dl_settings,TOP,0,10)
		.__END
		
		--Set the Close Button at the top of the window.
		dl_lootWindow_clsBtn = WINDOW_MANAGER:CreateControl("lwClose" , dlLootWindow , CT_BUTTON)
			:SetDimensions( 25 , 25 )
			:SetFont("ZoFontGameBold")
			:SetAnchor(TOPRIGHT,dlLootWindow,TOPRIGHT,-5,5)
			:SetNormalFontColor(1,1,1,1)
			:SetMouseOverFontColor(0.8,0.4,0,1)
			:SetText('[X]')
			:SetState( BSTATE_NORMAL )
			:SetHandler( "OnClicked" , function() CloseLootWindow() end )
		.__END
		
		--Set a background to make the window look nice and have a definite shape.
		dl_lootWindow_BG = WINDOW_MANAGER:CreateControl("dlLootWindowBG",dlLootWindow,CT_BACKDROP)
			:SetDimensions( dl_lootWindow:GetWidth() , dl_lootWindow:GetHeight() )
			:SetCenterColor(0,0,0,0.5)
			:SetEdgeColor(.1,.1,.1,1)
			:SetEdgeTexture("",8,1,2)
			:SetAnchor(CENTER,dlLootWindow,CENTER,0,0)
		.__END
	
	else
	
		dlLootWindow:SetHidden(false) -- If the window has already been created then show it.
		
	end

end