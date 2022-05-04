#!/usr/bin/env bash
################################################################################
#
# Author: Alvin
# License: MIT
# GitHub: https://github.com/dbadaily/easybash
#
# Test color
################################################################################

VERSION_STR="1.0.0"

current_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

lib_dir="$(dirname "${current_dir}")"

source "${lib_dir}/lib/easybash.sh"

add_main_options() {
  ## custom options
  # add your options here

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

  # add your options here
  log_info "LOG_FILE: $LOG_FILE"
  echo_red "echo_red"
  echo_red_bold "echo_red_bold"
  echo_green "echo_green"
  echo_green_bold "echo_green_bold"
  echo_yellow "echo_yellow"
  echo_yellow_bold "echo_yellow_bold"
  echo_blue "echo_blue"
  echo_blue_bold "echo_blue_bold"
  echo_magenta "echo_magenta"
  echo_magenta_bold "echo_magenta_bold"
  echo_cyan "echo_cyan"
  echo_cyan_bold "echo_cyan_bold"
  echo_white "echo_white"
  echo_white_bold "echo_white_bold"

  #log_info "LOG_FILE: $LOG_FILE"
  echo_blue "echo_blue: foreground - blue, no background." "" "bold"
  echo_blue "echo_blue: foreground - blue, background: yellow." "yellow" "bold"
  #log_info "LOG_FILE: $LOG_FILE"
  echo_color "echo_color: foreground - green, no background." "green" "" "bold"
  echo_color "echo_color: foreground - green, background - red." "green" "red" "bold"
  #log_info "LOG_FILE: $LOG_FILE"
  echo_color_by_num "echo_color_by_num: foreground - red, no background." "1" "" "bold"
  echo_color_by_num "echo_color_by_num: foreground - red, background - blue." "1" "4" "bold"

  set_color "green"
  echo "set_color: foreground - green, no background."
  echo "You can echo lines as usual."
  echo "So that you can easilly set color for existing echos."
  echo "Or set the same color for mulitple lines."
  echo "reset_color"
  reset_color
  log_info "LOG_FILE: $LOG_FILE"
  set_color "green" "" "bold"
  echo "set_color foreground - green bold, no background."
  echo "You can echo lines as usual."
  echo "So that you can easilly set color for existing echos."
  echo "Or set the same color for mulitple lines."
  echo "reset_color"
  reset_color
  log_info "LOG_FILE: $LOG_FILE"
  set_color "green" "red"
  echo "set_color foreground - green, background - red."
  echo "You can echo lines as usual."
  echo "So that you can easilly set color for existing echos."
  echo "Or set the same color for mulitple lines."
  echo "reset_color"
  reset_color
  #log_info "LOG_FILE: $LOG_FILE"
  #exit 1
  echo "This line is not expected to be colored."
  echo "Better way with two empty lines:"
  set_color "green" "red"
  echo ""
  echo "set_color foreground - green, background - red."
  echo "You can echo lines as usual."
  echo "So that you can easilly set color for existing echos."
  echo "Or set the same color for mulitple lines."
  echo "reset_color"
  reset_color
  #log_info "LOG_FILE: $LOG_FILE"
  echo ""
  echo "Better but not convenient:"
  set_color "green" "red"
  echo "set_color foreground - green, background - red.${COLOR_RESET}"
  reset_color
  set_color "green" "red"
  echo "You can echo lines as usual.${COLOR_RESET}"
  set_color "green" "red"
  echo "So that you can easilly set color for existing echos.${COLOR_RESET}"
  set_color "green" "red"
  echo "Or set the same color for mulitple lines.${COLOR_RESET}"
  set_color "green" "red"
  echo "reset_color${COLOR_RESET}"
  reset_color
  log_info "LOG_FILE: $LOG_FILE"
  echo "Best used in loop:"
  declare -a la_str
  la_str+=("set_color foreground - green, background - red.")
  la_str+=("You can echo lines as usual.")
  la_str+=("So that you can easilly set color for existing echos.")
  la_str+=("Or set the same color for mulitple lines.")
  la_str+=("reset_color")
  for str_value in "${la_str[@]}"; do
    set_color "green" "red"
    echo "${str_value}${COLOR_RESET}"
  done

}

main "$@"
