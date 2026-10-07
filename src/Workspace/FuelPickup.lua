local part = script.Parent
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:WaitForChild("EnergyRemotes")
local collectFuelRemote = remotesFolder:WaitForChild("CollectFuel")

part.Touched:Connect(function(hit)
    local character = hit.Parent
    if not character then return end

    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end

    collectFuelRemote:InvokeServer()
    part:Destroy()
end)
