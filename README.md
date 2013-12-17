#JKJALaunch#

An OS X launcher for Jedi Academy and some other Q3 engine games.

Older versions of Jedi Academy Multiplayer (and a few other Q3 engine games) don’t run on Lion/Mountain Lion because of some OpenGL issues on ATI graphics cards.

JKJALaunch is a launcher for Jedi Academy Multiplayer that forces ATI FSAA off, allowing the game to run on Lion and Mountain Lion (but unfortunately not on Mavericks). It also allows you to specify command-line options and force 32-bit colour (as needed on certain graphics cards).

Hold Shift down at launch to bring up the options window, where you can choose the location of Jedi Academy Multiplayer and set the command-line options.

When you’re asked to find Jedi Academy MP, you can also select Jedi Academy, Jedi Knight II, Jedi Knight II MP, Wolfenstein ET and Alice.

(if Jedi Academy MP can be found in the same folder as JKJALaunch, this will be launched regardless of your preferences)

JKJALaunch uses DYLD_INTERPOSE as found in Webkit.

##New in 1.2!##

The latest Steam and App Store versions of Jedi Academy (Multiplayer) have a problem with connecting to servers which you do not have all .pk3s for. JKJALaunch now supports launching them and fixes this. Only the Steam version supports command-line options.

JKJALaunch now has better support for multiple copies of the application, so that each copy can be set to launch a different game.

JKJALaunch also now has updating via Sparkle.