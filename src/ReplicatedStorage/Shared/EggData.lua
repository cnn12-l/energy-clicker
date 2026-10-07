local EggData = {
    {
        Id = "basic_egg",
        Name = "Basic Egg",
        Cost = 50,
        AreaRequired = 1,
        Pool = {
            { PetId = "solar_panel", Weight = 55 },
            { PetId = "hand_crank", Weight = 35 },
            { PetId = "wind_turbine", Weight = 10 },
        },
    },
    {
        Id = "advanced_egg",
        Name = "Advanced Egg",
        Cost = 250,
        AreaRequired = 2,
        Pool = {
            { PetId = "wind_turbine", Weight = 45 },
            { PetId = "geothermal_core", Weight = 35 },
            { PetId = "fusion_cell", Weight = 20 },
        },
    },
    {
        Id = "storm_egg",
        Name = "Storm Egg",
        Cost = 1000,
        AreaRequired = 3,
        Pool = {
            { PetId = "fusion_cell", Weight = 45 },
            { PetId = "particle_accelerator", Weight = 35 },
            { PetId = "dyson_sphere", Weight = 20 },
        },
    },
    {
        Id = "void_egg",
        Name = "Void Egg",
        Cost = 5000,
        AreaRequired = 4,
        Pool = {
            { PetId = "dyson_sphere", Weight = 40 },
            { PetId = "black_hole_synthesizer", Weight = 35 },
            { PetId = "quantum_reactor", Weight = 25 },
        },
    },
}

return EggData
