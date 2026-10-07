local RebirthConfig = {}

RebirthConfig.BaseCost = 1000
RebirthConfig.CostScale = 5
RebirthConfig.MultiplierScale = 1.2
RebirthConfig.GemsPerRebirth = 50

function RebirthConfig:GetCost(rebirthCount)
    return self.BaseCost * (self.CostScale ^ rebirthCount)
end

function RebirthConfig:GetMultiplier(rebirthCount)
    return self.MultiplierScale ^ rebirthCount
end

function RebirthConfig:GetGems(rebirthCount)
    return self.GemsPerRebirth * (rebirthCount + 1)
end

return RebirthConfig
