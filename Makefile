build:
	-rm -rf ${PLAYDATE_SDK_PATH}/Disk/Games/archery.pdx
	-rm -rf ./build.pdx
	-rm pdxinfo
	echo "name=Archery!\
	\nauthor=Headblockhead\
	\ndescription=Aim and FIRE!\
	\nbundleID=com.headblockhead.archery\
	\nversion=`cat version.txt`.`bash getBuildN_read.sh`\
	\nbuild=`bash getBuildN.sh`\
	\nimagePath=cards\
	\nlaunchSoundPath=SFX/launchgame" > pdxinfo
	echo `bash getBuildN_read.sh` > buildnum.txt
	pdc -k ./ ./build # -k is for ignoring unrecognised files (image source files)
	cp -r ./build.pdx ${PLAYDATE_SDK_PATH}/Disk/Games/archery.pdx	
	PlaydateSimulator ./build.pdx
