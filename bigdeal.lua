-- Settings -----------------------------------------------------------------------------------------------------
local toggleKey = Enum.KeyCode.P
local shutdownKey = nil
local minESPsize = 2
local lazerWidth = 0.05
-----------------------------------------------------------------------------------------------------------------

-- Global Variables ---------------------------------------------------------------------------------------------
local plr = game.Players.LocalPlayer
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("StarterGui")
-----------------------------------------------------------------------------------------------------------------

local library
if RunService:IsStudio() then
	library = require(script:WaitForChild("ErisModularGuiV2"))
else
	library = loadstring(game:HttpGet('https://raw.githubusercontent.com/xMar-O/NoBigDeal/refs/heads/main/menu.lua'))()
end

local Style = {
	name = "No Big Deal",
	size = UDim2.new(0, 600, 0, 400),
	primaryColor = Color3.new(0.2, 0.4, 0.6),
	secondaryColor = Color3.new(0.3, 0.6, 0.8),
	backgroundColor = Color3.new(0.1, 0.1, 0.1) -- Dark Gray
	draggable = true,
	centered = false,
	freemouse = true,
	maxPages = 3,
	barY = 20,
	startMinimized = false,
	toggleBind = toggleKey,
}

local window = library:Initialize(Style)

if shutdownKey ~= nil then
	game:GetService("UserInputService").InputBegan:Connect(function(key)
		if key.KeyCode == shutdownKey then
			window:Destroy()
		end
	end)
end

-- Functions ----------------------------------------------------------------------------------------------------
local ESPCache = {}
local espTextVisible = false
local borderThickness = 1

local function CreateESP(basepart, color)
	local newEspGui = Instance.new("BillboardGui", plr.PlayerGui)
	newEspGui.Adornee = basepart
	newEspGui.AlwaysOnTop = true
	newEspGui.ResetOnSpawn = false
	task.delay(5, function()
		newEspGui.ResetOnSpawn = true
	end)
	local espSize = basepart.Size.X > basepart.Size.Z and basepart.Size.X or basepart.Size.Z
	newEspGui.Size = UDim2.new(espSize, minESPsize, espSize, minESPsize)
	local espFrame = Instance.new("TextLabel", newEspGui)
	espFrame.Text = string.upper(string.sub(basepart.Parent.Name, 1, 1))
	espFrame.TextTransparency = espTextVisible and 0 or 1
	espFrame.TextScaled = true
	espFrame.Size = UDim2.new(1, 0, 1, 0)
	espFrame.BackgroundTransparency = 1
	local newStroke = Instance.new("UIStroke", espFrame)
	newStroke.Transparency = espTextVisible and 1 or 0
	if color then
		newStroke.Color = color
		espFrame.TextColor3 = color
	else
		newStroke.Color = basepart.Color
		espFrame.TextColor3 = basepart.Color
	end
	newStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	newStroke.LineJoinMode = Enum.LineJoinMode.Miter
	newStroke.Thickness = borderThickness
	table.insert(ESPCache, newEspGui)

	return newEspGui
end

local function lookAtBoard(board)
	local connection
	local goin = true

	task.delay(5, function()
		goin = false
		if connection then
			connection:Disconnect()
		end
	end)

	connection = RunService.RenderStepped:Connect(function()
		if goin then
			camera.CFrame = CFrame.new(board.CFrame.Position + board.CFrame.LookVector * 10, board.CFrame.Position)
		end
	end)
end

local function addLaser(part)
	if not part or not part:IsA("Attachment") then
		return
	end

	local laserPart = Instance.new("Part")
	laserPart.Parent = workspace
	laserPart.Anchored = true
	laserPart.CanCollide = false
	laserPart.CastShadow = false
	laserPart.Material = Enum.Material.Neon
	laserPart.Color = Color3.fromRGB(255, 0, 0)
	laserPart.Size = Vector3.new(lazerWidth, lazerWidth, 1)

	local function updateLaser()
		if not part or not part.Parent then
			laserPart:Destroy()
			return
		end

		local startPos = part.WorldCFrame.Position
		local direction = part.WorldCFrame.LookVector * 5000
		local rayOrigin = startPos
		local rayDirection = direction

		local raycastParams = RaycastParams.new()
		raycastParams.FilterDescendantsInstances = {part.Parent.Parent, laserPart, workspace:FindFirstChild(plr.Name)}
		raycastParams.FilterType = Enum.RaycastFilterType.Exclude
		raycastParams.IgnoreWater = true

		local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

		if raycastResult then
			local hitPoint = raycastResult.Position
			local laserLength = (hitPoint - startPos).Magnitude

			laserPart.Size = Vector3.new(lazerWidth, lazerWidth, laserLength)
			laserPart.CFrame = CFrame.new(startPos, hitPoint) * CFrame.new(0, 0, -laserLength / 2)
		else
			local maxEnd = startPos + direction
			local laserLength = (maxEnd - startPos).Magnitude

			laserPart.Size = Vector3.new(lazerWidth, lazerWidth, laserLength)
			laserPart.CFrame = CFrame.new(startPos, maxEnd) * CFrame.new(0, 0, -laserLength / 2)
		end
	end

	game:GetService("RunService").Heartbeat:Connect(updateLaser)
end

if game.ReplicatedFirst:FindFirstChild("doiii") then
    game.ReplicatedFirst:FindFirstChild("doiii").Enabled = false
end

local cash = {}
local markers = {}

local function getDistance(part1, part2)
	return (part1.Position - part2.Position).Magnitude
end

local function getAveragePosition(group)
	local totalPosition = Vector3.new(0, 0, 0)
	local count = #group

	for _, obj in ipairs(group) do
		totalPosition = totalPosition + obj.Position
	end

	return totalPosition / count
end

local showGroups = false
local function updateGroupMarkers(groups)
	-- Remove extra markers
	while #markers > #groups do
		local marker = table.remove(markers)
		if marker.marker and marker.text then
			marker.marker:Destroy()
			marker.text.Parent:Destroy()
		end
	end

	-- Update or create markers
	for i, group in ipairs(groups) do
		if #group > 0 then -- Prevent markers from staying if the group is empty
			local avgPosition = getAveragePosition(group) + Vector3.new(0, 100, 0)

			if markers[i] then
				markers[i].marker.Position = avgPosition
				markers[i].text.Text = "$"..#group
			else
				local marker = Instance.new("Part")
				marker.Size = Vector3.new(5, 5, 5)
				marker.Position = avgPosition
				marker.Anchored = true
				marker.CanCollide = false
				marker.Transparency = 1
				marker.Material = Enum.Material.Neon
				marker.Parent = workspace

				local newEspGui = Instance.new("BillboardGui", game.Players.LocalPlayer.PlayerGui)
				newEspGui.Adornee = marker
				newEspGui.AlwaysOnTop = true
				newEspGui.ResetOnSpawn = false
				task.delay(5, function()
					newEspGui.ResetOnSpawn = true
				end)
				newEspGui.Size = UDim2.new(0, 50, 0, 50)

				local markerText = Instance.new("TextLabel", newEspGui)
				markerText.TextScaled = true
				markerText.Size = UDim2.new(1, 0, 1, 0)
				markerText.BackgroundTransparency = 1
				markerText.TextColor3 = Color3.new(0.333333, 1, 0)
				markerText.TextTransparency = showGroups and 0 or 1

				markerText.Text = "$"..#group

				markers[i] = {marker = marker, text = markerText}
			end
		else
			-- If the group is empty, destroy the marker
			if markers[i] then
				markers[i].marker:Destroy()
				markers[i].text.Parent:Destroy()
				table.remove(markers, i)
			end
		end
	end
end

local function groupCashObjects()
	local groups = {}
	local visited = {}
	
	for i, c in cash do
		if c == nil or c.Parent == nil or c.Parent.Parent == nil then
			table.remove(cash, i)
			return
		end
	end

	for _, c in ipairs(cash) do
		if not visited[c] then
			local group = {c}
			visited[c] = true

			for _, other in ipairs(cash) do
				if not visited[other] and getDistance(c, other) <= 25 then
					table.insert(group, other)
					visited[other] = true
				end
			end

			table.insert(groups, group)
		end
	end
	
	updateGroupMarkers(groups)
end

-- Scan for existing cash in workspace
for _, d in ipairs(workspace:GetDescendants()) do
	if string.lower(d.Name) == "cash" and d:IsA("Model") then
		local part = d:FindFirstChild("Root")
		if part and part:IsA("BasePart") then
			table.insert(cash, part)
		end
	end
end

-- Detect new cash objects
workspace.DescendantAdded:Connect(function(d)
	task.wait(1) -- Small delay to allow the object to be fully initialized
	if string.lower(d.Name) == "cash" and d:IsA("Model") then
		local part = d:FindFirstChild("Root")
		if part and part:IsA("BasePart") then
			table.insert(cash, part)
		end
	end
end)

-- Continuously update groups and markers
RunService.Heartbeat:Connect(groupCashObjects)

-- Buttons ------------------------------------------------------------------------------------------------------
local espModule = window:createNewModule("ESP")

local function createESPButton(ButtonText, lookfor, bodyPart, color)
	local createdESPs = {}

	local newESPButton, newESPtoggled = espModule:AddToggle(ButtonText)
	newESPButton.Activated:Connect(function()
		if newESPtoggled:GetState() == false then
			for _, ce in createdESPs do
				ce:Destroy()
			end
			return
		end
		for i, d in workspace:GetDescendants() do
			if string.lower(d.Name) == lookfor and d:IsA("Model") then
				local part = d:FindFirstChild(bodyPart)
				if part:IsA("BasePart") then
					local newESP = CreateESP(part, color)
					table.insert(createdESPs, newESP)
				end
			end
		end
	end)
	workspace.DescendantAdded:Connect(function(d)
		if string.lower(d.Name) == lookfor and d:IsA("Model") then
			if newESPtoggled:GetState() == false then return end
			local part = d:FindFirstChild(bodyPart)
			if part:IsA("BasePart") then
				local newESP = CreateESP(part, color)
				table.insert(createdESPs, newESP)
			end
		end
	end)
end

local espTextToggle, espTextToggled = espModule:AddToggle("Use Text")
espTextToggle.Activated:Connect(function()
	espTextVisible = espTextToggled:GetState()
	for i, v in ESPCache do
		local espFrame = v:FindFirstChildOfClass("TextLabel")
		if espFrame then
			espFrame.TextTransparency = espTextToggled:GetState() and 0 or 1
			local espBorder = v:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("UIStroke")
			if espBorder then
				espBorder.Transparency = espTextToggled:GetState() and 1 or 0
			end
		end
	end
end)

local thicknessSlider = espModule:AddSlider("ESP Border Thickness", 1, 5)
thicknessSlider.OnValueChanged:Connect(function(value)
	borderThickness = value
	for i, v in ESPCache do
		if v and v:FindFirstChildOfClass("TextLabel") and v:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("UIStroke") then
			v:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("UIStroke").Thickness = value
		end
	end
end)

espModule:AddDivider()

local groupedCash, groupedCashToggled = espModule:AddToggle("Grouped Cash")
groupedCash.Activated:Connect(function()
	showGroups = groupedCashToggled:GetState()
	for i, gc in markers do
		gc.text.TextTransparency = showGroups and 0 or 1
	end
end)

createESPButton("Cash ESP", "cash", "Root", Color3.new(0, 1, 0))
createESPButton("Fake Cash ESP", "fakecash", "Root", Color3.new(1, 0.666667, 0))
createESPButton("Disk ESP", "disk", "Color", Color3.new(0, 0, 0))
createESPButton("Grenade ESP", "grenade", "Root", Color3.new(1, 0, 0))
createESPButton("Seltzer Bottle ESP", "bottle", "Fluid", Color3.new(0.666667, 0, 0.498039))

espModule:AddDivider()

local PlayerESP, playerESPtoggled = espModule:AddToggle("Player ESP")
local createdPlayerESPs = {}
PlayerESP.Activated:Connect(function()
	if playerESPtoggled:GetState() == false then
		for _, ce in createdPlayerESPs do
			ce:Destroy()
		end
		return
	end
	for i, p in game.Players:GetPlayers() do
		local playerChar = workspace:FindFirstChild(p.Name)
		if playerChar then
			if playerChar:FindFirstChild("Head") then
				local createdESP = CreateESP(playerChar:FindFirstChild("Head"), Color3.new(1, 1, 1))
				createdESP:FindFirstChildOfClass("TextLabel").TextTransparency = 1
				createdESP:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("UIStroke").Thickness = 1
				createdESP:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("UIStroke").Transparency = 0
				table.remove(ESPCache, table.find(ESPCache, createdESP))
				table.insert(createdPlayerESPs, createdESP)
			end
			if playerChar:FindFirstChild("Torso") then
				local createdESP = CreateESP(playerChar:FindFirstChild("Torso"), Color3.new(1, 1, 1))
				createdESP:FindFirstChildOfClass("TextLabel").TextTransparency = 1
				createdESP:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("UIStroke").Thickness = 1
				createdESP:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("UIStroke").Transparency = 0
				table.remove(ESPCache, table.find(ESPCache, createdESP))
				table.insert(createdPlayerESPs, createdESP)
			end
		end
	end
end)
workspace.ChildAdded:Connect(function(c)
	if playerESPtoggled:GetState() == false then return end
	task.wait(1)
	if game.Players:FindFirstChild(c.Name) and c:IsA("Model") then
		if c:FindFirstChild("Head") then
			local createdESP = CreateESP(c:FindFirstChild("Head"), Color3.new(1, 1, 1))
			createdESP:FindFirstChildOfClass("TextLabel").TextTransparency = 1
			createdESP:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("UIStroke").Thickness = 1
			createdESP:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("UIStroke").Transparency = 0
			table.remove(ESPCache, table.find(ESPCache, createdESP))
			table.insert(createdPlayerESPs, createdESP)
		end
		if c:FindFirstChild("Torso") then
			local createdESP = CreateESP(c:FindFirstChild("Torso"), Color3.new(1, 1, 1))
			createdESP:FindFirstChildOfClass("TextLabel").TextTransparency = 1
			createdESP:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("UIStroke").Thickness = 1
			createdESP:FindFirstChildOfClass("TextLabel"):FindFirstChildOfClass("UIStroke").Transparency = 0
			table.remove(ESPCache, table.find(ESPCache, createdESP))
			table.insert(createdPlayerESPs, createdESP)
		end
	end
end)

local lazerModule = window:createNewModule("Lazers")

local pistolLazers = lazerModule:AddButton("Pistol Lazers")
pistolLazers.Activated:Connect(function()
	for i, g in workspace:GetChildren() do
		if g.Name == "Pistol" or g.Name == "Snub" and g:FindFirstChild("Root") and g:FindFirstChild("Root"):FindFirstChild("Muzzle") then
			addLaser(g:FindFirstChild("Root"):FindFirstChild("Muzzle"))
		end
	end
end)

local kickLazers = lazerModule:AddButton("Kick-10 Lazers")
kickLazers.Activated:Connect(function()
	for i, g in workspace:GetChildren() do
		if g.Name == "ToolboxMAC10" and g:FindFirstChild("Root") and g:FindFirstChild("Root"):FindFirstChild("Muzzle") then
			addLaser(g:FindFirstChild("Root"):FindFirstChild("Muzzle"))
		end
	end
end)

local carcosaLazers = lazerModule:AddButton("Carcosa Rifle Lazers")
carcosaLazers.Activated:Connect(function()
	for i, g in workspace:GetChildren() do
		if g.Name == "Sniper" and g:FindFirstChild("Root") and g:FindFirstChild("Root"):FindFirstChild("Muzzle") then
			addLaser(g:FindFirstChild("Root"):FindFirstChild("Muzzle"))
		end
	end
end)

local aceLazers = lazerModule:AddButton("Ace Lazers")
aceLazers.Activated:Connect(function()
	for i, g in workspace:GetChildren() do
		if g.Name == "AceCarbine" and g:FindFirstChild("Root") and g:FindFirstChild("Root"):FindFirstChild("Muzzle") then
			addLaser(g:FindFirstChild("Root"):FindFirstChild("Muzzle"))
		end
	end
end)

local magnumLazers = lazerModule:AddButton("Magnum Lazers")
magnumLazers.Activated:Connect(function()
	for i, g in workspace:GetChildren() do
		if g.Name == "MAGNUM" and g:FindFirstChild("Root") and g:FindFirstChild("Root"):FindFirstChild("Muzzle") then
			addLaser(g:FindFirstChild("Root"):FindFirstChild("Muzzle"))
		end
	end
end)

local allLazers = lazerModule:AddButton("All Lazers")
allLazers.Activated:Connect(function()
	for i, g in workspace:GetChildren() do
		if (g.Name == "Snub" or g.Name == "Pistol" or g.Name == "DB" or g.Name == "AK47" or g.Name == "ToolboxMAC10" or g.Name == "MP5" or g.Name == "Sniper" or g.Name == "AceCarbine" or g.Name == "MAGNUM") and g:FindFirstChild("Root") and g:FindFirstChild("Root"):FindFirstChild("Muzzle") then
			addLaser(g:FindFirstChild("Root"):FindFirstChild("Muzzle"))
		end
	end
end)

local miscModule = window:createNewModule("Miscellaneous")

local lookAtMissionBoardList = miscModule:AddList("Look at board")
lookAtMissionBoardList:AddListItem("Alamont", "1")
lookAtMissionBoardList:AddListItem("Bergman", "3")
lookAtMissionBoardList:AddListItem("Halfwell", "2")
lookAtMissionBoardList.OnItemChanged:Connect(function(boardID)
	local board = workspace:WaitForChild("CurrentMap"):WaitForChild("Round"):WaitForChild("Core"):WaitForChild("Bases"):WaitForChild(boardID):WaitForChild("MissionBoard")
	lookAtBoard(board)
end)

local showOwnHealth, showingOwnHealth = miscModule:AddToggle("Show own health")
showOwnHealth.Activated:Connect(function()
	local characterHealthFrame = plr.PlayerGui:WaitForChild("RootGui"):WaitForChild("CharacterFrame"):WaitForChild("PaperDoll")
	for i, v in characterHealthFrame:GetChildren() do
		if v:IsA("TextLabel") then
			v.TextTransparency = showingOwnHealth:GetState() and 0 or 1
		end
	end
end)

local MonitorChat, monotoringChat = miscModule:AddToggle("Chat Monitor")
if game.ReplicatedStorage:FindFirstChild("Remotes") then
	local chatMonitor = false
	local chatEvent = game.ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("ToClient"):WaitForChild("Chat")
	if chatEvent then
		chatEvent.OnClientEvent:Connect(function(plr, part, message)
			if monotoringChat:GetState() then
				print(plr.Name .. " sent: ".. message)
				CoreGui:SetCore("SendNotification", {
					Title = plr.Name;
					Text = message;
					Duration = 3;
				})
			end
		end)
	end
end

local hearAllPlayersOutput = Instance.new("AudioDeviceOutput", plr)
hearAllPlayersOutput.Name = "HearAllPlayers"
hearAllPlayersOutput.Player = plr
local hearAllPlayersVolumeControl = Instance.new("AudioFader", hearAllPlayersOutput)
local newVolumeWire = Instance.new("Wire", hearAllPlayersVolumeControl)
newVolumeWire.SourceInstance = hearAllPlayersVolumeControl
newVolumeWire.TargetInstance = hearAllPlayersOutput
for i, p in game.Players:GetPlayers() do
	if p == plr then continue end
	local mic = p:FindFirstChildOfClass("AudioDeviceInput")
	if mic then
		local newWire = Instance.new("Wire", hearAllPlayersOutput)
		newWire.SourceInstance = mic
		newWire.TargetInstance = hearAllPlayersVolumeControl
	end
end
game.Players.PlayerAdded:Connect(function(plr)
	task.wait(1)
	local mic = plr:FindFirstChildOfClass("AudioDeviceInput")
	if mic then
		local newWire = Instance.new("Wire", hearAllPlayersVolumeControl)
		newWire.SourceInstance = mic
		newWire.TargetInstance = hearAllPlayersVolumeControl
	end
end)
local volumeSlider = miscModule:AddSlider("Global voice chat volume", 0, 1)
volumeSlider.OnValueChanged:Connect(function(value)
	if hearAllPlayersOutput then
		hearAllPlayersVolumeControl.Volume = value
	end
end)
hearAllPlayersVolumeControl.Volume = volumeSlider:GetValue() or 0

local showTeamSelectionMenu, toggledTeamSelectionMenu = miscModule:AddToggle("Toggle Team Selection Menu")
showTeamSelectionMenu.Activated:Connect(function()
	local teamMenu = plr.PlayerGui.RootGui.TeamFrame
	if teamMenu then
		teamMenu.Visible = toggledTeamSelectionMenu:GetState()
	end
end)

local removeVCWarning = miscModule:AddButton("Remove VC Warning Gui")
removeVCWarning.Activated:Connect(function()
	local vcWarningGui = game.Players.LocalPlayer.PlayerGui:FindFirstChild("VCWarning")
	if vcWarningGui then
		vcWarningGui:Destroy()
	end
end)

local teleportModule = window:createNewModule("Teleport")
teleportModule:AddText("!!! WARNING: THIS IS VERY LIKELY TO GET YOU CAUGHT !!!")
local function teleportTo(part)
	local char: Model = workspace:WaitForChild(game.Players.LocalPlayer.Name)
	for i = 1, 10 do
		char:PivotTo(part.CFrame)
		char:FindFirstChild("HumanoidRootPart").Velocity = 0
		wait()
	end
end
if workspace:FindFirstChild("CurrentMap") then
	for i, v in workspace:WaitForChild("CurrentMap"):WaitForChild("Round"):WaitForChild("Tempmarkers"):GetChildren() do
		teleportModule:AddButton(v.Name).Activated:Connect(function()
			teleportTo(v)
		end)
	end
end

local trollModule = window:createNewModule("Troll")

trollModule:AddText("Muah 3lik a ali")

trollModule:AddText("Need to be in driver sit for this to work")
local carKill, carKillToggled = trollModule:AddToggle("Car Kill")
carKill.Activated:Connect(function()
	task.spawn(function()
		while wait(math.random(5, 25)/100) and plr.Character and carKillToggled:GetState() == true do
			local randmPLR: Player = game.Players:GetPlayers()[math.random(1, #game.Players:GetChildren())]
			if randmPLR.Character == nil and randmPLR ~= game.Players.LocalPlayer then continue end
			if randmPLR.Character:GetPivot().Y <= -100 then continue end
			for i = 1, 25 do
				plr.Character:PivotTo(randmPLR.Character:GetPivot())
				wait(math.random(0, 10) / 200)
				plr.Character:PivotTo(plr.Character:GetPivot() + Vector3.new(0, 25, 0))
			end

			plr.Character:PivotTo(CFrame.new(0, 250, 0))
			if plr.Character:FindFirstChild("HumanoidRootPart") then plr.Character:FindFirstChild("HumanoidRootPart").Velocity = Vector3.new(0, 0, 0) end
		end
	end)
end)
-----------------------------------------------------------------------------------------------------------------

-- Credit Notification ------------------------------------------------------------------------------------------
CoreGui:SetCore("SendNotification", {
	Title = "No Big Deal Injected";
	Text = "Much Love Maro";
	Duration = 5;
})
-----------------------------------------------------------------------------------------------------------------
