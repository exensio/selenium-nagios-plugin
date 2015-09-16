#!/bin/bash
#
#
# check_website_by_selenium.sh
# Description : Checks a website using the Selenium Grid
#
# The MIT License (MIT)
# 
# Copyright (c) 2015, Roland Rickborn (roland.rickborn@exensio.de)
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Revision history:
# 2015-09-16  Created
#
# ---------------------------------------------------------------------------
#
# Example configuration
#
# commands.cfg:
#
# define command {
#   command_name                   check_website_by_selenium
#   command_line                   $USER2$/check_website_by_selenium.sh -s $ARG1$ -h $ARG2$ -b $ARG3$ -v $ARG4$
# }
#
#
# services.cfg:
#
# define service {
#   service_description            check_website_by_selenium_demo
#   host_name                      demo_host
#   use                            check_mk_active
#   check_command                  check_website_by_selenium!/tmp/demo.json
# }
#

# Default options
### NO CHANGES ABOVE THIS LINE ###
JAVA_BIN=/usr/bin/java
INTERPRETER=/opt/selenium/seInterpreter.jar
### NO CHANGES BELOW THIS LINE ###

# Version
VERSION="1.0"

# Plugin return codes
RC_OK=0
RC_WARN=1
RC_CRIT=2
RC_UNKNOWN=3

# Option processing
usage()
{
    echo "usage: check_website_by_selenium [-d] -s <path>"
    echo "usage: check_website_by_selenium [-d] [-b firefox] -s <path>"
    echo "usage: check_website_by_selenium [-d] [-v 37] -s <path>"
    echo "    -s: <path> to the Selenium json test script"
    echo "    -h: <url> to Selenium Grid hub"
    echo "    -b: <browser> to be used"
    echo "        (the available values depend on your hub)"
    echo "    -v: <version> of browser"
    echo "        (the available values depend on your hub)"
    echo "    -d: enable debugging"
    echo " "
    exit ${RC_UNKNOWN}
}

filter_debug()
{
    echo -e "$1"
}

# Other options
SCRIPTFILE=""
DEBUG=0
LOGGING=org.apache.commons.logging.impl.SimpleLog
# See https://github.com/SeleniumBuilder/se-builder/wiki/Se-Interpreter
HUB=http://127.0.0.1:4444/wd/hub
BROWSER=firefox
VERSION=37
PARAMETER="--driver.javascriptEnabled=true --driver.enableElementCacheCleanup=false --implicitlyWait=30 --pageLoadTimeout=30"
 
while getopts s:h:b:v:d OPTNAME; do
    case "${OPTNAME}" in
    s)
        SCRIPTFILE="${OPTARG}"
        ;;
    h)
        HUB="${OPTARG}"
        ;;
    b)
        BROWSER="${OPTARG}"
        ;;
    v)
        VERSION="${OPTARG}"
        ;;
    d)
        DEBUG=1
        LOGGING="org.apache.commons.logging.impl.SimpleLog -Dorg.apache.commons.logging.simplelog.log.com.sebuilder.interpreter.SeInterpreter=DEBUG"
        ;;
    *)
        usage
        ;;
    esac
done
 
if [ "$?" -ne "0" ]; then
    echo "ERROR - Could not retrieve status from website"
    exit ${RC_CRIT}
fi

STATUS=$(${JAVA_BIN} -Dorg.apache.commons.logging.Log=${LOGGING} \
    -jar ${INTERPRETER} --driver=Remote --driver.url=${HUB} --driver.browserName=${BROWSER} \
    --driver.version=$VERSION ${PARAMETER} ${SCRIPTFILE} 2>&1)

if [[ "${STATUS}" =~ "succeed" ]] && [ $DEBUG == 0 ]; then
    echo "Status: OK"
    exit "${RC_OK}"
elif [[ "${STATUS}" =~ "failed" ]] && [ $DEBUG == 0 ]; then
    echo "Status: CRITICAL"
    exit "${RC_CRIT}"
elif [[ "${STATUS}" =~ "succeed" ]] && [ $DEBUG == 1 ]; then
    echo "[DEBUG] Status: OK"
    filter_debug "${STATUS}"
    exit "${RC_OK}"
elif [[ "${STATUS}" =~ "failed" ]] && [ $DEBUG == 1 ]; then
    echo "[DEBUG] Status: CRITICAL"
    filter_debug "${STATUS}"
    exit "${RC_CRIT}"
fi
