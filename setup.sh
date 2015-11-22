#!/bin/bash
set -e
set -x

function cleanup {
  if [ -z $SKIP_CLEANUP ]; then
    echo "Removing build directory ${BUILDENV}"
    rm -rf "${BUILDENV}"
    rm -rf ${WORKSPACE}/build
    rm -f ${MAGENTO_VERSION}.tar.gz
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

echo "Using build directory ${BUILDENV}"

git clone https://github.com/ffuenf/MageTestStand "${BUILDENV}"

mkdir -p ${WORKSPACE}/build/logs
mkdir -p ${BUILDENV}/tools
if [ ! -f ${BUILDENV}/tools/modman ] ; then
  curl -s -L https://raw.githubusercontent.com/colinmollenhour/modman/master/modman -o ${BUILDENV}/tools/modman
  chmod +x ${BUILDENV}/tools/modman
fi
if [ ! -f ${BUILDENV}/tools/n98-magerun ] ; then
  curl -s -L http://files.magerun.net/n98-magerun-latest.phar -o ${BUILDENV}/tools/n98-magerun
  chmod +x ${BUILDENV}/tools/n98-magerun
fi
${BUILDENV}/n98-magerun-modules.sh
if [ ! -f ${BUILDENV}/tools/composer ] ; then
  curl -s -L https://getcomposer.org/composer.phar -o ${BUILDENV}/tools/composer
  chmod +x ${BUILDENV}/tools/composer
fi
if [ ! -f ${BUILDENV}/tools/phploc ] ; then
  curl -s -L https://phar.phpunit.de/phploc.phar -o ${BUILDENV}/tools/phploc
  chmod +x ${BUILDENV}/tools/phploc
fi
if [ ! -f ${BUILDENV}/tools/ocular ] ; then
  curl -s -L https://scrutinizer-ci.com/ocular.phar -o ${BUILDENV}/tools/ocular
  chmod +x ${BUILDENV}/tools/ocular
fi
if [ ! -f ${BUILDENV}/tools/assert.sh ] ; then
  curl -s -L https://raw.github.com/lehmannro/assert.sh/master/assert.sh -o ${BUILDENV}/tools/assert.sh
  chmod +x ${BUILDENV}/tools/assert.sh
fi
if [ ! -f ${BUILDENV}/tools/magedownload ] ; then
  curl -s -L http://magedownload.steverobbins.com/download/latest/magedownload.phar -o ${BUILDENV}/tools/magedownload
  chmod +x ${BUILDENV}/tools/magedownload
fi

cp ${BUILDENV}/.n98-magerun.yaml ~/.n98-magerun.yaml

cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"
${BUILDENV}/install.sh
if [ -d "${WORKSPACE}/vendor" ] ; then
    cp -rf ${WORKSPACE}/vendor/* "${BUILDENV}/vendor/"
fi

if [ -f ${WORKSPACE}/composer.json ] ; then
    cp -f "${WORKSPACE}/composer.json" "${BUILDENV}/htdocs/composer.json"
    cd ${BUILDENV}/htdocs
    if [ ! -f composer.lock ] ; then
        ${BUILDENV}/tools/composer install --prefer-source
        ${BUILDENV}/tools/modman deploy-all --force
    fi
fi

cd ${BUILDENV}
${BUILDENV}/test.sh

cd ${BUILDENV}/htdocs
${BUILDENV}/bin/phpunit --coverage-clover=${WORKSPACE}/build/logs/clover.xml --colors -d display_errors=1

if [ ! -z $CODECLIMATE_REPO_TOKEN ] ; then
  echo "Exporting code coverage results to codeclimate"
  cd ${WORKSPACE}
  ${BUILDENV}/vendor/codeclimate/php-test-reporter/composer/bin/test-reporter
fi

echo "Exporting code coverage results to scrutinizer-ci"
cd ${WORKSPACE}
if [ ! -z $SCRUTINIZER_ACCESS_TOKEN ] ; then
  php -f ${BUILDENV}/tools/ocular code-coverage:upload --access-token=${SCRUTINIZER_ACCESS_TOKEN} --format=php-clover ${WORKSPACE}/build/logs/clover.xml
else
  php -f ${BUILDENV}/tools/ocular code-coverage:upload --format=php-clover ${WORKSPACE}/build/logs/clover.xml
fi

if [ "$TRAVIS_TAG" != "" ]; then
  RELEASEDIR=`mktemp -d /tmp/${APPNAME}-${TRAVIS_TAG}.XXXXXXXX/`
  echo "Using release directory ${RELEASEDIR}"
  cd $WORKSPACE
  rsync -av \
    --exclude='build/' \
    --exclude='.travis/' \
    --exclude='.scrutinizer.yml' \
    --exclude='.travis.yml' \
    --exclude='.codeclimate.yml' \
    --exclude='.git/' \
    --exclude='.gitignore' \
    --exclude='Berksfile' \
    --exclude='Vagrantfile' \
    . ${RELEASEDIR}/${APPNAME}/
  cd ${RELEASEDIR}/
  zip -r ${APPNAME}-${TRAVIS_TAG}.zip ${APPNAME}
  tar -czf ${APPNAME}-${TRAVIS_TAG}.tar.gz ${APPNAME}
  echo "Bundled release ${TRAVIS_TAG}"
fi

echo "Done."