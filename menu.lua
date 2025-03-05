function randomString()
	local length = math.random(10,20)
	local array = {}
	for i = 1, length do
		array[i] = string.char(math.random(32, 126))
	end
	return table.concat(array)
end

-- Custom Event Code ------------------------------------------
local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _connections = {} }, Signal)
end

function Signal:Connect(callback)
	table.insert(self._connections, callback)
	return {
		Disconnect = function()
			for i, conn in ipairs(self._connections) do
				if conn == callback then
					table.remove(self._connections, i)
					break
				end
			end
		end
	}
end

function Signal:Fire(...)
	for _, callback in ipairs(self._connections) do
		callback(...)
	end
end
---------------------------------------------------------------

local erismodulargui = {}

function erismodulargui:Initialize(modularInfo)
	local newGUI = nil
	if game:GetService("RunService"):IsStudio() then
		newGUI = Instance.new("ScreenGui", game.Players.LocalPlayer:WaitForChild("PlayerGui"))
		newGUI.Name = randomString()
	else
		COREGUI = cloneref(game:GetService("CoreGui"))
		if get_hidden_gui or gethui then
			local hiddenUI = get_hidden_gui or gethui
			local Main = Instance.new("ScreenGui")
			Main.Name = randomString()
			Main.Parent = hiddenUI()
			newGUI = Main
		elseif (not is_sirhurt_closure) and (syn and syn.protect_gui) then
			local Main = Instance.new("ScreenGui")
			Main.Name = randomString()
			syn.protect_gui(Main)
			Main.Parent = COREGUI
			newGUI = Main
		elseif COREGUI:FindFirstChild('RobloxGui') then
			newGUI = COREGUI.RobloxGui
		else
			local Main = Instance.new("ScreenGui")
			Main.Name = randomString()
			Main.Parent = COREGUI
			newGUI = Main
		end
	end
	newGUI.ResetOnSpawn = false
	newGUI.IgnoreGuiInset = true
	
	modularInfo = modularInfo or {}
	
	modularInfo = {
		primaryColor = modularInfo.primaryColor or Color3.fromRGB(170, 85, 255),
		secondaryColor = modularInfo.secondaryColor or Color3.fromRGB(0, 170, 255),
		backgroundColor = modularInfo.backgroundColor or Color3.fromRGB(0, 0, 0),
		textColor = modularInfo.textColor or Color3.fromRGB(255, 255, 255),
		font = modularInfo.font or Enum.Font.Roboto,
		name = modularInfo.name or "Eri's Modular Gui Script",
		barY = modularInfo.barY or 16,
		maxPages = modularInfo.maxPages or 2,
		size = modularInfo.size or UDim2.new(0.4, 0, 0.9, 0),
		draggable = modularInfo.draggable or false,
		centered = modularInfo.centered == nil and true or modularInfo.centered,
		freemouse = modularInfo.freemouse or false,
		toggleBind = modularInfo.toggleBind or nil,
		startMinimized = modularInfo.startMinimized or false,
	}

	local minimized = not modularInfo.startMinimized
	
	local function centerUIelement(uiElement: GuiObject)
		uiElement.Position = UDim2.new(0.5, 0, 0.5, 0)
		uiElement.AnchorPoint = Vector2.new(0.5, 0.5)
	end

	local function addUIstroke(uiElement: GuiObject, thickness: number, color: Color3)
		local uiStroke = Instance.new("UIStroke", uiElement)
		uiStroke.Thickness = thickness or 1
		uiStroke.Color = color or Color3.new(1 - modularInfo.backgroundColor.R, 1 - modularInfo.backgroundColor.G, 1 - modularInfo.backgroundColor.B)
		return uiStroke
	end

	local function addPadding(uiElement: GuiObject, padding)
		local newPadding = Instance.new("UIPadding", uiElement)
		newPadding.PaddingTop = UDim.new(0, padding)
		newPadding.PaddingBottom = UDim.new(0, padding)
		newPadding.PaddingLeft = UDim.new(0, padding)
		newPadding.PaddingRight = UDim.new(0, padding)

		return newPadding
	end
	
	local function addButton(parent: GuiObject, text)
		local newButton = Instance.new("TextButton", parent)
		newButton.Size = UDim2.new(1, 0, 0, modularInfo.barY)
		newButton.Text = text
		newButton.TextScaled = true
		newButton.Font = modularInfo.font
		newButton.TextColor3 = modularInfo.textColor
		newButton.BackgroundColor3 = modularInfo.secondaryColor
		newButton.BackgroundTransparency = 0
		newButton.BorderSizePixel = 0
		
		return newButton
	end
	
	local freeMouseButton = Instance.new("TextButton", newGUI)
	freeMouseButton.Size = UDim2.new(1, 0, 1, 0)
	freeMouseButton.BackgroundTransparency = 1
	freeMouseButton.Text = ""
	freeMouseButton.Interactable = false
	freeMouseButton.Modal = modularInfo.freemouse
	freeMouseButton.Visible = not minimized

	local newMainFrame = Instance.new("Frame", newGUI)
	newMainFrame.Size = modularInfo.size
	newMainFrame.BackgroundColor3 = modularInfo.backgroundColor
	newMainFrame.BackgroundTransparency = 0.5
	newMainFrame.BorderSizePixel = 0
	addUIstroke(newMainFrame)
	if modularInfo.centered == true then
		centerUIelement(newMainFrame)
	else
		newMainFrame.Position = UDim2.new(1, 0, 1, 0)
		newMainFrame.AnchorPoint = Vector2.new(1, 1)
	end

	local topBar =  Instance.new("Frame", newMainFrame)
	topBar.Size = UDim2.new(1, 0, 0, modularInfo.barY)
	topBar.BackgroundColor3 = modularInfo.primaryColor
	topBar.BackgroundTransparency = 0
	topBar.BorderSizePixel = 0
	topBar.Position = UDim2.new(0, 0, 0, 0)
	topBar.AnchorPoint = Vector2.new(0, 0)
	topBar.AutomaticSize = Enum.AutomaticSize.Y
	local topBarUIList = Instance.new("UIListLayout", topBar)
	topBarUIList.SortOrder = Enum.SortOrder.LayoutOrder

	local titleLabel = addButton(topBar, modularInfo.name)
	titleLabel.BackgroundColor3 = modularInfo.primaryColor
	titleLabel.AutoButtonColor = false
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	local titlePadding = Instance.new("UIPadding", titleLabel)
	titlePadding.PaddingLeft =  UDim.new(0, 5)

	local closeMenuButton = Instance.new("TextButton", titleLabel)
	closeMenuButton.Size =  UDim2.new(0.1, 0, 0.8, 0)
	closeMenuButton.TextColor3 = modularInfo.textColor
	closeMenuButton.AnchorPoint = Vector2.new(1, 0.5)
	closeMenuButton.Position =  UDim2.new(1, -5, 0.5, 0)
	closeMenuButton.BorderSizePixel = 0
	closeMenuButton.BackgroundColor3 = modularInfo.backgroundColor
	closeMenuButton.TextScaled = true
	closeMenuButton.Font = modularInfo.font
	closeMenuButton.Text = "X"
	closeMenuButton.Activated:Connect(function()
		newGUI:Destroy()
	end)

	local pageSelector = Instance.new("Frame", topBar)
	pageSelector.LayoutOrder = 2
	pageSelector.Size =  UDim2.new(1, 0, 0, modularInfo.barY)
	pageSelector.BackgroundColor3 = modularInfo.secondaryColor
	pageSelector.BorderSizePixel = 0

	local leftPageButton = Instance.new("TextButton", pageSelector)
	leftPageButton.Size = UDim2.new(0.1, 0, 0.8, 0)
	leftPageButton.TextColor3 = modularInfo.textColor
	leftPageButton.AnchorPoint = Vector2.new(0, 0.5)
	leftPageButton.Position =  UDim2.new(0, 5, 0.5, 0)
	leftPageButton.BorderSizePixel = 0
	leftPageButton.BackgroundColor3 = modularInfo.backgroundColor
	leftPageButton.TextScaled = true
	leftPageButton.Font = modularInfo.font
	leftPageButton.Text = "<"

	local rightPageButton = Instance.new("TextButton", pageSelector)
	rightPageButton.Size = UDim2.new(0.1, 0, 0.8, 0)
	rightPageButton.TextColor3 = modularInfo.textColor
	rightPageButton.AnchorPoint = Vector2.new(1, 0.5)
	rightPageButton.Position =  UDim2.new(1, -5, 0.5, 0)
	rightPageButton.BorderSizePixel = 0
	rightPageButton.BackgroundColor3 = modularInfo.backgroundColor
	rightPageButton.TextScaled = true
	rightPageButton.Font = modularInfo.font
	rightPageButton.Text = ">"

	local pageIndicator = Instance.new("TextLabel", pageSelector)
	pageIndicator.Position = UDim2.new(0.5, 0, 0.5, 0)
	pageIndicator.AnchorPoint = Vector2.new(0.5, 0.5)
	pageIndicator.BackgroundTransparency = 1
	pageIndicator.Size = UDim2.new(0.3, 0, 1, 0)
	pageIndicator.TextScaled = true
	pageIndicator.TextColor3 = modularInfo.textColor
	pageIndicator.Font = modularInfo.font
	pageIndicator.Text = "1/1"

	local mainContentFrame = Instance.new("Frame", newMainFrame)
	mainContentFrame.Size =  UDim2.new(1, 0, 1, -topBar.AbsoluteSize.Y)
	mainContentFrame.Position = UDim2.new(0, 0, 1, 0)
	mainContentFrame.AnchorPoint = Vector2.new(0, 1)
	mainContentFrame.BackgroundTransparency = 1
	local mainContentUIList = Instance.new("UIListLayout", mainContentFrame)
	mainContentUIList.FillDirection = Enum.FillDirection.Horizontal
	mainContentUIList.HorizontalFlex = Enum.UIFlexAlignment.Fill
	mainContentUIList.VerticalFlex = Enum.UIFlexAlignment.Fill
	mainContentUIList.SortOrder = Enum.SortOrder.LayoutOrder

	local minimizeMenuButton = Instance.new("TextButton", titleLabel)
	minimizeMenuButton.Size =  UDim2.new(0.1, 0, 0.8, 0)
	minimizeMenuButton.TextColor3 = modularInfo.textColor
	minimizeMenuButton.AnchorPoint = Vector2.new(1, 0.5)
	minimizeMenuButton.Position =  UDim2.new(0.9, -10, 0.5, 0)
	minimizeMenuButton.BorderSizePixel = 0
	minimizeMenuButton.BackgroundColor3 = modularInfo.backgroundColor
	minimizeMenuButton.TextScaled = true
	minimizeMenuButton.Font = modularInfo.font
	minimizeMenuButton.Text = "-"
	
	local maximizeButton = Instance.new("TextButton", newGUI)
	maximizeButton.Size = UDim2.new(0, minimizeMenuButton.AbsoluteSize.X, 0, minimizeMenuButton.AbsoluteSize.Y)
	maximizeButton.TextColor3 = modularInfo.textColor
	maximizeButton.AnchorPoint = Vector2.new(1, 1)
	maximizeButton.Position =  UDim2.new(1, 0, 1, 0)
	maximizeButton.BorderSizePixel = 0
	maximizeButton.BackgroundColor3 = modularInfo.backgroundColor
	maximizeButton.TextScaled = true
	maximizeButton.Font = modularInfo.font
	maximizeButton.Text = "+"
	maximizeButton.Visible = false
	
	local function handleMinimize()
		minimized = not minimized
		
		if modularInfo.draggable == true  then
			if modularInfo.centered == true then
				pageSelector.Visible = not minimized
				mainContentFrame.Visible = not minimized
				freeMouseButton.Visible = not minimized
				minimizeMenuButton.Text = minimized and "+" or "-"
				newMainFrame.Size = minimized and UDim2.new(0, modularInfo.size.X.Offset, 0, modularInfo.barY) or modularInfo.size
				newMainFrame.AnchorPoint = Vector2.new(0.5, 0)
			else
				newMainFrame.Visible = not minimized
				maximizeButton.Visible = minimized
				freeMouseButton.Visible = not minimized
			end
		else
			newMainFrame.Visible = not minimized
			maximizeButton.Visible = minimized
			freeMouseButton.Visible = not minimized
		end
	end
	
	if modularInfo.draggable == true then
		if modularInfo.centered == true then
			newMainFrame.AnchorPoint = Vector2.new(0.5, 0)
			newMainFrame.Position = UDim2.new(0.5, 0, 0.5, -modularInfo.size.Y.Offset / 2)
		end
		
		local button = titleLabel
		local frame = newMainFrame
		local userInputService = game:GetService("UserInputService")
		local runService = game:GetService("RunService")

		local dragging = false
		local dragStart, startPos

		button.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				dragStart = userInputService:GetMouseLocation()
				startPos = frame.Position
			end
		end)

		local connection
		connection = runService.RenderStepped:Connect(function(dt)
			if dragging then
				local mousePos = userInputService:GetMouseLocation()
				local delta = UDim2.new(0, mousePos.X - dragStart.X, 0, mousePos.Y - dragStart.Y)

				-- Fix for UDim2 calculation
				local newPos = UDim2.new(
					startPos.X.Scale, startPos.X.Offset + delta.X.Offset,
					startPos.Y.Scale, startPos.Y.Offset + delta.Y.Offset
				)

				-- Smooth the position with Lerp
				frame.Position = frame.Position:Lerp(newPos, dt * 25)
			else
				return
			end
		end)

		userInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)
	end

	minimizeMenuButton.Activated:Connect(function()
		handleMinimize()
	end)

	maximizeButton.Activated:Connect(function()
		handleMinimize()
	end)
	
	if modularInfo.toggleBind then
		game:GetService("UserInputService").InputBegan:Connect(function(key)
			if key.KeyCode == modularInfo.toggleBind then
				handleMinimize()
			end
		end)
	end
	
	handleMinimize()

	local createdModules = {}
	local currentPage = 1
	local modulesPerPage = modularInfo.maxPages

	local function updateModuleVisibility()
		local totalPages = math.ceil(#createdModules / modulesPerPage)
		currentPage = math.clamp(currentPage, 1, totalPages)

		for _, module in pairs(createdModules) do
			module.Frame.Visible = false
		end

		local startIndex = (currentPage - 1) * modulesPerPage + 1
		local endIndex = math.min(startIndex + modulesPerPage - 1, #createdModules)

		for i = startIndex, endIndex do
			createdModules[i].Frame.Visible = true
		end

		pageIndicator.Text = tostring(currentPage) .. "/" .. tostring(totalPages)
	end

	leftPageButton.Activated:Connect(function()
		if currentPage > 1 then
			currentPage = currentPage - 1
			updateModuleVisibility()
		end
	end)

	rightPageButton.Activated:Connect(function()
		if currentPage < math.ceil(#createdModules / modulesPerPage) then
			currentPage = currentPage + 1
			updateModuleVisibility()
		end
	end)
	
	function self:createNewModule(title)
		local newModuleFrame = Instance.new("Frame", mainContentFrame)
		newModuleFrame.Name = title
		newModuleFrame.Size = UDim2.new(1, 0, 1, 0)
		newModuleFrame.BackgroundTransparency = 1
		newModuleFrame.AutomaticSize = Enum.AutomaticSize.Y
		newModuleFrame.Visible = false
		newModuleFrame.BorderSizePixel = 0
		--addUIstroke(newModuleFrame, 1)

		local moduleTitle = Instance.new("TextLabel", newModuleFrame)
		moduleTitle.Size = UDim2.new(1, 0, 0, modularInfo.barY)
		moduleTitle.TextColor3 = modularInfo.textColor
		moduleTitle.BackgroundColor3 = modularInfo.primaryColor
		moduleTitle.TextScaled = true
		moduleTitle.Font = modularInfo.font
		moduleTitle.Text = title
		moduleTitle.BorderSizePixel = 0

		local contentBox = Instance.new("Frame", newModuleFrame)
		contentBox.Position = UDim2.new(0, 0, 1, 0)
		contentBox.AnchorPoint = Vector2.new(0, 1)
		contentBox.BackgroundTransparency = 1
		contentBox.Size = UDim2.new(1, 0, 1, -moduleTitle.AbsoluteSize.Y)
		contentBox.BorderSizePixel = 0
		addPadding(contentBox, 10)
		local newContentUIList = Instance.new("UIListLayout", contentBox)
		newContentUIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
		newContentUIList.VerticalAlignment = Enum.VerticalAlignment.Top
		newContentUIList.Padding = UDim.new(0, 10)
		newContentUIList.SortOrder = Enum.SortOrder.LayoutOrder
		--newContentUIList.VerticalFlex = Enum.UIFlexAlignment.SpaceEvenly

		local module = {}
		module.Frame = newModuleFrame

		function module:AddText(text)
			local textLabel = Instance.new("TextLabel", contentBox)
			textLabel.Size = UDim2.new(1, 0, 0, modularInfo.barY)
			textLabel.Text = text
			textLabel.TextScaled = true
			textLabel.Font = modularInfo.font
			textLabel.TextColor3 = modularInfo.textColor
			textLabel.BackgroundColor3 = modularInfo.secondaryColor
			textLabel.BorderSizePixel = 0

			return textLabel
		end
		
		function module:AddDivider()
			local divider = Instance.new("Frame", contentBox)
			divider.Size = UDim2.new(1, 0, 0, math.sqrt(modularInfo.barY))
			divider.BackgroundColor3 = modularInfo.textColor
			divider.BorderSizePixel = 0

			return divider
		end

		function module:AddButton(buttonText)
			local button = addButton(contentBox, buttonText)

			return button
		end

		function module:AddToggle(toggleText)
			local toggleData = { state = false }

			local toggleButton = addButton(contentBox, toggleText)
			toggleButton.Text = toggleText .. ": OFF"

			toggleButton.MouseButton1Click:Connect(function()
				toggleData.state = not toggleData.state
				toggleButton.Text = toggleText .. (toggleData.state and ": ON" or ": OFF")
			end)

			function toggleData:GetState()
				return self.state
			end

			return toggleButton, toggleData
		end

		function module:AddList(listTitle)
			local listContainer = Instance.new("Frame", contentBox)
			listContainer.Size = UDim2.new(1, 0, 0, modularInfo.barY)
			listContainer.AutomaticSize = Enum.AutomaticSize.Y
			listContainer.BackgroundTransparency = 1
			listContainer.BorderSizePixel = 0

			local titleButton = addButton(listContainer, listTitle)

			local itemListFrame = Instance.new("ScrollingFrame", listContainer)
			itemListFrame.Position = UDim2.new(0, 0, 0, -5)
			itemListFrame.AnchorPoint = Vector2.new(0, 1)
			itemListFrame.Size = UDim2.new(1, 0, 5, 0)
			itemListFrame.BackgroundColor3 = modularInfo.backgroundColor
			itemListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
			itemListFrame.ScrollBarThickness = 0
			itemListFrame.Visible = false
			itemListFrame.BorderSizePixel = 0
			addUIstroke(itemListFrame, 1, Color3.new(1, 1, 1))
			addPadding(itemListFrame, 10)

			titleButton.Activated:Connect(function()
				itemListFrame.Visible = not itemListFrame.Visible
			end)

			local uiListLayout = Instance.new("UIListLayout", itemListFrame)
			uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			uiListLayout.Padding = UDim.new(0, 5)

			local listObject = {
				Frame = listContainer,
				currentItem = nil,
				Items = {},
				OnItemChanged = Signal.new()
			}

			function listObject:AddListItem(itemText, relatedValue)
				relatedValue = relatedValue or itemText
				local itemButton = addButton(itemListFrame, itemText)

				itemButton.Activated:Connect(function()
					listObject.currentItem = relatedValue
					titleButton.Text = listTitle .. ": " .. itemText
					itemListFrame.Visible = false
					listObject.OnItemChanged:Fire(relatedValue)
				end)

				table.insert(listObject.Items, {Button = itemButton, Value = relatedValue})
				return itemButton
			end

			function listObject:RemoveListItem(itemText)
				for i, itemButton in ipairs(listObject.Items) do
					if itemButton.Text == itemText then
						itemButton:Destroy()
						table.remove(listObject.Items, i)
						break
					end
				end
			end

			function listObject:GetCurrentItem()
				return listObject.currentItem
			end

			return listObject
		end
		
		function module:AddSlider(sliderText, min, max)
			-- Slider Frame
			local sliderFrame = Instance.new("Frame", contentBox)
			sliderFrame.Size = UDim2.new(1, 0, 0, 0)
			sliderFrame.BackgroundColor3 = modularInfo.secondaryColor
			sliderFrame.AutomaticSize = Enum.AutomaticSize.Y
			sliderFrame.BorderSizePixel = 0

			-- Slider Label
			local sliderLabel = Instance.new("TextLabel", sliderFrame)
			sliderLabel.Size = UDim2.new(1, 0, 0, modularInfo.barY)
			sliderLabel.Text = sliderText..": "..string.format("%.2f", min)
			sliderLabel.TextScaled = true
			sliderLabel.Font = modularInfo.font
			sliderLabel.TextColor3 = modularInfo.textColor
			sliderLabel.BackgroundColor3 = modularInfo.secondaryColor
			sliderLabel.BorderSizePixel = 0

			-- Slider Holder (Background)
			local sliderHolder = Instance.new("Frame", sliderFrame)
			sliderHolder.Size = UDim2.new(1, 0, 0, modularInfo.barY)
			sliderHolder.Position = UDim2.new(0, 0, 1, 0)
			sliderHolder.BackgroundColor3 = modularInfo.secondaryColor
			sliderHolder.BorderSizePixel = 0

			-- Slider Bar (The part that shows progress)
			local sliderBar = Instance.new("Frame", sliderHolder)
			sliderBar.Size = UDim2.new(0.9, 0, 0.6, 0)
			sliderBar.Position = UDim2.new(0.5, 0, 0.5, 0)
			sliderBar.AnchorPoint = Vector2.new(0.5, 0.5)
			sliderBar.BackgroundColor3 = modularInfo.textColor
			sliderBar.BorderSizePixel = 0

			-- Slider Button (the draggable part)
			local sliderButton = Instance.new("TextButton", sliderBar)
			sliderButton.Size = UDim2.new(0, 20, 1, 0)  -- Initial size of the slider button
			sliderButton.Position = UDim2.new(0, 0, 0, 0)
			sliderButton.BackgroundColor3 = modularInfo.primaryColor
			sliderButton.TextColor3 = modularInfo.textColor
			sliderButton.BorderSizePixel = 0
			sliderButton.Text = ""
			local sliderButtonAspectRatio = Instance.new("UIAspectRatioConstraint", sliderButton)

			-- Variables to track dragging
			local dragging = false
			local dragStart = nil
			local startPos = nil
			local userInputService = game:GetService("UserInputService")
			local runService = game:GetService("RunService")

			-- Signal for slider value changes
			local valueChanged = Signal.new()

			-- Mouse Input for dragging the slider button
			sliderButton.InputBegan:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					dragStart = userInputService:GetMouseLocation()
					startPos = sliderButton.Position
				end
			end)

			-- Smooth dragging with RenderStepped
			local connection
			connection = runService.RenderStepped:Connect(function(dt)
				if dragging then
					local mousePos = userInputService:GetMouseLocation()
					local delta = UDim2.new(0, mousePos.X - dragStart.X, 0, 0)

					-- Calculate the new position of the slider button
					local newPos = UDim2.new(
						startPos.X.Scale, startPos.X.Offset + delta.X.Offset,
						startPos.Y.Scale, startPos.Y.Offset
					)

					-- Ensure the slider button stays within the bounds of the slider bar
					local minPos = 0
					local maxPos = sliderBar.AbsoluteSize.X - sliderButton.AbsoluteSize.X
					newPos = UDim2.new(0, math.clamp(newPos.X.Offset, minPos, maxPos), 0, newPos.Y.Offset)

					-- Smoothly move the slider button using Lerp
					sliderButton.Position = newPos

					-- Calculate the slider value based on the position
					local sliderValue = min + (sliderButton.Position.X.Offset / maxPos) * (max - min)
					local formattedValue = string.format("%.2f", sliderValue)
					sliderLabel.Text = sliderText..": "..formattedValue

					-- Fire the valueChanged signal with the new value
					valueChanged:Fire(sliderValue)
				end
			end)

			-- Stop dragging when the mouse button is released
			userInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)

			local sliderObject = {
				Frame = sliderFrame,
				GetValue = function()
					return min + (sliderButton.Position.X.Offset / (sliderBar.AbsoluteSize.X - sliderButton.AbsoluteSize.X)) * (max - min)
				end,
				SetValue = function(value)
					value = math.clamp(value, min, max)
					local normalizedValue = (value - min) / (max - min)
					sliderButton.Position = UDim2.new(normalizedValue, 0, 0, 0)
					sliderLabel.Text = sliderText..": "..string.format("%.2f", value)
				end,
				OnValueChanged = valueChanged
			}

			return sliderObject
		end

		table.insert(createdModules, module)
		updateModuleVisibility()

		return module
	end
	
	return self
end

return erismodulargui