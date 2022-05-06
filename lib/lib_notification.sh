#!/usr/bin/env bash
################################################################################
#
# Author: Alvin
# License: MIT
# GitHub: https://github.com/dbadaily/easybash
#
# notification library
################################################################################

send_email() {
  local lv_recipients="$1"
  local lv_subject="$2"
  local lv_body="${3:-""}"

  log_trace "${lv_subject}"
  if [[ -n "${lv_recipients}" ]]; then
    echo "${lv_body}" | mail -s "${lv_subject}" "${lv_recipients}"
  fi
}

send_msg() {
  local lv_subject="$1"
  local lv_body="${2:-""}"
  if [[ -z "${RECIPIENTS:-""}" ]]; then
    log_warning "RECIPIENTS is not set or empty. option -m RECIPIENTS or --email=RECIPIENTS might be set."
  else
    send_email "${RECIPIENTS}" "${lv_subject}" "${lv_body}"
  fi
}

send_notification() {
  if [[ -z "${RECIPIENTS:-""}" ]]; then
    log_warning "RECIPIENTS is not set or empty. option -m RECIPIENTS or --email=RECIPIENTS might be set."
  else
    local ln_flag=$1
    local lv_msg=$2
    local lv_include_succ_ind="${3:-""}"
    if [[ "${ln_flag}" -ne 0 ]]; then
      send_msg "[FAILURE] $(hostname): ${lv_msg}" "${ln_flag}"
      exit "${ln_flag}"
    elif [[ -z "${lv_include_succ_ind}" || "${lv_include_succ_ind}" != "N" ]]; then
      if [[ "${SUCCESS_NOTIFICATION_IND:-""}" == 'Y' ]]; then
        send_msg "[SUCCESS] $(hostname): ${lv_msg}" "${ln_flag}"
      fi
    fi
  fi
}

verify_return_code() {
  send_notification "$1" "$2" "N"
}
