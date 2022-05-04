#!/usr/bin/env bash
################################################################################
#
# Author: Alvin
# License: MIT
# GitHub: https://github.com/dbadaily/easybash
#
# date library
################################################################################

set_dates() {
  local lv_start_date="$1"
  local lv_end_date="$2"
  local lv_flag=0
  START_DATE=$(date -d "${lv_start_date}" "${DATE_FORMAT_D}")
  lv_flag="$?"
  if [[ "${lv_flag}" -ne 0 ]]; then
    log_fatal "invalid date: ${lv_start_date}"
  fi
  END_DATE=$(date -d "${lv_end_date}" "${DATE_FORMAT_D}")
  lv_flag="$?"
  if [[ "${lv_flag}" -ne 0 ]]; then
    log_fatal "invalid date: ${lv_end_date}"
  fi
}

set_dates_by_days() {
  local lv_start_date="$1"
  local lv_end_date=""
  local ln_days="$2"
  local lv_flag=0
  lv_start_date="$(date -d "${lv_start_date}" "${DATE_FORMAT_D}")"
  lv_flag="$?"
  if [[ "${lv_flag}" -ne 0 ]]; then
    log_fatal "invalid date: ${lv_start_date}"
  fi
  lv_end_date="$(date -d "${lv_start_date} + $((ln_days - 1)) days" "${DATE_FORMAT_D}")"
  START_DATE="${lv_start_date}"
  END_DATE="${lv_end_date}"
}

set_dates_by_month() {
  local lv_month="$1"
  local lv_start_date=""
  local lv_end_date=""
  local lv_flag=0
  lv_start_date="$(date -d "${lv_month}01" "${DATE_FORMAT_D}")"
  lv_flag="$?"
  if [[ "${lv_flag}" -ne 0 ]]; then
    log_fatal "invalid month: ${lv_month}. Example: 202201"
  fi
  lv_end_date="$(date -d "${lv_start_date} + 1 month - 1 days" "${DATE_FORMAT_D}")"
  START_DATE="${lv_start_date}"
  END_DATE="${lv_end_date}"
}

get_dates() {
  local lv_start_date="$1"
  local lv_end_date="$2"
  local la_dates=()
  local old_IFS="$IFS"
  IFS=' '
  while [[ "${lv_start_date}" -le "${lv_end_date}" ]]; do
    #log_info "lv_start_date=${lv_start_date}"
    la_dates+=("${lv_start_date}")
    lv_start_date="$(date -d "${lv_start_date} + 1 days" +'%Y%m%d')"
  done
  echo "${la_dates[*]:-""}"
  IFS="${old_IFS}"
}

set_dates_by_args() {
  local lv_start_date=""
  local lv_end_date=""
  if [[ -n "${START_DATE}" && -n "${END_DATE}" ]]; then
    set_dates "${START_DATE}" "${END_DATE}"
  elif [[ -n "${START_DATE}" && -n "${DAYS_NUM:-""}" ]]; then
    set_dates_by_days "${START_DATE}" "${DAYS_NUM}"
  elif [[ -n "${MONTH_NUM:-""}" ]]; then
    set_dates_by_month "${MONTH_NUM}"
  fi

  lv_start_date="${START_DATE}"
  lv_end_date="${END_DATE}"

  if [[ -z "${lv_start_date}" || -z "${lv_end_date}" ]]; then
    log_fatal "Please specify date parameters correctly."
  fi
}

get_dates_by_args() {
  local lv_start_date=""
  local lv_end_date=""
  #set_dates_by_args &>/dev/null
  lv_start_date="${START_DATE}"
  lv_end_date="${END_DATE}"
  if [[ -n "${lv_start_date}" && -n "${lv_end_date}" ]]; then
    get_dates "${lv_start_date}" "${lv_end_date}"
  fi
}

print_dates() {
  local lv_dates="$1"
  local lv_date=""
  local old_IFS="${IFS}"
  IFS=' '
  for lv_date in ${lv_dates}; do
    log_info "lv_date=${lv_date}"
  done
  IFS="${old_IFS}"
}

loop_dates() {
  local lv_start_date="$1"
  local lv_end_date="$2"
  while [[ "${lv_start_date}" -le "${lv_end_date}" ]]; do
    log_info "lv_start_date=${lv_start_date}"
    lv_start_date=$(date -d "${lv_start_date} + 1 days" +'%Y%m%d')
  done
}
