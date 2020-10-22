#!/bin/bash
#Switch Android Q source update script

#Grab Flags.  Bail if invalid flag used.  Store ROM name for later.
while getopts ":fr:" OPTION
do
	case $OPTION in
		r) 
			rom=$OPTARG
			;;
		f)
			force_sync="true"
			;;
		*) 
			echo "Invalid or Incomplete Flag.  Valid flags are -f and -r.  Specify ROM name with -r <ROM NAME>."
			exit 1
			;;
	esac
done

#change directory  TODO: Add a flag to specify source location to allow running script from anywhere in filesystem.   Add flag to assume default location when running outside source location.
#cd ~/android/lineage

#Grab latest branch heads
repo forall -c 'git reset --hard'

#Update the switchroot local manifests portion
cd .repo/local_manifests
git pull
cd ../..

#Check if we are doing force-sync, otherwise do normal sync.

if [[ -n ${force_sync} ]]; then
	repo sync --force-sync
else
	repo sync
fi

#Set up build environment and apply repopicks
source build/envsetup.sh
repopick -t nvidia-enhancements-q
repopick -t nvidia-nvgpu-q
repopick -t icosa-bt-lineage-17.1
repopick 287339
repopick 284553

#Download and apply source patches
wget -O .repo/android_device_nvidia_foster.patch https://gitlab.com/ZachyCatGames/q-tips-guide/-/raw/master/res/android_device_nvidia_foster.patch
cd device/nvidia/foster
patch -p1 < ../../../.repo/android_device_nvidia_foster.patch
rm ../../../.repo/android_device_nvidia_foster.patch
cd ../../../bionic
patch -p1 < ../.repo/local_manifests/patches/bionic_intrinsics.patch
cd ../

echo "Source downloaded and patched.  Moving on to environment setup."
#Setup ccache
export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)
export WITHOUT_CHECK_API=true
ccache -M 50G

#Check which rom we're gonna build and set up and run lunch for it
if [[ -n $rom ]]; then
        case $rom in
                icosa)
			echo "Selected rom is Icosa"
                        lunch lineage_icosa-userdebug
                        ;;
                foster_tab)
			echo "Selected ROM is FosterTab"
                        lunch lineage_foster_tab-userdebug
                        ;;

                foster)
			echo "Selected ROM is Foster"
                        lunch lineage_foster-userdebug
                        ;;
                *)
                        echo "Incorrect ROM name or No ROM specified.  Exiting."
                        ;;
        esac
else
        echo "No ROM specified.  Exiting."
fi
