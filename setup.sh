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

pecl install xdebug

# check if this is a travis environment
if [ ! -z $TRAVIS_BUILD_DIR ] ; then
  WORKSPACE=$TRAVIS_BUILD_DIR
fi

if [ -z $WORKSPACE ] ; then
  echo "No workspace configured, please set your WORKSPACE environment"
  exit
fi
 
BUILDENV=`mktemp -d /tmp/mageteststand.XXXXXXXX`
 
echo "Using build directory ${BUILDENV}"
 
git clone https://github.com/ffuenf/MageTestStand.git "${BUILDENV}"

mkdir ${BUILDENV}/tools
curl -s -L https://raw.githubusercontent.com/colinmollenhour/modman/5ffd5758081d9f6da072efd3a1a331b5e7acbf3a/modman -o ${BUILDENV}/tools/modman
chmod +x ${BUILDENV}/tools/modman
curl -s -L https://raw.githubusercontent.com/netz98/n98-magerun/master/n98-magerun.phar -o ${BUILDENV}/tools/n98-magerun
chmod +x ${BUILDENV}/tools/n98-magerun
curl -s -L https://getcomposer.org/composer.phar -o ${BUILDENV}/tools/composer
chmod +x ${BUILDENV}/tools/composer
curl -s -L https://phar.phpunit.de/phploc.phar -o ${BUILDENV}/tools/phploc
chmod +x ${BUILDENV}/tools/phploc
curl -s -L https://scrutinizer-ci.com/ocular.phar -o ${BUILDENV}/tools/ocular
chmod +x ${BUILDENV}/tools/ocular

cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"
${BUILDENV}/install.sh

cd ${BUILDENV}/htdocs
${BUILDENV}/bin/phpunit --coverage-clover=${BUILDENV}/build/logs/clover.xml --colors -d display_errors=1

echo "Exporting code coverage results to codeclimate"
cd ${BUILDENV}
vendor/codeclimate/php-test-reporter/composer/bin/test-reporter --stdout > codeclimate.json
curl -X POST -d @codeclimate.json -H 'Content-Type: application/json' -H 'User-Agent: Code Climate (PHP Test Reporter v1.0.1-dev)' https://codeclimate.com/test_reports

echo "Exporting code coverage results to scrutinizer"
cd ${BUILDENV}
ocular code-coverage:upload --format=php-clover ${BUILDENV}/build/logs/clover.xml

echo "Done."
