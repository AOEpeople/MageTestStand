#!/bin/bash

# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
SOURCE_DIR=`dirname "${ABSPATH}"`

function error_exit {
	echo "$1" 1>&2
	exit 1
}

if [ -z $MAGENTO_DB_HOST ]; then MAGENTO_DB_HOST="localhost"; fi
if [ -z $MAGENTO_DB_PORT ]; then MAGENTO_DB_PORT="3306"; fi
if [ -z $MAGENTO_DB_USER ]; then MAGENTO_DB_USER="root"; fi
if [ -z $MAGENTO_DB_PASS ]; then MAGENTO_DB_PASS=""; fi
if [ -z $MAGENTO_DB_NAME ]; then MAGENTO_DB_NAME="mageteststand"; fi
if [ -z $MAGENTO_DB_ALLOWSAME ]; then MAGENTO_DB_ALLOWSAME="0"; fi

echo
echo "---------------------"
echo "- AOE MageTestStand -"
echo "---------------------"
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
    mysql -u${MAGENTO_DB_USER} ${MYSQLPASS} -h${MAGENTO_DB_HOST} -P${MAGENTO_DB_PORT} -e "DROP DATABASE IF EXISTS \`${MAGENTO_DB_NAME}\`; CREATE DATABASE \`${MAGENTO_DB_NAME}\`;" || error_exit "Mysql: Drop or create database failed"

    sed -i -e s/MAGENTO_DB_HOST/${MAGENTO_DB_HOST}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit || error_exit "Setting app/etc/local.xml.phpunit failed"
    sed -i -e s/MAGENTO_DB_PORT/${MAGENTO_DB_PORT}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit || error_exit "Setting app/etc/local.xml.phpunit failed"
    sed -i -e s/MAGENTO_DB_USER/${MAGENTO_DB_USER}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit || error_exit "Setting app/etc/local.xml.phpunit failed"
    sed -i -e s/MAGENTO_DB_PASS/${MAGENTO_DB_PASS}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit || error_exit "Setting app/etc/local.xml.phpunit failed"
    sed -i -e s/MAGENTO_DB_ALLOWSAME/${MAGENTO_DB_ALLOWSAME}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit || error_exit "Setting app/etc/local.xml.phpunit failed"

    if [ $MAGENTO_DB_ALLOWSAME == "0" ] ; then
      # Create test database
      mysql -u${MAGENTO_DB_USER} ${MYSQLPASS} -h${MAGENTO_DB_HOST} -P${MAGENTO_DB_PORT} -e "DROP DATABASE IF EXISTS \`${MAGENTO_DB_NAME}_test\`; CREATE DATABASE \`${MAGENTO_DB_NAME}_test\`;" || error_exit "Creating test database failed"
      sed -i -e s/MAGENTO_DB_NAME/${MAGENTO_DB_NAME}_test/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit || error_exit "Setting app/etc/local.xml.phpunit failed"
    else
      sed -i -e s/MAGENTO_DB_NAME/${MAGENTO_DB_NAME}/g .modman/Aoe_TestSetup/app/etc/local.xml.phpunit || error_exit "Setting app/etc/local.xml.phpunit failed"
    fi

    tools/n98-magerun.phar install \
      --dbHost="${MAGENTO_DB_HOST}" --dbUser="${MAGENTO_DB_USER}" --dbPass="${MAGENTO_DB_PASS}" --dbName="${MAGENTO_DB_NAME}" --dbPort="${MAGENTO_DB_PORT}" \
      --installSampleData=no \
      --useDefaultConfigParams=yes \
      --magentoVersionByName="${MAGENTO_VERSION}" \
      --installationFolder="${SOURCE_DIR}/htdocs" \
      --baseUrl="http://magento.local/" || error_exit "Installing Magento failed"
fi

if [ ! -f composer.lock ] ; then
    tools/composer.phar install || error_exit "Composer install failed"
fi

tools/modman deploy-all --force || error_exit "Modman deployment failed"

tools/n98-magerun.phar --root-dir=htdocs config:set dev/template/allow_symlink 1 || error_exit "Failed to allow symlinks configuration"
