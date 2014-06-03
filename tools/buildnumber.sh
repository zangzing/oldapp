#!/bin/sh

# this script is designed to be ran as part of a Build Schem in a "Run Script" pre action for the main project

# 1.- Edit the main project scheme (in Xcode 4 right click on the left side of the Scheme bar on the top toolbar)
# 2.- Click Edit Scheme
# 3.- Open the Build action
# 4.- Click on Pre-actions and click the plus sign, add a New Run Script Action
# 5.- Provide build setting from "choose the main target"
# 6.- Copy this script into the box
# 7.- Edit the main targets ZangZing-Info.plist file
# 8.- Set the value of "Bundle version" to GIT_VERSION
# 9.- Set the value of "Bunlde versions string,short" to APP_VERSION
# 10.- Git must be on your PATH
# Done!

cd $PROJECT_DIR
hash=`git rev-parse --verify HEAD`
version=`git rev-list --reverse HEAD | grep -n $hash | cut -d: -f1`
echo "#define GIT_VERSION $version" > $PROJECT_DIR/InfoPlist.h
echo "#define APP_VERSION 0.1" >> $PROJECT_DIR/InfoPlist.h
echo "#define GIT_COMMIT $hash" >> $PROJECT_DIR/InfoPlist.h