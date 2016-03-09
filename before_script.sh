#!/bin/bash
set -e
set -x

echo > ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/xdebug.ini
echo 'memory_limit = -1' >> ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/travis.ini
phpenv rehash;
composer self-update
if [[ -n "$GITHUB_TOKEN" ]]; then
    composer config github-oauth.github.com "$GITHUB_TOKEN"
fi
composer install --no-interaction --prefer-dist
