# MageTestStand

This tool is used to build a minimal Magento environment that allows to run PHPUnit tests for a Magento module on Travis CI.

It uses following tools:
- n98-magerun (to install a vanilla Magento instance for a given version number)
- modman (to link your module to the Magento instance)
- EcomDev_PHPUnit (actually, the AOE fork,... for some helpers that make unit testing in Magento much easier)
- PHPUnit
- Composer
- aoepeople/composer-installers (minimal composer installer for Magento modules which acts as a replacement for 'magento-hackathon/magento-composer-installer')

## Requirements

- database 'mage' (user 'root', blank password) This is the datatbase Magento uses
- database 'mage_test' (user 'root', blank password) This is the dummy database EcomDev_PHPUnit will use. Although you can configure this to use the original database, some tests (including fixtures) will behave differently...
- Environment variable "MAGENTO_VERSION" with valid Magento version for n98-magerun's install command

## Travis CI configuration

Example .travis.yaml file (in the Magento module you want to test):

```bash
language: php
php:
  - 5.3
  - 5.4
  - 5.5
env:
  - MAGENTO_VERSION=magento-ce-1.9.0.1
  - MAGENTO_VERSION=magento-ce-1.8.1.0
  - MAGENTO_VERSION=magento-ce-1.8.0.0
  - MAGENTO_VERSION=magento-ce-1.7.0.2
before_script:
  - mysql -e 'create database mage;'
  - mysql -e 'create database mage_test;'
  - git clone https://github.com/AOEpeople/MageTestStand.git ${TRAVIS_BUILD_DIR}/../build-environment
  - cp -rf ${TRAVIS_BUILD_DIR} ${TRAVIS_BUILD_DIR}/../build-environment/.modman/
  - ${TRAVIS_BUILD_DIR}/../build-environment/install.sh
script:
  - cd ${TRAVIS_BUILD_DIR}/../build-environment/htdocs
  - ${TRAVIS_BUILD_DIR}/../build-environment/bin/phpunit --colors -d display_errors=1
notifications:
  email:
    recipients:
      - mail@example.xom
    on_success: always
    on_failure: always
```