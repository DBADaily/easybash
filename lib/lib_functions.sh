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
  pv_sepa="$1"
  shift
  pa_arr=("$@")
  res=''
  lv_sepa=''
  for v in "${pa_arr[@]}"; do
    res="${res}${lv_sepa}${v}"
    lv_sepa="${pv_sepa}"
  done
  echo "${res}"
}
