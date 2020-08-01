## wmh - A system backup tool

Installation
------------
Just clone the repo and set it up to your needs according to the source code examples.
Put wmh.rkt in a folder where you want to back your files up (in my case its ~/bkp), configure it, and call it using ```racket wmh.rkt```, you'll need to have ```ansi-color```, which can be installed using ```raco pkg install ansi-color```.

Description
-----------
wmh serves as a "black box", you simply give it the directories/files/whatever you want to back up, it copies them into the same folder as the script, initializes it as a git repo, pushes it, and once you're on a fresh machine/install, you can just clone that same repo and set everything up.
