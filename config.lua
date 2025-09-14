Config = {}

Config.Garages = {

    police = {
        cars = {
            {
                label = "PSP Carros",
                job = "police",
                coords = vector3(454.55, -1023.7, 28.48),
                spawn = vector4(445.74, -1020.68, 28.52, 93.28),
                markerColor = {0,0,255},
                markerSize = 3.0,
                vehicles = {
                    {model='police', label='Carro 1', minGrade=0},
                    {model='police3', label='Carro 2', minGrade=0}
                }
            }
        },
        heli = {
            {
                label = "PSP Helicópteros",
                job = "police",
                coords = vector3(449.2, -981.53, 43.69),
                spawn = vector4(449.2, -981.53, 43.69, 175.68),
                markerColor = {0,0,255},
                markerSize = 3.0,
                vehicles = {
                    {model='polmav', label='Heli 01', minGrade=2}
                }
            }
        },
        boats = {
            {
                label = "PSP Barcos",
                job = "police",
                coords = vector3(-793.05, -1491.87, 1.6),
                spawn = vector4(-794.17, -1501.56, -0.47, 109.7),
                returnCoords = vector3(-796.02, -1502.59, 1.6),
                returnPlayer = vector4(-799.85, -1494.12, 1.6, 122.68),
                markerColor = {0,0,255},
                markerSize = 3.0,
                vehicles = {
                    {model='predator', label='Barco', minGrade=1}
                }
            }
        }
    },

    ambulance = {
        cars = {
            {
                label = "INEM Carros",
                job = "ambulance",
                coords = vector3(297.3, -601.74, 43.19),
                spawn = vector4(295.1, -607.43, 43.26, 70.7),
                markerColor = {255,0,255},
                markerSize = 3.0,
                vehicles = {
                    {model='ambulance', label='Ambulance', minGrade=0}
                }
            }
        },
        heli = {
            {
                label = "INEM Helicópteros",
                job = "ambulance",
                coords = vector3(351.86, -587.95, 74.06),
                spawn = vector4(351.86, -587.95, 74.06, 249.18),
                markerColor = {255,0,255},
                markerSize = 5.0,
                vehicles = {
                    {model='conada', label='Heli', minGrade=2}
                }
            }
        },
        boats = {
            {
                label = "INEM Barcos",
                job = "ambulance",
                coords = vector3(-793.05, -1491.87, 1.6),
                spawn = vector4(-794.17, -1501.56, -0.47, 109.7),
                returnCoords = vector3(-796.02, -1502.59, 1.0),
                returnPlayer = vector4(-799.85, -1494.12, 1.6, 122.68),
                markerColor = {255,0,255},
                markerSize = 3.0,
                vehicles = {
                    {model='dinghy', label='Barco', minGrade=1}
                }
            }
        }
    },

    fire = {
        cars = {
            {
                label = "Bombeiros Carros",
                job = "fire",
                coords = vector3(1212.58, -1474.7, 34.69),
                spawn = vector4(1205.5, -1474.84, 34.69, 355.72),
                markerColor = {255,165,0},
                markerSize = 3.0,
                vehicles = {
                    {model='firetruk', label='Fire Truk', minGrade=0},
                    {model='lguard', label='ABSC02', minGrade=0}
                }
            }
        },
        heli = {
            {
                label = "Bombeiros Helicópteros",
                job = "fire",
                coords = vector3(1220.92, -1512.53, 36.35),
                spawn = vector4(1221.87, -1512.46, 36.35, 90.49),
                markerColor = {255,165,0},
                markerSize = 5.0,
                vehicles = {
                    {model='maverick', label='Heli', minGrade=2}
                }
            }
        },
        boats = {
            {
                label = "Bombeiros Barcos",
                job = "fire",
                coords = vector3(-793.05, -1491.87, 1.6),
                spawn = vector4(-794.17, -1501.56, -0.47, 109.7),
                returnCoords = vector3(-793.64, -1502.12, 1.12),
                returnPlayer = vector4(-799.85, -1494.12, 1.6, 122.68),
                markerColor = {255,165,0},
                markerSize = 3.0,
                vehicles = {
                    {model='dinghy', label='Barco 01', minGrade=1}
                }
            }
        }
    }

}
