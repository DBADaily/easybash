#!/usr/bin/env bash
################################################################################
#
# Author: Alvin
# License: MIT
# GitHub: https://github.com/dbadaily/easybash
#
# Test date
################################################################################

VERSION_STR="1.0.0"

current_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

lib_dir="$(dirname "${current_dir}")"

source "${lib_dir}/lib/easybash.sh"

add_main_options() {
  ## custom options
  # add your options here
  add_options "s:" "start-date:" "START_DATE" "N" "start date"
  add_options "e:" "end-date:" "END_DATE" "N" "end date"
  add_options "M:" "month:" "MONTH_NUM" "N" "days of some month"
  add_options "d:" "days:" "DAYS_NUM" "N" "days since start date"

  ## common options
  # 1. options like m: or emails: can be changed
  # 2. variable names like RECIPIENTS are NOT expected to be changed as they are used in libraries
  add_options "m:" "email:" "RECIPIENTS" "N" "emails(separated by space) to receive notifications"
  add_options "S" "success-notification" "SUCCESS_NOTIFICATION_IND" "N" "indication whether to send success notifications"
  add_options "C" "check" "CHECK_MODE" "N" "don't make any changes"
  add_options "G" "generate-config" "GEN_CONFIG" "N" "generate config file if not exists"
  add_options "w" "write-values" "WRITE_VALUES" "N" "used together with -G, write values provided by command options to config file"
  add_options "H" "help" "HELP" "N" "show this help"
  add_options "V" "version" "VERSION" "N" "output version information"
  add_options "v" "verbose" "VERBOSE" "N" "verbose mode"
}

main() {
  add_main_options
  parse_args "$@"

  local lv_dates=""
  set_dates_by_args

  log_trace "calling get_dates with parameters START_DATE and END_DATE"
  lv_dates="$(get_dates "${START_DATE}" "${END_DATE}")"
  print_dates "${lv_dates}"

  log_trace "calling get_dates_by_args without parameters"
  lv_dates="$(get_dates_by_args)"
  print_dates "${lv_dates}"

  log_trace "calling loop_dates with parameter START_DATE and END_DATE"
  loop_dates "${START_DATE}" "${END_DATE}"
}

main "$@"
