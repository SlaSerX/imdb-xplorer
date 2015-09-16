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
DEBUG=${DEBUG:-}
V_DEBUG=${V_DEBUG:-}
DATE=$(date +'%Y-%m-%d')
CONFIGURATION_file="$HOME/.imdb-xplorer/etc/imdb-xplorer.cfg"
PID=$$
PID_file="$HOME/.imdb-xplorer/var/run/processfile.pid"
echo "$PID" > "$PID_file"
LOCK_file="$HOME/.imdb-xplorer/var/lock/lockfile.$PID"
cf_nosuggestions=${cf_nosuggestions:-false}


## safe_rm
function safe_rm() {
  file_name="$1";
  max_file_size=2048000
  file_size=$(wc -c < "$file_name")
  if [[ "$file_size" -ge "$max_file_size" ]]; then
    echo "Hello"
  else
    echo "Bye"
  fi
  return;
}

## completed and clean up
function completed_clean_up() {
  true;
}

## Killed and clean up
function killed_clean_up() {
  true;
}

## trap signals
##trap completed_clean_up
##trap killed_clean_up

## Colors
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

## Debug mode
function debug() {
  [[ -z "$DEBUG" ]] && return;
  case "$2" in
  1)
    print "$red"
    printf "Debug: %s\n" "$1";
    print "$normal"
    ;;
  2)
    print "$magenta"
    printf "Debug: %s\n" "$1";
    print "$normal"
    ;;
  3)
    print "$blue"
    printf "Debug: %s\n" "$1";
    print "$normal"
    ;;
  *)
    printf "Debug: %s\n" "$1";
    ;;
  esac
  exit 1;
}

## verbose debug mode
function v_debug() {
  [[ -z "$V_DEBUG" ]] && debug "$1" "$2"&& return;
  case "$3" in
  1)
    echo "$red"
    printf "Verbose: %s ---> %s\n" "$1" "$2";
    echo "$normal"
    ;;
  2)
    echo "$magenta"
    printf "Verbose: %s ---> %s\n" "$1" "$2";
    echo "$normal"
    ;;
  3)
    echo "$blue"
    printf "Verbose: %s ---> %s\n" "$1" "$2";
    echo "$normal"
    ;;
  *)
    printf "Verbose: %s ---> %s\n" "$1" "$2";
    ;;
  esac
  exit 1;
}

## function read configuration file
function read_config_file() {
  printf "Loading configuration file --> %s\n" "$CONFIGURATION_file"
  [[ ! -f "$CONFIGURATION_file" ]] && v_debug "Unable to read configuration fil\
e" "Reading of configuration file failed" "3"
  cf_color=$(cat $CONFIGURATION_file | grep colors | awk -F= '{print $2}' | tr \
-d " ")
  cf_version=$(cat $CONFIGURATION_file | grep version | awk -F= '{print $2}' | \
tr -d " ")
  return 0;
}

## function to test for lock file
function check_lockfile() {
  [[ -f "$LOCK_file" ]] && v_debug "Process is already running" "Lock file is\
 already present" "1"
 return 0;
}

## Usage
function usage() {
  cat <<EOF

${cyan}$PROGRAM_NAME Usage
===
$ imdb-xplorer [options] [arguments]

Options :
* -h, --help: displays the help page
* -s, --search [string]: searches for the string and displays the result
* -v, --version : gives the version of the script
* -n, --nosuggestions : suppress the suggestions
* -w, --warnings : displays the errors and warnings
----------------------------------------------------------------

For Example:
$ imdb-xplorer -s "Yancy Butler"
$ imdb-xplorer -s "cyberbitgame"

Please use the double quotes with search option
${normal}

EOF
  v_debug "Script completed successfully" "printed help manual" "3"
}

## function to start searching on imdb
function search_imdb() {
  search_string="$2"
  search_count=0
  [[ -z "$search_string" ]] && v_debug "Movie/Actress/Actor name missing" "Null\
argument supplied" "2" && exit 1
  printf "Downloading information about %s\n" "$search_string"
  search_string=$(echo "$search_string" | tr " " "+")
  curl --connect-timeout 20 -s "http://www.imdb.com/find?ref_=nv_sr_fn&q=${sear\
ch_string}&s=all" -o $HOME/.imdb-xplorer/tmp/tempfile_"$search_string"
  found=$(cat $HOME/.imdb-xplorer/tmp/tempfile_${search_string} | grep "No resu\
lts found for" | wc -l ) || true;
  [[ "$found" -ge 1 ]] && v_debug "No results and suggestions found" "IMDb sear\
ch failed" "2" && exit 0
  results_title=$(cat $HOME/.imdb-xplorer/tmp/tempfile_${search_string} | grep \
-o "title/tt[0-9]*" | awk '!a[$0]++') || true;
  results_name=$(cat $HOME/.imdb-xplorer/tmp/tempfile_${search_string} | grep \
-o "name/nm[0-9]*" | awk '!a[$0]++') || true;

  for i in $results_name;
  do
    curl --connect-timeout 20 --progress-bar "http://www.imdb.com/$i/#" -o $HOM\
E/.imdb-xplorer/tmp/title_"$search_string"_$search_count
    printf "${yellow}Name: "
    cat $HOME/.imdb-xplorer/tmp/title_"$search_string"_$search_count | grep -m \
1 title\> | sed 's/<title>\(.*\)<\/title>/\1/' | awk -F- '$NF=""; { printf $0}'\
 || true;
    printf "\nDate of Birth: "
    cat $HOME/.imdb-xplorer/tmp/title_"$search_string"_$search_count | grep -m \
1 datetime | awk -F\" '{printf $2}' || true;
    printf "\nMedia:\t\t"
    cat $HOME/.imdb-xplorer/tmp/title_"$search_string"_$search_count | grep ">[\
0-9]* photos" | awk -F/ '{printf $1}' | tr -d "<>" || true;
    printf "\nBio:\t\t"
    cat $HOME/.imdb-xplorer/tmp/title_"$search_string"_$search_count | grep og:\
description | awk -F\" '{printf $4}'
    echo ""
    printf "\nProfile URL: "
    printf "${blue}"
    echo "http://www.imdb.com/$i/"
    printf "${green}"
    search_count=$((search_count + 1))
    [[ $search_count -gt 2 ]] && break;
  done
  search_count=0
  for i in $results_title;
  do
    curl --connect-timeout 20 --progress-bar "http://www.imdb.com/$i/#" -o $HOM\
E/.imdb-xplorer/tmp/movie_"$search_string"_$search_count
    printf "${yellow}Movie: "
    cat $HOME/.imdb-xplorer/tmp/movie_"$search_string"_$search_count | grep -m \
1 title\> | sed 's/<title>\(.*\)<\/title>/\1/' | awk -F- '$NF=""; { printf $0}'\
 || true;
    printf "\nRating:\t\t"
    cat $HOME/.imdb-xplorer/tmp/movie_"$search_string"_$search_count | grep -m \
1 "star-box-giga-star" | awk '{printf $4}' || true;
    printf "\nDirector:\t"
    cat $HOME/.imdb-xplorer/tmp/movie_"$search_string"_$search_count | grep -A1\
 tt_ov_dr | awk 'NR==2' | awk -F">" '{printf $3}' | cut -d"<" -f1 || true;
    printf "Stars:\t\t"
    cat $HOME/.imdb-xplorer/tmp/movie_"$search_string"_$search_count | grep -A1\
 tt_ov_st\" | awk 'NR%2==0' | awk -F">" '{printf $3}' | sed 's/<\/span/,/g' || \
true
    printf "\nStroy:\t\t"
    cat $HOME/.imdb-xplorer/tmp/movie_"$search_string"_$search_count | grep -m1\
 -A1 itemprop=\"description\" | awk "NR==2" | cut -d"<" -f1 || true
    printf "\nIMDb URL:\t"
    printf "${blue}"
    echo "http://www.imdb.com/$i/"
    printf "${green}"
    search_count=$((search_count + 1))
    [[ $search_count -gt 2 ]] && break;
  done
  return 0;

}
## main
function main() {
  printf "${green}"
  printf "Starting script %s at %s by user: %s with process id %s\n" "$SCRIPT_N\
AME" "$DATE" "$USER_NAME" "$PID"
  echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  read_config_file;
  check_lockfile;
  touch $LOCK_file
  printf "Created lockfile ----> %s\n" "$LOCK_file"
  printf "Reading arguments passed to script ---> %s\n" "$SCRIPT_NAME"
  [ $# -gt 0 ] || usage
  while [ $# -gt 0 ]; do
    case "$1" in
      -s|--search)
        search_imdb "$1" "$2"
        shift
        shift
        ;;
      -w|--warnings)
        DEBUG=1
        V_DEBUG=2
        shift
        ;;
      -n|--nosuggestions)
          cf_nosuggestions=true;
          shift
          ;;
      -h|--help)
        usage
        exit 0
        ;;
      -v|--version)
        printf "Current version of the script is %s\n" "$cf_version"
        v_debug "Displayed the current version of script" "arguments checked" "\
3"
        exit 0
        ;;
      *)
        printf "Undefined option passed\n"
        v_debug "Invalid option passed" "Undefined behaviour" "2"
        exit 1
        ;;
    esac
  done
  printf "${normal}"

}

## call main function
main "$@"
