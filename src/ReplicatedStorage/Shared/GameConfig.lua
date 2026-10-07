local GameConfig = {}

GameConfig.BaseClickPower = 1
GameConfig.StartingEnergy = 0
GameConfig.StartingGems = 0
GameConfig.StartingRebirths = 0
GameConfig.MaxFuel = 100
GameConfig.FuelPerPickup = 10

GameConfig.RemoteNames = {
    State = "EnergyState",
    Click = "EnergyClick",
    BuyEgg = "BuyEgg",
    OpenEgg = "OpenEgg",
    CollectFuel = "CollectFuel",
    Travel = "Travel",
    Rebirth = "Rebirth",
    BuyGemUpgrade = "BuyGemUpgrade",
}

return GameConfig
