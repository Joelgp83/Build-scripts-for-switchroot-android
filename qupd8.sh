#!/bin/bash
#qupd8.sh -- Switch Android Q source update script
set -e

#Grab Flags.  Bail if invalid flag used.  Store ROM name for later.
while getopts ":fr:u" OPTION
do
	case $OPTION in
		r) 
			rom=$OPTARG
			;;
		f)
			force_sync="true"
			;;

		u)
			file1="../qupd8.sh"
			file2="../qbuild.sh"
			if [[ -f $file1 || -f $file2 ]]; then
				echo
				echo "Removing the old 1.0 versions of the scripts from the lineage directory..."
				if [ -f $file1 ]; then
					rm $file1
				fi
				if [ -f $file2 ]; then
					rm $file2
				fi
				echo "Removal Complete."
				echo
			fi
			git reset --hard
			git pull
			chmod +x *.sh
			echo
			echo "Scripts are updated to latest. Please run again without -u to update android-switch source."
			echo
			exit 1
			;;
		*) 
			echo
			echo "Invalid or Incomplete Flag.  Valid flags are -f, -r, and -u.  Specify ROM name with -r <ROM NAME>.  Update the Switchroot Scripts with -u."
			echo
			exit 1
			;;
	esac
done

#change directory TODO: Add check to make sure we're starting from switchroot_scripts in the lineage source
cd ../

#Grab latest branch heads
repo forall -c 'git reset --hard'

#Update the switchroot local manifests portion and the switchroot scripts repo
cd .repo/local_manifests
git pull
cd ../..

#Check if we are doing force-sync, otherwise do normal sync.

if [[ ${force_sync} = "true" ]]; then
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
			echo "Environment ready.  To build, run qbuild.sh -r <ROM NAME>."
                        ;;
                foster_tab)
			echo "Selected ROM is FosterTab"
                        lunch lineage_foster_tab-userdebug
			echo "Environment ready.  To build, run qbuild.sh -r <ROM NAME>."
                        ;;

                foster)
			echo "Selected ROM is Foster"
                        lunch lineage_foster-userdebug
			echo "Environment ready.  To build, run qbuild.sh -r <ROM NAME>."
                        ;;
                *)
                        echo "Incorrect ROM name or No ROM specified.  Exiting."
                        ;;
        esac
else
        echo "No ROM specified.  Exiting."
fi
