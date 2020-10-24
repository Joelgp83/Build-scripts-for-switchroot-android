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

#cd ~/android/lineage

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

	#Sizzling teh Bacon
	echo "Beginning Build...."
	make bacon -j$(($(nproc)-2))

	#Let's start moving everything to a more user-accessible spot
	mkdir -p ../$rom"_files"
	echo 'Delivering bacon to output folder.....'
	cd out/target/product/$rom
	bacon=`ls -t lineage-17.1*.zip | tail -1`
	cp $bacon ../../../../../$rom"_files"
	
	#Pull the files hekate needs to do the flash
	echo 'Bacon Delivered.  Grabbing the .dtb and kernel files.....'
	mkdir -p ../../../../../$rom"_files"/switchroot/install
	echo 'You will find them in the /switchroot/install/ folder of the output directory.'
	
	cp boot.img ../../../../../$rom"_files"/switchroot/install
	cp obj/KERNEL_OBJ/arch/arm64/boot/dts/tegra210-icosa.dtb ../../../../../$rom"_files"/switchroot/install
	exit 0	

else
        echo "No ROM specified. Please specify a rom with -r <ROM NAME>."
	exit 1
fi

