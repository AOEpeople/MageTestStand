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
- You can specify the database credentials using
  - `MAGENTO_DB_HOST`
  - `MAGENTO_DB_USER`
  - `MAGENTO_DB_PASS`
  - `MAGENTO_DB_NAME`
- Environment variable `MAGENTO_VERSION` with valid Magento version for n98-magerun's install command

## Travis CI configuration

Example .travis.yaml file (in the Magento module you want to test):

```bash
language: php
php:
  - 5.3
  - 5.4
  - 5.5
  - 5.6
  - hhvm
matrix:
  allow_failures:
  - php: 5.6
  - php: hhvm
env:
  - MAGENTO_VERSION=magento-ce-1.9.0.1
  - MAGENTO_VERSION=magento-ce-1.8.1.0
  - MAGENTO_VERSION=magento-ce-1.8.0.0
  - MAGENTO_VERSION=magento-ce-1.7.0.2
before_script:
  - git clone https://github.com/AOEpeople/MageTestStand.git ${TRAVIS_BUILD_DIR}/../build-environment
  - cp -rf ${TRAVIS_BUILD_DIR} ${TRAVIS_BUILD_DIR}/../build-environment/.modman/
  - ${TRAVIS_BUILD_DIR}/../build-environment/install.sh
script:
  - cd ${TRAVIS_BUILD_DIR}/../build-environment/htdocs
  - ${TRAVIS_BUILD_DIR}/../build-environment/bin/phpunit --colors -d display_errors=1
notifications:
  email:
    recipients:
      - travis@fabrizio-branca.de
    on_success: always
    on_failure: always
```

## Jenkins configuration

- create a new multiconfiguration project and check out your Magento Module.
- create a new axis on the configuration matrix, named "MAGENTO_VERSION" and add the following values

```
magento-ce-1.9.0.1
magento-ce-1.8.1.0
magento-ce-1.8.0.0
magento-ce-1.7.0.2
```

- Make sure that the configurations are build sequentiell, otherwise you might run into database issues!
- use the following script as a shell build step

```bash
rm -rf ${WORKSPACE}/build-environment
git clone https://github.com/AOEpeople/MageTestStand.git ${WORKSPACE}/build-environment
ln -s ${WORKSPACE} ${WORKSPACE}/build-environment/.modman/__testModule
${WORKSPACE}/build-environment/install.sh

cd ${WORKSPACE}/build-environment/htdocs
${WORKSPACE}/build-environment/bin/phpunit --colors -d display_errors=1
```

- enable "activate chuck norris" as a post build action to add awesomeness