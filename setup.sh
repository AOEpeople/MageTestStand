#!/bin/bash
set -e
set -x

function cleanup {
  if [ -z $SKIP_CLEANUP ]; then
    echo "Removing build directory ${BUILDENV}"
    rm -rf "${BUILDENV}"
    rm -rf ${WORKSPACE}/build
    rm -f magento-ce-${MAGENTO_VERSION}.tar.gz
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
curl -s -L https://raw.githubusercontent.com/colinmollenhour/modman/master/modman -o ${BUILDENV}/tools/modman
chmod +x ${BUILDENV}/tools/modman
curl -s -L http://files.magerun.net/n98-magerun-latest.phar -o ${BUILDENV}/tools/n98-magerun
chmod +x ${BUILDENV}/tools/n98-magerun
mkdir -p /tmp/n98-magerun-modules/
if [ ! -d /tmp/n98-magerun-modules/yireo ] ; then
  git clone https://github.com/yireo/magerun-addons /tmp/n98-magerun-modules/yireo
fi
if [ ! -d /tmp/n98-magerun-modules/mpmd ] ; then
  git clone https://github.com/aoepeople/mpmd /tmp/n98-magerun-modules/mpmd
fi
if [ ! -d /tmp/n98-magerun-modules/magerun-commands ] ; then
  git clone https://github.com/degdigital/magerun-commands /tmp/n98-magerun-modules/magerun-commands
fi
if [ ! -d /tmp/n98-magerun-modules/magerun-addons ] ; then
  git clone https://github.com/peterjaap/magerun-addons /tmp/n98-magerun-modules/magerun-addons
fi
if [ ! -d /tmp/n98-magerun-modules/magerun-creatuity ] ; then
  git clone https://github.com/creatuity/magerun-creatuity /tmp/n98-magerun-modules/magerun-creatuity
fi
if [ ! -d /tmp/n98-magerun-modules/magerun-module-cache-benchmark ] ; then
  git clone https://github.com/cmuench/magerun-module-cache-benchmark /tmp/n98-magerun-modules/magerun-module-cache-benchmark
fi
if [ ! -d /tmp/n98-magerun-modules/cmuench-magerun-addons ] ; then
  git clone https://github.com/cmuench/cmuench-magerun-addons /tmp/n98-magerun-modules/cmuench-magerun-addons
fi
if [ ! -d /tmp/n98-magerun-modules/kalenjordan-magerun-addons ] ; then
  git clone https://github.com/kalenjordan/magerun-addons /tmp/n98-magerun-modules/kalenjordan-magerun-addons
fi
if [ ! -d /tmp/n98-magerun-modules/Webgriffe_Golive ] ; then
  git clone https://github.com/aleron75/Webgriffe_Golive /tmp/n98-magerun-modules/Webgriffe_Golive
fi
if [ ! -d /tmp/n98-magerun-modules/ffuenf-download-remote-media ] ; then
  git clone https://github.com/ffuenf/download-remote-media /tmp/n98-magerun-modules/ffuenf-download-remote-media
fi
if [ ! -d /tmp/n98-magerun-modules/sxmlsv ] ; then
  git clone https://github.com/KamilBalwierz/sxmlsv /tmp/n98-magerun-modules/sxmlsv
fi
if [ ! -d /tmp/n98-magerun-modules/magerun-dataprofile ] ; then
  git clone https://github.com/marcoandreini/magerun-dataprofile /tmp/n98-magerun-modules/magerun-dataprofile
fi
if [ ! -d /tmp/n98-magerun-modules/Magerun-DBClean ] ; then
  git clone https://github.com/steverobbins/Magerun-DBClean /tmp/n98-magerun-modules/Magerun-DBClean
fi
if [ ! -d /tmp/n98-magerun-modules/magerun-modman ] ; then
  git clone https://github.com/fruitcakestudio/magerun-modman /tmp/n98-magerun-modules/magerun-modman
fi
if [ ! -d /tmp/n98-magerun-modules/EAVCleaner ] ; then
  git clone https://github.com/magento-hackathon/EAVCleaner /tmp/n98-magerun-modules/EAVCleaner
fi
if [ ! -d /tmp/n98-magerun-modules/magescan ] ; then
  git clone https://github.com/steverobbins/magescan /tmp/n98-magerun-modules/magescan
fi
curl -s -L https://getcomposer.org/composer.phar -o ${BUILDENV}/tools/composer
chmod +x ${BUILDENV}/tools/composer
curl -s -L https://phar.phpunit.de/phploc.phar -o ${BUILDENV}/tools/phploc
chmod +x ${BUILDENV}/tools/phploc
curl -s -L https://scrutinizer-ci.com/ocular.phar -o ${BUILDENV}/tools/ocular
chmod +x ${BUILDENV}/tools/ocular
curl -s -L https://raw.github.com/lehmannro/assert.sh/master/assert.sh -o ${BUILDENV}/tools/assert.sh
chmod +x ${BUILDENV}/tools/assert.sh
curl -s -L http://magedownload.steverobbins.com/download/latest/magedownload.phar -o ${BUILDENV}/tools/magedownload
chmod +x ${BUILDENV}/tools/magedownload

cp ${BUILDENV}/.n98-magerun.yaml ~/.n98-magerun.yaml

cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"
${BUILDENV}/install.sh
if [ -d "${WORKSPACE}/vendor" ] ; then
    cp -rf ${WORKSPACE}/vendor/* "${BUILDENV}/vendor/"
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
  php -f ${BUILDENV}/tools/ocular code-coverage:upload --access-token=${SCRUTINIZER_ACCESS_TOKEN} --format=php-clover build/logs/clover.xml
else
  php -f ${BUILDENV}/tools/ocular code-coverage:upload --format=php-clover build/logs/clover.xml
fi

echo "Done."
