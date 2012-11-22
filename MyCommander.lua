
local MyCommander = class(Commander)

function MyCommander:new(...)
    Commander.new(self, ...)
    -- Custom constructor here
end

function MyCommander:getName()
    -- Change this to return the commander name
    return "LuaCommander"
end

function MyCommander:initialize()
    -- Use this function to setup your bot before the game starts.
end

function MyCommander:tick()
    -- Use this function to do stuff each time a game update is received.
    -- Here you can access all the information in self.level (information about the level being played)
    -- and self.game (information about the current game state).
    -- You can send commands to your bots using the issue member function

    local enemyFlag = self.game.enemyTeam.flag
    local enemyFlagPosition = enemyFlag.position
	
    local bots = self.game.team.members
    for _, bot in ipairs(bots) do
        if bot.health > 0.0 then
            -- Tell all of the alive bots to attack the enemy flag
            self:issue(AttackCommand(bot.name, { target = enemyFlagPosition }, "attack"))
        end
    end
end

function MyCommander:shutdown()
    -- Use this function to do stuff after the game finishes.
end

return MyCommander
