#!/usr/bin/env bash

source /etc/acpi/actions/_acpi_logger.sh

main() {
    local group=${1%%/*}
    local action=${1#*/}
    local device=$2
    local id=$3
    local value=$4

    case "$group" in
            *) log_unhandled $*;;
    esac
}

main $*
