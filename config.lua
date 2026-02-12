Config = {}

Config.BotToken   = ""          -- Bot token (must have SERVER MEMBERS INTENT enabled)
Config.GuildID    = ""           -- Discord server ID

Config.Commands = {
    { command = 'mygun',   item = '',        RequiredRole = '' },
    { command = 'mygun2',  item = '',      RequiredRole = '' },
    { command = 'mygun3',  item = '',           RequiredRole = '' },
    { command = 'mygun4',  item = '',  RequiredRole = '' },
    { command = 'mygunf',  item = '',     RequiredRole = '' },
}

-- Optional: how many of the item to give
Config.DefaultAmount = 1