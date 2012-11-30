AiGameDev CTF Lua Bindings
==========================

The Lua starter kit for the Capture the Flag SDK allows you to write your commander in Lua. 
It uses a network interface (JSON) to give orders to your bots. 


Prerequisites
-------------
In order to use it you need the aisandbox AND the Capture the Flag SDK. If you have not installed these yet get to http://aisandbox.com/download/. 


Developing on Windows
---------------------
Modify the simulate.py file so that the defaults variable is set with the game.NetworkCommander and the commander that you want to test your commander against.
eg defaults = ['examples.Defender', 'game.NetworkCommander']
Run simulate.bat to start the game server.

Write your commander into the functions provided in MyCommander.lua.

Run client.lua.

	client.bat [HOST PORT] [CommanderFile]

You can launch the examples with the following commands:
* `client.bat examples.RandomCommander`
* `client.bat examples.DefenderCommander`
* `client.bat examples.GreedyCommander`
* `client.bat examples.BalancedCommander`


Developing on Linux
-------------------
Run the game server using simulate.py with game.NetworkCommander as one of the provided commanders.
eg simulate.py example.GreedyCommander game.NetworkCommander

Write your commander into the functions provided in MyCommander.lua.

Run client.lua.

	lua client.lua [HOST PORT] [CommanderFile]

You can launch the examples with the following commands:
* `lua client.lua examples.RandomCommander`
* `lua client.lua examples.DefenderCommander`
* `lua client.lua examples.GreedyCommander`
* `lua client.lua examples.BalancedCommander`


API
---

### Commands

* `DefendCommand( bot.name [ , description ] )`
* `DefendCommand( bot.name , { facingDirection = { x, y } } [ , description ] )`
* `DefendCommand( bot.name, { facingDirection_list = { [ DefendCommand.FacingDirection( { x1, y1 } [ , time ] ) ]* } } [ , description ] )`
* `MoveCommand( bot.name , { target = { x, y } } [ , description ] )`
* `MoveCommand( bot.name, { target_list = { [ { x, y } ]* } } [ , description ] )`
* `AttackCommand( bot.name , { target = { x, y } [ , lookAt = { x, y } ] } [ , description ] )`
* `AttackCommand( bot.name, { target_list = { [ { x, y } ]* } [ , lookAt = { x, y } ] } [ , description ] )`
* `ChargeCommand( bot.name , { target = { x, y } } [ , description ] )`
* `ChargeCommand( bot.name, { target_list = { [ { x, y } ]* } } [ , description ] )`


ToDo
----

* Convert examples.GreedyCommander and examples.BalancedComander to Lua
* Merge received GameInfo at each tick instead of replacing it (to allow the user to extend it)
* Add Vector2 metatable


History
-------

### Next version

* Fix function LevelInfo.findRandomFreePositionInBox
* Fix commander examples.DefenderCommander

### Version 0.2 (2012-11-29)

* Update to protocol version 1.2
* Add a short API documentation
* Lot of bugfixes
* Add Vector2 utilities
* Convert examples.RandomCommander and examples.DefenderComander to Lua

### Version 0.1 (2012-11-21)

* Early version release (alpha)
* Handle protocol version 1.1
