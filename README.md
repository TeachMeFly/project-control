project-control
===============

This is small script for start/stop nodejs and meteor projects like system service.

.project-mrt-control.conf example
=================================

run_command() {
    export ROOT_URL="http://gazprommet.ru"
    export MONGO_URL="mongodb://localhost:27017/gazprommet"
    export PORT="3020"

    nohup node bundle/main.js 1> ${STDOUT} 2> ${STDERR}&
}

