#!/bin/bash
set -e
set -x

export PATH="$HOME/.cache/bin:$PATH"

mv ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/xdebug.ini ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/xdebug.ini.disabled
echo 'memory_limit = -1' >> ~/.phpenv/versions/$(phpenv version-name)/etc/conf.d/travis.ini
phpenv rehash;
composer self-update
if [[ -n "$GITHUB_TOKEN" ]]; then
    composer config github-oauth.github.com "$GITHUB_TOKEN"
fi
composer install --no-interaction --prefer-dist

# install or update composer in casher dir
if [ "$CASHER_DIR" ]; then
    mkdir -p $HOME/.cache/bin
    # modman
    if [ ! -f $HOME/.cache/bin/modman ]; then
        curl --connect-timeout 30 -sS https://raw.githubusercontent.com/colinmollenhour/modman/master/modman \
             -o $HOME/.cache/bin/modman
        chmod +x $HOME/.cache/bin/modman
    fi
    # n98-magerun
    if [ ! -f $HOME/.cache/bin/n98-magerun ]; then
        curl --connect-timeout 30 -sS https://files.magerun.net/n98-magerun-latest.phar \
             -o $HOME/.cache/bin/n98-magerun
        chmod +x $HOME/.cache/bin/n98-magerun
    fi
    # phpcs
    if [ ! -f $HOME/.cache/bin/phpcs ]; then
        curl --connect-timeout 30 -sS https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
             -o $HOME/.cache/bin/phpcs
        chmod +x $HOME/.cache/bin/phpcs
    fi
    # phploc
    if [ ! -f $HOME/.cache/bin/phploc ]; then
        curl --connect-timeout 30 -sS https://phar.phpunit.de/phploc.phar \
             -o $HOME/.cache/bin/phploc
        chmod +x $HOME/.cache/bin/phploc
    fi
    # ocular
    if [ ! -f $HOME/.cache/bin/ocular ]; then
        curl --connect-timeout 30 -sL https://scrutinizer-ci.com/ocular.phar \
             -o $HOME/.cache/bin/ocular
        chmod +x $HOME/.cache/bin/ocular
    fi
    # assert.sh
    if [ ! -f $HOME/.cache/bin/assert.sh ]; then
        curl --connect-timeout 30 -sS https://raw.githubusercontent.com/lehmannro/assert.sh/master/assert.sh \
             -o $HOME/.cache/bin/assert.sh
        chmod +x $HOME/.cache/bin/assert.sh
    fi
    # magedownload
    if [ ! -f $HOME/.cache/bin/magedownload ]; then
        curl --connect-timeout 30 -sSL "$(curl -sSL https://api.github.com/repos/steverobbins/magedownload-cli/releases | grep browser_download_url | grep '[.]phar' | head -n 1 | cut -d '"' -f 4)" \
             -o $HOME/.cache/bin/magedownload
        chmod +x $HOME/.cache/bin/magedownload
    fi
fi

# Magento ECG
git clone https://github.com/ffuenf/coding-standard $(pear config-get php_dir)/PHP/CodeSniffer/Standards/Ecg
