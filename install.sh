#!/bin/bash

# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
SOURCE_DIR=`dirname "${ABSPATH}"`

if [ -z $MAGENTO_DB_HOST ]; then MAGENTO_DB_HOST="localhost"; fi
if [ -z $MAGENTO_DB_USER ]; then MAGENTO_DB_USER="root"; fi
if [ -z $MAGENTO_DB_PASS ]; then MAGENTO_DB_PASS=""; fi
if [ -z $MAGENTO_DB_NAME ]; then MAGENTO_DB_NAME="mage"; fi

echo
echo "---------------------"
echo "- AOE MageTestStand -"
echo "---------------------"
echo
echo "Installing ${MAGENTO_VERSION} in ${SOURCE_DIR}/htdocs"
echo "using Database Credentials:"
echo "    Host: ${MAGENTO_DB_HOST}"
echo "    User: ${MAGENTO_DB_USER}"
echo "    Pass: [hidden]"
echo "    Name: ${MAGENTO_DB_NAME}"
echo

cd ${SOURCE_DIR}

if [ ! -f htdocs/app/etc/local.xml ] ; then
    tools/n98-magerun.phar install \
      --dbHost="${MAGENTO_DB_HOST}" --dbUser="${MAGENTO_DB_USER}" --dbPass="${MAGENTO_DB_PASS}" --dbName="${MAGENTO_DB_NAME}" \
      --installSampleData=no \
      --useDefaultConfigParams=yes \
      --magentoVersionByName="${MAGENTO_VERSION}" \
      --installationFolder="${SOURCE_DIR}/htdocs" \
      --baseUrl="http://magento.local/" || { echo "Installing Magento failed"; exit 1; }
fi

if [ ! -f composer.lock ] ; then
    tools/composer.phar install
fi

tools/modman deploy-all --force

tools/n98-magerun.phar --root-dir=htdocs config:set dev/template/allow_symlink 1
