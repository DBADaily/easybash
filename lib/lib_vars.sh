#!/usr/bin/env bash
################################################################################
#
# Author: Alvin
# License: MIT
# GitHub: https://github.com/dbadaily/easybash
#
# vars library
################################################################################

# config file name
export CONFIG_FILE="config.sh"

#date and time
#https://docs.oracle.com/cd/E41183_01/DR/Date_Format_Types.html
#D YYMMDD Year-Month-Day with no separators (20200101)
export DATE_FORMAT_D='+%Y%m%d'
#3 YY-MM-DD Year-Month-Day with leading zeros (2020-01-01)
export DATE_FORMAT_3='+%Y-%m-%d'
export TIME_FORMAT_3='+%Y-%m-%d %H:%M:%S'
export TIME_FORMAT_w='+%Y%m%d_%w_%H%M%S'
export MONTH_STR="$(date +%Y%m)"
export DATE_STR="$(date "${DATE_FORMAT_D}")"
export TIME_STR="$(date "${TIME_FORMAT_w}")"

# script
export SCRIPT_FULL_PATH="$(readlink -f "$0")"
export SCRIPT_DIR="$(dirname "${SCRIPT_FULL_PATH}")"
export SCRIPT_FULL_NAME="$(basename "$0")"
export SCRIPT_NAME="${SCRIPT_FULL_NAME%.*}"
export SCRIPT_EXTENSION="${SCRIPT_FULL_NAME##*.}"

## logging
# LOG LEVEL: TRACE DEBUG INFO WARN ERROR FATAL
export LOG_LEVEL="INFO"
export LOG_FILE_IND="Y"
export LOG_DIR="${SCRIPT_DIR}/logs/${MONTH_STR}/${DATE_STR}"
export LOG_FILE_PREFIX="${LOG_DIR}/${SCRIPT_NAME}_${TIME_STR}"
export LOG_FILE="${LOG_FILE_PREFIX}.log"
export ON_ERROR_STOP="N"

# parse
export SEPA_CHAR="|"
export OPTIONS_LONG_STR=
export OPTIONS_SHORT_STR=
export OPTIONS_VARS_STR=
export OPTIONS_VARS_IND_STR=
export OPTIONS_COMMENT_STR=
export VERSION_STR="${VERSION_STR:-""}"
export CHECK_MODE=
export CUR_FUNC=

# color
export DEFAULT_COLOR=white
export DEFAULT_COLOR_STYLE=bold
export COLOR_TRACE="green"
export COLOR_DEBUG="cyan"
export COLOR_INFO="white"
export COLOR_WARN="yellow"
export COLOR_ERROR="red"
export COLOR_FATAL="red"
export COLOR_RESET=$(tput sgr0)

# date
export START_DATE=""
export END_DATE=""
