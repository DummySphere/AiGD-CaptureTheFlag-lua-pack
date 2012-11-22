
local GreedyCommander = class(Commander)

error("TODO: GreedyCommander")
--[[
class GreedyCommander : public Commander
{
public:
    virtual string getName() const;
    virtual void initialize();
    virtual void tick();
    virtual void shutdown();
};

REGISTER_COMMANDER(GreedyCommander);


string GreedyCommander::getName() const
{
    // change this to return the commander name
    return "GreedyCommander";
}


void GreedyCommander::initialize()
{
    // do stuff in here before the game starts
}


void GreedyCommander::tick()
{
    //
    // Process the bots that are waiting for orders, either send them all to attack or all to defend.
    //

    bool captured = m_game->enemyTeam->flag->carrier == NULL;

    Vector2 our_flag = m_game->team->flag->position;
    Vector2 their_flag = m_game->enemyTeam->flag->position;
    Vector2 their_base = m_level->botSpawnAreas[m_game->enemyTeam->name].first;

    int option = (int)((float)rand()/RAND_MAX*3);
    Vector2 lookat;
    switch(option)
    {
    case 0: lookat = their_flag; break;
    case 1: lookat = their_flag; break;
    case 2: lookat = their_base; break;
    }

    // Only process bots that are done with their orders...
    for(size_t i=0; i<m_game->bots_available.size(); ++i)
    {
        BotInfo* bot = m_game->bots_available[i];
        if(captured)
        {
            Vector2 target = m_game->team->flagScoreLocation;
            float closeEnoughDist = 8.0f;

            // 1) Either run home, if this bot is the carrier or otherwise randomly.
            if((bot->flag != NULL) || (rand()<(RAND_MAX/2)) || target.distance(*bot->position) > closeEnoughDist)
            {
                issue(new ChargeCommand(bot->name, target, "scrambling home"));
            }
            else // 2) Run to the exact flag location, effectively escorting the carrier.
            {
                issue(new AttackCommand(bot->name, m_game->enemyTeam->flag->position, boost::make_optional(lookat), "attacking enemy flag"));
            }
        }
        else
        {
            std::pair<Vector2, Vector2> spawnArea = m_level->botSpawnAreas[m_game->team->name];
            bool inSpawn =  (   bot->position->x >= spawnArea.first.x 
                            &&  bot->position->x <= spawnArea.second.x
                            &&  bot->position->y >= spawnArea.first.y
                            &&  bot->position->y <= spawnArea.second.y);

            vector<Vector2> path;
            path.push_back(m_game->enemyTeam->flag->position);

            if(inSpawn && (rand()<(RAND_MAX/2)))
                path.insert(path.begin(), m_game->team->flagScoreLocation);

            issue(new AttackCommand(bot->name, path, boost::make_optional(lookat), "attacking enemy flag"));
        }
    }
}


void GreedyCommander::shutdown()
{
    // do stuff in here after the game finishes
}
]]

return GreedyCommander
