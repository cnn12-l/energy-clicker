# Energy Clicker

An idle clicker game built for Roblox Studio with:
- click-to-gain energy gameplay
- generator pets that orbit the player
- world progression across multiple areas
- fuel gathering mechanic
- rebirth system with permanent multiplier gains
- gem-based permanent upgrades

## Core loop
1. Click to gain energy.
2. Buy eggs / generator pets.
3. Let pets generate energy automatically over time.
4. Travel to new areas for stronger pets.
5. Farm fuel and gems in later zones.
6. Rebirth to earn permanent power scaling.

## Project structure
- `src/ServerScriptService/GameSystems.lua` — main game logic
- `src/StarterPlayer/StarterPlayerScripts/ClickerClient.lua` — client UI and interactions
- `src/ReplicatedStorage/Shared/*.lua` — game data and balance config

## How to use in Roblox Studio
1. Create a new place in Roblox Studio.
2. Put `GameSystems.lua` in `ServerScriptService`.
3. Put `ClickerClient.lua` in `StarterPlayer/StarterPlayerScripts`.
4. Make sure the `Shared` folder exists in `ReplicatedStorage`.
5. Paste in `GameConfig.lua`, `PetData.lua`, `AreaData.lua`, `RebirthConfig.lua`, and `GemUpgrades.lua` into that folder.
6. Press Play.

## Notes
This is a complete starter project designed for a balanced clicker/rebirth gameplay loop.
It is built around the idea of generator pets floating around the player and energy-based progression, while keeping the structure familiar to games like Clicker Simulator and Rebirth Simulator.
