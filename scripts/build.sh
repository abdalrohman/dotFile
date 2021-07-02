#!/bin/bash
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

export LC_MESSAGES=C
export LANG=C

# Colors
disable_colors() {
    unset ALL_OFF BOLD BLUE GREEN RED YELLOW
}

enable_colors() {
    # prefer terminal safe colored and bold text when tput is supported
    if tput setaf 0 &>/dev/null; then
        CLR_RST="$(tput sgr0)"
        CLR_BLD="$(tput bold)"
        CLR_GRN="$(tput setaf 2)"
        CLR_MAG="$(tput setaf 5)"
        CLR_BLD_RED="${CLR_BLD}$(tput setaf 1)"
        CLR_BLD_GRN="${CLR_BLD}$(tput setaf 2)"
        CLR_BLD_YLW="${CLR_BLD}$(tput setaf 3)"
        CLR_BLD_MAG="${CLR_BLD}$(tput setaf 5)"
    else
        CLR_RST="\e[0m"
        CLR_BLD="\e[1m"
        CLR_GRN="\e[32m"
        CLR_BLD_RED="${CLR_BLD}\e[31m"
        CLR_BLD_GRN="${CLR_BLD}\e[32m"
        CLR_BLD_YLW="${CLR_BLD}\e[33m"
        CLR_BLD_MAG="${CLR_BLD}\e[35m"
    fi
    readonly ALL_OFF BOLD BLUE GREEN RED YELLOW
}

if [[ -t 2 ]]; then
    enable_colors
else
    disable_colors
fi

# Set functions
msg() {
    local mesg=$1
    shift
    printf "${CLR_BLD_MAG}${mesg}${CLR_RST}\n" "$@" >&2
}

msg2() {
    local val=$1
    local mesg=$2
    shift
    printf "${CLR_BLD_GRN}==> ${val}${CLR_RST}${CLR_BLD} ${mesg}\n" "$@" >&2
}

warning() {
    local mesg=$1
    shift
    printf "${CLR_BLD_YLW}[!]WARNING:${CLR_RST}${CLR_BLD} ${mesg}${CLR_RST}\n" "$@" >&2
}

success() {
    local mesg=$1
    shift
    printf "${CLR_BLD_GRN}[✔]SUCCESS:${CLR_RST}${CLR_BLD} ${mesg}${CLR_RST}\n" "$@" >&2
}

error() {
    local mesg=$1
    shift
    printf "${CLR_BLD_RED}[✘]ERROR:${CLR_RST}${CLR_BLD} ${mesg}${CLR_RST}\n" "$@" >&2
}

# variable
BUILD_TYPE="userdebug"

# Usage
showHelpAndExit() {
    echo -e "Usage: $(basename "$0") <device> [options]"
    echo -e "  -h  --help            Display this help message"
    echo -e "  -c  --clean           Wipe the tree before building"
    echo -e "  -s  --repo-sync       Sync before building"
    echo -e "  -r  --rome            Specify rom name"
    echo -e "  -t  --build-type      Specify build type default=${BUILD_TYPE}"
    echo -e "  -j  --jobs            Specify jobs/threads to use"
    echo -e "  -m  --module          Build a specific module"
    exit 1
}

# Setup getopt
getopt_cmd=$(getopt -a -o hcs:r:t:j:m: --long help,clean,repo-sync:,rom:,build-type:,jobs:,module: \
    -n "$(basename "$0")" -- "$@") ||
    {
        error "Getopt failed. Extra args"
        showHelpAndExit
        exit 1
    }

eval set -- "${getopt_cmd}"

while true; do
    case "${1}" in
    -h | --help) showHelpAndExit ;;
    -c | --clean) FLAG_CLEAN_BUILD=y ;;
    -s | --repo-sync) FLAG_SYNC=y ;;
    -r | --rome)
        ROM="${2}"
        shift
        ;;
    -t | --build-type)
        BUILD_TYPE="${2}"
        shift
        ;;
    -j | --jobs)
        JOBS="${2}"
        shift
        ;;
    -m | --module)
        MODULE="${2}"
        shift
        ;;
    --)
        shift
        break
        ;;
    esac
    shift
done

# Check device exist
if [ $# -eq 0 ]; then
    warning "No device specified"
fi
export DEVICE="${1}"
shift

# Make sure we are running on 64-bit
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
if [ "${ARCH}" != "64" ]; then
    error "unsupported arch (expected: 64, found: ${ARCH})"
    exit 1
fi

# Initializationizing
echo -e "${CLR_BLD_MAG}Setting up the environment${CLR_RST}"
. build/envsetup.sh &>/dev/null

# check and set ccache path on envsetup
if [ -z "${CCACHE_EXEC}" ]; then
    ccache_path=$(which ccache)
    if [ ! -z "$ccache_path" ]; then
        export USE_CCACHE=1
        export CCACHE_COMPRESS=1
        export CCACHE_EXEC="$ccache_path"
        msg2 "ccache:" "enabled and CCACHE_EXEC has been set to : $ccache_path"
    else
        error "ccache not found/installed!"
    fi
fi

# Set java options
export _JAVA_OPTIONS=-Xmx4096m
msg2 "java flag:" "_JAVA_OPTIONS has been set to : -Xmx4096m"
echo -e ""

# Use the thread count specified by user
CMD=""
if [ "${JOBS}" ]; then
    CMD+=" -j${JOBS}"
fi

# Pick the default thread count (allow overrides from the environment)
if [ -z "${JOBS}" ]; then
    if [ "$(uname -s)" = 'Darwin' ]; then
        JOBS=$(sysctl -n machdep.cpu.core_count)
    else
        JOBS=$(cat /proc/cpuinfo | grep '^processor' | wc -l)
    fi
fi

# Prep for a clean build, if requested so
if [ "${FLAG_CLEAN_BUILD}" = 'y' ]; then
    msg "Cleaning output files left from old builds"
    make clean"${CMD}" &>/dev/null
    if [[ $? != 0 ]]; then
        error "Make clean"
        exit 1
    else
        success "Clean completed successfully"
    fi
    echo -e ""
fi

# Sync up, if asked to
if [ "${FLAG_SYNC}" = 'y' ]; then
    msg "Downloading the latest source files"
    repo sync -j"${JOBS}" -c --no-clone-bundle --current-branch --no-tags
    if [ $? -ne 0 ]; then
        error "Sync faield"
        exit 1
    else
        success "Sync completed successfully"
    fi
    echo ""
fi

# Check the starting time (of the real build process)
TIME_START=$(date +%s.%N)

# Friendly logging to tell the user everything is working fine is always nice
msg "Building AOSP for ${DEVICE}${CLR_RST}"
msg2 "Start time:" "$(date +%H:%M:%S)  ($(date +%Y-%m-%d))"
echo -e ""

# Lunch-time!
if [[ "${ROM}" != "" ]] && [[ "${BUILD_TYPE}" != "" ]]; then
    msg "Lunching ${ROM}_${DEVICE}-${BUILD_TYPE} (Including dependencies sync)"
    lunch "${ROM}_${DEVICE}-${BUILD_TYPE}" &>/dev/null
    if [ $? -ne 0 ]; then
        error "Launching faield"
        exit 1
    else
        success "Launching completed successfully"
    fi
    echo -e ""
else
    error "Ensure you set -r and -t flag"
    showHelpAndExit
fi

# Build away!
if [ "${MODULE}" ]; then
    msg "Starting compilation"
    make "${MODULE}${CMD}"
    if [ $? -ne 0 ]; then
        error "Build faield"
        exit 1
    else
        success "Build completed successfully"
    fi
    echo -e ""
else
    error "Ensure you set -m flag"
    showHelpAndExit
fi

# Check the finishing time
TIME_END=$(date +%s.%N)

# Log those times at the end
msg "Total time elapsed: $(echo "(${TIME_END} - ${TIME_START}) / 60" | bc) minutes ($(echo "${TIME_END} - ${TIME_START}" | bc) seconds)"
echo -e ""

exit 0
