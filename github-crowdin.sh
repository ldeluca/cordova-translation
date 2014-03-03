#!/bin/bash
DOMAIN_NAME='http://api.crowdin.net'

#---CHANGE THE VARIABLES BELOW---
BASE_GIT_REPO_PATH=/home/ldeluca/git/
GIT_REPO_PATH=/home/ldeluca/git/cordova-docs
CROWDIN_CLI_PATH=/home/ldeluca/crowdin
PROJECT_IDENTIFIER='cordova'
PROJECT_KEY='____APIKEY________'

#--- git repos
## declare an array variable
declare -a gitrepos=("cordova-docs" "cordova-plugin-battery-status" "cordova-plugin-camera" "cordova-plugin-contacts" "cordova-plugin-device" "cordova-plugin-device-motion" "cordova-plugin-dialogs" "cordova-plugin-file" "cordova-plugin-file-transfer" "cordova-plugin-geolocation" "cordova-plugin-globalization" "cordova-plugin-inappbrowser" "cordova-plugin-media" "cordova-plugin-media-capture" "cordova-plugin-network-information" "cordova-plugin-splashscreen" "cordova-plugin-vibration")

#---

## now loop through the gitrepos array
for i in "${gitrepos[@]}"
do
   echo "**************** $i *************************"
   cd $BASE_GIT_REPO_PATH/$i

   # below pushes changes from local to fork
   git pull origin master
   git push origin
done

#cd $BASE_GIT_REPO_PATH/cordova-docs
#git pull origin master
#git push origin


cd $CROWDIN_CLI_PATH

java -jar crowdin-cli.jar upload sources

curl $DOMAIN_NAME/api/project/$PROJECT_IDENTIFIER/status?key=$PROJECT_KEY > result.xml

read_dom () {
    local IFS=\>
    read -d \< ENTITY CONTENT
}

while read_dom; do
      if [[ $ENTITY = "code" ]] ; then
	code=( "${code[@]}" "$CONTENT" )
      fi
      if [[ $ENTITY = "translated_progress" ]] ; then
	progress=( "${progress[@]}" "$CONTENT" )
      fi
done < result.xml

for (( i = 0; i < ${#progress[@]}; i++ )); do
   if [ "${progress[$i]}" = "100" ]; then
      index=( "${index[@]}" "$i" )
   else 
      echo "------- language not at 100 percent ${code[$i]} ------"
   fi
done

for element in "${index[@]}"; do
    java -jar crowdin-cli.jar download -l ${code[$element]}
done

# fix crowdin issues:
echo "About to fix crowdin errors with resulting files"
find /home/ldeluca/git/ -name \*.md -exec sed -i "s/\* \* \*/---/1" {} \; 
find /home/ldeluca/git/ -name \*.md -exec sed -i "s/## under the License./   under the License.\n---/g" {} \;
echo "Done with crowdin fix"

#cd $BASE_GIT_REPO_PATH
#  git add .
#  git commit -m 'Lisa testing pulling in plugin docs'
#  git push origin
  
## now loop through the gitrepos array
for i in "${gitrepos[@]}"
do
   echo "**************** $i *************************"
   cd $BASE_GIT_REPO_PATH/$i
   git add .
   git commit -m "Lisa testing pulling in plugins for plugin: $i"
   git push origin
done
  
# ****************************************************************************
#--- NOW DO THE CALLS FOR EACH PLUGIN --

#-- BATTERY STATUS
#-- https://github.com/apache/cordova-plugin-battery-status/blob/dev/doc/index.md
# -- git clone ssh://git@github.com/ldeluca/cordova-plugin-battery-status.git
