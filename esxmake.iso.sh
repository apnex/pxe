#!/bin/bash
## prerequisites ##
# yum install -y xz-devel make gcc makeisofs syslinux
# detect and resolve symlink
if [[ $(readlink -f $0) =~ ^(.*)/([^/]+)$ ]]; then
	WORKDIR="${BASH_REMATCH[1]}"
	CALLED="${BASH_REMATCH[2]}"
fi
IPXEDIR="${WORKDIR}/ipxe/src"
MYDIR="$(pwd)"

# COLOURS
NC='\033[0m' # no colour
GREEN='\033[0;32m' # green
ORANGE='\033[0;33m' # orange
BLUE='\033[0;34m' # blue
CYAN='\e[0;36m' # cyan
function corange {
	local STRING=${1}
	printf "${ORANGE}${STRING}${NC}"
}
function cgreen {
	local STRING=${1}
	printf "${GREEN}${STRING}${NC}"
}
function ccyan {
	local STRING=${1}
	printf "${CYAN}${STRING}${NC}"
}

## check if ipxe exists, and download
if [[ ! -d ${IPXEDIR} ]]; then
	printf "$(ccyan "IPXE not found, downloading now...")\n" 1>&2
	git clone https://github.com/ipxe/ipxe
	make -C ${IPXEDIR}
fi

FILE=$1
IPXE=$2
if [[ -n "${FILE}" ]]; then
	# setup custom ipxe flags
	cat <<-EOF > ${IPXEDIR}/config/local/general.h
		#define DOWNLOAD_PROTO_HTTPS
		#define PARAM_CMD
		#define CONSOLE_CMD
		#define IMAGE_PNG
		#define HTTP_HACK_GCE
	EOF
	## https://ipxe.org/console
	cat <<-EOF > ${IPXEDIR}/config/local/console.h
		#define CONSOLE_SERIAL CONSOLE_USAGE_ALL
		#define COMCONSOLE COM1
		#define COMSPEED 115200
		#define COMDATA 8
		#define COMPARITY 0
		#define COMSTOP 1
		#define LOG_LEVEL LOG_ALL
		#define PING_CMD
		#define NSLOOKUP_CMD
	EOF
	#define	CONSOLE_FRAMEBUFFER

	# build iso
	MAKECMD="make -C ${IPXEDIR} bin/ipxe.iso"
	if [[ -n "${IPXE}" ]]; then
		MAKECMD+=" EMBED=${MYDIR}/${IPXE}"
	fi
	echo "${MAKECMD}"
	eval "${MAKECMD}"
	mv ${IPXEDIR}/bin/ipxe.iso ${MYDIR}/${FILE}
	printf "File: $(ccyan "${FILE}") created\n" 1>&2
else
	printf "[$(corange "ERROR")]: Usage: $(cgreen "make.iso.sh") $(ccyan "<output.file> [ <ipxe.script> ]")\n" 1>&2
fi
