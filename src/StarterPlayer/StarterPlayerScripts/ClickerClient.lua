local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local PetData = require(Shared:WaitForChild("PetData"))
local AreaData = require(Shared:WaitForChild("AreaData"))
local RebirthConfig = require(Shared:WaitForChild("RebirthConfig"))
local GemUpgrades = require(Shared:WaitForChild("GemUpgrades"))

local remotesFolder = ReplicatedStorage:FindFirstChild("EnergyRemotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "EnergyRemotes"
    remotesFolder.Parent = ReplicatedStorage
end

local stateRemote = remotesFolder:WaitForChild(GameConfig.RemoteNames.State)
local clickRemote = remotesFolder:WaitForChild(GameConfig.RemoteNames.Click)
local buyPetRemote = remotesFolder:WaitForChild(GameConfig.RemoteNames.BuyPet)
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
root.BackgroundColor3 = Color3.fromRGB(9, 12, 20)
root.BackgroundTransparency = 0.15
root.BorderSizePixel = 0
root.Parent = screenGui

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, -24, 0.12, 0)
topBar.Position = UDim2.new(0, 12, 0, 8)
topBar.BackgroundColor3 = Color3.fromRGB(18, 28, 39)
topBar.BorderSizePixel = 0
topBar.Parent = root

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = topBar

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
gemsLabel.TextSize = 20
gemsLabel.Parent = topBar

local areaLabel = Instance.new("TextLabel")
areaLabel.Size = UDim2.new(0.22, 0, 1, 0)
areaLabel.Position = UDim2.new(0.5, 0, 0, 0)
areaLabel.BackgroundTransparency = 1
areaLabel.Text = "Area 1"
areaLabel.TextColor3 = Color3.fromRGB(130, 220, 255)
areaLabel.Font = Enum.Font.GothamBold
areaLabel.TextSize = 20
areaLabel.Parent = topBar

local rebirthLabel = Instance.new("TextLabel")
rebirthLabel.Size = UDim2.new(0.2, 0, 1, 0)
rebirthLabel.Position = UDim2.new(0.74, 0, 0, 0)
rebirthLabel.BackgroundTransparency = 1
rebirthLabel.Text = "Rebirth: 0"
rebirthLabel.TextColor3 = Color3.fromRGB(157, 255, 178)
rebirthLabel.Font = Enum.Font.GothamBold
rebirthLabel.TextSize = 18
rebirthLabel.Parent = topBar

local clickButton = Instance.new("TextButton")
clickButton.Size = UDim2.new(0.3, 0, 0.22, 0)
clickButton.Position = UDim2.new(0.35, 0, 0.22, 0)
clickButton.Text = "Generate Energy"
clickButton.BackgroundColor3 = Color3.fromRGB(42, 95, 180)
clickButton.TextColor3 = Color3.fromRGB(255, 255, 255)
clickButton.BorderSizePixel = 0
clickButton.Font = Enum.Font.GothamBlack
clickButton.TextSize = 26
clickButton.Parent = root

local clickCorner = Instance.new("UICorner")
clickCorner.CornerRadius = UDim.new(0, 18)
clickCorner.Parent = clickButton

local fuelBarBG = Instance.new("Frame")
fuelBarBG.Size = UDim2.new(0.35, 0, 0.03, 0)
fuelBarBG.Position = UDim2.new(0.325, 0, 0.49, 0)
fuelBarBG.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
fuelBarBG.BorderSizePixel = 0
fuelBarBG.Parent = root

local fuelBarFill = Instance.new("Frame")
fuelBarFill.Size = UDim2.new(0.5, 0, 1, 0)
fuelBarFill.BackgroundColor3 = Color3.fromRGB(67, 214, 143)
fuelBarFill.BorderSizePixel = 0
fuelBarFill.Parent = fuelBarBG

local fuelText = Instance.new("TextLabel")
fuelText.Size = UDim2.new(0.35, 0, 0.04, 0)
fuelText.Position = UDim2.new(0.325, 0, 0.54, 0)
fuelText.BackgroundTransparency = 1
fuelText.Text = "Fuel: 0 / 100"
fuelText.TextColor3 = Color3.fromRGB(255, 255, 255)
fuelText.Font = Enum.Font.GothamMedium
fuelText.TextSize = 16
fuelText.Parent = root

local collectFuelButton = Instance.new("TextButton")
collectFuelButton.Size = UDim2.new(0.18, 0, 0.06, 0)
collectFuelButton.Position = UDim2.new(0.41, 0, 0.58, 0)
collectFuelButton.Text = "Collect Fuel"
collectFuelButton.BackgroundColor3 = Color3.fromRGB(40, 150, 120)
collectFuelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
collectFuelButton.BorderSizePixel = 0
collectFuelButton.Font = Enum.Font.GothamBold
collectFuelButton.TextSize = 16
collectFuelButton.Parent = root

local petListHolder = Instance.new("ScrollingFrame")
petListHolder.Size = UDim2.new(0.44, 0, 0.54, 0)
petListHolder.Position = UDim2.new(0.05, 0, 0.16, 0)
petListHolder.BackgroundColor3 = Color3.fromRGB(22, 34, 46)
petListHolder.BorderSizePixel = 0
petListHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
petListHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
petListHolder.ScrollBarThickness = 6
petListHolder.Parent = root

local gemHolder = Instance.new("ScrollingFrame")
gemHolder.Size = UDim2.new(0.44, 0, 0.54, 0)
gemHolder.Position = UDim2.new(0.51, 0, 0.16, 0)
gemHolder.BackgroundColor3 = Color3.fromRGB(22, 34, 46)
gemHolder.BorderSizePixel = 0
gemHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
gemHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
gemHolder.ScrollBarThickness = 6
gemHolder.Parent = root

local function formatNumber(value)
    if value >= 1000000 then
        return string.format("%.1fM", value / 1000000)
    elseif value >= 1000 then
        return string.format("%.1fK", value / 1000)
    end
    return tostring(math.floor(value))
end

local function createPetButton(pet)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -12, 0, 110)
    button.BackgroundColor3 = Color3.fromRGB(35, 52, 74)
    button.BorderSizePixel = 0
    button.Text = ""
    button.Parent = petListHolder

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = button

    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 52, 0, 52)
    icon.Position = UDim2.new(0, 14, 0, 14)
    icon.BackgroundTransparency = 1
    icon.Text = pet.Icon
    icon.TextSize = 30
    icon.Font = Enum.Font.GothamBold
    icon.TextColor3 = Color3.fromRGB(255, 255, 255)
    icon.Parent = button

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.45, 0, 0, 24)
    nameLabel.Position = UDim2.new(0, 76, 0, 18)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.Text = pet.Name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = button

    local costLabel = Instance.new("TextLabel")
    costLabel.Size = UDim2.new(0.45, 0, 0, 18)
    costLabel.Position = UDim2.new(0, 76, 0, 42)
    costLabel.BackgroundTransparency = 1
    costLabel.Font = Enum.Font.GothamMedium
    costLabel.Text = "Cost: " .. formatNumber(pet.Cost)
    costLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
    costLabel.TextXAlignment = Enum.TextXAlignment.Left
    costLabel.Parent = button

    local statsLabel = Instance.new("TextLabel")
    statsLabel.Size = UDim2.new(0.7, 0, 0, 36)
    statsLabel.Position = UDim2.new(0, 76, 0, 60)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Font = Enum.Font.Gotham
    statsLabel.Text = pet.Description
    statsLabel.TextColor3 = Color3.fromRGB(192, 200, 210)
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.TextWrapped = true
    statsLabel.Parent = button

    button.MouseButton1Click:Connect(function()
        local success, message = buyPetRemote:InvokeServer(pet.Id)
        if not success then
            warn(message)
        end
    end)

    return button
end

local function setPetList(pets)
    for _, child in ipairs(petListHolder:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local index = 0
    for _, pet in ipairs(pets) do
        local button = createPetButton(pet)
        button.Position = UDim2.new(0, 6, 0, 6 + (index * 118))
        index = index + 1
    end
end

local function createGemButton(upgrade)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -12, 0, 80)
    button.BackgroundColor3 = Color3.fromRGB(48, 64, 42)
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
    label.Font = Enum.Font.GothamBold
    label.Text = upgrade.Name .. "\nCost: " .. upgrade.Cost .. " gems\n" .. upgrade.Description
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
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

local function setGemList()
    for _, child in ipairs(gemHolder:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    local index = 0
    for _, upgrade in ipairs(GemUpgrades) do
        local button = createGemButton(upgrade)
        button.Position = UDim2.new(0, 6, 0, 6 + index * 86)
        index = index + 1
    end
end

clickButton.MouseButton1Click:Connect(function()
    clickRemote:FireServer()
end)

collectFuelButton.MouseButton1Click:Connect(function()
    local gain = collectFuelRemote:InvokeServer()
    if gain then
        print("Collected fuel: " .. gain)
    end
end)

local function updateUI(state)
    energyLabel.Text = "Energy: " .. formatNumber(state.energy)
    gemsLabel.Text = "Gems: " .. state.gems
    areaLabel.Text = "Area " .. state.area
    rebirthLabel.Text = "Rebirth: " .. state.rebirths

    local fuelPercent = (state.fuel / math.max(state.maxFuel, 1)) * 100
    fuelBarFill.Size = UDim2.new(fuelPercent / 100, 0, 1, 0)
    fuelText.Text = "Fuel: " .. state.fuel .. " / " .. state.maxFuel

    local allowedPets = {}
    for _, pet in ipairs(PetData) do
        if pet.AreaRequired <= state.area then
            table.insert(allowedPets, pet)
        end
    end
    setPetList(allowedPets)
end

stateRemote.OnClientEvent:Connect(function(state)
    updateUI(state)
end)

setGemList()
setPetList(PetData)
