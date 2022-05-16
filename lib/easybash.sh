#!/usr/bin/env bash
################################################################################
#
# Author: Alvin
# License: MIT
# GitHub: https://github.com/dbadaily/easybash
#
# Easy Bash template
################################################################################

VERSION_STR="1.0.0"

# set -euo pipefail

export EASY_BASH_DIR="$(dirname "${BASH_SOURCE[0]}")"

# common libraries
source "${EASY_BASH_DIR}"/lib_vars.sh
source "${EASY_BASH_DIR}"/lib_color.sh
source "${EASY_BASH_DIR}"/lib_logging.sh
source "${EASY_BASH_DIR}"/lib_date.sh
source "${EASY_BASH_DIR}"/lib_functions.sh
source "${EASY_BASH_DIR}"/lib_notification.sh
source "${EASY_BASH_DIR}"/lib_parse.sh

# custom libraries

mkdir -p "${LOG_DIR}"
