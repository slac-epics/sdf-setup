#
# For S3DF Testing of Development Network only.
# No other "facilities" or variations are supported yet.
#

#
# Unset some of the old unused variables to avoid environment mixing
#
unset PACKAGE_TOP
unset PACKAGE_SITE_TOP
unset TOOLS
unset CONFIG_SITE_TOP
unset TOOLS_SITE_TOP
unset SETUP_SITE_TOP
unset TOOLS_DATA

#
# New variables: EPICS_PACKAGE_TOP, EPICS_TOOLS, EPICS_TOOLS_DATA
# Retained for backwards compatibility: PACKAGE_SITE_TOP, PACKAGE_TOP
#
export FACILITY_ROOT=/sdf/sw
    export COMMON=$FACILITY_ROOT
    export LCLS_ROOT=$FACILITY_ROOT
    export EPICS_TOP=$FACILITY_ROOT/epics
        export EPICS_SITE_TOP=$EPICS_TOP
        export EPICS_PACKAGE_TOP=$EPICS_TOP/package
            export RTEMS=$EPICS_PACKAGE_TOP/rtems
        export PACKAGE_SITE_TOP=$EPICS_PACKAGE_TOP
        export PACKAGE_TOP=$EPICS_PACKAGE_TOP
export FACILITY_GROUP=/sdf/group/cds
    export TFTPBOOT=$FACILITY_GROUP/dev/tftpboot
    export GIT_SITE_TOP=$FACILITY_GROUP/git/repos
    export CONFIG_SITE_TOP=$FACILITY_GROUP/sw/epics/config
    export EPICS_APPS=$FACILITY_GROUP/sw/epics
        export EPICS_IOCS=$EPICS_APPS/iocCommon
	export EPICS_IOC_SCREEN=$EPICS_IOCS
        export EPICS_CPUS=$EPICS_APPS/cpuCommon
        export EPICS_IOC_TOP=$EPICS_APPS/iocTop
        export EPICS_CONFIG=$EPICS_APPS/config
        export EPICS_SETUP=$EPICS_APPS/setup
        export EPICS_TOOLS=$EPICS_APPS/tools
            export GW_SITE_TOP=$EPICS_TOOLS/gateway
            export ALHTOP=$EPICS_TOOLS/AlarmConfigsTop
export FACILITY_DATA=/sdf/data
    export LCLS_DATA=$FACILITY_DATA
        export IOC_DATA=$FACILITY_DATA/cds/dev/ioc
        export EPICS_TOOLS_DATA=$FACILITY_DATA/cds/dev/tools

#
# EPICS Version Specific
#
if [[ "$(basename "${BASH_SOURCE[0]}")" == *"7.0.8.1"* ]]; then
    export BASE_MODULE_VERSION=7.0.8.1-1.0
elif [[ "$(basename "${BASH_SOURCE[0]}")" == *"7.0-devel"* ]]; then
    export BASE_MODULE_VERSION=7.0-devel
else
    export BASE_MODULE_VERSION=7.0.3.1-1.0
fi
        export EPICS_BASE_VER=${BASE_MODULE_VERSION}
        export EPICS_MODULES_VER=${BASE_MODULE_VERSION}
        export EPICS_BASE=${EPICS_TOP}/base/${BASE_MODULE_VERSION}
                export EPICS_BASE_RELEASE=${EPICS_BASE}
                export EPICS_HOST_ARCH=$(${EPICS_BASE}/startup/EpicsHostArch)
                        export PYEPICS_LIBCA=${EPICS_BASE}/lib/${EPICS_HOST_ARCH}/libca.so
                        export PYEPICS_LIBCOM=${EPICS_BASE}/lib/${EPICS_HOST_ARCH}/libCom.so
        export EPICS_MODULES=${EPICS_TOP}/modules/${BASE_MODULE_VERSION}
                export EPICS_MODULES_TOP=${EPICS_MODULES}
                        export EPICS_MBA_TEMPLATE_TOP=$EPICS_MODULES_TOP/icdTemplates/icdTemplates-R1-2-2
export EPICS_EXTENSIONS=${EPICS_TOP}/extensions/R1.4.1

#
# The "facility" is not represented in the filesystem.
#
export FACILITY=dev
export IOCCONSOLE_ENV=Dev

#
# Network
#
export EPICS_PVA_SERVER_PORT=5075
export EPICS_PVA_BROADCAST_PORT=5076
export EPICS_PVA_AUTO_ADDR_LIST=NO
export EPICS_CA_AUTO_ADDR_LIST=NO
export EPICS_CA_REPEATER_PORT="5067"
export EPICS_CA_SERVER_PORT="5066"
export EPICS_TS_NTP_INET="134.79.18.40"
export EPICS_IOC_LOG_INET="134.79.219.136"

export EPICS_CA_CONN_TMO;                   EPICS_CA_CONN_TMO="30.0"
export EPICS_CA_BEACON_PERIOD;         EPICS_CA_BEACON_PERIOD="15.0"
export EPICS_TS_MIN_WEST;                   EPICS_TS_MIN_WEST="480"
export EPICS_IOC_LOG_PORT;                 EPICS_IOC_LOG_PORT="7004"
export EPICS_IOC_LOG_FILE_LIMIT;     EPICS_IOC_LOG_FILE_LIMIT="1000000"
export EPICS_IOC_LOG_FILE_COMMAND; EPICS_IOC_LOG_FILE_COMMAND=""
export EPICS_CMD_PROTO_PORT;             EPICS_CMD_PROTO_PORT=""
export EPICS_AR_PORT;                           EPICS_AR_PORT="7002"
export EPICS_CA_MAX_ARRAY_BYTES="80000000"

#
# Archiver
# URL and firefox launcher for the Archiver Appliance Management web U/I
# Recommend firefox version 43 or newer or google-chrome version 44 or newer
#
export FACET_ARCHIVER_URL=http://facet-archapp:17665/mgmt/ui/index.html
export LCLS_ARCHIVER_URL=http://lcls-archapp01:17665/mgmt/ui/index.html
export TESTFAC_ARCHIVER_URL=http://testfac-archappp:17665/mgmt/ui/index.html

alias FacetArchiver="firefox --no-remote $FACET_ARCHIVER_URL 2>1 > /dev/null&"
alias LCLSArchiver="firefox --no-remote $LCLS_ARCHIVER_URL 2>1 > /dev/null&"
alias TestFacArchiver="firefox --no-remote $TESTFAC_ARCHIVER_URL 2>1 > /dev/null&"

#
# Additional support variables
#
export MATLAB_PACKAGE_TOP=${EPICS_PACKAGE_TOP}/matlab

#
# Add 'newlist' command to manage lists like PATH, EPICS_CA_ADDR_LIST, etc.
#
if [[ ! $(declare -f -F newlist) ]];
then
        if [ -r $EPICS_SETUP/newlist.sh ];
        then
                source $EPICS_SETUP/newlist.sh
        else
                printf "Cannot find '%s' script for path management.\n" "$EPICS_SETUP/newlist.sh"
                exit 1
        fi
fi

#
# 'newlist' creates functions, see
# top of newlist.sh for details.
#
newlist path PATH
newlist lib  LD_LIBRARY_PATH
newlist ca   EPICS_CA_ADDR_LIST -s' ' -e
newlist pva  EPICS_PVA_ADDR_LIST -s' ' -e
newlist py   PYTHONPATH -e

#
# Network
#
addca  134.79.219.255
addca  172.26.97.63
addpva 134.79.219.255
addpva 255.255.255.255

#
# Executables
#
inspath $EPICS_TOOLS/bin
inspath -q $EPICS_TOOLS/script
inspath ${EPICS_BASE}/bin/${EPICS_HOST_ARCH}
addpath -q $EPICS_TOOLS/edm/script
addpath -q $ALHTOP/SCRIPT
addpath -q /usr/X11R6/bin
addpath ${EPICS_EXTENSIONS}/bin/${EPICS_HOST_ARCH}
#addpath -q ${PVACCESSCPP}/bin/${EPICS_HOST_ARCH}

#
# Libraries
#
addlib  ${EPICS_BASE}/lib/${EPICS_HOST_ARCH}
addlib  ${EPICS_EXTENSIONS}/lib/${EPICS_HOST_ARCH}
#addlib  ${PACKAGE_TOP}/IPMC/lib64

#
# Python
#
addpy  ${PVAPY}/lib/python/2.7/${EPICS_HOST_ARCH}


