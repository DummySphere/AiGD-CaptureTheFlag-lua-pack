
local GreedyCommander = class(Commander)

error("TODO: GreedyCommander")
--[[
class GreedyCommander : public Commander
{
public:
    virtual string getName() const
    virtual void initialize()
    virtual void tick()
    virtual void shutdown()
end

REGISTER_COMMANDER(GreedyCommander)


function GreedyCommander:getName()
    -- change this to return the commander name
    return "GreedyCommander"
end


function GreedyCommander:initialize()
    -- do stuff in here before the game starts
end


function GreedyCommander:tick()
    --
    -- Process the bots that are waiting for orders, either send them all to attack or all to defend.
    --

    local captured = self.game.enemyTeam.flag.carrier == nil

    local our_flag = self.game.team.flag.position
    local their_flag = self.game.enemyTeam.flag.position
    local their_base = self.level.botSpawnAreas[self.game.enemyTeam.name].first

    local option = (int)((float)rand()/RAND_MAX*3)
    local lookat
    switch(option)
    {
    case 0: lookat = their_flag; break
    case 1: lookat = their_flag; break
    case 2: lookat = their_base; break
    end

    -- Only process bots that are done with their orders...
    for(size_t i=0; i<self.game.bots_available.size(); ++i)
    {
        local bot = self.game.bots_available[i]
        if(captured)
        {
            local target = self.game.team.flagScoreLocation
            local closeEnoughDist = 8.0f

            -- 1) Either run home, if this bot is the carrier or otherwise randomly.
            if((bot.flag ~= nil) or (rand()<(RAND_MAX/2)) or target.distance(*bot.position) > closeEnoughDist)
            {
                self:issue(ChargeCommand(bot.name, target, "scrambling home"))
            end
            else -- 2) Run to the exact flag location, effectively escorting the carrier.
            {
                self:issue(AttackCommand(bot.name, self.game.enemyTeam.flag.position, boost:make_optional(lookat), "attacking enemy flag"))
            end
        end
        else
        {
            local spawnArea = self.level.botSpawnAreas[self.game.team.name]
            local inSpawn =  (   bot.position.x >= spawnArea.first.x 
                            and  bot.position.x <= spawnArea.second.x
                            and  bot.position.y >= spawnArea.first.y
                            and  bot.position.y <= spawnArea.second.y)

            local path
            path.push_back(self.game.enemyTeam.flag.position)

            if(inSpawn and (rand()<(RAND_MAX/2)))
                path.insert(path.begin(), self.game.team.flagScoreLocation)

            self:issue(AttackCommand(bot.name, path, boost:make_optional(lookat), "attacking enemy flag"))
        end
    end
end


function GreedyCommander:shutdown()
    -- do stuff in here after the game finishes
end
]]

return GreedyCommander
