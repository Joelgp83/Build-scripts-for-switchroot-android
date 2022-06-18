#!/bin/bash
#Q build script
#exit on error
set -e

while getopts ":cj:r:t" OPTION
do
	
	case $OPTION in
		c)
			echo "Performing make clean....."
			make clean
			;;

		j)
			numThread=$OPTARG
			numTest='^[0-9]+$'
			if ! [[ $numThread =~ $numTest ]]; then
				echo 'Invalid number of threads specified.'
				exit 1
			fi
			;;
			
		r) 
			rom=$OPTARG
			;;

		*)	
			echo "Not a valid flag.  Accepted flags are -c, -r, -j, -t.  Please refer to README.md for flag details."
			exit 1
			;;
	esac
done

#change directory TODO: Add check to make sure we're starting from switchroot_scripts in the lineage source
cd ../

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
                android)
			echo "Selected Non-TV target ROM"
			romdir=icosa_sr
                        lunch lineage_icosa_sr-userdebug
                        ;;

                androidtv)
			echo "Selected TV Target ROM"
			romdir=icosa_tv_sr
                        lunch lineage_icosa_tv_sr-userdebug
                        ;;

                *)
                        echo "Incorrect ROM Type or No Type specified, exiting."
			exit 1
                        ;;
        esac

	#Sizzling teh Bacon
	#check if we're doing a custom thread count, make sure it does not exceed the cpu's max supported threads.
	if [[ -n $numThread ]]; then
		#Check for and limit to max supported CPU threads. 
		if (( numThread > $(nproc) )) ; then
			echo
			echo "WARNING: Max CPU supported threads on this system is $(nproc). Limiting requested value to that...."
			numThread=$(nproc)
		fi	
		
		echo Beginning Build with $numThread threads....
		make bacon -j$numThread

	else
		echo "Beginning Build...."
		make bacon
	fi

	#Let's start moving everything to a more user-accessible spot
	mkdir -p ../$romdir"_files"
	echo 'Delivering bacon to output folder.....'
	
	#We'll be running the next few copies from the out/target/product/$romdir directory.  All will be relative to that.
	cd out/target/product/$romdir
	
	#Determine latest bacon.zip file name, store for later
	bacon=`ls -t lineage-17.1*.zip | tail -1`

	#Destination is up the path back in android/$romdir_files.  Recurse all the way back.
	cp $bacon ../../../../../$romdir"_files"
	
	#Now for the files hekate needs to do the flash
	echo 'Bacon Delivered.  Grabbing the .dtb, twrp.img, and kernel files.....'

	#Grab prebuilt twrp image.  Delete old copy of twrp first since wget can't seem to overwrite files.
	if [ -f ../../../../../$romdir"_files"/switchroot/install/twrp.img ]; then
		rm ../../../../../$romdir"_files"/switchroot/install/twrp.img
	fi
	cp twrp.img ../../../../../$romdir"_files"

	#Prepare new directory android/$romdir"_files"/switchroot/install, and copy boot.img back up to that.
	mkdir -p ../../../../../$romdir"_files"/switchroot/install
	echo 'You will find them in the switchroot/install/ folder of the output directory.'	
	cp boot.img ../../../../../$rom"_files"/switchroot/install

	#Reach deeper into where the dtb lives, and copy it to output directory.
	cp obj/KERNEL_OBJ/arch/arm64/boot/dts/tegra210-icosa.dtb ../../../../../$romdir"_files"/switchroot/install
	
		
else
        echo "No ROM Type specified. Please specify a Type with -r <ROM TYPE>."
	exit 1
fi
