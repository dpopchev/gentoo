#!/usr/bin/env bash

ACPI_LOG=/var/log/acpid.log

log() {
    local status=$1; shift
    local message="ACPI event $status: $*"
    logger $message
    echo $message >> $ACPI_LOG
}

log_handled() {
    log "handled" "$*"
}

log_unhandled() {
    log "unhandled" "$*"
}
