#!/bin/bash
#Q build script
#exit on error
set -e

while getopts ":r:" OPTION
do
	
	case $OPTION in
		r) 
			rom=$OPTARG
			;;

		*)	
			echo "Not a valid flag.  Please specify which ROM with -r <ROM NAME>."
			exit 1
			;;
	esac
done

#change directory  TODO: Add a flag to specify source location to allow running script from anywhere in filesystem.   Add flag to assume default location when running outside source location.
#cd android/lineage

#Set Build Environment
echo "Setting up build environment...."
source build/envsetup.sh
export USE_CCACHE=1
export CCACHE_EXEC=$(which ccache)
export WITHOUT_CHECK_API=true
ccache -M 50G

#check rom and set up lunch
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
                        echo "Incorrect ROM name or No ROM specified, exiting."
			exit 1
                        ;;
        esac
else
        echo "No ROM specified. Please specify a rom with -r <ROM NAME>."
	exit 1
fi

#Sizzling teh Bacon
echo "Beginning Build...."
make bacon -j$(($(nproc)-2))
