local meleeEnabled = true
local lastMeleeTime = 0

RegisterCommand(Config.Command, function()
    lib.registerContext({
        id = 'melee_toggle_menu',
        title = Locales.menu_title,
        options = {
            {
                title = meleeEnabled and Locales.menu_enabled or Locales.menu_disabled,
                description = Locales.menu_desc,
                icon = 'fa-solid fa-gun',
                onSelect = function()
                    meleeEnabled = not meleeEnabled
                    lib.notify({
                        title = Locales.menu_title,
                        description = meleeEnabled and Locales.notify_on or Locales.notify_off,
                        type = meleeEnabled and 'success' or 'error'
                    })
                end
            }
        }
    })

    lib.showContext('melee_toggle_menu')
end, false)

CreateThread(function()
    while true do
        Wait(0)
        if meleeEnabled and IsControlJustPressed(0, 45) then
            local ped = PlayerPedId()

            if IsPedArmed(ped, 4) and not IsPedReloading(ped) and not IsPedInAnyVehicle(ped) then
                local weaponHash = GetSelectedPedWeapon(ped)

                if IsWeaponGun(weaponHash) then
                    local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

                    if closestPlayer ~= -1 and closestDistance <= Config.MeleeDistance then
                        local now = GetGameTimer()
                        if now - lastMeleeTime >= Config.Cooldown then
                            lastMeleeTime = now

                            TaskPlayAnim(ped, "melee@unarmed@streamed_variations", "plyr_takedown_front_slap", 8.0, -8, -1, 0, 0, false, false, false)
                            Wait(600)
                            ApplyDamageToPed(GetPlayerPed(closestPlayer), 10, false)

                            lib.notify({
                                title = Locales.menu_title,
                                description = Locales.notify_hit,
                                type = 'inform'
                            })
                        end
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    RequestAnimDict("melee@unarmed@streamed_variations")
    while not HasAnimDictLoaded("melee@unarmed@streamed_variations") do
        Wait(10)
    end
end)
