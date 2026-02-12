local function hasRole(playerDiscordId, requiredRoleId)
    if not Config.BotToken or Config.BotToken == "YOUR_BOT_TOKEN_HERE" then
        print("[discord_gun_commands] Error: Bot token not set!")
        return false
    end

    if not Config.GuildID or Config.GuildID == "YOUR_GUILD_ID_HERE" then
        print("[discord_gun_commands] Error: Guild ID not set!")
        return false
    end

    local endpoint = ("https://discord.com/api/v10/guilds/%s/members/%s"):format(Config.GuildID, playerDiscordId)
    local headers = {
        ["Authorization"] = "Bot " .. Config.BotToken,
        ["Content-Type"]  = "application/json"
    }

    PerformHttpRequest(endpoint, function(statusCode, response, headers)
        if statusCode == 200 then
            local data = json.decode(response)
            if data and data.roles then
                for _, role in ipairs(data.roles) do
                    if role == requiredRoleId then
                        -- Found the role → trigger the give logic
                        local src = source  -- because we're in callback, source is lost
                        local xPlayer = source  -- wait, better to pass source earlier

                        -- Actually better structure below
                        return
                    end
                end
            end
        elseif statusCode == 429 then
            print("[discord_gun_commands] Rate limited by Discord API!")
        elseif statusCode == 401 or statusCode == 403 then
            print("[discord_gun_commands] Invalid bot token or missing permissions!")
        end
    end, 'GET', '', headers)

    -- If we reach here without finding role in sync way → false
    -- (this is async, so we need to restructure – see improved version below)
end

-- Better: we'll do the check inside each command

for _, cmd in ipairs(Config.Commands) do
    RegisterCommand(cmd.command, function(source, args, raw)
        local player = source

        -- Get player's Discord identifier
        local discordId
        for _, id in ipairs(GetPlayerIdentifiers(player)) do
            if string.find(id, "discord:") then
                discordId = string.sub(id, 9)  -- remove "discord:"
                break
            end
        end

        if not discordId then
            TriggerClientEvent('ox_lib:notify', player, {
                type = 'error',
                title = 'Error',
                description = 'Cannot find your Discord ID. Make sure Discord is linked.'
            })
            return
        end

        -- Check role via Discord API
        local url = ("https://discord.com/api/v10/guilds/%s/members/%s"):format(Config.GuildID, discordId)

        PerformHttpRequest(url, function(code, text)
            if code ~= 200 then
                TriggerClientEvent('ox_lib:notify', player, {
                    type = 'error',
                    description = 'Failed to verify Discord role (API error ' .. code .. ')'
                })
                if code == 401 or code == 403 then
                    print("[discord_gun_commands] Invalid bot token or bot not in server / missing perms")
                end
                return
            end

            local member = json.decode(text)
            if not member or not member.roles then
                TriggerClientEvent('ox_lib:notify', player, { type = 'error', description = 'Could not read your Discord roles' })
                return
            end

            local hasRequiredRole = false
            for _, roleId in ipairs(member.roles) do
                if roleId == cmd.RequiredRole then
                    hasRequiredRole = true
                    break
                end
            end

            if not hasRequiredRole then
                TriggerClientEvent('ox_lib:notify', player, {
                    type = 'error',
                    title = 'Access Denied',
                    description = 'You need a specific Discord role to use this command.'
                })
                return
            end

            -- Has role → give item
            local success, response = exports.ox_inventory:AddItem(player, cmd.item, Config.DefaultAmount or 1)

            if success then
                TriggerClientEvent('ox_lib:notify', player, {
                    type = 'success',
                    description = 'Received ' .. cmd.item .. ' ×' .. (Config.DefaultAmount or 1)
                })
            else
                TriggerClientEvent('ox_lib:notify', player, {
                    type = 'error',
                    description = 'Could not add item: ' .. tostring(response or 'unknown error')
                })
            end

        end, 'GET', '', {
            Authorization = "Bot " .. Config.BotToken,
            ["Content-Type"] = "application/json"
        })

    end, false)  -- false = not ACE restricted
end

print("[discord_gun_commands] Loaded " .. #Config.Commands .. " role-based weapon commands")