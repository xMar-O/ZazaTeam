local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

local backgroundFrame = Instance.new("Frame")
backgroundFrame.Size = UDim2.new(0.5, 0, 0.05, 0)
backgroundFrame.Position = UDim2.new(0.25, 0, 0.45, 0)
backgroundFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
backgroundFrame.BackgroundTransparency = 0.5
backgroundFrame.Parent = screenGui

local progressBar = Instance.new("Frame")
progressBar.Size = UDim2.new(0, 0, 1, 0) 
progressBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
progressBar.Parent = backgroundFrame

local percentageLabel = Instance.new("TextLabel")
percentageLabel.Size = UDim2.new(1, 0, 1, 0)
percentageLabel.Position = UDim2.new(0, 0, 0, 0)
percentageLabel.BackgroundTransparency = 1
percentageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
percentageLabel.TextSize = 20
percentageLabel.Text = "Loading... 0%"
percentageLabel.TextStrokeTransparency = 0.5
percentageLabel.Parent = backgroundFrame

local logoImage = Instance.new("ImageLabel")
logoImage.Size = UDim2.new(0, 100, 0, 100)
logoImage.Position = UDim2.new(0.5, -50, 0.3, 0)
logoImage.Image = "rbxassetid://84454240337179"
logoImage.BackgroundTransparency = 1
logoImage.Parent = screenGui

local function fadeIn(element)
    element.BackgroundTransparency = 1
    for i = 1, 10 do
        wait(0.05)
        element.BackgroundTransparency = element.BackgroundTransparency - 0.1
    end
end

local function fadeOut(element)
    for i = 1, 10 do
        wait(0.05)
        element.BackgroundTransparency = element.BackgroundTransparency + 0.1
    end
    element:Destroy() 
end

local function showLoadingBar()
    fadeIn(backgroundFrame)
    fadeIn(logoImage)
    fadeIn(percentageLabel)

    for i = 0, 100 do
        progressBar.Size = UDim2.new(i / 100, 0, 1, 0)
        
        percentageLabel.Text = "Loading... " .. i .. "%"
        
        wait(0.1)
    end
    
    percentageLabel.Text = "Loading Complete! Injecting..."
    wait(1)

    loadstring(game:HttpGet("https://raw.githubusercontent.com/xMar-O/ZazaTeam/refs/heads/main/bigdeal.lua", true))()

    fadeOut(backgroundFrame)
    fadeOut(logoImage)
    fadeOut(percentageLabel)
end

showLoadingBar()
