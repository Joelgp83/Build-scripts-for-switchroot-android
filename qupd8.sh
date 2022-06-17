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
			#Temporarily disabling this until I understand snack.sh better 
			#force_sync="true"
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
			exit
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

#Update the switchroot local manifests portion and the switchroot scripts repo
.repo/local_manifests/snack/snack.sh -y

#Check if we are doing force-sync, otherwise do normal sync.
if [[ ${force_sync} = "true" ]]; then
	#repo sync --force-sync
else
	#repo sync
fi

echo "Source downloaded and patched.  Moving on to environment setup."
#Setup ccache
export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)
export WITHOUT_CHECK_API=true
ccache -M 50G

echo "Sources ready. To build, type ./qbuild -r <rom_name>, which will be either android or androidtv."