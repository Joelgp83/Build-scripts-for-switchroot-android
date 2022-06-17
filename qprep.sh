#!/bin/bash
#firstPrep.sh -- Script for first-time download and setup of the Switchroot Android Q source
set -e

#Get options and bail if invalid flags set
while getopts ":s" OPTION
do
	
	case $OPTION in
		
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

#add repos
cd ..
echo "Adding main Lineage 17.1 repo...."
repo init -u https://github.com/LineageOS/android.git -b lineage-17.1

echo
echo "Now adding the Switchroot Q repo...."
echo
git clone https://gitlab.com/switchroot/android/manifest.git --recursive -b lineage-17.1-icosa_sr .repo/local_manifests
#Call the snack.sh script
echo "Syncing the repos.  This may take some time."
.repo/local_manifests/snack/snack.sh -y
echo 
repo sync

echo
echo "==========================================================================="
echo "Source preparation complete.  To build, please run qbuild.sh -r <ROM NAME>."
echo "Please be aware that a first build may take several hours to complete, depending on your hardware."
echo


 
