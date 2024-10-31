# Remaking Atari Basketball (1978) in TIC-80 -- Made with Classmate Devin Burger

Play our remake [here](https://github.swarthmore.edu/pages/CS91S-F24/remake-dburger1-jstump2/game/).

Keyboard controlls Player1:
  ```
  Arrow Keys: Movement
  Z: Jump
  Hold A: Shoot
 ```

To use Player 2, must have 2 TIC-80 supported controllers

## The Early Process

This remake reimagines the 1979 Atari Basketball game using TIC-80, a fantasy emulator with self-imposed technical limitations to mimic retro style 8-bit games of the 1980s. Before programming, we focused on the setup of the game, customizing the sprites and map in the TIC-80 editor. We modeled our sprites – the characters of the game – after stop animation. For example, the dribble animation is created by alternating the sprite id drawn on the screen between the ball in the hand of the player and the ball on the ground. Our sprites were much more detailed than the original, making the ball round, the baskets realistic, and the players look like actual people. We also felt that the map in the original game was a bit boring, so we used the tile editor to create a much more colorful court, adding fans in the background, and the score being displayed on a jumbotron. 

![The Court at the beginning of the game](https://imgur.com/gIZMGWS.png)

> (Above): The map and sprites as the look at the beginning of the game.

## Essence of the Original

### Shooting and Perspective

Besides our obvious sprite deviations, we decided on a few changes we wanted to implement in our remake, and also a few aspects of the original that were an absolute necessity to keep in order to capture the essence of the game. First, we knew that the fan’s eye perspective – a 2D court captured from above but at angle rather than at the 12 o’clock bird’s eye view – was critical in not just gameplay but also how a player would perceive the pseudo-3D mechanics like shooting and jumping. In addition, making the shooting feel smooth and rewarding was the biggest singular focus of our remake. We wanted to maintain shot timing, where the longer the shot button is pressed, the farther the shot goes. To do this, we implemented a shot meter: a sprite next to the player that charges up the longer the shoot button is pressed. If the player shoots the ball with the correct timing, the meter will turn green and sparkly, signifying that the shot will eventually go in. We implemented this using a counter variable ‘t’ in the TIC() function – which is called 60 times per second – to track each iteration that the shoot button was held. In the background, we calculated the necessary ‘t’ value that should be pressed in order to score. During the press of the shoot button, ‘t’ is compared to the ideal ‘t’ value and the meter is updated based on what percentage ‘t’ is of the ideal t. By using this to determine initial velocity, the player only controls one variable of the shot: power. We also played with the audio to add a satisfying noise when the ball goes through the basket. 

![Player 1 dribbling before a shot](https://imgur.com/YaZn783.png)
> (Above): Player 1 dribbiling before a shot

![Player 1 part-way through shooting](https://imgur.com/QmL2GGB.png)
> (Above): Player 1 halfway through shooting

![Ball in the air after a shot](https://imgur.com/6HduOhP.png)
> (Above): Player 1 after releasing the ball. The green meter indicates the ball with eventually go in.

It’s important to pause here and note one unintended effect of the previously mentioned shot mechanics and the way player sprites are drawn: shooting from the direct corner of the court is impossible. In the original game, the player sprites aren’t very realistic to people, and the shot physics in the corner are different from other instances. If we implemented different physics in the corner into our game, it would look very strange because the detail of the player sprites firmly cements them in one direction. Even when a player moves along the y-axis, the sprite does not turn in any way. Therefore, our shot physics were visualized primarily as an x-axis action event. So when a player shoots from directly under the basket, the ball cannot get high enough to score before it moves past the basket in the x-direction. In the future, it would be interesting to explore changing the sprites to face the basket upon a corner shot and adding physics accordingly.

### Collision

Another aspect of the original we wanted to mimic was the collision detection. Using the ‘checkCollision()’ function, we used pixel checks to keep the same logic on steals and blocks. Like the Atari game, we used a range of values for the scoring check to keep the difficulty from being extreme. Since TIC-80 tracks the upper left corner of a sprite as its x and y values, we altered the collision point between player and ball to be the player’s dribble hand. This feels more natural when you go for a steal or to pick up a loose ball.

## Remake Deviations

When playing the original game, we were a bit disappointed by the slow pace – particularly after a shot. By implementing a roll feature that would move the ball toward the center of the screen after a shot, the player doesn't have to chase it down. Another change we made was maximum shot power. Since the sprites are bigger relative to the court in our version, we wanted players to shoot from any spot on the floor, making defense and offense constantly engaging. Since scoring would occur more often, we changed the point system to 1s and 2s instead of only 2s – deviating from the original by adding a virtual line in which a shot beyond the line would be given an additional point. To mirror this classic 1v1 streetball style, we altered the time-based win condition to a point-based win condition, where a player wins with 21 points, playing a buzzer sound to signify the end of the game.

## Patterns for Gameplay

In order to implement the gameplay mechanics, we used the middleclass library to create objects for the ball, players, and a vector class to help with the physics of shooting. We also utilized a manager to control the different states according to the state pattern discussed in class. It was tricky to decide which methods should fall under the object or a state in the game. We decided actions that directly affected the object should fall under the object itself, but states such as ‘Shoot’ and ‘Jump’ would handle game state variables such as ‘is_jumping’ or ‘is_scored.’ We also wanted to implement the update pattern, but since we were using the button inputs from the controller we decided it would be better to have an ‘updatePlayers’ state that could handle player1 and player2 separately rather than the player object’s self. This helped firm up our game loop in the TIC() function, where we would render with the ‘Game’ state, process input with ‘updatePlayers,’ ‘checkCollision,’ and  ‘ensureGameConstants’ – which checks important positions relevant to game flow and bug fixes. The game is then updated by calls to the different states, such as shooting, moving, and the ball class method ‘maybeRoll.’ 
