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

	lua client.lua [HOST PORT] [CommanderFile]


Developing on Linux
-------------------
Run the game server using simulate.py with game.NetworkCommander as one of the provided commanders.
eg simulate.py example.GreedyCommander game.NetworkCommander

Write your commander into the functions provided in MyCommander.lua.

Run your bot, providing the commander name as the command line argument.
eg client MyCommander


TODO
----

* Convert the example folder to Lua.
