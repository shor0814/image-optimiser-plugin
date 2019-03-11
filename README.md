# image-optimiser-plugin
CentminMod Image Optimiser is a WordPress plugin and a modification to George Liu's optimise-images shell script.  This WordPress plugin works with a modified version of optimise-images.sh to optimize (and optionally create .webp files)  media files as they are uploaded through WordPress.  The plugin relies on the optiise-images-plugin.sh to optimise each image individually as it is uploaded.  Additionally it is possible to call optimise-images-plugin.sh from the command line to otimize all images in a given directory (and subs) and optionally creates webp format.  This differs from the original by removing the 2 level deep directory search and allows a file to be passed instead of directory for optimization.

To Use:
The optimise-images-plugin.sh shell script gets called by the plugin.  Store it somewhere in your path (/usr/bin, /usr/sbin, etc.) and will get called via the plugin configuration variable.
The shell script can be run standalone for the first time to optimize all images in your WordPress directory or with a filename to optimize just that file.

optimise-images-plugin.sh {optimise} /PATH/TO/DIRECTORY/WITH/IMAGES
optimise-images-plugin.sh {optimise} /PATH/TO/DIRECTORY/WITH/IMAGES/NAMEOFIMAGE.EXT
optimise-images-plugin.sh {install} /PATH/TO/DIRECTORY/WITH/IMAGES

The shell script is currently where most of the configuation is done.  Just change the items you want to change based on the instructions in the original (https://github.com/centminmod/optimise-images).

Installation:
Create a folder called optimg-plugin in your WordPress directory (wp-content/plugins) and copy the optimg-plugin.php file into that folder.  Inside your WordPress Plugins admin area you should see a new plugin for CentminMod Image Optimiser that you can activate.  Copy the optimise-images-plugin.sh script to the /usr/sbin directory (or wherever you want outside of WordPress) and make sure the $scriptlocation variable in the script points to that location.  Make the optimise-images-plugin.sh readable and executable by your web server user.  In CentminMod that would mean that the permissions for "other" need to be read and execute (r-x).  Another way would be to "chgrp nginx optimise-images-plugin.sh" and make the group permissions r-x.  I haven't tried that yet.

You can run optimise-images-plugin.sh {optimise} /PATH/TO/WORDPRESS to optimize and generate WebP files.  In the future, when you upload images via the WordPress Media tool the image (and all optional sizes) will be optimized and a WebP file created for each image including the optional sizes.  When you use the WordPress Media tool the WebP files will be deleted if they exist. 

Follow the instructions in optimise-images to create a directive in your NGINX configuration to serve up WebP files instead of .jpg if the browser supports. (https://centminmod.com/webp/)
