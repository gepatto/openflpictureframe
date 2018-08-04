# Openfl Picture Frame

## Work in Progress !!

OpenFL-dev (last tested on commit 78f57ba99c3855fd1b1051d20f5eeb1aff4648b3)
Lime 6.4.0

This is a Test of using OpenFL on the Raspberry Pi 3.
It's a slideshow that uses a simple shader for transitioning between images.

The app can be configured in the config.json file that's located in the App Directory.
These settings can be overwritten by setting them as parameters when starting the Application

i.e:
`openfl run rpi -args path=/home/pi/Pictures contentFill=fill`
or from the bin directory
`./Pictureframe -args path=/home/pi/Pictures contentFill=fill transitionTime=100`

available parameters are:

- path -> path to images
- contentFill -> fill|fit|scale
- transitionTime -> milliseconds > 100
- displayTime -> milliseconds > 1000
- showFileName -> 0|1

Keyboard Commands:

- ESC -> quit app
- D -> debug file list to commandline
- F -> toggle between contentFill modes
- S -> toggle Show FileName
- SPACE -> restart at first image
- W -> toggle FPS debug
