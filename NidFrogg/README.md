# Inspired Creation Project -- NidFrogg (loosely based on Nidhogg)

Created by Jonathan Stump and Devin Burger

Sources: "Programming in Lua" by Roberto Ierusalimschy physical book and Lua.org/pil

BUTTONS CHANGED DURING EXPORT -- FOR CONTROLLER

Throw -- was B now B

Jump -- was A now X

Pickup -- was Y now A

Stab -- was X now Y

Alternatively without controller use, Press Esc, Settings, set keyboard controls for player 1 and 2

## Origins

This project is an expansion of our original attempt at a Nidhogg based game, in which we created a 1-D 1v1 frog fighting game.
In Nidhogg, two fighters attempt to maul each other to death with swords, becomming on the advance when they win and attempting to run as far as they can toward their edge of the screen
before the player who died respawns and defends. A player wins by reaching their end of the screen. A player can change the state of their sword,
which essentially serves as its attack position. If two players have the same sword state, they cannot hurt each other.

In our first attempt, we created a single instance of a Nidhogg game, but with a frog theme. In it, two frog players fight with their tongues, changing between three tongue states.
Each player starts with three lives, losing one each time they are hit and losing the game at zero. The biggest accomplishment
was implementing a hit timer that gave a player invincibility for three seconds upon being hit.

## Improvements to Gameplay
One big takeaway from our expansion process that we learned was about immersion. How the game makes you feel influences the enjoyment of the game, and games with immense immersion
can have a potentially cultural impact. On the contrary, games that don't feel right -- from visually such as Atari Pac-Man to mechanics such as collision detection in E.T. -- 
distract from the successes of the product. For greater immersion, we upgraded the game both visually and mechanically.

### Visuals/Sound
Our new map places the players in a gothic world under purple moonlight, a stark contrast from our hasty, kindergarten
drawn blue sky and green ground in the first attempt or the silly, playful graphics of Nidhogg 2. We also updated the player sprites themselves, making them less blocky. 
The playful frogs and mysterious setting create a uniquely fun but tense atmosphere.

In the original attempt, there was no sprite animation besides the changing of states. In this creation, we animated running, jumping, attacking, and even dying, giving a smooth look and feel
to every movement, and adding classic 8-bit sound to each one.

### Mechanics
We upgraded many attack mechanics from the original attempt, in particular attacking. Instead of tongues, our fighting frogs now have swords, which can be thrown or stabbed. To dodge, the other player can have their sword at the same
state, or can crouch or jump around it. Now when a player is hit, they do not lose a heart of health, but are either disarmed or take damage, a sword being more dangerous than a fist.

In addition, we replaced the invincibility timer mechanic with a bounce back mechanic, where a player is launched backwards if they make contact with an enemy.

### Objective
In this creation project, we expanded the map to create multiple rounds, with a movement based progression system similar to Nidhogg's. After killing the other player, you are allowed to advance to the next screen/round,
where the other player will respawn to confront you again. If that player kills you, it becomes their turn to advance in the opposite direction.

## Improvement to Code

### Abstraction/Optimization
We are proud to say that the TIC function is two lines long, a stark contrast from our first attempt.
We accomplished this through greater abstraction of helper functions focusing on more specific tasks rather than a broader aspect of gameplay. 

Another goal of ours was to keep the code as clean as possible. Despite little to no previous experience, we explored ternary operators as a way to save ourselves from hundreds of lines of if statements.

### Classes/Metatables
Through middleclass, we implemented both the players and sword as classes, a big upgrade from the tables in our original attempt.
One area of interest in this process was the relationship between the sword and player. We decided that the sword should have a player, but the player would not see any instance of the sword. By doing this, we can base some
sword attributes off of the player's. To do this, we implemented a metatable for the sword. Using the __index metamethod, if a function makes a call for sword.x or sword.y (which are not defined in the sword class), it enters the __index metamethod, returning a value
based on the player's x and y values. This value can be overriden if the sword is thrown throught the __newindex metamethod, which is called when the player sets sword.x = some value and sets an override variable equal to the value. Then, if the program calls for 
one of the nil variables such as x or y, the __index metamethod knows that the override variable has a value and returns that instead.

### Scene Manager
Because we did not employ a scene manager correctly in previous projects, we decided it was time for redemption. For this project, we added an opening screen, instructions screen, and game over screen in addition to the game being played. To swap between these screens appropriately,
we utilized a scene manager and the state pattern, which sets scenes to active, draws them, and for the game state, updates. Along with utilizing the buttonListener function to process input, this constituted our gamp loop design pattern.

## Our Unique Spin
Despite great influence from Nidhogg, we added our own creativity to make the game ours. For one, the screen stays locked until a kill in our game. This means that each screen is treated like a round, rather than one continuous race. In Nidhogg, players could jump over and run around their
opponent to progress towards their side of victory. In our game, the primary focus of each screen is combat, and with the screen lock no player has a traversal advantage each round. 

In combat, our aggressive bounce back, quick pickups, and disarming makes for unique gameplay, where the state of the duel is often neutral. While the width of the total map is smaller than Nidhogg, each duel lasts longer and feels more rewarding.
