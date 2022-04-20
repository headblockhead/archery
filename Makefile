build:
	-rm -rf ${PLAYDATE_SDK_PATH}/Disk/Games/archery.pdx
	-rm -rf ./build.pdx
	-rm pdxinfo
	echo "name=Archery!\
	\nauthor=Headblockhead\
	\ndescription=Aim and FIRE!\
	\nbundleID=com.headblockhead.archery\
	\nversion=0.1\
	\nbuild=`bash getBuildN.sh`\
	\nimagePath=cards\
	\nlaunchSoundPath=SFX/launchgame" > pdxinfo
	pdc ./ ./build
	cp -r ./build.pdx ${PLAYDATE_SDK_PATH}/Disk/Games/archery.pdx	
	PlaydateSimulator ./build.pdx
