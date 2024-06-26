Config = {}

Config.deliveryVehicleSpawn = {x = 529.66, y = 106.79, z = 95.18, heading = 339.52} -- Delivery Vehicle Spawn
Config.deliveryVehicle = 'Faggio' -- The Delivery Vehicle

Config.deliverylocations = { -- locations where the user will have to deliver pizzas
    vector3(478.26, 57.05, 95.30),
    vector3(501.96, 112.99, 96.64), 
}

Config.RewardMultiplier = { -- How much money do you want to give them per delivery? Random number between min and max
    min = 25,
    max = 50
}

Config.DeliveryJob = 'pizzathis' -- This is the job that will be able to target the AI when active as the job and on duty. 

Config.PEDModel = 's_m_y_chef_01' -- PED Model we'll be using for the target
Config.PEDSpawn = {x = 537.12, y = 102.00, z = 95.56, heading = 160.63} -- PED spawn coordinates and heading
