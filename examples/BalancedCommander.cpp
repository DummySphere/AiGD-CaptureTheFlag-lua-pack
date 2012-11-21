#include <string>
#include <boost/none.hpp>

#include "../api/Commands.h"
#include "../api/Commander.h"
#include "../api/CommanderFactory.h"
#include "../api/GameInfo.h"

using namespace std;

class BalancedCommander : public Commander
{
public:
    virtual string getName() const;
    virtual void initialize();
    virtual void tick();
    virtual void shutdown();

private:
    Vector2 getFlankingPosition(BotInfo* bot, Vector2 target);

    BotInfo *attacker;
    BotInfo *defender;
    Vector2 middle, left, right, front;
};

REGISTER_COMMANDER(BalancedCommander);


string BalancedCommander::getName() const
{
    // change this to return the commander name
    return "BalancedCommander";
}


void BalancedCommander::initialize()
{
    // do stuff in here before the m_game starts
    attacker = NULL;
    defender = NULL;

    // Calculate flag positions &&  store the middle->
    Vector2 ours = m_game->team->flag->position;
    Vector2 theirs = m_game->enemyTeam->flag->position;
    middle = (theirs + ours) / 2.0f;

    Vector2 d = (ours - theirs);    
    left = Vector2(-d.y, d.x).normalisedCopy();
    right = Vector2(d.y, -d.x).normalisedCopy();
    front = Vector2(d.x, d.y).normalisedCopy();
}


void BalancedCommander::tick()
{
    // the attacker is dead we"ll pick another when available
    if(attacker && *attacker->health <= 0)
        attacker = NULL;

    // the defender is dead we"ll pick another when available
    if( defender &&  (*defender->health <= 0 || defender->flag))
        defender = NULL;

    // In this example we loop through all living bots without orders (m_game->bots_available)
    // All other bots will wander randomly
    for (size_t i=0; i< m_game->bots_available.size(); ++i)
    {
        auto bot = m_game->bots_available[i];
        if( (defender == NULL || defender == bot) &&  !bot->flag)
        {
            defender = bot;

            // Stand on a random position in a box of 4m around the flag->
            Vector2 targetPosition = m_game->team->flagScoreLocation;
            Vector2 targetMin = targetPosition - Vector2(2.0f, 2.0f);
            Vector2 targetMax = targetPosition + Vector2(2.0f, 2.0f);
            Vector2 goal = targetPosition;
            m_level->findRandomFreePositionInBox(goal, targetMin, targetMax);

            if( (goal - *bot->position).length() > 8.0f)
                issue(new ChargeCommand(defender->name, goal, "running to defend"));
            else
                issue(new DefendCommand(defender->name, (middle - *bot->position), "turning to defend"));
        }
        else if (attacker == NULL || attacker == bot || bot->flag)
        {
            // Our attacking bot
            attacker = bot;
            if( bot->flag)
            {
                // Tell the flag carrier to run home!
                Vector2 target = m_game->team->flagScoreLocation;
                issue(new MoveCommand(bot->name, target, "running home"));
            }
            else
            {
                Vector2 target = m_game->enemyTeam->flag->position;
                Vector2 flank = getFlankingPosition(bot, target);
                if( (target - flank).length() > (*bot->position - target).length())
                    issue(new AttackCommand(bot->name, target, target, "attack from flank"));
                else
                {
                    m_level->findNearestFreePosition(flank, flank);
                    issue(new MoveCommand(bot->name, flank, "running to flank"));
                }
            }
        }
        else
        {
            // All our other (random) bots

            // pick a random position in the m_level to move to                               
            int minSide = min(m_level->width, m_level->height);
            Vector2 box = Vector2((float)minSide,(float)minSide);
            Vector2 target;

            // issue the order
            if(m_level->findRandomFreePositionInBox(target, middle + box * 0.4f, middle - box * 0.4f))
                issue(new AttackCommand(bot->name, target, boost::none,"random patrol"));
        }
    }
}   


void BalancedCommander::shutdown()
{
    // do stuff in here after the game finishes
}

Vector2 BalancedCommander::getFlankingPosition( BotInfo* bot, Vector2 target )
{
    Vector2 flanks[]  =  {target + left*16.0f, target + right*16.0f};
    vector<Vector2> options;
    for(int i=0; i<2; ++i)
    {
        Vector2 val;
        if(m_level->findNearestFreePosition(val, flanks[i]))
            options.push_back(val);
    }

    float bestDist = FLT_MAX;
    Vector2 bestOption = target;
    for (size_t i=0; i<options.size(); ++i)
    {
        float dist = (options[i]-*bot->position).length();
        if(dist < bestDist)
        {
            bestDist = dist;
            bestOption = options[i];
        }
    }
    return bestOption;
}

