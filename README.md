# Build-scripts-for-switchroot-android
## Various scripts for managing the switchroot android build process

These scripts are used to update your Switchroot Android Q source, and build from it.  They are based on the Android 10 / Q build guide on the Switchroot Wiki: https://wiki.switchroot.org/en/Android/Build-10

# Installation:

This process requires several dependencies to be installed before the scripts can successfully build.  If you are running Ubuntu 18.04 or newer, or a distro based on that, you can grab those dependencies by running:

```
sudo apt install -y bc bison build-essential ccache curl flex g++-multilib gcc-multilib git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev libwxgtk3.0-dev
```
With that settled, please `cd` to your `android/lineage` folder containing the source. If you're building Android for the first time and don't already have that folder, run

```
mkdir -p ~/android/lineage
cd android/lineage
```

To create and enter the folder.

Clone this repo with 
```
git clone https://github.com/Joelgp83/Build-scripts-for-switchroot-android.git switchroot_scripts
cd switchroot_scripts
chmod +x *.sh
```
The scripts will then be synced and ready for use.  

# USAGE
There are several scripts available to manage the switchroot android source. These must be run from the `switchroot_scripts` directory.

## qprep.sh
`qprep.sh` is used to setup the source from scratch.  
Invoke the script with `./qprep.sh`.

For first timers who have never interacted with git before, there will be some interactivity required.  The repo utility used requires an email address and username to identify yourself to git for the source sync. It will prompt you for this.  After entering an email address and username, it may ask you about terminal colors.  After answering that question, the rest of the script is automatic.

If this is not your first time, and you are merely restarting from scratch, you can skip this entirely by invoking with the `-s` flag. The script will then be non-interactive.

## qupd8.sh

qupd8.sh is the source update script.  Run this when you want to grab the latest switchroot source changes.

Invoke the update script with `./qupd8.sh `   


If you wish to update your copies of the Switchroot scripts, run with `-u`.


## qbuild.sh

`qbuild.sh` is the build script. Optionally, you can control the number of CPU cores/threads to use with `-j(number)`.  Run this script after `qprep.sh` for your first build, or run it after `qupd8.sh` to build with the latest source changes.

Standard invocation with default options will be 

```
./qbuild.sh -r <ROM TYPE>.
``` 

Your choices are:

`android` : **For standard tablet Android and UI**

`androidtv` : **For Android TV plus the TV UI**

So if you wanted to build the regular android tablet rom, you'd run `./qbuild.sh -r android`  

Finally, invoking with `-c` will do a `make clean` before the build, in case you wanted do a fresh build.


## Getting the files you need after build

The script will place the resulting android-switch install .zip in `android/<rom name>_files`.  Further, in that folder you will find a `switchroot/install` folder containing the `twrp.img`, `tegra210-icosa.dtb` and `boot.img` files that hekate will flash. Simply copy the zip file and the `switchroot` folder to the sd card's hos partition, and you'll be ready to flash the new build with hekate (Get the latest from https://github.com/CTCaer/hekate/releases) and TWRP.
