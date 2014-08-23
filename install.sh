#!/bin/bash

# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
SOURCE_DIR=`dirname "${ABSPATH}"`

cd ${SOURCE_DIR}

if [ ! -f htdocs/app/etc/local.xml ] ; then
    tools/n98-magerun.phar install \
      --dbHost="localhost" --dbUser="root" --dbPass="" --dbName="mage" \
      --installSampleData=no \
      --useDefaultConfigParams=yes \
      --magentoVersionByName="${MAGENTO_VERSION}" \
      --installationFolder="${SOURCE_DIR}/htdocs" \
      --baseUrl="http://magento.localdomain/" || { echo "Installing Magento failed"; exit 1; }
fi

if [ ! -f composer.lock ] ; then
    tools/composer.phar install
fi

tools/modman deploy-all --force

tools/n98-magerun.phar --root-dir=htdocs config:set dev/template/allow_symlink 1
