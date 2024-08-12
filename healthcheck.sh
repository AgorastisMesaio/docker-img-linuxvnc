#!/usr/bin/env bash

# Test an HTTP site, return any error or http error
curl_test() {
    MSG=$1
    ERR=$2
    URL=$3
    echo -n ${MSG}
    http_code=`curl -o /dev/null -s -w "%{http_code}\n" ${URL}`
    ret=$?
    if [ "${ret}" != 0 ]; then
        echo " - ${ERR}, return code: ${ret}"
        return ${ret}
    else
        if [ "${http_code}" != 200 ]; then
            echo " - ${ERR}, HTTP code: ${http_code}"
            return 1
        fi
    fi
    return 0
}

# Test backend ("novnc2") Python Web app providing an API (written with Flask) on port 6079
curl_test "Test backend webapp" "Error backend webapp :${PORT}" "http://127.0.0.1:6079/api/health" || { ret=${?}; exit ${ret}; }
echo " Ok."

# Test VNC port 5900
echo -n "Test VNC"
PORT=5900
export ERR_MSG="Error testing VNC :${PORT}"
/usr/bin/nc -w 3 -z ${HOSTNAME} ${PORT} > /dev/null 2>&1 || { ret=${?}; echo " - ${ERR_MSG}, return code: ${ret}"; exit ${ret}; }
echo " Ok."

# All passed
exit 0
