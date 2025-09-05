#!/usr/bin/env bash

#set -x
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
LAYOUT_FILE=${SCRIPT_DIR}/../xkb
XSLT_FILE=${SCRIPT_DIR}/xml.xslt
XKB_DIR=/usr/share/X11/xkb
SYMBOLS_DIR=${XKB_DIR}/symbols
RULES_DIR=${XKB_DIR}/rules
EVDEV_XML=${RULES_DIR}/evdev.xml

add_layout_to_registry() {
    # Backup the system's xkb evdev.xml file if we haven't already, just in case
    if ! test -f ${EVDEV_XML}.bak; then
        echo "Backing up evdev.xml file"
        cp ${EVDEV_XML} ${EVDEV_XML}.bak
    fi

    # Add the layout to evdev.xml and store the result in /tmp/evdev.xml
    TMP_FILE=$(mktemp -q /tmp/evdev.XXXXXX)
    #echo "Modifying xkb evdev.xml file and storing temporarily at ${TMP_FILE}"
    pushd ${RULES_DIR} >/dev/null
    xsltproc --nodtdattr -o ${TMP_FILE} ${XSLT_FILE} evdev.xml
    if ! [ "$?" == "0" ]; then
        echo "Failed to update the xkb registry";
        popd
        exit 1
    fi
    popd >/dev/null

    # Now copy it over the top of the system's xkb evdev file
    cp ${TMP_FILE} ${EVDEV_XML}
    rm ${TMP_FILE}
    echo "Updated xkb registry"
}

add_layout_symbols() {
    # Append the layout to the end of the 'us' symbols file
    #echo "Appending contents of ${LAYOUT_FILE} to ${SYMBOLS_DIR}/us"
    echo "//---MIDNIGHT BEGIN---" >> ${SYMBOLS_DIR}/us
    cat ${LAYOUT_FILE} >> ${SYMBOLS_DIR}/us
    echo "//---MIDNIGHT END---" >> ${SYMBOLS_DIR}/us
    echo "Added Mid-Night as US layout variant"
}

install_layout() {
    add_layout_symbols
    add_layout_to_registry
}

uninstall_layout() {
	sed -i '/^\/\/---MIDNIGHT BEGIN---/,/^\/\/---MIDNIGHT END---/d' ${SYMBOLS_DIR}/us
	sed -i '/MIDNIGHT BEGIN/,/MIDNIGHT END/d' ${EVDEV_XML}
}

verify_user_is_root() {
    if [ ! "${EUID:-$(id -u)}" -eq 0 ]; then
        echo "This script must be run as root"
        exit 1
    fi
}

verify_tools_available() {
    if ! command -v xsltproc >/dev/null 2>&1; then
        echo "This script requires that xsltproc is available.  Please install it first."
        exit 1
    fi
}


verify_tools_available
verify_user_is_root
uninstall_layout
install_layout

echo ""
