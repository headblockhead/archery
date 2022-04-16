build:
	rm -rf ./build.pdx
	pdc ./ ./build
	PlaydateSimulator ./build.pdx
