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

echo "Using build directory ${BUILDENV}"

git clone -b feature/n98-magerun-addons https://github.com/ffuenf/MageTestStand "${BUILDENV}"

mkdir -p ${WORKSPACE}/build/logs
mkdir -p ${BUILDENV}/tools
curl -s -L https://raw.githubusercontent.com/colinmollenhour/modman/master/modman -o ${BUILDENV}/tools/modman
chmod +x ${BUILDENV}/tools/modman
curl -s -L http://files.magerun.net/n98-magerun-latest.phar -o ${BUILDENV}/tools/n98-magerun
chmod +x ${BUILDENV}/tools/n98-magerun
mkdir -p /usr/local/share/n98-magerun/modules/
if [ ! -f /usr/local/share/n98-magerun/modules/yireo ] ; then
  git clone https://github.com/yireo/magerun-addons /usr/local/share/n98-magerun/modules/yireo
fi
if [ ! -f /usr/local/share/n98-magerun/modules/mpmd ] ; then
  git clone https://github.com/aoepeople/mpmd /usr/local/share/n98-magerun/modules/mpmd
fi
if [ ! -f /usr/local/share/n98-magerun/modules/magerun-commands ] ; then
  git clone https://github.com/degdigital/magerun-commands /usr/local/share/n98-magerun/modules/magerun-commands
fi
if [ ! -f /usr/local/share/n98-magerun/modules/magerun-addons ] ; then
  git clone https://github.com/peterjaap/magerun-addons /usr/local/share/n98-magerun/modules/magerun-addons
fi
if [ ! -f /usr/local/share/n98-magerun/modules/magerun-creatuity ] ; then
  git clone https://github.com/creatuity/magerun-creatuity /usr/local/share/n98-magerun/modules/magerun-creatuity
fi
if [ ! -f /usr/local/share/n98-magerun/modules/magerun-module-cache-benchmark ] ; then
  git clone https://github.com/cmuench/magerun-module-cache-benchmark /usr/local/share/n98-magerun/modules/magerun-module-cache-benchmark
fi
if [ ! -f /usr/local/share/n98-magerun/modules/cmuench-magerun-addons ] ; then
  git clone https://github.com/cmuench/cmuench-magerun-addons /usr/local/share/n98-magerun/modules/cmuench-magerun-addons
fi
if [ ! -f /usr/local/share/n98-magerun/modules/kalenjordan-magerun-addons ] ; then
  git clone https://github.com/kalenjordan/magerun-addons /usr/local/share/n98-magerun/modules/kalenjordan-magerun-addons
fi
if [ ! -f /usr/local/share/n98-magerun/modules/Webgriffe_Golive ] ; then
  git clone https://github.com/aleron75/Webgriffe_Golive /usr/local/share/n98-magerun/modules/Webgriffe_Golive
fi
if [ ! -f /usr/local/share/n98-magerun/modules/ffuenf-download-remote-media ] ; then
  git clone https://github.com/ffuenf/download-remote-media /usr/local/share/n98-magerun/modules/ffuenf-download-remote-media
fi
if [ ! -f /usr/local/share/n98-magerun/modules/sxmlsv ] ; then
  git clone https://github.com/KamilBalwierz/sxmlsv /usr/local/share/n98-magerun/modules/sxmlsv
fi
if [ ! -f /usr/local/share/n98-magerun/modules/magerun-dataprofile ] ; then
  git clone https://github.com/marcoandreini/magerun-dataprofile /usr/local/share/n98-magerun/modules/magerun-dataprofile
fi
if [ ! -f /usr/local/share/n98-magerun/modules/Magerun-DBClean ] ; then
  git clone https://github.com/steverobbins/Magerun-DBClean /usr/local/share/n98-magerun/modules/Magerun-DBClean
fi
if [ ! -f /usr/local/share/n98-magerun/modules/magerun-modman ] ; then
  git clone https://github.com/fruitcakestudio/magerun-modman /usr/local/share/n98-magerun/modules/magerun-modman
fi
if [ ! -f /usr/local/share/n98-magerun/modules/EAVCleaner ] ; then
  git clone https://github.com/magento-hackathon/EAVCleaner /usr/local/share/n98-magerun/modules/EAVCleaner
fi
curl -s -L https://getcomposer.org/composer.phar -o ${BUILDENV}/tools/composer
chmod +x ${BUILDENV}/tools/composer
curl -s -L https://phar.phpunit.de/phploc.phar -o ${BUILDENV}/tools/phploc
chmod +x ${BUILDENV}/tools/phploc
curl -s -L https://scrutinizer-ci.com/ocular.phar -o ${BUILDENV}/tools/ocular
chmod +x ${BUILDENV}/tools/ocular

cp -rf "${WORKSPACE}" "${BUILDENV}/.modman/"
${BUILDENV}/install.sh
if [ -d "${WORKSPACE}/vendor" ] ; then
    cp -rf ${WORKSPACE}/vendor/* "${BUILDENV}/vendor/"
fi

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
