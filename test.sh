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
CMD='tools/n98-magerun dev:module:rewrite:conflicts'
${CMD}
_clean STOP=1; assert "${CMD} | grep -co 'No rewrite conflicts were found.'" "1"
assert_end
echo

echo
echo -e "${YELLOW}scanning files for malformed XML${NC}"
CMD='tools/n98-magerun sxmlsv:scan'
${CMD}
_clean STOP=1; assert "${CMD} | grep -co 'finding 0 problems'" "1"
assert_end
echo

echo
echo -e "${YELLOW}[APPSEC-1063] testing for possible SQL vulnerabilities${NC}"
CMD='tools/n98-magerun dev:possible-sql-injection'
${CMD}
_clean STOP=1; assert "${CMD} | grep -co 'APPSEC-1063'" "0"
assert_end
echo

echo
echo -e "${YELLOW}[SUPEE-6788] testing for old-style admin routing${NC}"
CMD='tools/n98-magerun dev:old-admin-routing'
${CMD}
_clean STOP=1; assert "${CMD} | grep -co 'Yay! All extension are compatible, good job!'" "0"
assert_end
echo

echo
echo -e "${YELLOW}[SUPEE-6788] testing for non-whitelisted template vars${NC}"
CMD='tools/n98-magerun dev:old-admin-routing'
${CMD}
_clean STOP=1; assert "${CMD} | grep -co 'Yay! All blocks and variables are whitelisted.'" "0"
assert_end
echo
