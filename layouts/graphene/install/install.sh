#!/usr/bin/env bash

#set -x
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
LAYOUT_FILE=${SCRIPT_DIR}/../xkb
XSLT_FILE=${SCRIPT_DIR}/xml.xslt
XKB_DIR=/usr/share/X11/xkb
SYMBOLS_DIR=${XKB_DIR}/symbols
RULES_DIR=${XKB_DIR}/rules
EVDEV_XML=${RULES_DIR}/base.xml

add_layout_to_registry() {
    # Backup the system's xkb base.xml file if we haven't already, just in case
    if ! test -f ${EVDEV_XML}.bak; then
        echo "Backing up base.xml file"
        cp ${EVDEV_XML} ${EVDEV_XML}.bak
    fi

    # Add the layout to base.xml and store the result in /tmp/base.xml
    TMP_FILE=$(mktemp -q /tmp/base.XXXXXX)
    #echo "Modifying xkb base.xml file and storing temporarily at ${TMP_FILE}"
    pushd ${RULES_DIR} >/dev/null
    xsltproc --nodtdattr -o ${TMP_FILE} ${XSLT_FILE} base.xml
    if ! [ "$?" == "0" ]; then
        echo "Failed to update the xkb registry";
        popd
        exit 1
    fi
    popd >/dev/null

    # Now copy it over the top of the system's xkb base file
    cp ${TMP_FILE} ${EVDEV_XML}
    rm ${TMP_FILE}
    echo "Updated xkb registry"
    if ! grep -q "graphene        us: English (Graphene)" /usr/share/X11/xkb/rules/base.lst; then
        sed -i '/^! variant/a \  graphene        us: English (Graphene)' /usr/share/X11/xkb/rules/base.lst
    fi
}


add_layout_symbols() {
    if ! grep -q "//---GRAPHENE BEGIN---" "${SYMBOLS_DIR}/us"; then
        # Append the layout to the end of the 'us' symbols file
        #echo "Appending contents of ${LAYOUT_FILE} to ${SYMBOLS_DIR}/us"
        echo "//---GRAPHENE BEGIN---" >> ${SYMBOLS_DIR}/us
        cat ${LAYOUT_FILE} >> ${SYMBOLS_DIR}/us
        echo "//---GRAPHENE END---" >> ${SYMBOLS_DIR}/us
        echo "Added Graphene as US layout variant"
    fi
}

install_layout() {
    add_layout_symbols
    add_layout_to_registry
}

uninstall_layout() {
	if grep -q "//---GRAPHENE BEGIN---" "${SYMBOLS_DIR}/us"; then
		sed -i '/^\/\/---GRAPHENE BEGIN---/,/^\/\/---GRAPHENE END---/d' "${SYMBOLS_DIR}/us"
	fi
	if grep -q "GRAPHENE BEGIN" "${EVDEV_XML}"; then
		sed -i '/GRAPHENE BEGIN/,/GRAPHENE END/d' "${EVDEV_XML}"
	fi
	if grep -q "graphene        us: English (Graphene)" /usr/share/X11/xkb/rules/base.lst; then
		sed -i '/graphene        us: English (Graphene)/d' /usr/share/X11/xkb/rules/base.lst
	fi
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


usage() {
    echo "Usage: $0 [install|uninstall]"
    exit 1
}

verify_tools_available
verify_user_is_root

case "${1:-install}" in
    install)
        uninstall_layout
        install_layout
        ;;
    uninstall)
        uninstall_layout
        ;; 
    *)
		echo "error: unknown argument \"$1\""
        usage
        ;;
esac



echo ""
