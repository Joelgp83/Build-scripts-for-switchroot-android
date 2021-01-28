#!/bin/bash
#firstPrep.sh -- Script for first-time download and setup of the Switchroot Android Q source
set -e

#Get options and bail if invalid flags set
while getopts ":s" OPTION
do
	
	case $OPTION in
		r)
			rom=$OPTARG
			;;
		
		s)
			skipID="true"
			;;

		*)
			echo "Invalid flag."
			echo
			exit 1
			;;

	esac
done

echo "Please be sure you have installed necessary dependencies listed in the readme file, or you will have problems compiling!"
echo

#cd upwards to android/lineage/
cd ../

#Grab repo
echo
echo "Installing repo utility...."
echo

mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
echo
echo "repo utility installed."
echo

source ~/.profile

#Check to see if the -s flag has been set, and if not, start the user interactive portion of the script

if ! [[ ${skipID} = "true" ]]; then
	echo "The repo utility requires you identify yourself before it can sync the Android source code. This information is only used by the repo uility when communicating with git and is not shared anywhere else.  If you have an existing email/username associated with Github or Gitlab, use those. If you've run this before and/or already provided this information to git previously, enter \"skip\"."
	echo
	read -p 'Please provide an email address: ' email

	#check to see if we're skipping id information.  If we're not, ask for username and configure.
	if [[ ${email} != "skip" ]]; then

		read -p 'Please provide a Username: ' userName
		git config --global user.email $email
		git config --global user.name $userName
	fi
	echo
	echo "Thank you.  Now, we'll initialize the repo and begin syncing source. This may take some time depending on your connection speed, so please be patient."
	echo
fi

cd ..
repo init -u https://github.com/LineageOS/android.git -b lineage-17.1
repo sync

echo
echo "Initial sync complete.  Now adding the Switchroot Q repo...."
echo
git clone https://gitlab.com/switchroot/android/manifest.git -b lineage-17.1 .repo/local_manifests
echo "Now re-syncing to include the switchroot specific code.  This may take some time."
echo 
repo sync


#Set up build environment and apply repopicks
source build/envsetup.sh
repopick -t icosa-bt-lineage-17.1
repopick -t nvidia-shieldtech-q
repopick -t nvidia-beyonder-q
repopick 300860
repopick 287339
repopick 302339
repopick 302554
repopick 284553

#Download and apply source patches
patch -d device/nvidia/foster_tab -p1 <  .repo/local_manifests/patches/device_nvidia_foster_tab-beyonder.patch
patch -d bionic -p1 < .repo/local_manifests/patches/bionic_intrinsics.patch
patch -d frameworks/native -p1 < .repo/local_manifests/patches/frameworks_native-mouse.patch
patch -d system/core -p1 < .repo/local_manifests/patches/system_core-gatekeeper-hack.patch
patch -d frameworks/base -p1 < .repo/local_manifests/patches/frameworks_base-desktop-dock.patch

#Check if we're doing Foster/AndroidTV, and apply that specific patch
if [[ -n $rom ]]; then
        case $rom in
		foster)
			patch -d device/lineage/atv -p1 < .repo/local_manifests/patches/device_lineage_atv-res.patch
			;;
		*)
			;;
	esac
fi

echo
echo "==========================================================================="
echo "Source preparation complete.  To build, please run qbuild.sh -r <ROM NAME>."
echo "Please be aware that a first build may take several hours to complete, depending on your hardware."
echo


 
