#!/usr/bin/env bash
################################################################################
#
# Author: Alvin
# License: MIT
# GitHub: https://github.com/dbadaily/easybash
#
# echo dates
################################################################################

VERSION_STR="1.0.0"

current_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

lib_dir="$(dirname "${current_dir}")"

source "${lib_dir}/lib/easybash.sh"

add_main_options() {
  ## custom options
  # add your options here
  add_options "s:" "start-date:" "START_DATE" "Y" "start date"
  add_options "e:" "end-date:" "END_DATE" "Y" "end date"

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

# custom function
echo_dates() {
  local lv_start_date="$1"
  local lv_end_date="$2"
  #local lv_msg="Work between ${lv_start_date} and ${lv_end_date} is done."
  while [[ "${lv_start_date}" -le "${lv_end_date}" ]]; do
    echo_blue_bold "Processing for date ${lv_start_date}"
    log_trace "Work for date ${lv_start_date} done."
    lv_start_date=$(date -d "${lv_start_date} + 1 days" +'%Y%m%d')
  done
  #send_msg "${lv_msg}"
}

main() {
  add_main_options
  parse_args "$@"

  # add your logic here
  if [[ "$CHECK_MODE" != "Y" ]]; then
    echo_dates "${START_DATE}" "${END_DATE}"
  elif [[ "$CHECK_MODE" == "Y" ]]; then
    log_warning "CHECK MODE. Skip echoing dates."
  fi
}

main "$@"
