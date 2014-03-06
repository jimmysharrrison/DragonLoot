--Function to make the settings window, we don't make the window unless someone calls it from the chat command.
function DL.ShowSettings()

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
		dl_settings_clsBtn:SetHandler( "OnClicked" , function() DL.CloseWindow() end )
		
		--Set a background to make the window look nice and have a definite shape.
		dl_settings_BG = WINDOW_MANAGER:CreateControl("dlSettingsBG", dlSettings, CT_BACKDROP)
		dl_settings_BG:SetDimensions( dl_settings:GetWidth() , dl_settings:GetHeight() )
		dl_settings_BG:SetCenterColor(0,0,0,0.5)
		dl_settings_BG:SetEdgeColor(.1,.1,.1,1)
		dl_settings_BG:SetEdgeTexture("",8,1,2)
		dl_settings_BG:SetAnchor(CENTER,dlSettings,CENTER,0,0)
		
		--This function dynamically creates the labels and buttons.
		DL.MakeLabels()
	
	else
	
		dlSettings:SetHidden(false) -- If the window has already been created then show it.
		
	end

end


--Dynamically creates labels and buttons on the dlSettings window.
function DL.MakeLabels()

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
		buttonname:SetHandler( "OnClicked" , function() _G["DL"][toggleFunction](buttonname) end)
		
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
		dl_settings_sell_btn:SetHandler( "OnClicked" , function() DL.ToggleSell(dl_settings_sell_btn) end)
		
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
		dl_settings_buy_btn:SetHandler( "OnClicked" , function() DL.ToggleBuy(dl_settings_buy_btn) end)
		
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
		dl_settings_autosell_btn:SetHandler( "OnClicked" , function() DL.ToggleAutoSell(dl_settings_autosell_btn) end)
		
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
		dl_settings_lootwindow_btn:SetHandler( "OnClicked" , function() DL.ToggleLootWindow(dl_settings_lootwindow_btn) end)	
		
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
		dl_settings_chatloot_btn:SetHandler( "OnClicked" , function() DL.ToggleChatLoot(dl_settings_chatloot_btn) end)			

end


--Close the settings window and save the position for next time.
function DL.CloseWindow()

	dlSettings:SetHidden(true)
	DL.savedVars.settingsY = dlSettings:GetTop()
	DL.savedVars.settingsX = dlSettings:GetLeft()

end