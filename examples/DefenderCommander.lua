error("TODO: DefenderCommander")
--[[
class DefenderCommander : public Commander
{
public:
    virtual string getName() const;
    virtual void initialize();
    virtual void tick();
    virtual void shutdown();

private:
    BotInfo *attacker;
};

REGISTER_COMMANDER(DefenderCommander);


string DefenderCommander::getName() const
{
    // change this to return the commander name
    return "DefenderCommander";
}


void DefenderCommander::initialize()
{
    // do stuff in here before the m_game starts
    attacker = NULL;
}


void DefenderCommander::tick()
{
    // TODO: When defender is down to the last bot that"s attacking the flag, it"ll end up ordering
    // the attacker to run all the way back from the flag to defend!
    if (attacker && *attacker->health <= 0)
        attacker = NULL;

    for (size_t i=0; i<m_game->bots_available.size(); ++i)
    {
        auto bot = m_game->bots_available[i];
        if ((!attacker || attacker == bot) && m_game->bots_available.size() > 1)
        {
            if(bot->flag)
            {
                //bring it hooome
                auto targetLocation = m_game->team->flagScoreLocation;
                issue(new ChargeCommand(bot->name, targetLocation, "returning enemy flag!"));
            }
            else
            {
                // find the closest flag that isn"t ours
                auto enemyFlagLocation = m_game->enemyTeam->flag->position;
                issue(new ChargeCommand(bot->name, enemyFlagLocation, "getting enemy flag!"));
            }
            attacker = bot;
        }
        else
        {
            if (attacker == bot)
                attacker = NULL;

            // defend the flag!
            Vector2 targetPosition = m_game->team->flagScoreLocation;
            Vector2 targetMin = targetPosition - Vector2(8.0f, 8.0f);
            Vector2 targetMax = targetPosition + Vector2(8.0f, 8.0f);
            if(bot->flag)
            {
                //bring it hooome
                auto targetLocation = m_game->team->flagScoreLocation;
                issue(new ChargeCommand(bot->name, targetLocation, "returning enemy flag!"));
            }
            else if(bot->position)
            {
                if ((targetPosition - *bot->position).length() > 9.0f &&  (targetPosition - *bot->position).length() > 3.0f)
                {
                    bool found = false;
                    while(!found)
                    {
                        Vector2 position = targetPosition;
                        if(m_level->findRandomFreePositionInBox(position, targetMin,targetMax) && (targetPosition - position).length() > 3.0f)
                        {
                            issue(new MoveCommand(bot->name, position, "defending around flag"));
                            found = true;
                        }
                    }
                }
                else 
                    issue(new DefendCommand(bot->name, (targetPosition - *bot->position), "defending facing flag"));
            }
        }
    }
}


void DefenderCommander::shutdown()
{
    // do stuff in here after the m_game finishes
}
]]

return DefenderCommander
