#!/bin/bash

VERSION=""

# Get parameters
while getopts v: flag
do
  case "${flag}" in
    v) VERSION=${OPTARG};; # Version
  esac
done

# Get the highest tag number, and add v0.1.0 if doesn't exist
git fethch --prune --unshallow 2>/dev/null
CURRENT_VERSION=`git describe --abbrev=0 --tags 2>/dev/null`

if [[ $CURRENT_VERSION == '']]
then
  CURRENT_VERSION='v0.1.0'
fi
echo "Current Version: $CURRENT_VERSION"

# Replace . with space so can split into an array
CURRENT_VERSION_PARTS=(${CURRENT_VERSION//./ })

# Get number parts
VNUM1=${CURRENT_VERSION_PARTS[0]}
VNUM2=${CURRENT_VERSION_PARTS[1]}
VNUM3=${CURRENT_VERSION_PARTS[2]}

if [[ $VERSION == 'major' ]]
then
  VNUM1=$((VNUM1+1))
  VNUM2=0
  VNUM3=0
elif [[ $VERSION == 'minor' ]]
then
  VNUM2=$((VNUM2+1))
  VNUM3=0
elif [[ $VERSION == 'patch' ]]
then
  VNUM3=$((VNUM3+1))
else
  echo "No version type (https://semver.org) or incorrect type specified, try : -v [major, minor, patch]"
  exit 1
fi

# Create new tag
NEW_TAG="v$VNUM1.$VNUM2.$VNUM3"
echo "($VERSION Updating $CURRENT_VERSION to $NEW_TAG)"

# Get current hash and see if it already has a tag
GIT_COMMIT=`git rev-parse HEAD`
NEEDS_TAG=`git describe --contains $GIT_COMMIT 2>/dev/null`

# Only tag if no tag already (would be better if the git describe command above could have a silent option)
if [[ -z "$NEEDS_TAG" ]]
then
  echo "Tagged with $NEW_TAG (Ignoring fatal:cannot describe - this means commit is untagged) "
  git tag $NEW_TAG
  git push --tags
else
  echo "Already a tag on this commit"
fi

echo ::set-output name=new-version::$NEW_TAG

exit 0