#include <string>
#include <boost/none.hpp>

#include "../api/GameInfo.h"
#include "../api/Commands.h"
#include "../api/Commander.h"
#include "../api/CommanderFactory.h"

using namespace std;

class RandomCommander : public Commander
{
public:
    virtual string getName() const;
    virtual void initialize();
    virtual void tick();
    virtual void shutdown();
};

REGISTER_COMMANDER(RandomCommander);


string RandomCommander::getName() const
{
    // change this to return the commander name
    return "RandomCommander";
}


void RandomCommander::initialize()
{
    // do stuff in here before the game starts
}


void RandomCommander::tick()
{
    //"""Process all the bots that are done with their orders and available for taking commands."""

    // The 'bots_available' list is a dynamically calculated list of bots that are done with their commands.
    for (auto i = m_game->bots_available.begin(), end = m_game->bots_available.end(); i!=end; ++i)
    {
        // Determine a place to run randomly...
        Vector2 target;
        switch((int)((float)rand()/RAND_MAX*3))
        {
        case 0: // Either a random choice of *current* flag locations, ours or theirs.
            target = (((float)rand()/RAND_MAX > 0.5f) ? m_game->team:m_game->enemyTeam)->flag->position;
            break;

        case 1: // Or a random choice of the goal locations for returning flags.
            target = (((float)rand()/RAND_MAX > 0.5f) ? m_game->team:m_game->enemyTeam)->flagScoreLocation;
            break; 

        case 2: // Or a random position in the entire level, one that's not blocked.
            target = *(*i)->position;
            m_level->findRandomFreePositionInBox(target, Vector2(0.0f,0.0f), Vector2((float)m_level->width, (float)m_level->height));
            break;
        }

        switch((int)((float)rand()/RAND_MAX*2))
        {
            case 0: issue(new AttackCommand((*i)->name, target, boost::none, "random")); break;
            case 1: issue(new ChargeCommand((*i)->name, target, "random")); break;
        }
    }
}


void RandomCommander::shutdown()
{
    // do stuff in here after the game finishes
}

