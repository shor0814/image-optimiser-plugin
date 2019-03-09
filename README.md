# image-optimiser-plugin
CentminMod Image Optimiser.  This WordPress plugin works with CentminMod to optimize all images in a given directory (and subs) and optionally creates webp format files

the optimise-images-plugin.sh shell script gets called by the plugin.  Store it somewhere in your path (/usr/bin, /usr/sbin, etc.) and will get called via the plugin configuration variable.
The shell script can be run standalone for the first time to optimize all images in your WordPress directory or with a filename to optimize just that file.

optimise-images-plugin.sh {optimise} /PATH/TO/DIRECTORY/WITH/IMAGES
optimise-images-plugin.sh {optimise} /PATH/TO/DIRECTORY/WITH/IMAGES/NAMEOFIMAGE.EXT
optimise-images-plugin.sh {install} /PATH/TO/DIRECTORY/WITH/IMAGES

The shell script is currently where most of the configuation is done.  Just change the items you want to change based on the instructions in the original (https://github.com/centminmod/optimise-images).
