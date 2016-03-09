#!/bin/bash
set -e
set -x

function cleanup {
  if [ -z $SKIP_CLEANUP ]; then
    echo "Removing build directory ${BUILDENV}"
    rm -rf "${BUILDENV}"
    rm -rf ${WORKSPACE}/build
    rm -f magento-${MAGENTO_VERSION}.tar.gz
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

git clone -b dev https://github.com/ffuenf/MageTestStand "${BUILDENV}"

mkdir -p ${WORKSPACE}/build/logs

${BUILDENV}/n98-magerun-modules.sh
cp ${BUILDENV}/.n98-magerun.yaml ~/.n98-magerun.yaml

cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"

if [ -d "${WORKSPACE}/.modman" ] ; then
  cp -rf ${WORKSPACE}/.modman/* "${BUILDENV}/.modman/"
fi
${BUILDENV}/magento.sh

cd ${BUILDENV}
${BUILDENV}/test.sh

cd ${BUILDENV}/htdocs

if [ ! -z $PHPCS ] ; then
  php $HOME/.cache/bin/phpcs --config-set ignore_warnings_on_exit true
  php $HOME/.cache/bin/phpcs --standard=$(pear config-get php_dir)/PHP/CodeSniffer/Standards/Ecg --encoding=utf-8 --report-width=120 ${BUILDENV}/.modman/${APPNAME}/app/code
fi

phpunit --coverage-clover=${WORKSPACE}/build/logs/clover.xml --colors -d display_errors=1

echo "Exporting code coverage results to scrutinizer-ci"
cd ${WORKSPACE}
if [ ! -z $SCRUTINIZER_ACCESS_TOKEN ] ; then
  php -f $HOME/.cache/bin/ocular code-coverage:upload --access-token=${SCRUTINIZER_ACCESS_TOKEN} --format=php-clover ${WORKSPACE}/build/logs/clover.xml
else
  php -f $HOME/.cache/bin/ocular code-coverage:upload --format=php-clover ${WORKSPACE}/build/logs/clover.xml
fi

if [ "$TRAVIS_TAG" != "" ]; then
  RELEASEDIR=`mktemp -d /tmp/${APPNAME}-${TRAVIS_TAG}.XXXXXXXX`
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
  mv ${APPNAME}-${TRAVIS_TAG}.zip $WORKSPACE
  tar -czf ${APPNAME}-${TRAVIS_TAG}.tar.gz ${APPNAME}
  mv ${APPNAME}-${TRAVIS_TAG}.tar.gz $WORKSPACE
  rm -rf ${RELEASEDIR}
  echo "Bundled release ${TRAVIS_TAG}"
fi

echo "Done."