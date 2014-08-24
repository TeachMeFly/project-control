# ver

MOUNT_COMMAND="mount-svnfs"

SVN_DIR="/home/svn"
CACHE_DIR="/tmp/svnfs_cache"
MOUNT_OPTIONSS="-o allow_other"
MOUNT_DIR=".svn-repo"
SOURCE_LINK="svn-sources"

mount_svn_repository() {
	if [[ $is_bundle ]]; then
		return 0
	fi
	if [[ -n $(cat /etc/mtab | grep $(pwd)/${MOUNT_DIR}) ]]; then
		fusermount -u $(pwd)/${MOUNT_DIR} || (echo "Cannot unmount $(pwd)/${MOUNT_DIR}" 1>&2 && exit 4);
	fi

	if [[ ! -d "${SVN_DIR}/${project_name}" ]]; then
		echo "${SVN_DIR}/${project_name} svn repository not exist, nothing to mount." 1>&2
		exit 4
	fi
	if [[ -d ${MOUNT_DIR} ]]; then
		rmdir "${MOUNT_DIR}" 2> /dev/null || (echo "Mountpoitnt \"$(pwd)/${MOUNT_DIR}\" not empty" 1>&2 && exit 4)
	fi
	if [[ -h "${SOURCE_LINK}" ]]; then
		rm svn-sources
	elif [[ -e "${SOURCE_LINK}" ]]; then
		echo "File \"${SOURCE_LINK}\" exist and not a link" 1>&2
		exit 4
	fi

	mkdir ${MOUNT_DIR}; chmod 755 ${MOUNT_DIR};
	ln -s ${MOUNT_DIR}/head ${SOURCE_LINK};

	mount-svnfs ${SVN_DIR}/${project_name} ${MOUNT_DIR} -o cache_dir=/tmp/svnfs_cache/${project_name}

	echo "SVN repository mounted to $(pwd)/${MOUNT_DIR}"
}

umount_svn_repository() {
	if [[ $is_bundle ]]; then
		return 0
	fi

	if [[ -n $(cat /etc/mtab | grep $(pwd)/${MOUNT_DIR}) ]]; then
		(fusermount -u $(pwd)/${MOUNT_DIR} && echo "SVN repository unmounted from $(pwd)/${MOUNT_DIR}") || echo "Cannot unmount $(pwd)/${MOUNT_DIR}" 1>&2;
	fi

	if [[ -d ${MOUNT_DIR} ]]; then
		rmdir "${MOUNT_DIR}" 2> /dev/null || echo "Mountpoitnt \"$(pwd)/${MOUNT_DIR}\" not empty" 1>&2
	fi
	if [[ -h "${SOURCE_LINK}" ]]; then
		rm svn-sources
	elif [[ -e "${SOURCE_LINK}" ]]; then
		echo "File \"${SOURCE_LINK}\" exist and not a link" 1>&2
	fi
}
