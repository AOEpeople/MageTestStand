#!/bin/bash
set -e
set -x

if [ -z "$TEST_BASEDIR" ]; then echo "No $TEST_BASEDIR found"; exit 1; fi

function cleanup {
  if [ -z "$SKIP_CLEANUP" ]; then
    echo "Removing build directory ${BUILDENV}"
    rm -rf "${BUILDENV}"
  fi
}
 
trap cleanup EXIT

# check if this is a travis environment
if [ ! -z "$TRAVIS_BUILD_DIR" ] ; then WORKSPACE=$TRAVIS_BUILD_DIR; fi

if [ -z $WORKSPACE ] ; then echo "No workspace configured, please set your WORKSPACE environment"; exit 1; fi
 
BUILDENV=$(mktemp -d /tmp/mageteststand.XXXXXXXX)
 
echo "Using build directory ${BUILDENV}"

# Get the rest of MageTestStand
curl -sL https://github.com/AOEpeople/MageTestStand/archive/plain_phpunit.tar.gz | tar zx -C "${BUILDENV}" --strip-components 1

# Copy the actual test subject into .modman folder
cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"

# Install Magento
${BUILDENV}/install.sh


if [ -d "${WORKSPACE}/vendor" ] ; then
  cp -rf ${WORKSPACE}/vendor/* "${BUILDENV}/vendor/"
fi

# Run the tests


if [ ! -d "${BUILDENV}/${TEST_BASEDIR}" ] ; then
    echo "Could not find test dir ${BUILDENV}/${TEST_BASEDIR}"
fi

cd "${BUILDENV}/${TEST_BASEDIR}"
${BUILDENV}/tools/phpunit.phar --colors -d display_errors=1

