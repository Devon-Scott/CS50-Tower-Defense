This is a tower defense game I created as my final project for CS50x.
I created it primarily with the goal of testing my ability to learn and implement new ideas, such as mouse movement, the trigonometry involved with projectiles, rotation, and range calculations, level and path creation, as well as game balancing and enemy pathing
I also had the secondary goal of acheiving a game that I could show to my friends and that they would hopefully enjoy
This game is fairly simple and straightforward. The first couple of levels are some basic tutorial points, talking about how to spawn towers, move them onto the battlefield, and upgrade them, and about some of their properties. Level 4 starts an endless mode, where the number of enemies spawned increases relevant to the level number.
After level 3, there will be a number of cheezburger cats equal to the level number, and the cat itself will spawn a number of enemies equal to the level number upon its death
I used portions of the CS50x games track code, specifically the setTile, getTile, tileAt functions for the map, the Animation.lua and Util.lua files to help cut up my spritesheets and use them to create the map, towers, and enemy animations, and the self.behaviours and part of the collision detection logic for the enemy pathing and speed
I also used the Class.lua and Push.lua files shown in the games track for their respective functionalities (creating classes and objects, and helping with screen resolution and size translations, respectively)
All the sound effects and music were obtained from freesound.org, under the creative commons license
Enemies and tiles were obtained from a texture pack by Kenney.nl on opengameart.org
Tower and projectile art were obtained from a texture pack by Nido, also on opengameart.org
Links to their work are in main.lua