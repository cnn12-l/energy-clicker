local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local PetData = require(Shared:WaitForChild("PetData"))
local EggData = require(Shared:WaitForChild("EggData"))
local AreaData = require(Shared:WaitForChild("AreaData"))
local GemUpgrades = require(Shared:WaitForChild("GemUpgrades"))

local remotesFolder = ReplicatedStorage:WaitForChild("EnergyRemotes")
local stateRemote = remotesFolder:WaitForChild(GameConfig.RemoteNames.State)
local clickRemote = remotesFolder:WaitForChild(GameConfig.RemoteNames.Click)
local buyEggRemote = remotesFolder:WaitForChild(GameConfig.RemoteNames.BuyEgg)
local openEggRemote = remotesFolder:WaitForChild(GameConfig.RemoteNames.OpenEgg)
local collectFuelRemote = remotesFolder:WaitForChild(GameConfig.RemoteNames.CollectFuel)
local travelRemote = remotesFolder:WaitForChild(GameConfig.RemoteNames.Travel)
local rebirthRemote = remotesFolder:WaitForChild(GameConfig.RemoteNames.Rebirth)
local gemUpgradeRemote = remotesFolder:WaitForChild(GameConfig.RemoteNames.BuyGemUpgrade)

local player = Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EnergyClickerUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local root = Instance.new("Frame")
root.Size = UDim2.new(1, 0, 1, 0)
root.BackgroundColor3 = Color3.fromRGB(12, 15, 22)
root.BackgroundTransparency = 0.15
root.BorderSizePixel = 0
root.Parent = screenGui

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, -24, 0.12, 0)
topBar.Position = UDim2.new(0, 12, 0, 8)
topBar.BackgroundColor3 = Color3.fromRGB(20, 30, 42)
topBar.BorderSizePixel = 0
topBar.Parent = root

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 14)
topCorner.Parent = topBar

local energyLabel = Instance.new("TextLabel")
energyLabel.Size = UDim2.new(0.28, 0, 1, 0)
energyLabel.Position = UDim2.new(0.02, 0, 0, 0)
energyLabel.BackgroundTransparency = 1
energyLabel.Text = "Energy: 0"
energyLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
energyLabel.Font = Enum.Font.GothamBold
energyLabel.TextSize = 22
energyLabel.Parent = topBar

local gemsLabel = Instance.new("TextLabel")
gemsLabel.Size = UDim2.new(0.18, 0, 1, 0)
gemsLabel.Position = UDim2.new(0.31, 0, 0, 0)
gemsLabel.BackgroundTransparency = 1
gemsLabel.Text = "Gems: 0"
gemsLabel.TextColor3 = Color3.fromRGB(255, 208, 88)
gemsLabel.Font = Enum.Font.GothamBold
gemsLabel.TextSize = 18
gemsLabel.Parent = topBar

local areaLabel = Instance.new("TextLabel")
areaLabel.Size = UDim2.new(0.18, 0, 1, 0)
areaLabel.Position = UDim2.new(0.5, 0, 0, 0)
areaLabel.BackgroundTransparency = 1
areaLabel.Text = "Area 1"
areaLabel.TextColor3 = Color3.fromRGB(130, 220, 255)
areaLabel.Font = Enum.Font.GothamBold
areaLabel.TextSize = 18
areaLabel.Parent = topBar

local rebirthLabel = Instance.new("TextLabel")
rebirthLabel.Size = UDim2.new(0.2, 0, 1, 0)
rebirthLabel.Position = UDim2.new(0.74, 0, 0, 0)
rebirthLabel.BackgroundTransparency = 1
rebirthLabel.Text = "Rebirth: 0"
rebirthLabel.TextColor3 = Color3.fromRGB(150, 255, 175)
rebirthLabel.Font = Enum.Font.GothamBold
rebirthLabel.TextSize = 18
rebirthLabel.Parent = topBar

local clickButton = Instance.new("TextButton")
clickButton.Size = UDim2.new(0.3, 0, 0.2, 0)
clickButton.Position = UDim2.new(0.35, 0, 0.22, 0)
clickButton.Text = "Generate Energy"
clickButton.BackgroundColor3 = Color3.fromRGB(45, 95, 180)
clickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clickButton.BorderSizePixel = 0
clickButton.Font = Enum.Font.GothamBlack
clickButton.TextSize = 24
clickButton.Parent = root

local clickCorner = Instance.new("UICorner")
clickCorner.CornerRadius = UDim.new(0, 18)
clickCorner.Parent = clickButton

local fuelBarBG = Instance.new("Frame")
fuelBarBG.Size = UDim2.new(0.35, 0, 0.03, 0)
fuelBarBG.Position = UDim2.new(0.325, 0, 0.49, 0)
fuelBarBG.BackgroundColor3 = Color3.fromRGB(55, 60, 75)
fuelBarBG.BorderSizePixel = 0
fuelBarBG.Parent = root

local fuelBarFill = Instance.new("Frame")
fuelBarFill.Size = UDim2.new(0.5, 0, 1, 0)
fuelBarFill.BackgroundColor3 = Color3.fromRGB(63, 210, 150)
fuelBarFill.BorderSizePixel = 0
fuelBarFill.Parent = fuelBarBG

local fuelText = Instance.new("TextLabel")
fuelText.Size = UDim2.new(0.35, 0, 0.05, 0)
fuelText.Position = UDim2.new(0.325, 0, 0.545, 0)
fuelText.BackgroundTransparency = 1
fuelText.Text = "Fuel: 0 / 100"
fuelText.TextColor3 = Color3.fromRGB(255, 255, 255)
fuelText.Font = Enum.Font.GothamMedium
fuelText.TextSize = 16
fuelText.Parent = root

local collectFuelButton = Instance.new("TextButton")
collectFuelButton.Size = UDim2.new(0.18, 0, 0.06, 0)
collectFuelButton.Position = UDim2.new(0.41, 0, 0.59, 0)
collectFuelButton.Text = "Collect Fuel"
collectFuelButton.BackgroundColor3 = Color3.fromRGB(40, 155, 120)
collectFuelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
collectFuelButton.BorderSizePixel = 0
collectFuelButton.Font = Enum.Font.GothamBold
collectFuelButton.TextSize = 15
collectFuelButton.Parent = root

local gemButton = Instance.new("TextButton")
gemButton.Size = UDim2.new(0.15, 0, 0.065, 0)
gemButton.Position = UDim2.new(0.82, 0, 0.16, 0)
gemButton.Text = "Gems 💎"
gemButton.BackgroundColor3 = Color3.fromRGB(70, 90, 190)
gemButton.TextColor3 = Color3.fromRGB(255, 255, 255)
gemButton.BorderSizePixel = 0
gemButton.Font = Enum.Font.GothamBold
gemButton.TextSize = 15
gemButton.Parent = root

local gemPanelBG = Instance.new("Frame")
gemPanelBG.Size = UDim2.new(1, 0, 1, 0)
gemPanelBG.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
gemPanelBG.BackgroundTransparency = 0.65
gemPanelBG.BorderSizePixel = 0
gemPanelBG.Visible = false
gemPanelBG.Parent = root

local gemPanel = Instance.new("Frame")
gemPanel.Size = UDim2.new(0.5, 0, 0.8, 0)
gemPanel.Position = UDim2.new(0.25, 0, 0.1, 0)
gemPanel.BackgroundColor3 = Color3.fromRGB(22, 34, 46)
gemPanel.BorderSizePixel = 0
gemPanel.Parent = gemPanelBG

local gemCorner = Instance.new("UICorner")
gemCorner.CornerRadius = UDim.new(0, 14)
gemCorner.Parent = gemPanel

local gemTitle = Instance.new("TextLabel")
gemTitle.Size = UDim2.new(1, -40, 0, 38)
gemTitle.Position = UDim2.new(0, 20, 0, 10)
gemTitle.BackgroundTransparency = 1
gemTitle.Text = "Gem Upgrades"
gemTitle.TextColor3 = Color3.fromRGB(255, 208, 88)
gemTitle.Font = Enum.Font.GothamBold
gemTitle.TextSize = 24
gemTitle.TextXAlignment = Enum.TextXAlignment.Left
gemTitle.Parent = gemPanel

local gemCloseButton = Instance.new("TextButton")
gemCloseButton.Size = UDim2.new(0, 30, 0, 30)
gemCloseButton.Position = UDim2.new(1, -40, 0, 10)
gemCloseButton.BackgroundColor3 = Color3.fromRGB(190, 60, 60)
gemCloseButton.Text = "X"
gemCloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
gemCloseButton.BorderSizePixel = 0
gemCloseButton.Font = Enum.Font.GothamBold
gemCloseButton.TextSize = 18
gemCloseButton.Parent = gemPanel

local gemHolder = Instance.new("ScrollingFrame")
gemHolder.Size = UDim2.new(1, -20, 1, -70)
gemHolder.Position = UDim2.new(0, 10, 0, 60)
gemHolder.BackgroundColor3 = Color3.fromRGB(18, 28, 39)
gemHolder.BorderSizePixel = 0
gemHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
gemHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
gemHolder.ScrollBarThickness = 6
gemHolder.Parent = gemPanel

local eggHolder = Instance.new("ScrollingFrame")
eggHolder.Size = UDim2.new(0.42, 0, 0.54, 0)
eggHolder.Position = UDim2.new(0.05, 0, 0.16, 0)
eggHolder.BackgroundColor3 = Color3.fromRGB(22, 34, 46)
eggHolder.BorderSizePixel = 0
eggHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
eggHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
eggHolder.ScrollBarThickness = 6
eggHolder.Parent = root

local petHolder = Instance.new("ScrollingFrame")
petHolder.Size = UDim2.new(0.42, 0, 0.54, 0)
petHolder.Position = UDim2.new(0.53, 0, 0.16, 0)
petHolder.BackgroundColor3 = Color3.fromRGB(22, 34, 46)
petHolder.BorderSizePixel = 0
petHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
petHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
petHolder.ScrollBarThickness = 6
petHolder.Parent = root

local function formatNumber(value)
    if value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fK", value / 1000)
    end
    return tostring(math.floor(value))
end

local function createEggButton(egg)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -12, 0, 110)
    button.BackgroundColor3 = Color3.fromRGB(48, 64, 74)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = eggHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, -10)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = egg.Name .. "\nCost: " .. formatNumber(egg.Cost) .. "\nArea " .. egg.AreaRequired
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextWrapped = true
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = button

    button.MouseButton1Click:Connect(function()
        local success, message = buyEggRemote:InvokeServer(egg.Id)
        if not success then
            warn(message)
        else
            print(message)
        end
    end)

    return button
end

local function createHatchButton(egg)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -12, 0, 110)
    button.BackgroundColor3 = Color3.fromRGB(60, 75, 80)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = petHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, -10)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = egg.Name .. "\nOpen Egg"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextWrapped = true
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = button

    button.MouseButton1Click:Connect(function()
        local success, petName = openEggRemote:InvokeServer(egg.Id)
        if not success then
            warn(petName)
        else
            print("You hatched: " .. petName)
        end
    end)

    return button
end

local function createGemButton(upgrade)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -12, 0, 90)
    button.BackgroundColor3 = Color3.fromRGB(55, 72, 48)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = gemHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = button

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, -10)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = upgrade.Name .. "\nCost: " .. upgrade.Cost .. " gems\n" .. upgrade.Description
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextWrapped = true
    label.TextYAlignment = Enum.TextYAlignment.Center
    label.Parent = button

    button.MouseButton1Click:Connect(function()
        local success, message = gemUpgradeRemote:InvokeServer(upgrade.Id)
        if not success then
            warn(message)
        end
    end)

    return button
end

local function setEggList()
    for _, child in ipairs(eggHolder:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local index = 0
    for _, egg in ipairs(EggData) do
        local button = createEggButton(egg)
        button.Position = UDim2.new(0, 6, 0, 6 + index * 118)
        index += 1
    end
end

local function setGemList()
    for _, child in ipairs(gemHolder:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local index = 0
    for _, upgrade in ipairs(GemUpgrades) do
        local button = createGemButton(upgrade)
        button.Position = UDim2.new(0, 6, 0, 6 + index * 96)
        index += 1
    end
end

local function setOwnedPetList(state)
    for _, child in ipairs(petHolder:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local allPets = {}
    for _, pet in ipairs(PetData) do
        local count = state.ownedPets[pet.Id] or 0
        if count > 0 then
            table.insert(allPets, { Pet = pet, Count = count })
        end
    end

    local index = 0
    for _, entry in ipairs(allPets) do
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, -12, 0, 80)
        button.BackgroundColor3 = Color3.fromRGB(52, 70, 80)
        button.BorderSizePixel = 0
        button.Text = ""
        button.Parent = petHolder

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 12)
        corner.Parent = button

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 1, -10)
        label.Position = UDim2.new(0, 10, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = entry.Pet.Name .. " x" .. entry.Count
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextWrapped = true
        label.Parent = button

        button.Position = UDim2.new(0, 6, 0, 6 + index * 88)
        index += 1
    end
end

local function updateUI(state)
    energyLabel.Text = "Energy: " .. formatNumber(state.energy)
    gemsLabel.Text = "Gems: " .. state.gems
    areaLabel.Text = "Area " .. state.area
    rebirthLabel.Text = "Rebirth: " .. state.rebirths

    local fuelPercent = (state.fuel / math.max(state.maxFuel, 1)) * 100
    fuelBarFill.Size = UDim2.new(fuelPercent / 100, 0, 1, 0)
    fuelText.Text = "Fuel: " .. state.fuel .. " / " .. state.maxFuel

    setOwnedPetList(state)
end

clickButton.MouseButton1Click:Connect(function()
    clickRemote:FireServer()
end)

collectFuelButton.MouseButton1Click:Connect(function()
    local gain = collectFuelRemote:InvokeServer()
    if gain then
        print("Fuel collected: " .. gain)
    end
end)

gemButton.MouseButton1Click:Connect(function()
    gemPanelBG.Visible = not gemPanelBG.Visible
end)

gemCloseButton.MouseButton1Click:Connect(function()
    gemPanelBG.Visible = false
end)

stateRemote.OnClientEvent:Connect(function(state)
    updateUI(state)
end)

setEggList()
setGemList()
