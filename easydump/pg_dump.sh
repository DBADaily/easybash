#!/usr/bin/env bash
################################################################################
#
# Author: Alvin
# License: MIT
# GitHub: https://github.com/dbadaily/easybash
#
# PostgreSQL pg_dump utils
################################################################################

VERSION_STR="1.0.0"

current_dir="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

lib_dir="$(dirname "${current_dir}")"

source "${lib_dir}/lib/easybash.sh"

add_main_options() {
  ## custom options
  # source db
  add_options "h:" "host:" "DBHOST" "Y" "source database server host or socket directory"
  add_options "p:" "port:" "DBPORT" "Y" "source database server port number"
  add_options "U:" "username:" "DBUSER" "Y" "source database user name"
  add_options "W:" "password:" "PGPASSWORD" "Y" "source database user password"
  add_options "d:" "dbname:" "DBNAME" "N" "source database name to connect to"

  # target db
  add_options "P:" "target-port:" "DBPORT_TARGET" "Y" "target database server port number"
  add_options "B:" "bin-dir:" "PGBIN" "Y" "PostgreSQL bin directory"

  # dump modes
  add_options "M:" "mode:" "DUMP_MODE" "Y" "dump modes: ALL USERS DBS DB TABLE"
  # ALL mode
  add_options "s" "schema-only" "SCHEMA_ONLY" "N" "SCHEMA mode: dump only the schema, no data"
  # ALL or DBS mode
  add_options "D:" "databases:" "DATABASES" "N" "ALL mode: databases(separated by space) to dump"
  # DB or TABLE mode
  add_options "T:" "tables:" "DBTABLES" "N" "tables(separated by space) to dump. DB mode: dump tables in parallel; TABLE mode: tables to dump"
  # DB mode
  add_options "E:" "excludetables:" "DBTABLES_EXCLUDE" "N" "tables to exclude"

  # other options
  add_options "u" "users" "DUMP_ALL_USERS" "N" "dump all users regardless of dump mode"
  add_options "L" "parallel" "PARALLEL_IND" "N" "parallel indicator"
  add_options "t:" "sleep-time:" "SLEEP_TIME" "N" "time to sleep between dumps"

  ### common options
  ## 1. options like m: or emails: can be changed
  ## 2. variable names like RECIPIENTS are NOT expected to be changed as they are used in shared functions
  add_options "m:" "email:" "RECIPIENTS" "N" "emails(separated by space) to receive notifications"
  add_options "S" "success-notification" "SUCCESS_NOTIFICATION_IND" "N" "indication whether to send success notifications"
  add_options "C" "check" "CHECK_MODE" "N" "don't make any changes"
  add_options "G" "generate-config" "GEN_CONFIG" "N" "generate config file if not exists"
  add_options "w" "write-values" "WRITE_VALUES" "N" "used together with -G, write values provided by command options to config file"
  add_options "H" "help" "HELP" "N" "show this help"
  add_options "V" "version" "VERSION" "N" "output version information"
  add_options "v" "verbose" "VERBOSE" "N" "verbose mode"
}

sleep_time() {
  local ln_sleep="${SLEEP_TIME:-3}"
  #log_info "sleeping for ${ln_sleep} seconds..."
  sleep "${ln_sleep}"
}

send_dump_status() {
  local lv_dump_log="$1"
  local lv_restore_log="$2"
  local lv_msg="$3"
  shift 3
  local la_flag=("$@")

  local ln_flag=0
  local ln_dump_status="${la_flag[0]}"
  local ln_restore_status=0
  local lv_error_log="${LOG_FILE_PREFIX}_errors.log"
  local lv_error_msg=""
  if [[ "${#la_flag[@]}" -gt 1 ]]; then
    ln_restore_status="${la_flag[1]}"
  fi

  if [[ "${ln_dump_status}" -ne 0 && "${ln_restore_status}" -eq 0 ]]; then
    log_warning "Dump failed. Please check errors in log file: ${lv_dump_log}"
    ln_flag="${ln_dump_status}"
    grep -i -E 'error:|fatal:|warning:' "${lv_dump_log}" | tee -a "${lv_error_log}"
    if [[ ! -s "${lv_error_log}" ]]; then
      head -3 "${lv_dump_log}" | tee -a "${lv_error_log}"
    fi
    lv_error_msg="${lv_msg}:$(cat "${lv_error_log}")"
  fi

  if [[ "${ln_restore_status}" -ne 0 ]]; then
    log_warning "Restore failed. Please check errors in log file: ${lv_restore_log}"
    ln_flag="${ln_restore_status}"
    grep -i -E 'error:|fatal:|warning:' "${lv_restore_log}" | tee "${lv_error_log}"
    if [[ ! -s "${lv_error_log}" ]]; then
      head -3 "${lv_restore_log}" | tee -a "${lv_error_log}"
    fi
    lv_error_msg="${lv_msg}:$(cat "${lv_error_log}")"
  fi
  if [[ "${ln_flag}" -ne 0 ]]; then
    log_debug "lv_error_log: ${lv_error_log}"
    lv_msg="${lv_msg}: ${lv_error_msg}"
  fi
  send_notification "${ln_flag}" "${lv_msg}"
}

dump_schema_file() {
  local lv_case="$1"
  local lv_dump_log="$2"
  local lv_schema_file="$3"
  "${PGBIN}"/pg_dumpall -v -U "${DBUSER}" -h "${DBHOST}" -p "${DBPORT}" -s 2>>"${lv_dump_log}" 1>"${lv_schema_file}"
  send_dump_status "${lv_dump_log}" "" "${lv_case}" "$?"
}

dump_all_schema() {
  local lv_case="$1"
  local lv_dump_log="$2"
  local lv_restore_log="$3"
  time "${PGBIN}"/pg_dumpall -v -U "${DBUSER}" -h "${DBHOST}" -p "${DBPORT}" -s 2>>"${lv_dump_log}" | "${PGBIN}"/psql -U postgres -p "${DBPORT_TARGET}" -e &>>"${lv_restore_log}"
  send_dump_status "${lv_dump_log}" "${lv_restore_log}" "${lv_case}" "${PIPESTATUS[@]}"
}

dump_all_schema_and_data() {
  local lv_case="$1"
  local lv_dump_log="$2"
  local lv_restore_log="$3"
  time "${PGBIN}"/pg_dumpall -v -U "${DBUSER}" -h "${DBHOST}" -p "${DBPORT}" 2>>"${lv_dump_log}" | "${PGBIN}"/psql -U postgres -p "${DBPORT_TARGET}" -e &>>"${lv_restore_log}"
  send_dump_status "${lv_dump_log}" "${lv_restore_log}" "${lv_case}" "${PIPESTATUS[@]}"
}

dump_users() {
  local lv_case="$1"
  local lv_dump_log="$2"
  local lv_restore_log="$3"
  # use -g or -r here
  time "${PGBIN}"/pg_dumpall -v -U "${DBUSER}" -h "${DBHOST}" -p "${DBPORT}" -g 2>>"${lv_dump_log}" | "${PGBIN}"/psql -U postgres -p "${DBPORT_TARGET}" -e &>>"${lv_restore_log}"
  send_dump_status "${lv_dump_log}" "${lv_restore_log}" "${lv_case}. Users dumped." "${PIPESTATUS[@]}"
}

dump_database() {
  local lv_case="$1"
  local lv_dump_log="$2"
  local lv_restore_log="$3"
  local lv_dbname="$4"
  time "${PGBIN}"/pg_dump -v -U "${DBUSER}" -h "${DBHOST}" -p "${DBPORT}" -d "${lv_dbname}" 2>>"${lv_dump_log}" | "${PGBIN}"/psql -U postgres -p "${DBPORT_TARGET}" -d "${lv_dbname}" -e &>>"${lv_restore_log}"
  send_dump_status "${lv_dump_log}" "${lv_restore_log}" "${lv_case}. Database ${lv_dbname} dump finished." "${PIPESTATUS[@]}"
}

dump_database_with_exclusion() {
  local lv_case="$1"
  local lv_dump_log="$2"
  local lv_restore_log="$3"
  local lv_dbname="$4"
  local lv_tables_exp="$5"
  time "${PGBIN}"/pg_dump -v -U "${DBUSER}" -h "${DBHOST}" -p "${DBPORT}" -d "${lv_dbname}" -T "${lv_tables_exp}" 2>>"${lv_dump_log}" | "${PGBIN}"/psql -U postgres -p "${DBPORT_TARGET}" -d "${lv_dbname}" -e &>>"${lv_restore_log}"
  send_dump_status "${lv_dump_log}" "${lv_restore_log}" "${lv_case}. Database ${lv_dbname} dump with exclusion finished." "${PIPESTATUS[@]}"
}

dump_table() {
  local lv_case="$1"
  local lv_dump_log="$2"
  local lv_restore_log="$3"
  local lv_table_name="$4"
  time "${PGBIN}"/pg_dump -v -U "${DBUSER}" -h "${DBHOST}" -p "${DBPORT}" -d "${DBNAME}" -t "${lv_table_name}" 2>>"${lv_dump_log}" | "${PGBIN}"/psql -U postgres -p "${DBPORT_TARGET}" -d "${DBNAME}" -e &>>"${lv_restore_log}"
  send_dump_status "${lv_dump_log}" "${lv_restore_log}" "${lv_case}. Table ${lv_table_name} dump finished." "${PIPESTATUS[@]}"
}

main() {
  add_main_options
  parse_args "$@"

  local lv_dump_log="${LOG_FILE_PREFIX}_dumpall.log"
  local lv_restore_log="${LOG_FILE_PREFIX}_restore.log"
  local ln_flag=0
  local lv_schemas=()
  local lv_tabs=()
  local lv_schema_name=""
  local lv_tab_name=""
  local lv_schema_exp=""
  local lv_table_exp=""
  local lv_tables_exp=""
  local lv_case=""
  local lv_dump_all_users_ind='N'
  local lv_exclude_ind="N"
  local lv_table_mode_ind="N"
  local lv_check_dbs="N"
  local lv_loop_dbs="N"
  local lv_loop_tables="N"
  local lv_dumpall_ind="N"
  local lv_schema_only_ind="N"

  local lv_dbtables="${DBTABLES:-""}"
  local lv_dbtables_exclude="${DBTABLES_EXCLUDE:-""}"
  local lv_parallel_ind="${PARALLEL_IND:-""}"
  local lv_databases="${DATABASES:-""}"

  local lv_tables="${lv_dbtables} ${lv_dbtables_exclude}"

  log_info "DUMP_MODE=${DUMP_MODE} PARALLEL_IND=${lv_parallel_ind} DATABASES=${lv_databases} DBTABLES=${lv_dbtables}"

  if [[ "${DUMP_MODE}" == "ALL" ]]; then
    if [[ "${lv_parallel_ind}" != "Y" && -z "${lv_databases}" ]]; then
      if [[ "${SCHEMA_ONLY}" == "Y" ]]; then
        lv_case="${DUMP_MODE} case 1 - Dump all schema only"
        lv_schema_only_ind="Y"
      else
        lv_case="${DUMP_MODE} case 2 - Dump all schema and data"
      fi
      lv_dumpall_ind="Y"
      lv_check_dbs="N"
      lv_loop_dbs="N"
    elif [[ "${lv_parallel_ind}" != "Y" && -n "${lv_databases}" ]]; then
      lv_case="${DUMP_MODE} case 3 - Dump specified databases"
      lv_dump_all_users_ind="Y"
      lv_check_dbs="N"
      lv_loop_dbs="Y"
    elif [[ "${lv_parallel_ind}" == "Y" && -z "${lv_databases}" ]]; then
      lv_case="${DUMP_MODE} case 4 - Dump all databases in parallel"
      lv_dump_all_users_ind="Y"
      lv_check_dbs="Y"
      lv_loop_dbs="Y"
    elif [[ "${lv_parallel_ind}" == "Y" && -n "${lv_databases}" ]]; then
      lv_case="${DUMP_MODE} case 5 - Dump specified databases in parallel"
      lv_dump_all_users_ind="Y"
      lv_check_dbs="N"
      lv_loop_dbs="Y"
    else
      lv_case="not usefull case"
    fi
  elif [[ "${DUMP_MODE}" == "USERS" ]]; then
    lv_case="${DUMP_MODE} case 1 - Dump roles only"
    lv_dump_all_users_ind="Y"
  elif [[ "${DUMP_MODE}" == "DBS" ]]; then
    lv_loop_dbs="Y"
    if [[ "${lv_parallel_ind}" != "Y" && -z "${lv_databases}" ]]; then
      lv_case="${DUMP_MODE} case 1 - Dump all databases"
      lv_check_dbs="Y"
    elif [[ "${lv_parallel_ind}" != "Y" && -n "${lv_databases}" ]]; then
      lv_check_dbs="N"
      lv_case="${DUMP_MODE} case 2 - Dump specified databases"
    elif [[ "${lv_parallel_ind}" == "Y" && -z "${lv_databases}" ]]; then
      lv_case="${DUMP_MODE} case 3 - Dump all databases in parallel"
      lv_check_dbs="Y"
    elif [[ "${lv_parallel_ind}" == "Y" && -n "${lv_databases}" ]]; then
      lv_case="${DUMP_MODE} case 4 - Dump specified databases in parallel"
      lv_check_dbs="N"
    else
      lv_case="not usefull case"
    fi
  elif [[ "${DUMP_MODE}" == "DB" ]]; then
    lv_loop_dbs="Y"
    lv_databases="${DBNAME}"
    local lv_case_str="Dump all tables"
    local ln_case_num=0
    if [[ -z "${DBNAME}" ]]; then
      log_fatal "DBNAME should NOT be empty in ${DUMP_MODE} mode."
    fi
    if [[ -n "${lv_dbtables_exclude}" ]]; then
      lv_exclude_ind="Y"
      lv_case_str="${lv_case_str} with exclusion"
      ln_case_num=1
    fi
    if [[ "${lv_parallel_ind}" != "Y" && -z "${lv_dbtables}" ]]; then
      ln_case_num=$((ln_case_num + 1))
      lv_case="${DUMP_MODE} case ${ln_case_num} - ${lv_case_str}"
    elif [[ "${lv_parallel_ind}" != "Y" && -n "${lv_dbtables}" ]]; then
      ln_case_num=$((ln_case_num + 3))
      lv_case="${DUMP_MODE} case ${ln_case_num}. Forbidden"
      log_fatal "In ${DUMP_MODE} mode, -T or --tables is only intended to be used together with -L or --parallel."
    elif [[ "${lv_parallel_ind}" == "Y" && -z "${lv_dbtables}" ]]; then
      ln_case_num=$((ln_case_num + 5))
      lv_case="${DUMP_MODE} case ${ln_case_num}. Forbidden"
      log_fatal "In ${DUMP_MODE} mode, -T or --tables is only intended to be used together with -L or --parallel."
    elif [[ "${lv_parallel_ind}" == "Y" && -n "${lv_dbtables}" ]]; then
      ln_case_num=$((ln_case_num + 7))
      lv_case="${DUMP_MODE} case ${ln_case_num} - ${lv_case_str}, specified tables are dumped in parallel"
      lv_exclude_ind="Y"
      lv_loop_tables="Y"
    else
      lv_case="not usefull case"
    fi
  elif [[ "${DUMP_MODE}" == "TABLE" ]]; then
    lv_table_mode_ind="Y"
    lv_loop_tables="Y"
    if [[ -z "${lv_dbtables}" ]]; then
      log_fatal "DBTABLES should NOT be empty in ${DUMP_MODE} mode."
    fi
    if [[ "${lv_parallel_ind}" != "Y" ]]; then
      lv_case="${DUMP_MODE} case 1 - Dump specified tables one by one"
    elif [[ "${lv_parallel_ind}" == "Y" ]]; then
      lv_case="${DUMP_MODE} case 2 - Dump specified tables in parallel"
    else
      lv_case="not usefull case"
    fi
  fi

  if [[ "${DUMP_ALL_USERS}" == "Y" && "${lv_dump_all_users_ind}" != "Y" ]]; then
    lv_dump_all_users_ind="Y"
  fi

  log_trace "lv_case='${lv_case}'"

  local lv_table_name=""
  if [[ "${lv_exclude_ind}" == "Y" || "${lv_table_mode_ind}" == "Y" ]]; then
    log_debug "lv_tables=${lv_tables}"

    for lv_table_name in $lv_tables; do
      lv_tab_name=${lv_table_name##*.}
      if [[ ${#lv_table_name} != ${#lv_tab_name} ]]; then
        lv_schema_name=${lv_table_name%.*}
      else
        lv_schema_name="public"
      fi
      if [[ "${#lv_schemas[@]}" -eq 0 ]]; then
        lv_schemas+=("${lv_schema_name}")
      elif [[ ! "${lv_schemas[*]}" =~ (^|[[:space:]])"${lv_schema_name}"($|[[:space:]]) ]]; then
        lv_schemas+=("${lv_schema_name}")
      fi
      if [[ "${#lv_tabs[@]}" -eq 0 ]]; then
        lv_tabs+=("${lv_tab_name}")
      elif [[ ! "${lv_tabs[*]}" =~ (^|[[:space:]])"${lv_tab_name}"($|[[:space:]]) ]]; then
        lv_tabs+=("${lv_tab_name}")
      fi
    done
    lv_schema_exp=$(get_string_from_arr '|' "${lv_schemas[@]}")
    lv_table_exp=$(get_string_from_arr '|' "${lv_tabs[@]}")
    lv_tables_exp="${lv_schema_exp}.${lv_table_exp}"

    log_debug "lv_tables_exp=${lv_tables_exp}"
    log_info "Matching tables:"
    "${PGBIN}"/psql -U "${DBUSER}" -h "${DBHOST}" -p "${DBPORT}" -d "${DBNAME}" -c "\dt+ ${lv_tables_exp}" | tee -a "${LOG_FILE}"
    verify_return_code "${PIPESTATUS[0]}" "Check database ${DBNAME} for matching tables"
  fi

  local lv_schema_file="${LOG_DIR}/dumpall_schema_${DBHOST}_${DBPORT}.sql"
  log_info "lv_dump_log: ${lv_dump_log}"
  log_info "lv_restore_log: ${lv_restore_log}"
  if [[ ! -f "${lv_schema_file}" ]] || [[ -f "${lv_schema_file}" && ! -s "${lv_schema_file}" ]]; then
    dump_schema_file "${lv_case}" "${lv_dump_log}" "${lv_schema_file}"
    log_info "lv_schema_file: ${lv_schema_file}"
  else
    log_info "schema file exists: ${lv_schema_file}"
  fi
  if [[ "${lv_dumpall_ind}" == "Y" && "${CHECK_MODE}" != "Y" ]]; then
    if [[ "${lv_schema_only_ind}" != "Y" ]]; then
      log_info "All shema and data is being dumped. pid = $$"
      dump_all_schema_and_data "${lv_case}" "${lv_dump_log}" "${lv_restore_log}"
    elif [[ "${lv_schema_only_ind}" == "Y" ]]; then
      log_info "All shema is being dumped. pid = $$"
      dump_all_schema "${lv_case}" "${lv_dump_log}" "${lv_restore_log}"
    fi
    exit 0
  elif [[ "${lv_dumpall_ind}" == "Y" && "${CHECK_MODE}" == "Y" ]]; then
    log_info "CHECK MODE. Skip dumping all databases or schema."
  fi

  if [[ "${lv_dump_all_users_ind}" == "Y" && "${CHECK_MODE}" != "Y" ]]; then
    dump_users "${lv_case}" "${lv_dump_log}" "${lv_restore_log}"
  elif [[ "${lv_dump_all_users_ind}" == "Y" && "${CHECK_MODE}" == "Y" ]]; then
    log_info "CHECK MODE. Skip dumping users."
  fi

  if [[ -z "${lv_databases}" && "${lv_check_dbs}" == "Y" ]]; then
    lv_databases=$("${PGBIN}"/psql -U "${DBUSER}" -d postgres -h "${DBHOST}" -p "${DBPORT}" -qtAX -c "SELECT datname FROM pg_database WHERE datname NOT IN ('template0','template1') ORDER BY datname")
    verify_return_code "$?" "Check databases to be dumped"
    log_info "DATABASES to be dumped: ${lv_databases}"
  fi
  if [[ "${lv_loop_dbs}" == "Y" && "${CHECK_MODE}" != "Y" ]]; then
    local lv_db_create_sql=""
    local lv_dbname=""
    for lv_dbname in ${lv_databases}; do
      lv_db_create_sql="${LOG_FILE_PREFIX}_create_${lv_dbname}.sql"
      grep "DATABASE ${lv_dbname}" "${lv_schema_file}" >"${lv_db_create_sql}"
      ln_flag="$?"
      if [[ "${lv_dbname}" != "postgres" ]]; then
        verify_return_code "${ln_flag}" "Database ${lv_dbname} does not exist"
        log_info "Database ${lv_dbname} CREATE sql file: ${lv_db_create_sql}"
      fi
      lv_dump_log="${LOG_FILE_PREFIX}_dump_${lv_dbname}.log"
      lv_restore_log="${LOG_FILE_PREFIX}_restore_${lv_dbname}.log"
      log_info "lv_dump_log: ${lv_dump_log}"
      log_info "lv_restore_log: ${lv_restore_log}"

      "${PGBIN}"/psql -U postgres -p "${DBPORT_TARGET}" -f "${lv_db_create_sql}" &>>"${LOG_FILE}"
      verify_return_code "$?" "Create database ${lv_dbname}"
      log_info "Database ${lv_dbname} created"

      if [[ "${lv_exclude_ind}" != "Y" ]]; then
        if [[ "${lv_parallel_ind}" != "Y" ]]; then
          log_info "Database ${lv_dbname} is being dumped. pid = $$"
          dump_database "${lv_case}" "${lv_dump_log}" "${lv_restore_log}" "${lv_dbname}"
        elif [[ "${lv_parallel_ind}" == "Y" ]]; then
          dump_database "${lv_case}" "${lv_dump_log}" "${lv_restore_log}" "${lv_dbname}" &
          log_info "Database ${lv_dbname} is being dumped in parallel. pid = $!"
        fi
      elif [[ "${lv_exclude_ind}" == "Y" ]]; then
        if [[ "${lv_parallel_ind}" != "Y" ]]; then
          log_info "Database ${lv_dbname} is being dumped. pid = $$"
          dump_database_with_exclusion "${lv_case}" "${lv_dump_log}" "${lv_restore_log}" "${lv_dbname}" "${lv_tables_exp}"
        elif [[ "${lv_parallel_ind}" == "Y" ]]; then
          dump_database_with_exclusion "${lv_case}" "${lv_dump_log}" "${lv_restore_log}" "${lv_dbname}" "${lv_tables_exp}" &
          log_info "Database ${lv_dbname} is being dumped in parallel. pid = $!"
        fi
      fi
      sleep_time
    done
  elif [[ "${lv_loop_dbs}" == "Y" && "${CHECK_MODE}" == "Y" ]]; then
    log_info "CHECK MODE. Skip dumping databases."
  fi
  if [[ "${lv_loop_tables}" == "Y" && "${CHECK_MODE}" != "Y" ]]; then
    for lv_table_name in ${lv_dbtables}; do
      lv_dump_log="${LOG_FILE_PREFIX}_dump_${lv_table_name}.log"
      lv_restore_log="${LOG_FILE_PREFIX}_restore_${lv_table_name}.log"
      log_info "lv_dump_log: ${lv_dump_log}"
      log_info "lv_restore_log: ${lv_restore_log}"

      if [[ "${lv_parallel_ind}" != "Y" ]]; then
        log_info "Table ${lv_table_name} is being dumped. pid = $$"
        dump_table "${lv_case}" "${lv_dump_log}" "${lv_restore_log}" "${lv_table_name}"
      elif [[ "${lv_parallel_ind}" == "Y" ]]; then
        dump_table "${lv_case}" "${lv_dump_log}" "${lv_restore_log}" "${lv_table_name}" &
        log_info "Table ${lv_table_name} is being dumped in parallel. pid = $!"
      fi
      sleep_time
    done
  elif [[ "${lv_loop_tables}" == "Y" && "${CHECK_MODE}" == "Y" ]]; then
    log_info "CHECK MODE. Skip dumping tables."
  fi
}

main "$@"
