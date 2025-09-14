ESX = nil
local jobBlips = {}
local currentJobGarages = {}

-- Inicializa ESX
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
end)

-- Função para definir tanque cheio (0.0 a 1.0)
function SetFullFuel(vehicle)
    if DoesEntityExist(vehicle) then
        SetVehicleFuelLevel(vehicle, GetVehicleHandlingFloat(vehicle, 'CHandlingData', 'fPetrolTankVolume') or 100)
    end
end

-- Evento spawn de veículo do servidor
RegisterNetEvent('garage:spawnVehicleClient')
AddEventHandler('garage:spawnVehicleClient', function(vehicleData)
    local ped = PlayerPedId()
    local model = GetHashKey(vehicleData.model)
    RequestModel(model)
    while not HasModelLoaded(model) do Citizen.Wait(10) end

    local vehicle = CreateVehicle(model, vehicleData.coords.x, vehicleData.coords.y, vehicleData.coords.z, vehicleData.heading or 0.0, true, false)
    SetVehicleOnGroundProperly(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    TaskWarpPedIntoVehicle(ped, vehicle, -1)

    -- Tanque cheio
    SetFullFuel(vehicle)

    exports['okokNotify']:Alert("Garagem", "Veículo spawnado: " .. vehicleData.label, 3000, 'success')
end)


-- Evento devolver veículo do servidor
RegisterNetEvent('garage:returnVehicleClient')
AddEventHandler('garage:returnVehicleClient', function(vehicleType, garage)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then
        DeleteVehicle(vehicle)
        exports['okokNotify']:Alert("Garagem", "Veículo devolvido!", 3000, 'success')

        if vehicleType == "boats" and garage.returnPlayer then
            SetEntityCoords(ped, garage.returnPlayer.x, garage.returnPlayer.y, garage.returnPlayer.z)
            SetEntityHeading(ped, garage.returnPlayer.w or 0.0)
            exports['okokNotify']:Alert("Garagem", "Foste transportado para o cais!", 3000, 'info')
        end
    else
        exports['okokNotify']:Alert("Garagem", "Nenhum veículo por perto!", 3000, 'error')
    end
end)

-- Menu spawn de veículos
function OpenSpawnMenu(garage, vehicleType)
    local playerJob = ESX.GetPlayerData().job
    local elements = {}

    for _, v in ipairs(garage.vehicles) do
        -- Verifica autorização por grade
        local allowed = true
        if v.minGrade and playerJob.grade < v.minGrade then
            allowed = false
        end

        local emoji = (vehicleType=='cars' and '🚙 ') or (vehicleType=='boats' and '🚤 ') or '🚁 '
        local label = allowed and v.label or v.label .. " (⛔️ Sem autorização ⛔️)"
        table.insert(elements, {label = emoji..label, value = v, allowed = allowed})
    end

    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "garage_spawn_menu", {
        title="Escolher veículo", align="center", elements=elements
    }, function(data2, menu2)
        if not data2.current.allowed then
            exports['okokNotify']:Alert("Garagem", "Não tens autorização para retirar este veículo.", 3000, 'error')
            return
        end

        local vehicleData = data2.current.value
        vehicleData.type = vehicleType
        if vehicleType=="boats" and garage.spawn then
            vehicleData.coords = vector3(garage.spawn.x, garage.spawn.y, garage.spawn.z)
            vehicleData.heading = garage.spawn.w
        else
            vehicleData.coords = garage.spawn
            vehicleData.heading = garage.spawn.w
        end
        TriggerServerEvent("garage:spawnVehicle", garage.job, vehicleData)
        menu2.close()
    end, function(data2, menu2) menu2.close() end)
end

-- Menu devolver veículo
function OpenReturnMenu(garage, vehicleType)
    TriggerServerEvent("garage:returnVehicle", garage.job, vehicleType, garage)
end

-- Menu carros (reparar + extras)
function OpenCarExtrasMenu()
    local ped = PlayerPedId()
    local car = GetVehiclePedIsIn(ped, false)
    if car == 0 then
        exports['okokNotify']:Alert("Garagem", "Não estas num veículo!", 3000, 'error')
        return
    end

    SetVehicleFixed(car)
    SetVehicleDeformationFixed(car)
    SetVehicleUndriveable(car, false)
    SetVehicleEngineOn(car, true, true, true)
    exports['okokNotify']:Alert("Garagem", "Veículo reparado!", 3000, 'success')
end

-- Menu devolver/reparar barco
function OpenReturnBoatMenu(garage)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        exports['okokNotify']:Alert("Garagem", "Não está em um barco!", 3000, 'error')
        return
    end

    local elements = {
        {label="🛑 Devolver veículo", value="return"},
        {label="🛠 Reparar veículo", value="repair"}
    }

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "boat_return_menu", {
        title="Opções do barco", align="center", elements=elements
    }, function(data, menu)
        if data.current.value == "return" then
            TriggerServerEvent("garage:returnVehicle", ESX.GetPlayerData().job.name, "boats", garage)
            menu.close()
        elseif data.current.value == "repair" then
            SetVehicleFixed(vehicle)
            SetVehicleDeformationFixed(vehicle)
            SetVehicleUndriveable(vehicle, false)
            SetVehicleEngineOn(vehicle, true, true, true)
            exports['okokNotify']:Alert("Garagem", "Barco reparado!", 3000, 'success')
        end
    end, function(data, menu) menu.close() end)
end

-- Atualiza garages do job
function UpdateJobGarages(jobName)
    currentJobGarages = {}
    if Config.Garages[jobName] then
        for vehicleType, garages in pairs(Config.Garages[jobName]) do
            for _, garage in ipairs(garages) do
                table.insert(currentJobGarages, {garage = garage, type = vehicleType})
            end
        end
    end
end

-- Thread de marcadores
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)

        for _, data in ipairs(currentJobGarages) do
            local garage = data.garage
            local vehicleType = data.type

            -- Carros e heli
            if vehicleType ~= "boats" then
                local dist = #(playerCoords - garage.coords)
                if dist < garage.markerSize then
                    DrawMarker(1, garage.coords.x, garage.coords.y, garage.coords.z-1.0,
                        0,0,0,0,0,0,
                        garage.markerSize, garage.markerSize, 1.0,
                        garage.markerColor[1],garage.markerColor[2],garage.markerColor[3],
                        100,false,true,2,nil,nil,false)

                    if dist < 2.5 then
                        ESX.ShowHelpNotification("Pressione ~INPUT_CONTEXT~ para abrir a garagem")
                        if IsControlJustReleased(0,38) then
                            ESX.UI.Menu.CloseAll()
                            local emojiSpawn = (vehicleType=="cars" and "🚙 ") or "🚁 "
                            local elements = {
                                {label=emojiSpawn.."Retirar veículo", value="spawn"},
                                {label="🛠 Reparar veículo", value="repair"},
                                {label="🛑 Devolver veículo", value="return"}
                            }
                            ESX.UI.Menu.Open("default", GetCurrentResourceName(), "garage_car_menu", {title=garage.label, align="center", elements=elements},
                                function(data, menu)
                                    if data.current.value=="spawn" then OpenSpawnMenu(garage, vehicleType)
                                    elseif data.current.value=="return" then OpenReturnMenu(garage, vehicleType)
                                    elseif data.current.value=="repair" then OpenCarExtrasMenu()
                                    end
                                    menu.close()
                                end, function(data, menu) menu.close() end)
                        end
                    end
                end
            end

            -- Barcos
            if vehicleType=="boats" then
                -- Retirar
                local distSpawn = #(playerCoords - garage.coords)
                if distSpawn < garage.markerSize then
                    DrawMarker(1, garage.coords.x, garage.coords.y, garage.coords.z-1.0,
                        0,0,0,0,0,0,
                        garage.markerSize,garage.markerSize,1.0,
                        garage.markerColor[1],garage.markerColor[2],garage.markerColor[3],
                        100,false,true,2,nil,nil,false)

                    if distSpawn<2.5 then
                        ESX.ShowHelpNotification("Pressione ~INPUT_CONTEXT~ para retirar veículo")
                        if IsControlJustReleased(0,38) then
                            OpenSpawnMenu(garage, vehicleType)
                        end
                    end
                end

                -- Devolver
                if garage.returnCoords then
                    local distReturn = #(playerCoords - garage.returnCoords)
                    if distReturn < garage.markerSize then
                        DrawMarker(1, garage.returnCoords.x, garage.returnCoords.y, garage.returnCoords.z-1.0,
                            0,0,0,0,0,0,
                            garage.markerSize,garage.markerSize,1.0,
                            255,0,0, -- Vermelho
                            100,false,true,2,nil,nil,false)

                        if distReturn<2.5 then
                            ESX.ShowHelpNotification("Pressione ~INPUT_CONTEXT~ para devolver veículo")
                            if IsControlJustReleased(0,38) then
                                OpenReturnBoatMenu(garage)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Criação de blips
function CreateJobBlips(jobName)
    for _, blip in pairs(jobBlips) do RemoveBlip(blip) end
    jobBlips = {}
    if Config.Garages[jobName] then
        for vehicleType, garages in pairs(Config.Garages[jobName]) do
            for _, garage in ipairs(garages) do
                local blip = AddBlipForCoord(garage.coords.x, garage.coords.y, garage.coords.z)
                SetBlipSprite(blip, (vehicleType=="cars" and 225) or (vehicleType=="boats" and 410) or (vehicleType=="heli" and 43) or 1)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 0.7)
                SetBlipColour(blip, (vehicleType=="cars" and 3) or (vehicleType=="boats" and 5) or (vehicleType=="heli" and 1) or 0)
                SetBlipAsShortRange(blip,true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(garage.label)
                EndTextCommandSetBlipName(blip)
                table.insert(jobBlips, blip)
            end
        end
    end
end

-- Inicialização
Citizen.CreateThread(function()
    while ESX==nil do Citizen.Wait(10) end
    while ESX.GetPlayerData().job==nil do Citizen.Wait(10) end
    local job = ESX.GetPlayerData().job.name
    CreateJobBlips(job)
    UpdateJobGarages(job)
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    CreateJobBlips(job.name)
    UpdateJobGarages(job.name)
end)
