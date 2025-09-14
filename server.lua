ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)
    ESX = obj
end)

-- Spawn de veículo
RegisterServerEvent('garage:spawnVehicle')
AddEventHandler('garage:spawnVehicle', function(jobName, vehicleData)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerJob = xPlayer.job

    if playerJob.name ~= jobName then
        print(('garage: %s tentou spawnar veículo do job %s!'):format(xPlayer.identifier, jobName))
        return
    end

    if not Config.Garages[jobName] then
        print(('garage: job %s não existe no config!'):format(jobName))
        return
    end

    if not Config.Garages[jobName][vehicleData.type] then
        print(('garage: tipo %s não existe para o job %s no config!'):format(vehicleData.type, jobName))
        return
    end

    for _, garage in ipairs(Config.Garages[jobName][vehicleData.type]) do
        for _, v in ipairs(garage.vehicles) do
            if v.model == vehicleData.model then
                local minGrade = v.minGrade or 0
                if playerJob.grade < minGrade then
                    TriggerClientEvent('okokNotify:Alert', source, "Garagem", "🚫 Não tens autorização para usar este veículo!", 3000, 'error')
                    return
                end

                local spawn = garage.spawn
                vehicleData.coords = vector3(spawn.x, spawn.y, spawn.z)
                vehicleData.heading = spawn.w
                TriggerClientEvent('garage:spawnVehicleClient', source, vehicleData)
                return
            end
        end
    end

    print(('garage: veículo %s não encontrado para job %s e tipo %s'):format(vehicleData.model, jobName, vehicleData.type))
end)

-- Devolver veículo
RegisterServerEvent('garage:returnVehicle')
AddEventHandler('garage:returnVehicle', function(jobName, vehicleType, garage)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerJob = xPlayer.job

    if playerJob.name ~= jobName then
        print(('garage: %s tentou devolver veículo do job %s!'):format(xPlayer.identifier, jobName))
        return
    end

    TriggerClientEvent('garage:returnVehicleClient', source, vehicleType, garage)
end)
