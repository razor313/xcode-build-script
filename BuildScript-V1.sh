#!/bin/bash -l

NOW="$(date +%m%d.%H.%M)"
LINE="-----------------------------------"

echo $LINE
echo "This Script build xcode project and exprot IPA file"
echo "Write by Razor_One313"
echo $LINE

# Check exist Xcode 9x
# -----------------------------------------------------------------------------
echo "Check Xcode version"
$(exec xcodebuild -version | grep 'Xcode 9' &> /dev/null)
if [ $? == 0 ]; then
echo "found Xcode 9.x"
else
echo "Xcode 9.x not found or not set on your device"
echo "You must install and set Xcode 9.x"
exit 1;
fi
echo $LINE

# Checkout project from SVN
# -----------------------------------------------------------------------------
echo "[INFO] checkout fresh project from SVN"
echo "Enter path(url) of your project"
echo "Ex: http://xxx.xxx.xxx"
read URL 
svn checkout ${URL}
echo "[INFO] change directory into Relase/Build folder"

if [ $? == 0 ]; then
echo "checkout was success"
else
echo "checkout wasn't success"
exit 1;
fi

# Start pod install
# -----------------------------------------------------------------------------
echo "Enter path of workspace"
echo "Ex:~/Users/X/workspace/trunk"
read WORKSPACE
echo "change directory for pod install"
cd ${WORKSPACE}/trunk/src/xcode
echo "pod install for project"
pod install
echo "change directory for build"
cd ${WORKSPACE}

# Starting build by xcodebuild command
# -----------------------------------------------------------------------------

echo 'This script create ipa file of iOS App'
echo 'Enter just project name without .xcworkspace'
read PROJECT_NAME

FINAL_APPLICATION="final-application"
TARGET_SDK="iphoneos"
PROJECT_BUILDDIR="src/xcode/build/Release-iphoneos"
BUILD_WORKSPACE="trunk/src/xcode/${PROJECT_NAME}.xcworkspace"

echo 'Enter Relase Version Number:'
echo 'Ex: xxx.xx'
read RELEASE_VERSION
echo 'Your version number is: ${RELEASE_VERSION}'

# Start finding the pom file of project
# -----------------------------------------------------------------------------
POM_FILE="pom.xml"
echo 'find pom file into workspace'
if [ ! -f "$POM_FILE" ]; then
	echo "ERROR: Cannot find pom.xml!"
	exit 1;
fi
echo "[INFO] I find pom.xml"


MY_PATH=${WORKSPACE}/${FINAL_APPLICATION}/${PROJECT_NAME}/${RELEASE_VERSION}
echo "[INFO] SET PATH TO: ${MY_PATH}"
echo "[INFO] START BUILD FOR ${PROJECT_NAME}"
    
echo "[INFO] make directory of ${PROJECT_NAME} into the ${FINAL_APPLICATION}" 
mkdir -p ${FINAL_APPLICATION}/${PROJECT_NAME}/${RELEASE_VERSION}

echo 'Enter path of Info.plist that define information of provision profile'	
read PLIST_FILE
echo 'check exist plist file'
	# Check exist plit file
	if [ ! -f "$PLIST_FILE" ]; then
		echo "[ERROR] Cannot find plist file!"
		exit 1
    	else
    	echo "[INFO] Find plist file"
    
    	# TODO CHECK RELEASE_VERSION
    	/usr/libexec/PlistBuddy -x -c "Set :CFBundleShortVersionString ${RELEASE_VERSION}" ${PLIST_FILE}
    	echo "[INFO] set versin number to plist file" 
	fi

	# compile project
    
	echo "[INFO] Building Project"
	xcodebuild -workspace "${BUILD_WORKSPACE}" -scheme "${PROJECT_NAME}" -sdk "${TARGET_SDK}" -archivePath "${PROJECT_BUILDDIR}/${PROJECT_NAME}.xcarchive" -configuration Release archive

	# Check if build succeeded
	if [ $? != 0 ]
		then
  		echo "[ERORR] build of ${PROJECT_NAME} failed!!!"
  		exit 1
	fi

	# Export the archive to an ipa
	echo "[INFO] Export the archive to an IPA"
	xcodebuild -exportArchive -archivePath "${PROJECT_BUILDDIR}/${PROJECT_NAME}.xcarchive" -exportOptionsPlist "${PLIST_FILE}" -exportPath "${PROJECT_BUILDDIR}"

	# Check if archive succeeded
	if [ $? != 0 ]
		then
  		echo "[ERORR] archive of ${PROJECT_NAME} failed!!!"
  		exit 1
	fi

	# TODO check exist ipa file
	echo "copy ipa file to final application folder"
	cp ${PROJECT_BUILDDIR}/${PROJECT_NAME}.ipa ${MY_PATH}

	echo "clean build folder"
	rm -rf ${PROJECT_BUILDDIR}

done

# Start copy $DIST_FOLDER
# -----------------------------------------------------------------------------

if [ -d "$FINAL_APPLICATION" ]; then
    mkdir ~/Documents/$NOW
    cp -R $FINAL_APPLICATION ~/Documents/$NOW
else
 	echo "could not find $FINAL_APPLICATION"
fi
