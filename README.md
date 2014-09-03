project-control
===============

This is small script for start/stop nodejs and meteor projects like system service.

.project-mrt-control.conf example
=================================

start_command() {
    mount_svn_repository
    export ROOT_URL="http://some-addr.com"
    export MONGO_URL="mongodb://localhost:27017/some-dbs"
    export PORT="3020"

    nohup node bundle/main.js 1> ${STDOUT} 2> ${STDERR}&
}

stop_command() {
    umount_svn_repository
}

