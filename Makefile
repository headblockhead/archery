build:
	rm -rf ${PLAYDATE_SDK_PATH}/Disk/Games/archery.pdx
	rm -rf ./build.pdx
	pdc ./ ./build
	cp -r ./build.pdx ${PLAYDATE_SDK_PATH}/Disk/Games/archery.pdx	
	PlaydateSimulator ./build.pdx
