#!/usr/bin/env bash
################################################################################
#
# Author: Alvin
# License: MIT
# GitHub: https://github.com/dbadaily/easybash
#
# color library
################################################################################

echo_color_by_num() {
  local lv_msg="$1"
  local ln_foreground="${2:-""}"
  local ln_background="${3:-""}"
  local lv_effect="${4:-""}"
  local lv_format=""

  if [[ -n "${ln_foreground}" ]]; then
    lv_format="${lv_format}$(tput setaf ${ln_foreground})"
  fi
  if [[ -n "${ln_background}" ]]; then
    lv_format="${lv_format}$(tput setab ${ln_background})"
  fi
  if [[ -n "${lv_effect}" ]]; then
    lv_format="${lv_format}$(tput ${lv_effect})"
  fi
  echo "${lv_format}${lv_msg}$(tput sgr0)"
}

echo_color() {
  local lv_msg="$1"
  local lv_foreground="${2:-""}"
  local lv_background="${3:-""}"
  local lv_effect="${4:-""}"

  declare -A lA_colors=(["black"]="0" ["red"]="1" ["green"]="2" ["yellow"]="3" ["blue"]="4" ["magenta"]="5" ["cyan"]="6" ["white"]="7")

  local ln_foreground=
  local ln_background=
  if [[ -n "${lv_foreground}" ]]; then
    ln_foreground="${lA_colors[${lv_foreground}]}"
  fi
  if [[ -n "${lv_background}" ]]; then
    ln_background="${lA_colors[${lv_background}]}"
  fi
  echo_color_by_num "${lv_msg}" "${ln_foreground}" "${ln_background}" "$lv_effect"
}

echo_black() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "black" "${2:-""}" "${3:-""}"
}

echo_black_bold() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "black" "${2:-""}" "bold"
}

echo_red() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "red" "${2:-""}" "${3:-""}"
}

echo_red_bold() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "red" "${2:-""}" "bold"
}

echo_green() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "green" "${2:-""}" "${3:-""}"
}

echo_green_bold() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "green" "${2:-""}" "bold"
}

echo_yellow() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "yellow" "${2:-""}" "${3:-""}"
}

echo_yellow_bold() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "yellow" "${2:-""}" "bold"
}

echo_blue() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "blue" "${2:-""}" "${3:-""}"
}

echo_blue_bold() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "blue" "${2:-""}" "bold"
}

echo_magenta() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "magenta" "${2:-""}" "${3:-""}"
}

echo_magenta_bold() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "magenta" "${2:-""}" "bold"
}

echo_cyan() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "cyan" "${2:-""}" "${3:-""}"
}

echo_cyan_bold() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "cyan" "${2:-""}" "bold"
}

echo_white() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "white" "${2:-""}" "${3:-""}"
}

echo_white_bold() {
  local lv_msg="$1"
  echo_color "${lv_msg}" "white" "${2:-""}" "bold"
}

# set color separatedly
set_fg_color_by_num() {
  local ln_foreground="$1"
  echo -n "$(tput setaf ${ln_foreground})"
}

set_fg_color() {
  local lv_foreground="$1"
  declare -A lA_colors=(["black"]="0" ["red"]="1" ["green"]="2" ["yellow"]="3" ["blue"]="4" ["magenta"]="5" ["cyan"]="6" ["white"]="7")
  echo -n "$(tput setaf "${lA_colors[${lv_foreground}]}")"
}

set_bg_color_by_num() {
  local ln_background="$1"
  echo -n "$(tput setab "${ln_background}")"
}

set_bg_color() {
  local lv_background="$1"
  declare -A lA_colors=(["black"]="0" ["red"]="1" ["green"]="2" ["yellow"]="3" ["blue"]="4" ["magenta"]="5" ["cyan"]="6" ["white"]="7")
  echo -n "$(tput setab "${lA_colors[${lv_background}]}")"
}

set_color_style() {
  local lv_effect="$1"
  echo -n "$(tput "${lv_effect}")"
}

set_color_by_num() {
  local ln_foreground="${1:-""}"
  local ln_background="${2:-""}"
  local lv_effect="${3:-""}"
  set_fg_color_by_num "${ln_foreground}"

  if [[ -n "${ln_background}" ]]; then
    set_bg_color_by_num "${ln_background}"
  fi

  if [[ -n "${lv_effect}" ]]; then
    set_color_style "${lv_effect}"
  fi
}

set_color() {
  local lv_foreground="${1:-""}"
  local lv_background="${2:-""}"
  local lv_effect="${3:-""}"
  set_fg_color "${lv_foreground}"

  if [[ -n "${lv_background}" ]]; then
    set_bg_color "${lv_background}"
  fi

  if [[ -n "${lv_effect}" ]]; then
    set_color_style "${lv_effect}"
  fi
}

reset_color() {
  echo -n "$(tput sgr0)"
}
