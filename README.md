JS-Pong
=======

Task:

The task is to create a Pong game with 1- and 2 player mode using native programming (Objective C). In 1-player mode your opponent is AI (computer).

Log:

Started out with trying to achieve a one-player mode demo. Had to do some reading to remember what iOS-coding was all about. New stuff for me since I last was into it, is the storyboard design pane. Figured out roughly how it works, and set up the game play view objects, totally without design (or maybe design inspired by the original pong...). Implemented the interaction, such as moving a vertical slider, moves your paddle. First iteration of a game loop, inside the game view controller. Created the puck object that should take care of its own position and movements (puck = ball). Collision detection inside the game loop. First simple embryo of single player AI: opponent paddle moves in the same direction as the puck (impossible to beat). Added goal detection and points counter.

Next: Multiplayer network game. Implemented packet messaging on top of GameKit (GKSession), inspired by a tutorial by Matthijs Hollemans (http://www.raywenderlich.com/12735/how-to-make-a-simple-playing-card-game-with-multiplayer-and-bluetooth-part-1). Added the views for hosting and joining games to my iPhone-storyboard. Added packet classes for sending info about paddle movements between server and client. Begun to move a lot of the game logic to a game model class, as the server is to be responsible for keeping track of object movements on the screen. Broke most of the single game functionality as I moved the game loop to the game model. 

What's next: Rewrite the game loop and let the puck move again. Rewrite the points calculation. Add a single player mode to the game model.



