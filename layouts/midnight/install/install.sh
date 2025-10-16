#!/usr/bin/env bash

#set -x
set -e

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
LAYOUT_FILE=${SCRIPT_DIR}/../xkb
MAP_FILE=${SCRIPT_DIR}/../map
SUDOERS_CONFIG=${SCRIPT_DIR}/loadkeys-all
AUTO_LOAD_KEYS=${SCRIPT_DIR}/config.fish
XSLT_FILE=${SCRIPT_DIR}/xml.xslt
XKB_DIR=/usr/share/X11/xkb
SYMBOLS_DIR=${XKB_DIR}/symbols
RULES_DIR=${XKB_DIR}/rules
BASE_XML=${RULES_DIR}/base.xml
EVDEV_XML=${RULES_DIR}/evdev.xml

add_layout_to_registry() {
    # Backup the system's xkb files if we haven't already, just in case
    if ! test -f ${BASE_XML}.bak; then
        echo "Backing up base.xml file"
        install --mode 644 ${BASE_XML} ${BASE_XML}.bak
    fi
    if ! test -f ${EVDEV_XML}.bak; then
        echo "Backing up evdev.xml file"
        install --mode 644 ${EVDEV_XML} ${EVDEV_XML}.bak
    fi

    # Add the layout to base.xml and store the result in a temporary file
    TMP_FILE=$(mktemp -q /tmp/base.XXXXXX)
    pushd ${RULES_DIR} >/dev/null
    xsltproc --nodtdattr -o ${TMP_FILE} ${XSLT_FILE} base.xml
    if ! [ "$?" == "0" ]; then
        echo "Failed to update the xkb registry";
        popd
        exit 1
    fi
    popd >/dev/null

    # Now copy it over the top of the system's xkb base file
    install --mode 644 ${TMP_FILE} ${BASE_XML}
    rm ${TMP_FILE}
    echo "Updated xkb registry (base)"
    if ! grep -q "midnight        us: English (Mid-Night)" /usr/share/X11/xkb/rules/base.lst; then
        sed -i '/^! variant/a \  midnight        us: English (Mid-Night)' /usr/share/X11/xkb/rules/base.lst
    fi

    # Add the layout to evdev.xml and store the result in a temporary file
    TMP_FILE=$(mktemp -q /tmp/evdev.XXXXXX)
    pushd ${RULES_DIR} >/dev/null
    xsltproc --nodtdattr -o ${TMP_FILE} ${XSLT_FILE} evdev.xml
    if ! [ "$?" == "0" ]; then
        echo "Failed to update the xkb registry";
        popd
        exit 1
    fi
    popd >/dev/null

    # Now copy it over the top of the system's xkb evdev file
    install --mode 644 ${TMP_FILE} ${EVDEV_XML}
    rm ${TMP_FILE}
    echo "Updated xkb registry (evdev)"
    if ! grep -q "midnight        us: English (Mid-Night)" /usr/share/X11/xkb/rules/evdev.lst; then
        sed -i '/^! variant/a \  midnight        us: English (Mid-Night)' /usr/share/X11/xkb/rules/evdev.lst
    fi
}

add_layout_symbols() {
    if ! grep -q "//---MIDNIGHT BEGIN---" "${SYMBOLS_DIR}/us"; then
        # Append the layout to the end of the 'us' symbols file
        #echo "Appending contents of ${LAYOUT_FILE} to ${SYMBOLS_DIR}/us"
        echo "//---MIDNIGHT BEGIN---" >> ${SYMBOLS_DIR}/us
        cat ${LAYOUT_FILE} >> ${SYMBOLS_DIR}/us
        echo "//---MIDNIGHT END---" >> ${SYMBOLS_DIR}/us
        echo "Added Mid-Night as US layout variant"
    fi
}

load_on_vconsole() {
    read -p "Do you want to automatically load the keymap on console boot? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        return 0
    fi

	mkdir -p /etc/fish/conf.d/
	mv ${AUTO_LOAD_KEYS} /etc/fish/conf.d/midnight-vconsole.fish
}

add_map_virtual_console() {
	mv ${MAP_FILE} /usr/share/kbd/keymaps/midnight.map
	mv ${SUDOERS_CONFIG} /etc/sudoers.d/
	load_on_vconsole
}

install_layout() {
    add_layout_symbols
    add_layout_to_registry
    add_map_virtual_console
}

uninstall_layout() {
	if grep -q "//---MIDNIGHT BEGIN---" "${SYMBOLS_DIR}/us"; then
		sed -i '/^\/\/---MIDNIGHT BEGIN---/,/^\/\/---MIDNIGHT END---/d' "${SYMBOLS_DIR}/us"
	fi
	if grep -q "MIDNIGHT BEGIN" "${BASE_XML}"; then
		sed -i '/MIDNIGHT BEGIN/,/MIDNIGHT END/d' "${BASE_XML}"
	fi
	if grep -q "MIDNIGHT BEGIN" "${EVDEV_XML}"; then
		sed -i '/MIDNIGHT BEGIN/,/MIDNIGHT END/d' "${EVDEV_XML}"
	fi
	if grep -q "midnight        us: English (Mid-Night)" /usr/share/X11/xkb/rules/base.lst; then
		sed -i '/midnight        us: English (Mid-Night)/d' /usr/share/X11/xkb/rules/base.lst
	fi
	if grep -q "midnight        us: English (Mid-Night)" /usr/share/X11/xkb/rules/evdev.lst; then
		sed -i '/midnight        us: English (Mid-Night)/d' /usr/share/X11/xkb/rules/evdev.lst
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
        ;;    *)
		echo "error: unknown argument \"$1\""
        usage
        ;;
esac


echo ""
