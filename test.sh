#!/bin/bash
set -e
. assert.sh

_clean() {
    _assert_reset # reset state
    DEBUG= STOP= INVARIANT=1 DISCOVERONLY= CONTINUE= # reset flags
    eval $* # read new flags
}
NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'

# Get absolute path to main directory
ABSPATH=$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")
SOURCE_DIR=`dirname "${ABSPATH}"`
cd ${SOURCE_DIR}

echo
echo "---------------------"
echo "- n98-magerun tests -"
echo "---------------------"
echo

echo
echo -e "${YELLOW}testing for rewrite conflicts${NC}"
CMD="${HOME}/.cache/bin/n98-magerun dev:module:rewrite:conflicts"
${CMD}
_clean STOP=1; assert "${CMD} | grep -co 'No rewrite conflicts were found.'" "1"
assert_end
echo

echo
echo -e "${YELLOW}scanning files in htdocs/app/ for malformed XML${NC}"
CMD="${HOME}/.cache/bin/n98-magerun sxmlsv:scan htdocs/app/"
${CMD}
_clean STOP=1; assert "${CMD} | grep -co 'finding 0 problems'" "1"
assert_end
echo

echo
echo -e "${YELLOW}[APPSEC-1063] testing for possible SQL vulnerabilities${NC}"
CMD="${HOME}/.cache/bin/n98-magerun dev:possible-sql-injection"
${CMD}
_clean STOP=1; assert "${CMD} | grep -co 'not affected by APPSEC-1063'" "1"
assert_end
echo

echo
echo -e "${YELLOW}[SUPEE-6788] testing for old-style admin routing${NC}"
CMD="${HOME}/.cache/bin/n98-magerun dev:old-admin-routing"
${CMD}
_clean STOP=1; assert "${CMD} | grep -co 'All extension are compatible'" "1"
assert_end
echo

echo
echo -e "${YELLOW}[SUPEE-6788] testing for non-whitelisted template vars${NC}"
CMD="${HOME}/.cache/bin/n98-magerun dev:template-vars"
${CMD}
_clean STOP=1; assert "${CMD} | grep -co 'All blocks and variables are whitelisted'" "1"
assert_end
echo
