# Build-scripts-for-switchroot-android
Various scripts for managing the switchroot android build process

These scripts are used to update your Switchroot Android Q source, and build from it.  They are based on the Q-Tips guide at https://gitlab.com/ZachyCatGames/q-tips-guide.  If you've used that guide to download your source, these scripts will work with it.

USAGE:

Place the .sh files in your android/lineage folder on whatever driver you're using to build. Make executable with chmod +x.

Invoke the update script with ./qupd8.sh -r <ROM NAME>  Your choices are:

icosa : For No Nvidia Stuff
foster_tab : For Nvidia Stuff
foster : For Android TV with Nvidia Stuff

If you wish to perform a force-sync, invoke with -f.

If you use no flags, source will still be updated and the switchroot-specific patches applied, but the lunch command will not be run.


qbuild.sh is the build script.  It will set the build process to use all but 2 of your CPU cores/threads.  Run it after qupd8.sh.  Invoke it with ./qbuild.sh -r <ROM NAME>. 

For Example:

./qbuild.sh -r icosa  

Will build the icosa ROM.
