#!/usr/bin/env bash

################################################################################
# Purpose: run setup.sh to install and configure the imdb-xplorer program.
#
# Usage:
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

## Setting rc file for shell
P_SHELL=${SHELL##*/} # Parameter Expansion
[[ "zsh" == "$P_SHELL" ]] && F_RC="$HOME/.zshrc"
[[ "bash" == "$P_SHELL" ]] && F_RC="$HOME/.bashrc"

## Debug mode
function debug() {
  [[ -z "$DEBUG" ]] && return;
  printf "Debug: %s\n" "$1";
  exit 1;
}

## verbose debug mode
function v_debug() {
  [[ -z "$V_DEBUG" ]] && debug "$1" && return;
  printf "Verbose: %s ---> %s\n" "$1" "$2";
  exit 1;
}

## Clean Up

## Options and modes

## Initial Checks
[[ ! -w $HOME ]] && v_debug "$USER_NAME don't have permission to write in $HOME\
" "Initial Checks failed"

## Dependency Checks
[[ ! -f /usr/bin/install ]] && v_debug "Program `install` not found" "Dependency \
check failed"

## Support for colors
## ## Check if stdout is terminal or not
[[ -t 1 ]] && ncolors=$(tput colors) # set the number of colors tmp/05.sh
[[ -z "ncolors" ]] && v_debug "Colors not supported" "tput color is failed"
if test -n "$ncolors" && test "$ncolors" -ge 8; then
  bold="$(tput bold)"
  underline="$(tput smul)"
  standout="$(tput smso)"
  normal="$(tput sgr0)"
  black="$(tput setaf 0)"
  red="$(tput setaf 1)"
  green="$(tput setaf 2)"
  yellow="$(tput setaf 3)"
  blue="$(tput setaf 4)"
  magenta="$(tput setaf 5)"
  cyan="$(tput setaf 6)"
  white="$(tput setaf 7)"
fi

## Taking inputs for configuration file
printf "Do you want to set colors(Y/N): "
read P_COLORS;
case $P_COLORS in
  [yY]|[yY][eE][sS]) printf "${green}Value of Color parameter is set to true${n\
ormal}\n"
  cp etc/imdb-xplorer.cfg etc/imdb-xplorer.cfg.orig
  awk '/^colors/ {$3="yes"}1' etc/imdb-xplorer.cfg.orig  > etc/imdb-xplorer.cfg
  rm etc/imdb-xplorer.cfg.orig
                    ;;
  [nN]|[nN][oO]) printf "${red}Value for color parameter is set to false${norma\
l}\n"
  cp etc/imdb-xplorer.cfg etc/imdb-xplorer.cfg.orig
  awk '/^colors/ {$3="no"}1' etc/imdb-xplorer.cfg.orig > etc/imdb-xplorer.cfg
  rm etc/imdb-xplorer.cfg.orig
                ;;
  *) v_debug "Invalid value $P_COLORS for colors" "Configuration Parameter \"Co\
lors\" setting failed";
esac

## Installing files and directories
install -Dm755 src/imdb-xplorer.sh $HOME/.imdb-xplorer/bin/imdb-xplorer
[[ ! -x $HOME/.imdb-xplorer/bin/imdb-xplorer ]] && v_debug "Unable to install t\
he program" "Installation of imdb-xplorer failed"
install -Dm644 logs/imdb-xplorer.log $HOME/.imdb-xplorer/logs/imdb-xplorer.log
[[ ! -f $HOME/.imdb-xplorer/logs/imdb-xplorer.log ]] && v_debug "Unable to add \
log file" "Installation of imdb-xplorer.log file failed"
install -Dm644 etc/imdb-xplorer.cfg $HOME/.imdb-xplorer/etc/imdb-xplorer.cfg
[[ ! -f $HOME/.imdb-xplorer/etc/imdb-xplorer.cfg ]] && v_debug "Unable to add c\
onfiguration file" "Installation of imdb-xplorer.cfg failed"
[[ ! -d $HOME/.imdb-xplorer/var ]] && mkdir $HOME/.imdb-xplorer/var
[[ ! -d $HOME/.imdb-xplorer/var/run ]] && mkdir $HOME/.imdb-xplorer/var/run
[[ ! -d $HOME/.imdb-xplorer/var/lock ]] && mkdir $HOME/.imdb-xplorer/var/lock
[[ ! -d $HOME/.imdb-xplorer/tmp ]] && mkdir $HOME/.imdb-xplorer/tmp
[[ ! -d $HOME/.imdb-xplorer/var ]] && v_debug "Unable to create directory" "Ins\
tallation failed"
printf "\n$PROGRAM_NAME is successfully installed in $HOME/.imdb-xplorer/bin\n"
[[ ! -f `which $SCRIPT_NAME` ]] && [[ -f $F_RC ]] && echo "export PATH=$HOME/.i\
mdb-xplorer/bin:\$PATH" >> $F_RC
printf "You need to restart your terminal to make the changes effect\n"
cat <<EOF

${blue}Usage
===
$ imdb-xplorer [options] [arguments]

Options :
* -h: displays the help page
* -s [string]: searches for the string and displays the result
* -v: gives the version of the script
* -n: suppress the suggestions
* -w: displays the errors and warnings
${normal}
EOF
