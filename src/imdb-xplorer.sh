#!/usr/bin/env bash

################################################################################
# Purpose: Search and display informartion of your favourite actress and movie.
#
# Usage: imdb-xplorer [option]
#
# Revision history:
# Author-Name           Version       Message             Environment-Impact
# ===========           =======       =======             ==================
# Sarvsav Sharma        1.0.0         Initail Commit      yes, read README.md
#
################################################################################

## Adding unofficial bash script mode
set -e; #Immiditely exit from the script on failure of command. Ex: tmp/01.sh
set -u; #It exits and generate errors on unbound variables. Ex: tmp/02.sh
set -o pipefail; #It exits when pipe command fails. Ex: tmp/03.sh
IFS=$'\n\t'; #It reads the complete line, doesn't fail during loops. Ex:
             #tmp/04.sh
#exec 2>&- #suppressing error messages
clear #clearing the screen

## Global names
PROGRAM_NAME="IMDB xPlorer"
SCRIPT_NAME="imdb-xplorer"
USER_NAME=$(whoami)
SHELL=${SHELL}
MODE=${1:-}
DEBUG=${DEBUG:-}
V_DEBUG=${V_DEBUG:-}
DATE=$(date +'%Y-%m-%d')
[[ -z "$MODE" ]] && DEBUG="" && V_DEBUG=""
[[ "1" == "$MODE" ]] && DEBUG=1 && V_DEBUG=""
[[ "2" == "$MODE" ]] && DEBUG=1 && V_DEBUG=2

## Debug mode
function debug() {
  [[ -z "$DEBUG" ]] && return;
  printf "Debug: "$1"\n";
  exit 1;
}

## verbose debug mode
function v_debug() {
  [[ -z "$V_DEBUG" ]] && debug "$1" && return;
  printf "Verbose: "$1" ---> "$2"\n";
  exit 1;
}

hostname=`hostname`
user=`whoami`
