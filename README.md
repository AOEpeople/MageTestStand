# MageTestStand

This tool is used to build a minimal Magento environment that allows to run PHPUnit tests for a Magento module on Travis CI.

It uses following tools:
- [n98-magerun](https://github.com/netz98/n98-magerun) (to install a vanilla Magento instance for a given version number)
- [modman](https://github.com/colinmollenhour/modman) (to link your module to the Magento instance)
- [EcomDev_PHPUnit](https://github.com/AOEpeople/EcomDev_PHPUnit) (actually, the AOE fork,... for some helpers that make unit testing in Magento much easier)
- [PHPUnit](https://phpunit.de/)
- [Composer](https://getcomposer.org/)
- [aoepeople/composer-installers](https://github.com/AOEpeople/composer-installers) (minimal composer installer for Magento modules which acts as a replacement for '[magento-hackathon/magento-composer-installer](https://github.com/magento-hackathon/magento-composer-installer)')

## Requirements

- Main Database: defaults to 'mageteststand' (user 'root', blank password) This is the database Magento uses
- Test Database: main database name with '_test' appended: 'mageteststand_test' (host, username, password and port are the same as the main database) This is the dummy database EcomDev_PHPUnit will use. Although you can configure this to use the original database, some tests (including fixtures) will behave differently...
- You can override the default database credentials using following environment variables:
  - `MAGENTO_DB_HOST`
  - `MAGENTO_DB_PORT`
  - `MAGENTO_DB_USER`
  - `MAGENTO_DB_PASS`
  - `MAGENTO_DB_NAME`
- In case you want to allow EcomDev_PHPUnit to use the main database instead of the test database you can set following environment variable to 1. This might be required if you're planning on writing integration tests.
  - `MAGENTO_DB_ALLOWSAME`
- Environment variable `MAGENTO_VERSION` with valid Magento version for n98-magerun's install command
- Define `MAGETESTSTAND_URL` to use a customized MageTestStand repository.

## General usage

- Set the environment variable `MAGENTO_VERSION` to the desired version, e.g. magento-ce-1.9.0.1
- Set the environment variable `WORKSPACE` to the directory of the magento module
- checkout your magento module
- run `curl -sSL https://raw.githubusercontent.com/AOEpeople/MageTestStand/master/setup.sh | bash` as the build step, this will do everything automatically in a temporary directory
- you can use the script contents as a build step for sure, but this way it's easier ;)

## Travis CI configuration

Example .travis.yaml file (in the Magento module you want to test):

```yml
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
#  global:
#    - MAGENTO_DB_ALLOWSAME=1
#    - SKIP_CLEANUP=1
#    - MAGETESTSTAND_URL=https://github.com/xxxx/MageTestStand.git
  - MAGENTO_VERSION=magento-ce-1.9.0.1
  - MAGENTO_VERSION=magento-ce-1.8.1.0
  - MAGENTO_VERSION=magento-ce-1.8.0.0
  - MAGENTO_VERSION=magento-ce-1.7.0.2
script:
  - curl -sSL https://raw.githubusercontent.com/AOEpeople/MageTestStand/master/setup.sh | bash
notifications:
  email:
    recipients:
      - notify@someone.com
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
- use the following script as a shell build step `curl -sSL https://raw.githubusercontent.com/AOEpeople/MageTestStand/master/setup.sh | bash`

## Unittest your Module directly from bash/zsh/shell
- Set up your environment
```bash
export WORKSPACE=/full/path/to/your/module
export MAGENTO_VERSION=magento-ce-1.9.0.1

# if necessary
export MAGENTO_DB_HOST=somewhere
export MAGENTO_DB_PORT=somenum
export MAGENTO_DB_USER=someone
export MAGENTO_DB_PASS=something
export MAGENTO_DB_NAME=somename
```

- Run MageTestStand:
```
curl -sSL https://raw.githubusercontent.com/AOEpeople/MageTestStand/master/setup.sh | bash
```

## Misc

### Skip cleanup

If you're running this in an CI environment that will delete the workspace after the run (e.g. Travis CI) you might not want to wait for this script to explicitely cleanup. Using `SKIP_CLEANUP` parameter you can make MageTestStand skip this step. 

This parameter can be set via an environment variable (Travis CI supports that via env/global) or from command line:
```
export SKIP_CLEANUP=1
```
