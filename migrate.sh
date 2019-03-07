#!/bin/bash

# check the number of args
if [ -z "$1" ] || [ ! $# -eq 1 ]
  then
    echo
    echo "Usage: ${BASH_SOURCE[0]} /path/to/WOnder/project"
    echo
    exit 1
fi

TARGET_PROJECT_DIR=$1

# ensure the argument is a directory
if [[ ! -d $TARGET_PROJECT_DIR ]]; then
    echo
    echo "$TARGET_PROJECT_DIR is not a directory"
    echo
    exit 1;
fi

# identify location of project template files
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
NEW_CLASSPATH="$SCRIPT_DIR/templates/.classpath"
NEW_WOPROJECT="$SCRIPT_DIR/templates/woproject"
NEW_PROJECT="$SCRIPT_DIR/templates/.project"
NEW_POM="$SCRIPT_DIR/templates/pom.xml"

# change to the target project directory
cd $TARGET_PROJECT_DIR

EXPECTED_ITEMS=(woproject Sources Resources .classpath build.properties build.xml)

# ensure the current structure confirms to a Fluffy Bunny WOnder project structure
for i in "${EXPECTED_ITEMS[@]}"; do
  if [[ ! -e $i ]]; then
    echo
    echo "$i not found. This might not be a Fluffy Bunny WebObjects project"
    echo
    exit 1;
  fi
done

# looks good so far

echo
echo "WOnder Maven Migrator"
echo
echo "Converts a WOnder fluffy bunny project to a WOnder Maven project."
echo "Configuring dependecies beyond stock WOnder frameworks in pom.xml is required."
echo
echo "This process is destructive and assumes you have backed up your target project."
echo

read -p "Do you wish to continue (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        echo
        echo "Let's get cracking"
        echo
    ;;
    * )
        exit 0
    ;;
esac

# Get the project name
PROJECT_NAME="$( grep project\.name\= build.properties |  sed s/project\.name\=// )"

# Get the project type
PROJECT_TYPE="$( grep project\.type\= build.properties |  sed s/project\.type\=// )"

echo "Project Name: $PROJECT_NAME"
echo "Project Type: $PROJECT_TYPE"
echo

# have a shot at determining a default GROUP_ID then prompt for it
DEFAULT_GROUP_ID="$( grep principalClass\= build.properties |  sed s/principalClass\=// | sed s/\.[^.]*$// )"
read -p "pom.xml groupId [$DEFAULT_GROUP_ID]: " GROUP_ID
GROUP_ID=${GROUP_ID:-$DEFAULT_GROUP_ID}
echo $GROUP_ID
echo

# default the artifactId to the project name the prompt for it
DEFAULT_ARTIFACT_ID=$PROJECT_NAME
read -p "pom.xml artifactId [$DEFAULT_ARTIFACT_ID]: " ARTIFACT_ID
ARTIFACT_ID=${ARTIFACT_ID:-$DEFAULT_ARTIFACT_ID}
echo $ARTIFACT_ID
echo

# set a WOnder default version
DEFAULT_WONDER_VERSION="7.1-SNAPSHOT"

# prompt for WOnder version
read -p "pom.xml Wonder version [$DEFAULT_WONDER_VERSION]: " WONDER_VERSION
WONDER_VERSION=${WONDER_VERSION:-$DEFAULT_WONDER_VERSION}
echo $WONDER_VERSION
echo

# grab the .project file
echo "Adding a .project file"
cp $NEW_PROJECT .

# replace the project name placeholder with this project's name
echo "Replacing project name placeholder with $PROJECT_NAME"
sed -i '' s/PROJECT_NAME/$PROJECT_NAME/ .project
echo

# change the classes.dir build property
echo "Changing build.properties classes.dir value to target/classes"
sed -i '' s/classes\.dir.*/classes.dir=target\\/classes/ build.properties
echo

# backup and replace .classpath
echo "Backing up and replacing the .classpath file."
mv .classpath .classpath.old
cp $NEW_CLASSPATH .
echo

# replace woproject directory
echo "Replacing woproject directory to introduce the appropriate .patternset files"
cp -r $NEW_WOPROJECT .
echo

echo "Adding a pom.xml file"
cp $NEW_POM .

# replace the groupId placeholder
echo "Replacing groupId placeholder with $GROUP_ID"
sed -i '' s/GROUP_ID/$GROUP_ID/ pom.xml

# replace the artifactId placeholder
echo "Replacing artifactId placeholder with $ARTIFACT_ID"
sed -i '' s/ARTIFACT_ID/$ARTIFACT_ID/ pom.xml

# replace the name placeholder
echo "Replacing project name placeholder with $PROJECT_NAME"
sed -i '' s/PROJECT_NAME/$PROJECT_NAME/ pom.xml

# replace the wonder.version placeholder
echo "Replacing wonder.version placeholder with $WONDER_VERSION"
sed -i '' s/WONDER_VERSION/$WONDER_VERSION/ pom.xml

if [[ $PROJECT_TYPE != 'application' ]]; then
  echo "Removing <packaging>woapplication</packaging> from pom.xml"
  sed -i '' 's/<packaging>woapplication<\/packaging>//' pom.xml
fi

echo

# create maven project structure and move contents
echo "Creating a standard Maven project structure"
rm -r src
mkdir -p src/main

if [[ -d Components ]]; then
  echo "Moving Components to src/main/components"
  mv Components src/main/components
fi

echo "Moving Sources to src/main/java"
mv Sources src/main/java

echo "Moving Resources to src/main/resources"
mv Resources src/main/resources

if [[ -d WebServerResources ]]; then
  echo "Moving WebServerResources to src/main/webserver-resources"
  mv WebServerResources src/main/webserver-resources
fi

# update path references in .eogen files
echo "Finding .eogen files in src/main/resources and changing path references to new structure"
find src/main/resources -name *.eogen \
-exec sed -i '' 's/destination\ Sources/destination\ src\/main\/java/' {} \; \
-exec sed -i '' 's/subclassDestination\ Sources/subclassDestination\ src\/main\/java/' {} \; \
-exec sed -i '' 's/model\ Resources/model\ src\/main\/resources/' {} \; \
-exec echo "Updating {}" \;

echo
echo "Done."
echo
echo "Use .classpath.old help configure pom.xml dependencies"
echo
