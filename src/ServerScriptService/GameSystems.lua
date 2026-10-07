local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local PetData = require(Shared:WaitForChild("PetData"))
local AreaData = require(Shared:WaitForChild("AreaData"))
local RebirthConfig = require(Shared:WaitForChild("RebirthConfig"))
local GemUpgrades = require(Shared:WaitForChild("GemUpgrades"))

local remoteFolder = ReplicatedStorage:FindFirstChild("EnergyRemotes")
if not remoteFolder then
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "EnergyRemotes"
    remoteFolder.Parent = ReplicatedStorage
end

local function createRemote(name)
    local existing = remoteFolder:FindFirstChild(name)
    if existing then
        return existing
    end

    local remote = Instance.new("RemoteEvent")
    remote.Name = name
    remote.Parent = remoteFolder
    return remote
end

local function createFunction(name)
    local existing = remoteFolder:FindFirstChild(name)
    if existing then
        return existing
    end

    local remote = Instance.new("RemoteFunction")
    remote.Name = name
    remote.Parent = remoteFolder
    return remote
end

local stateRemote = createRemote(GameConfig.RemoteNames.State)
local clickRemote = createRemote(GameConfig.RemoteNames.Click)
local buyPetRemote = createFunction(GameConfig.RemoteNames.BuyPet)
local collectFuelRemote = createFunction(GameConfig.RemoteNames.CollectFuel)
local travelRemote = createFunction(GameConfig.RemoteNames.Travel)
local rebirthRemote = createFunction(GameConfig.RemoteNames.Rebirth)
local gemUpgradeRemote = createFunction(GameConfig.RemoteNames.BuyGemUpgrade)

local playerState = {}

local function getPetMapFromList(list)
    local map = {}
    for _, pet in ipairs(list) do
        map[pet.Id] = pet
    end
    return map
end

local function getPetById(id)
    for _, pet in ipairs(PetData) do
        if pet.Id == id then
            return pet
        end
    end

    return nil
end

local function hasAreaUnlocked(data, areaId)
    return data.area >= areaId
end

local function getAreaById(areaId)
    for _, area in ipairs(AreaData) do
        if area.Id == areaId then
            return area
        end
    end

    return AreaData[1]
end

local function getPlayerMultipliers(data)
    local multiplier = RebirthConfig:GetMultiplier(data.rebirths)
    local gemBoost = 1
    if data.permanentUpgrades.click_boost then
        gemBoost = gemBoost * 1.05
    end
    if data.permanentUpgrades.generator_boost then
        gemBoost = gemBoost * 1.1
    end

    return multiplier * gemBoost
end

local function getClickPower(data)
    local total = GameConfig.BaseClickPower
    local multiplier = getPlayerMultipliers(data)

    for _, pet in ipairs(PetData) do
        local owned = data.ownedPets[pet.Id] or 0
        if owned > 0 then
            total = total + (pet.ClickBoost * owned)
        end
    end

    return total * multiplier
end

local function getAutoEnergyRate(data)
    local total = 0
    local multiplier = getPlayerMultipliers(data)

    for _, pet in ipairs(PetData) do
        local owned = data.ownedPets[pet.Id] or 0
        if owned > 0 then
            total = total + (pet.EnergyPerSecond * owned)
        end
    end

    return total * multiplier
end

local function defaultPlayerData()
    return {
        energy = GameConfig.StartingEnergy,
        totalEarned = 0,
        gems = GameConfig.StartingGems,
        rebirths = GameConfig.StartingRebirths,
        area = 1,
        fuel = 0,
        maxFuel = 100,
        ownedPets = {},
        permanentUpgrades = {},
    }
end

local function getUpgradeCost(upgradeId)
    for _, upgrade in ipairs(GemUpgrades) do
        if upgrade.Id == upgradeId then
            return upgrade.Cost
        end
    end

    return nil
end

local function getPlayerState(player)
    local data = playerState[player]
    if not data then
        data = defaultPlayerData()
        playerState[player] = data
    end

    return data
end

local function syncPlayer(player)
    local data = getPlayerState(player)
    local state = {
        energy = math.floor(data.energy),
        gems = data.gems,
        rebirths = data.rebirths,
        area = data.area,
        fuel = data.fuel,
        maxFuel = data.maxFuel,
        clickPower = getClickPower(data),
        autoRate = getAutoEnergyRate(data),
        ownedPets = data.ownedPets,
        permanentUpgrades = data.permanentUpgrades,
        areaUnlockCost = AreaData[data.area + 1] and AreaData[data.area + 1].UnlockCost or nil,
    }

    stateRemote:FireClient(player, state)
end

local function awardPassiveEnergy()
    for _, player in ipairs(Players:GetPlayers()) do
        local data = getPlayerState(player)
        data.energy = data.energy + getAutoEnergyRate(data) * 1
        data.totalEarned = data.totalEarned + getAutoEnergyRate(data) * 1
        syncPlayer(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    playerState[player] = defaultPlayerData()
    syncPlayer(player)
end)

Players.PlayerRemoving:Connect(function(player)
    playerState[player] = nil
end)

clickRemote.OnServerEvent:Connect(function(player)
    local data = getPlayerState(player)
    local amount = getClickPower(data)
    data.energy = data.energy + amount
    data.totalEarned = data.totalEarned + amount
    syncPlayer(player)
end)

buyPetRemote.OnServerInvoke = function(player, petId)
    local data = getPlayerState(player)
    local pet = getPetById(petId)
    if not pet then
        return false, "Pet not found"
    end

    if pet.AreaRequired > data.area then
        return false, "This area is not unlocked yet"
    end

    local count = data.ownedPets[petId] or 0
    local cost = pet.Cost * (1 + (count * 0.7))

    if data.energy < cost then
        return false, "Not enough energy"
    end

    data.energy = data.energy - cost
    data.ownedPets[petId] = count + 1
    syncPlayer(player)

    return true, "Purchased " .. pet.Name
end

collectFuelRemote.OnServerInvoke = function(player)
    local data = getPlayerState(player)
    local area = getAreaById(data.area)
    local bonus = area.FuelMultiplier or 1
    local gain = math.floor((GameConfig.BaseFuelGain * bonus) + (data.rebirths * 2))
    data.fuel = math.min(data.maxFuel, data.fuel + gain)
    syncPlayer(player)

    return gain
end

travelRemote.OnServerInvoke = function(player, targetAreaId)
    local data = getPlayerState(player)
    local area = getAreaById(targetAreaId)
    if not area then
        return false, "Invalid area" 
    end

    if targetAreaId > data.area + 1 then
        return false, "Area not unlocked"
    end

    if targetAreaId > data.area and data.energy < area.UnlockCost then
        return false, "Not enough energy to travel"
    end

    if targetAreaId > data.area then
        data.energy = data.energy - area.UnlockCost
    end

    data.area = targetAreaId
    syncPlayer(player)
    return true, "You travel to " .. area.Name
end

rebirthRemote.OnServerInvoke = function(player)
    local data = getPlayerState(player)
    local cost = RebirthConfig:GetCost(data.rebirths)
    if data.energy < cost then
        return false, "Not enough energy to rebirth"
    end

    data.energy = 0
    data.totalEarned = 0
    data.area = 1
    data.fuel = 0
    data.maxFuel = 100
    data.ownedPets = {}
    data.permanentUpgrades = data.permanentUpgrades or {}

    local newRebirths = data.rebirths + 1
    data.rebirths = newRebirths
    data.gems = data.gems + RebirthConfig:GetGems(newRebirths - 1)
    syncPlayer(player)

    return true, "Rebirth complete. x" .. tostring(RebirthConfig:GetMultiplier(newRebirths)) .. " power"
end

gemUpgradeRemote.OnServerInvoke = function(player, upgradeId)
    local data = getPlayerState(player)
    local upgrade = nil
    for _, item in ipairs(GemUpgrades) do
        if item.Id == upgradeId then
            upgrade = item
            break
        end
    end

    if not upgrade then
        return false, "Upgrade not found"
    end

    if data.permanentUpgrades[upgradeId] then
        return false, "Upgrade already purchased"
    end

    if data.gems < upgrade.Cost then
        return false, "Not enough gems"
    end

    data.gems = data.gems - upgrade.Cost
    data.permanentUpgrades[upgradeId] = true
    syncPlayer(player)

    return true, "Upgrade purchased"
end

if RunService:IsStudio() then
    task.wait(1)
end

while true do
    task.wait(1)
    awardPassiveEnergy()
end
