#!/bin/bash
set -e
set -x

function cleanup {
  if [ -z $SKIP_CLEANUP ]; then
    echo "Removing build directory ${BUILDENV}"
    rm -rf "${BUILDENV}"
  fi
}
 
trap cleanup EXIT

# check if this is a travis environment
if [ ! -z $TRAVIS_BUILD_DIR ] ; then
  WORKSPACE=$TRAVIS_BUILD_DIR
fi

if [ -z $WORKSPACE ] ; then
  echo "No workspace configured, please set your WORKSPACE environment"
  exit
fi
 
BUILDENV=`mktemp -d /tmp/mageteststand.XXXXXXXX`

if [ ! -z $TOOLS_DIR ] ; then
  TOOLS_DIR=$BUILDENV/tools
fi

if [ -z $TOOLS_DIR ] ; then
  echo "No tools directory configured, please set your TOOLS_DIR"
  exit
fi

echo "Using build directory ${BUILDENV}"
 
git clone -b testing https://github.com/ffuenf/MageTestStand "${BUILDENV}"

mkdir ${TOOLS_DIR}
curl -s -L https://raw.githubusercontent.com/colinmollenhour/modman/master/modman -o ${TOOLS_DIR}/modman
chmod +x ${TOOLS_DIR}/modman
curl -s -L https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar -o ${TOOLS_DIR}/n98-magerun
chmod +x ${TOOLS_DIR}/n98-magerun
curl -s -L https://getcomposer.org/composer.phar -o ${TOOLS_DIR}/composer
chmod +x ${TOOLS_DIR}/composer
curl -s -L https://phar.phpunit.de/phploc.phar -o ${TOOLS_DIR}/phploc
chmod +x ${TOOLS_DIR}/phploc
curl -s -L https://scrutinizer-ci.com/ocular.phar -o ${TOOLS_DIR}/ocular
chmod +x ${TOOLS_DIR}/ocular

cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"
${BUILDENV}/install.sh

cd ${BUILDENV}/htdocs
${BUILDENV}/bin/phpunit --coverage-clover=${BUILDENV}/build/logs/clover.xml --colors -d display_errors=1

if [ ! -z $CODECLIMATE_REPO_TOKEN ] ; then
  echo "Exporting code coverage results to codeclimate"
  cd ${BUILDENV}
  vendor/codeclimate/php-test-reporter/composer/bin/test-reporter
fi

#echo "Exporting code coverage results to scrutinizer"
#cd ${BUILDENV}
#${TOOLS_DIR}/ocular code-coverage:upload --access-token=${SCRUTINIZER_ACCESS_TOKEN} --format=php-clover ${BUILDENV}/build/logs/clover.xml

echo "Done."
