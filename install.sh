#!/bin/bash

# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
SOURCE_DIR=`dirname "${ABSPATH}"`

if [ -z $MAGENTO_DB_HOST ]; then MAGENTO_DB_HOST="localhost"; fi
if [ -z $MAGENTO_DB_PORT ]; then MAGENTO_DB_PORT="3306"; fi
if [ -z $MAGENTO_DB_USER ]; then MAGENTO_DB_USER="root"; fi
if [ -z $MAGENTO_DB_PASS ]; then MAGENTO_DB_PASS=""; fi
if [ -z $MAGENTO_DB_NAME ]; then MAGENTO_DB_NAME="mageteststand"; fi
if [ -z $MAGENTO_DB_ALLOWSAME ]; then MAGENTO_DB_ALLOWSAME="0"; fi

echo
echo "------------------------"
echo "- Ffuenf MageTestStand -"
echo "------------------------"
echo
echo "Installing ${MAGENTO_VERSION} in ${SOURCE_DIR}/htdocs"
echo "using Database Credentials:"
echo "    Host: ${MAGENTO_DB_HOST}"
echo "    Port: ${MAGENTO_DB_PORT}"
echo "    User: ${MAGENTO_DB_USER}"
echo "    Pass: [hidden]"
echo "    Main DB: ${MAGENTO_DB_NAME}"
echo "    Test DB: ${MAGENTO_DB_NAME}_test"
echo "    Allow same db: ${MAGENTO_DB_ALLOWSAME}"
echo

cd ${SOURCE_DIR}

if [ ! -f htdocs/app/etc/local.xml ] ; then

    # Create main database
    MYSQLPASS=""
    if [ ! -z $MAGENTO_DB_PASS ]; then MYSQLPASS="-p${MAGENTO_DB_PASS}"; fi
    mysql -u${MAGENTO_DB_USER} ${MYSQLPASS} -h${MAGENTO_DB_HOST} -P${MAGENTO_DB_PORT} -e "DROP DATABASE IF EXISTS \`${MAGENTO_DB_NAME}\`; CREATE DATABASE \`${MAGENTO_DB_NAME}\`;"

    sed -i -e s/MAGENTO_DB_HOST/${MAGENTO_DB_HOST}/g .modman/Ffuenf_TestSetup/app/etc/local.xml.phpunit
    sed -i -e s/MAGENTO_DB_PORT/${MAGENTO_DB_PORT}/g .modman/Ffuenf_TestSetup/app/etc/local.xml.phpunit
    sed -i -e s/MAGENTO_DB_USER/${MAGENTO_DB_USER}/g .modman/Ffuenf_TestSetup/app/etc/local.xml.phpunit
    sed -i -e s/MAGENTO_DB_PASS/${MAGENTO_DB_PASS}/g .modman/Ffuenf_TestSetup/app/etc/local.xml.phpunit
    sed -i -e s/MAGENTO_DB_ALLOWSAME/${MAGENTO_DB_ALLOWSAME}/g .modman/Ffuenf_TestSetup/app/etc/local.xml.phpunit

    if [ $MAGENTO_DB_ALLOWSAME == "0" ] ; then
      # Create test database
      mysql -u${MAGENTO_DB_USER} ${MYSQLPASS} -h${MAGENTO_DB_HOST} -P${MAGENTO_DB_PORT} -e "DROP DATABASE IF EXISTS \`${MAGENTO_DB_NAME}_test\`; CREATE DATABASE \`${MAGENTO_DB_NAME}_test\`;"
      sed -i -e s/MAGENTO_DB_NAME/${MAGENTO_DB_NAME}_test/g .modman/Ffuenf_TestSetup/app/etc/local.xml.phpunit
    else
      sed -i -e s/MAGENTO_DB_NAME/${MAGENTO_DB_NAME}/g .modman/Ffuenf_TestSetup/app/etc/local.xml.phpunit
    fi

    VERSION=`echo ${MAGENTO_VERSION} | sed -n 's/.*-\(.*\)/\1/p'`
    VER=`echo "${VERSION//./}"`
    if [ $VER -gt 1900 ] ; then # use magedownload-cli only for magento > 1.9.0.0
        if [ ! -f /tmp/magento-ce-${VERSION}.tar.gz ] ; then
            tools/magedownload file --id=${MAGEDOWNLOAD_ID} --token=${MAGEDOWNLOAD_TOKEN} magento-${VERSION}.tar.gz /tmp/${MAGENTO_VERSION}.tar.gz
        fi
    fi

    tools/n98-magerun install \
      --dbHost="${MAGENTO_DB_HOST}" --dbUser="${MAGENTO_DB_USER}" --dbPass="${MAGENTO_DB_PASS}" --dbName="${MAGENTO_DB_NAME}" --dbPort="${MAGENTO_DB_PORT}" \
      --installSampleData=no \
      --useDefaultConfigParams=yes \
      --magentoVersionByName="${MAGENTO_VERSION}" \
      --installationFolder="${SOURCE_DIR}/htdocs" \
      --baseUrl="http://magento.local/" || { echo "Installing Magento failed"; exit 1; }
fi

if [ ! -f composer.lock ] ; then
    tools/composer install --prefer-source
fi
mv ${SOURCE_DIR}/htdocs/ext_vendor/* ${SOURCE_DIR}/htdocs/vendor/
rm -rf ${SOURCE_DIR}/htdocs/ext_vendor

tools/modman deploy-all --force

tools/n98-magerun --root-dir=htdocs config:set dev/template/allow_symlink 1
