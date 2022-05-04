get_log_level() {
  local lv_log_level=""
  if [[ -z "${LOG_LEVEL}" ]]; then
    lv_log_level="INFO"
  else
    lv_log_level="${LOG_LEVEL}"
  fi
  echo "${lv_log_level}"
}

get_log_level_num() {
  local lv_level="$1"
  local ln_log_level_num=3
  case "${lv_level}" in
    TRACE)
      ln_log_level_num=0
      ;;
    DEBUG)
      ln_log_level_num=1
      ;;
    INFO)
      ln_log_level_num=3
      ;;
    WARNING)
      ln_log_level_num=7
      ;;
    ERROR)
      ln_log_level_num=15
      ;;
    FATAL)
      ln_log_level_num=31
      ;;
  esac
  echo "${ln_log_level_num}"
}

reset_log_level() {
  CUR_FUNC="${FUNCNAME[0]}"
  if [[ -n "${VERBOSE:-""}" && "${VERBOSE:-""}" == "Y" && "${LOG_LEVEL}" != "TRACE" ]]; then
    LOG_LEVEL="TRACE"
    log_trace "reset LOG_LEVEL to ${LOG_LEVEL}"
  fi
  CUR_FUNC=
}

log_msg() {
  local lv_level="$1"
  local lv_msg="$2"
  local lv_color="$3"
  local lv_style="${4:-""}"
  local ln_log_level_num_default="$(get_log_level_num "$(get_log_level)")"
  local ln_log_level_num="$(get_log_level_num "${lv_level}")"
  local lv_cur_func=""
  local lv_time_str="$(date "${TIME_FORMAT_3}")"
  if [[ -n "${CUR_FUNC}" ]]; then
    lv_cur_func=" [${CUR_FUNC}]"
  fi
  if [[ -z "${lv_color}" ]]; then
    lv_color="${DEFAULT_COLOR}"
  fi
  local lv_msg_new="[$lv_time_str ${lv_level}]${lv_cur_func} ${lv_msg}"
  echo "${lv_msg_new}" >>"${LOG_FILE}"
  if [[ "${ln_log_level_num}" -ge "${ln_log_level_num_default}" ]]; then
    eval "echo_${lv_color} \"${lv_msg_new}\" '' \"$lv_style\""
  fi
}

log_trace() {
  local lv_msg="$1"
  log_msg "TRACE" "${lv_msg}" "${COLOR_TRACE}" #"bold"
}

log_debug() {
  local lv_msg="$1"
  log_msg "DEBUG" "${lv_msg}" "${COLOR_DEBUG}" #"bold"
}

log_info() {
  local lv_msg="$1"
  log_msg "INFO" "${lv_msg}" "${COLOR_INFO}"
}

log_warning() {
  local lv_msg="$1"
  log_msg "WARNING" "${lv_msg}" "${COLOR_WARN}" #"bold"
}

log_error() {
  local lv_msg="$1"
  log_msg "ERROR" "${lv_msg}" "${COLOR_ERROR}"
  if [[ "${ON_ERROR_STOP}" == "Y" ]]; then
    log_trace "ON_ERROR_STOP=${ON_ERROR_STOP}"
    exit 1
  fi
}

log_fatal() {
  local lv_msg="$1"
  log_msg "FATAL" "${lv_msg}" "${COLOR_FATAL}" "bold"
  exit 1
}
