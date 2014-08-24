#!/bin/bash

CONF_FILE=".project-mrt-control.conf"
PGID_FILES_DIR="project-mrt-control"
STDERR="stderr.log"
STDOUT="stdout.log"

SOURCE_PATH="/usr/local/lib"
source "${SOURCE_PATH}/project-mrt-control/svnfs_mount.sh"

export is_bundle=""
if [[ -e "bundle/main.js" ]]; then
    project_name=${PWD##*/}
    is_bundle=true
elif [[ -e ".meteor/release" ]]; then
    project_name=${PWD##*/}
else
    echo "This is not meteor project dir"
    exit 4
fi

if [[ ! -e ${CONF_FILE} ]]; then
    echo "'${CONF_FILE}' config file not found"
    exit 4
fi
source ${CONF_FILE}
if [[ $(declare -f run_command > /dev/null; echo $?) != '0' ]]; then
    echo "'${CONF_FILE}' must have 'run_command()' function"
    exit 4
fi

mkdir -p /run/user/$(id -u)/${PGID_FILES_DIR}
PGID_FILE="/run/user/$(id -u)/${PGID_FILES_DIR}/${project_name}.pgid"

if [[ -z "${PGID}" && -e "${PGID_FILE}" ]]; then
    PGID=$(cat ${PGID_FILE})
fi

usage() {
    echo "Usage: some usage info"
}

start() {
    if [[ -n "${PGID}" ]]; then
        if [[ -z "$(ps -e -o pgid,pid= | grep ${PGID})" ]]; then
            rm ${PGID_FILE};
        else
            echo "Project \"${project_name}\" already running, PGID=${PGID}";
            exit 4
        fi
    fi
    
    run_command;

    echo $$ > ${PGID_FILE};
    echo "Project \"${project_name}\" started, PGID=$$"
}

status() {
    if [[ -z "${PGID}" ]]; then
        echo "Project \"${project_name}\" is not running (missing PGID)"
        return 0
    elif [[ -n "$(ps -e -o pgid,pid= | grep ${PGID})" ]]; then
        PIDS=""
        IFS=$'\n'
        for pid in $(ps -e -o pgid,pid= | grep ${PGID}); do
            PIDS="$(echo $pid | awk -F ' ' '{print $2}') $PIDS"
        done
        unset IFS
        echo  "Project \"${project_name}\" running PGID=${PGID}, PIDs: $PIDS"
        return 1
    else
        echo "Project \"${project_name}\" is not running (tested PGID: ${PGID})"
        return 0
    fi
}

stop() {
    if [[ -z "${PGID}" ]]; then
        echo "Project \"${project_name}\" is not running (missing PGID)"
    elif [[ -n "$(ps -e -o pgid,pid= | grep ${PGID})" ]]; then
        PIDS=""
        IFS=$'\n'
        for pid in $(ps -e -o pgid,pid= | grep ${PGID}); do
            PIDS="$(echo $pid | awk -F ' ' '{print $2}') $PIDS"
        done
        unset IFS
        kill -2 ${PIDS}
        echo "Sending SIGNINT to all childs. Project \"${project_name}\" stopped"
        if [[ -e "${PGID_FILE}" ]]; then
            rm ${PGID_FILE}; unset PGID;
        fi
    else
        echo "Project \"${project_name}\" is not running (tested PGID: ${PGID})"
        if [[ -e "${PGID_FILE}" ]]; then
            rm ${PGID_FILE}; unset PGID;
        fi
    fi
}

case $1 in
    start)
        mount_svn_repository;
        start;
        ;;
    stop)
        stop;
        umount_svn_repository;
        ;;
    status)
        status;
        ;;
    restart)
        status > /dev/null;
        if [[ $? -eq 1 ]]; then
            stop;
            sleep 3;
            start;
        else
            echo "You need to start project before"
        fi
        ;;
    *)
        usage;
        exit 4
        ;;
esac
