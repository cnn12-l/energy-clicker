local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local GameConfig = require(Shared:WaitForChild("GameConfig"))
local PetData = require(Shared:WaitForChild("PetData"))
local EggData = require(Shared:WaitForChild("EggData"))
local AreaData = require(Shared:WaitForChild("AreaData"))
local RebirthConfig = require(Shared:WaitForChild("RebirthConfig"))
local GemUpgrades = require(Shared:WaitForChild("GemUpgrades"))

local remotesFolder = ReplicatedStorage:FindFirstChild("EnergyRemotes")
if not remotesFolder then
    remotesFolder = Instance.new("Folder")
    remotesFolder.Name = "EnergyRemotes"
    remotesFolder.Parent = ReplicatedStorage
end

local function createRemote(name, eventType)
    local existing = remotesFolder:FindFirstChild(name)
    if existing then
        return existing
    end

    local remote
    if eventType == "RemoteEvent" then
        remote = Instance.new("RemoteEvent")
    else
        remote = Instance.new("RemoteFunction")
    end

    remote.Name = name
    remote.Parent = remotesFolder
    return remote
end

local stateRemote = createRemote(GameConfig.RemoteNames.State, "RemoteEvent")
local clickRemote = createRemote(GameConfig.RemoteNames.Click, "RemoteEvent")
local buyEggRemote = createRemote(GameConfig.RemoteNames.BuyEgg, "RemoteFunction")
local openEggRemote = createRemote(GameConfig.RemoteNames.OpenEgg, "RemoteFunction")
local collectFuelRemote = createRemote(GameConfig.RemoteNames.CollectFuel, "RemoteFunction")
local travelRemote = createRemote(GameConfig.RemoteNames.Travel, "RemoteFunction")
local rebirthRemote = createRemote(GameConfig.RemoteNames.Rebirth, "RemoteFunction")
local gemUpgradeRemote = createRemote(GameConfig.RemoteNames.BuyGemUpgrade, "RemoteFunction")

local playerState = {}

local function getPetById(id)
    for _, pet in ipairs(PetData) do
        if pet.Id == id then
            return pet
        end
    end
    return nil
end

local function getEggById(id)
    for _, egg in ipairs(EggData) do
        if egg.Id == id then
            return egg
        end
    end
    return nil
end

local function getAreaById(areaId)
    for _, area in ipairs(AreaData) do
        if area.Id == areaId then
            return area
        end
    end
    return AreaData[1]
end

local function defaultPlayerData()
    return {
        energy = GameConfig.StartingEnergy,
        gems = GameConfig.StartingGems,
        rebirths = GameConfig.StartingRebirths,
        area = 1,
        fuel = 0,
        maxFuel = GameConfig.MaxFuel,
        ownedPets = {},
        eggInventory = {},
        permanentUpgrades = {},
        totalEarned = 0,
    }
end

local function getPlayerState(player)
    if not playerState[player] then
        playerState[player] = defaultPlayerData()
    end
    return playerState[player]
end

local function getPlayerMultipliers(data)
    local multiplier = RebirthConfig:GetMultiplier(data.rebirths)
    local gemBonus = 1

    if data.permanentUpgrades.click_boost then
        gemBonus = gemBonus * 1.05
    end
    if data.permanentUpgrades.generator_boost then
        gemBonus = gemBonus * 1.1
    end

    return multiplier * gemBonus
end

local function getClickPower(data)
    local total = GameConfig.BaseClickPower
    local multiplier = getPlayerMultipliers(data)

    for _, pet in ipairs(PetData) do
        local count = data.ownedPets[pet.Id] or 0
        total = total + (pet.ClickBoost * count)
    end

    return total * multiplier
end

local function activePetCount(data)
    local count = 0
    for _, pet in ipairs(PetData) do
        count += data.ownedPets[pet.Id] or 0
    end
    return count
end

local function getAutoEnergyRate(data)
    local total = 0
    for _, pet in ipairs(PetData) do
        local count = data.ownedPets[pet.Id] or 0
        total += pet.EnergyPerSecond * count
    end

    return total * getPlayerMultipliers(data)
end

local function syncPlayer(player)
    local data = getPlayerState(player)
    local state = {
        energy = math.floor(data.energy),
        gems = data.gems,
        rebirths = data.rebirths,
        area = data.area,
        fuel = math.floor(data.fuel),
        maxFuel = data.maxFuel,
        clickPower = getClickPower(data),
        autoRate = getAutoEnergyRate(data),
        ownedPets = data.ownedPets,
        eggInventory = data.eggInventory,
        permanentUpgrades = data.permanentUpgrades,
        areaCost = AreaData[data.area + 1] and AreaData[data.area + 1].UnlockCost or nil,
    }

    stateRemote:FireClient(player, state)
end

local function rollEggPet(egg)
    local totalWeight = 0
    for _, entry in ipairs(egg.Pool) do
        totalWeight += entry.Weight
    end

    local roll = math.random() * totalWeight
    local current = 0

    for _, entry in ipairs(egg.Pool) do
        current += entry.Weight
        if roll <= current then
            return entry.PetId
        end
    end

    return egg.Pool[1].PetId
end

local function awardPassiveEnergy()
    for _, player in ipairs(Players:GetPlayers()) do
        local data = getPlayerState(player)

        local pets = activePetCount(data)
        if pets > 0 and data.fuel > 0 then
            local generation = getAutoEnergyRate(data)
            local burn = math.min(data.fuel, pets * 0.25)
            data.fuel = math.max(0, data.fuel - burn)
            data.energy = data.energy + generation
            data.totalEarned = data.totalEarned + generation
        end

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

buyEggRemote.OnServerInvoke = function(player, eggId)
    local data = getPlayerState(player)
    local egg = getEggById(eggId)
    if not egg then
        return false, "Egg not found"
    end

    if egg.AreaRequired > data.area then
        return false, "This egg is not available in this area"
    end

    if data.energy < egg.Cost then
        return false, "Not enough energy"
    end

    data.energy = data.energy - egg.Cost
    data.eggInventory[eggId] = (data.eggInventory[eggId] or 0) + 1
    syncPlayer(player)

    return true, "Bought " .. egg.Name
end

openEggRemote.OnServerInvoke = function(player, eggId)
    local data = getPlayerState(player)
    local egg = getEggById(eggId)
    if not egg then
        return false, "Egg not found"
    end

    if (data.eggInventory[eggId] or 0) <= 0 then
        return false, "You do not own this egg"
    end

    data.eggInventory[eggId] = data.eggInventory[eggId] - 1

    local petId = rollEggPet(egg)
    local pet = getPetById(petId)
    if not pet then
        return false, "The egg did not contain a valid pet"
    end

    data.ownedPets[petId] = (data.ownedPets[petId] or 0) + 1
    syncPlayer(player)

    return true, pet.Name
end

collectFuelRemote.OnServerInvoke = function(player)
    local data = getPlayerState(player)
    local gain = GameConfig.FuelPerPickup + (data.rebirths * 2)
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

    if targetAreaId > data.area then
        if data.energy < area.UnlockCost then
            return false, "Not enough energy to travel"
        end
        data.energy = data.energy - area.UnlockCost
    end

    data.area = targetAreaId
    syncPlayer(player)
    return true, "Travelled to " .. area.Name
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
    data.maxFuel = GameConfig.MaxFuel
    data.eggInventory = {}
    data.ownedPets = {}

    local newRebirths = data.rebirths + 1
    data.rebirths = newRebirths
    data.gems = data.gems + RebirthConfig:GetGems(newRebirths - 1)

    syncPlayer(player)
    return true, "Rebirth complete. Multiplier: x" .. tostring(RebirthConfig:GetMultiplier(newRebirths))
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
        return false, "Already purchased"
    end

    if data.gems < upgrade.Cost then
        return false, "Not enough gems"
    end

    data.gems = data.gems - upgrade.Cost
    data.permanentUpgrades[upgradeId] = true
    syncPlayer(player)

    return true, "Purchased " .. upgrade.Name
end

if RunService:IsStudio() then
    task.wait(1)
end

while true do
    task.wait(1)
    awardPassiveEnergy()
end
