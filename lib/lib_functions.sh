#!/usr/bin/env bash
################################################################################
#
# Author: Alvin
# License: MIT
# GitHub: https://github.com/dbadaily/easybash
#
# function library
################################################################################

replace() {
  local lv_str="$1"
  local lv_str_from="$2"
  local lv_str_to="$3"
  local lv_result="$(sed "s/"${lv_str_from}"/"${lv_str_to}"/g" <<<"${lv_str}")"
  echo "${lv_result}"
}

get_string_from_arr() {
  local lv_sepa_char="$1"
  shift
  local la_arr=("$@")
  local lv_res=''
  local lv_sepa=''
  local lv_value=''
  for lv_value in "${la_arr[@]}"; do
    lv_res="${lv_res}${lv_sepa}${lv_value}"
    lv_sepa="${lv_sepa_char}"
  done
  echo "${lv_res}"
}
