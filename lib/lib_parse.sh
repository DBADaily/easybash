#!/usr/bin/env bash
################################################################################
#
# Author: Alvin
# License: MIT
# GitHub: https://github.com/dbadaily/easybash
#
# parse library
################################################################################

add_option() {
  local lv_str_src="$1"
  local lv_str_add="$2"
  local lv_sepa="${SEPA_CHAR}"
  if [[ -z "${lv_str_src}" ]]; then
    lv_sepa=""
  fi
  echo "${lv_str_src}${lv_sepa}${lv_str_add}"
}

add_options() {
  local lv_short="$1"
  local lv_long="$2"
  local lv_var="$3"
  local lv_required_ind="$4"
  local lv_comment="$5"
  OPTIONS_SHORT_STR="$(add_option "$OPTIONS_SHORT_STR" "$lv_short")"
  OPTIONS_LONG_STR="$(add_option "$OPTIONS_LONG_STR" "$lv_long")"
  OPTIONS_VARS_STR="$(add_option "$OPTIONS_VARS_STR" "$lv_var")"
  OPTIONS_VARS_IND_STR="$(add_option "$OPTIONS_VARS_IND_STR" "$lv_required_ind")"
  OPTIONS_COMMENT_STR="$(add_option "$OPTIONS_COMMENT_STR" "$lv_comment")"
}

test_getopt() {
  local ln_flag=$(
    getopt -T &>/dev/null
    echo $?
  )
  if [[ ! "$ln_flag" -eq 4 ]]; then
    log_fatal "getopt on this host does NOT work. See 'man getopt' option '-T' for details."
  fi
}

parse_args() {
  test_getopt

  CUR_FUNC="${FUNCNAME[0]}"
  local la_arr=("$@")
  local lv_options_short="$(replace "$OPTIONS_SHORT_STR" "|" "")"
  local lv_options_long="$(replace "$OPTIONS_LONG_STR" "|" ",")"

  local lv_short="$(replace "$OPTIONS_SHORT_STR" ":" "")"
  local lv_long="$(replace "$OPTIONS_LONG_STR" ":" "")"
  local lv_vars="${OPTIONS_VARS_STR}"
  local lv_ind="${OPTIONS_VARS_IND_STR}"
  local lv_comment="${OPTIONS_COMMENT_STR}"
  local ln_return=0
  declare -A local lA_short
  declare -A local lA_long
  declare -A local lA_vars
  declare -A local lA_values
  declare -A local lA_ind
  declare -A local lA_comment
  declare -A local lA_optional
  lA_optional["Y"]="Required"
  lA_optional["N"]="Optional"

  log_trace "lv_options_short: ${lv_options_short}"
  log_trace "lv_options_long: ${lv_options_long}"

  local OLDIFS="${IFS}"

  IFS="${SEPA_CHAR}"

  local la_options_short=(${OPTIONS_SHORT_STR})
  local la_short=(${lv_short})
  local la_long=(${lv_long})
  local la_vars=(${lv_vars})
  local la_ind=(${lv_ind})
  local la_comment=(${lv_comment})

  for ((i = 0; i < "${#la_short[@]}"; i++)); do
    lA_short["${la_short[$i]}"]="${la_options_short[$i]}"
    lA_long["${la_long[$i]}"]="${la_short[$i]}"
    lA_vars["${la_short[$i]}"]="${la_vars[$i]}"
    lA_ind["${la_short[$i]}"]="${la_ind[$i]}"
    lA_comment["${la_short[$i]}"]="${la_comment[$i]}"
  done

  #for item in "${!lA_short[@]}";
  #do
  #  printf "$item is ${lA_short[$item]} \n"
  #done

  #for item in "${!lA_vars[@]}";
  #do
  #  printf "$item is ${lA_vars[$item]} \n"
  #done

  #for item in "${!lA_long[@]}";
  #do
  #  printf "$item is ${lA_long[$item]} \n"
  #done

  IFS="${OLDIFS}"

  local lv_valid_args=""
  lv_valid_args="$(getopt -o "$lv_options_short" --long "$lv_options_long" -- "${la_arr[@]:-""}")"
  ln_return=$?
  log_trace "ln_return=${ln_return}"
  if [[ "${ln_return}" -ne 0 ]]; then
    log_error "getopt error"
    exit 1
  fi

  if [[ "${lv_valid_args}" =~ " -v" || "${lv_valid_args}" =~ " --verbose" ]] && [[ "${LOG_LEVEL}" != "TRACE" ]]; then
    #log_info "reset LOG_LEVEL from $LOG_LEVEL to TRACE"
    LOG_LEVEL="TRACE"
  fi
  log_trace "LOG_FILE: ${LOG_FILE}"

  log_trace "lv_valid_args: '${lv_valid_args}'"

  local lv_config_file="${SCRIPT_DIR}/${CONFIG_FILE}"
  if [[ -f "${lv_config_file}" ]]; then
    source "${lv_config_file}"
  fi

  eval set -- "${lv_valid_args}"
  local lv_option=""
  local lv_short_option=""
  local ln_option_length=0
  local lv_var=""
  while [[ : ]]; do
    case "$1" in
      --)
        shift
        break
        ;;
      *)
        lv_option="$1"
        if [[ "${#lv_option}" -gt 2 ]]; then
          lv_option="${lA_long["${lv_option:2}"]}"
        else
          lv_option="${lv_option:1}"
        fi
        lv_var="${lA_vars["${lv_option}"]}"

        #echo "Processing option. Input argument is '$1':'$2'"
        lv_short_option="${lv_option}"
        lv_option="${lA_short["${lv_option}"]}"
        ln_option_length="${#lv_option}"
        if [[ "${ln_option_length}" -eq 2 ]]; then
          eval "export ${lv_var}=\"$2\""
          lA_values["${lv_short_option}"]="$2"
          log_debug "${lv_var}=$2"
        elif [[ "${ln_option_length}" -eq 1 ]]; then
          eval export "${lv_var}"="Y"
          lA_values["${lv_short_option}"]="Y"
          log_debug "${lv_var}=Y"
        fi
        #eval echo "value: \$${lv_var}"
        shift "${ln_option_length}"
        ;;
    esac
  done

  if [[ -n "${VERSION:-""}" ]]; then
    echo "Version: ${VERSION_STR}"
    exit 0
  fi

  # help message
  if [[ -n "${HELP:-""}" ]]; then
    set_color "cyan"
    echo -e "Version: ${VERSION_STR}\n"
    echo "Usage:"
    echo -e "  bash ${SCRIPT_FULL_NAME} [OPTIONS]\n"
    local lv_value_pair=""
    echo "OPTIONS:"
    for ((i = 0; i < "${#la_short[@]}"; i++)); do
      #echo "index: $i, value: ${la_short[$i]}, ${la_options_short[$i]}, ${la_long[$i]}, ${la_vars[$i]}, ${la_ind[$i]}, ${la_comment[$i]}"
      if [[ "${#la_short[$i]}" -eq "${#la_options_short[$i]}" ]]; then
        lv_value_pair="${la_long[$i]}"
      else
        lv_value_pair="${la_long[$i]}=\"${la_vars[$i]}\""
      fi
      printf "  -%c, --%-39s%-9s%-50s\n" "${la_short[$i]}" "${lv_value_pair}" "${lA_optional[${la_ind[$i]}]}" "${la_comment[$i]}"
    done
    reset_color
    exit 0
  fi
  # generate config file
  if [[ -n "${GEN_CONFIG:-""}" && -n "${CONFIG_FILE:-""}" ]]; then
    local la_no_config_option=("HELP" "VERSION" "VERBOSE" "GEN_CONFIG" "WRITE_VALUES")
    local lv_config_file_bak=""
    if [[ -f "${lv_config_file}" ]]; then
      #log_fatal "config file already exists: $lv_config_file"
      lv_config_file_bak="${SCRIPT_DIR}/${CONFIG_FILE}_${TIME_STR}.bak"
      mv "${lv_config_file}" "${lv_config_file_bak}"
      log_warning "config file already exists, rename to ${lv_config_file_bak}"
    fi
    local lv_option_value=""
    local lv_write_hint=" with values"
    for ((i = 0; i < "${#la_short[@]}"; i++)); do
      if [[ ! ${la_no_config_option[*]} =~ (^|[[:space:]])"${la_vars[$i]}"($|[[:space:]]) ]]; then
        lv_option_value="${lA_values[${la_short[$i]}]:-""}"
        if [[ "${WRITE_VALUES:-""}" != "Y" ]]; then
          lv_option_value=""
          lv_write_hint=" with empty values"
        fi
        echo "# ${la_comment[$i]}" >>"${lv_config_file}"
        echo -e "${la_vars[$i]}=\"${lv_option_value}\"\n" >>"${lv_config_file}"
      fi
    done
    log_info "config file generated${lv_write_hint}: ${lv_config_file}"
    exit 0
  fi
  # check required parameters
  local lv_flag="N"
  for ((i = 0; i < "${#la_short[@]}"; i++)); do
    #log_trace "index: $i, value: ${la_short[$i]}, ${la_options_short[$i]}, ${la_long[$i]}, ${la_vars[$i]}, ${la_ind[$i]}, ${la_comment[$i]}"
    if [[ "${la_ind[$i]}" == "Y" && -z "$(eval echo "\$${la_vars[$i]}")" ]]; then
      lv_flag="Y"
      log_warning "${la_vars[$i]} is not set or empty. option -${la_short[$i]} ${la_vars[$i]} or --${la_long[$i]}=${la_vars[$i]} might be set."
    fi
  done
  if [[ "${lv_flag}" == "Y" ]]; then
    log_warning "set parameters via options(higher priority) or in config file(might be overwritten by options)"
    log_warning "config file: ${lv_config_file}"
    log_fatal "NOT ALL required parameters are given. Get help message by 'bash ${SCRIPT_FULL_NAME} -H' or 'bash ${SCRIPT_FULL_NAME} --help'"
  fi
  CUR_FUNC=
  #reset_log_level
}
