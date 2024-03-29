#!/usr/bin/env bash

bindir=
logdir=

## Command parsing ################################################################################
cmd="${1}"; shift

## Argument and option parsing ####################################################################
while (( "$#" )); do
  case "${1}" in
    --channel=*) channel=${1/--channel=/''}; shift ;;
    --quality=*) quality=${1/--quality=/''}; shift ;;
    -c*) channel=${2}; shift; shift ;;
    -q*) quality=${2}; shift; shift ;;
    *)
      case "${cmd}" in
        listen|play) test -n "${1}" && test -z "${channel}" && channel=${1} ;;
      esac
      shift
    ;;
  esac
done

## Default arguments and options ##################################################################
case "${cmd}" in
  listen|play) test -z "${quality}" && quality=high ;;
esac

## Argument and option prompting ##################################################################
case "${cmd}" in
  listen|play)
    test -z "${channel}" && \
      read -e -p 'Enter channel (e.g. groovesalad, defcon, poptron): ' channel
  ;;
esac

## Command functions ##############################################################################
function channels() {
  local channels=$(curl -s -H 'Accept: application/json' https://somafm.com/channels.json | \
    jq -r '.channels | sort_by(.listeners | tonumber) | reverse | .[]' | \
    jq -r '.id + " | " + .listeners + " listeners | " + .description')

  case "${channels}" in
    '') return 1 ;;
    *) echo "${channels}" ;;
  esac
}

function help() {
  local a=(${0//\// })
  local bin=${a[${#a[@]}-1]}

  echo 'Usage:'
  echo "  ${bin} channels"
  echo "  ${bin} listen <channel> [--quality=<low|high|highest>]"
  echo
  echo 'Options:'
  echo '  quality    The listening quality (default: high)'
  echo
  echo 'Commands:'
  echo '  channels|list|ls    List channels'
  echo '  listen|play         Listen to channel'
}

function listen() {
  local playlist=$(curl -s -H 'Accept: application/json' https://somafm.com/channels.json | \
    jq -r ".channels | map(select(.id == \"${channel}\")) | .[]" | \
    jq -r ".playlists | map(select(.quality == \"${quality}\")) | limit(1;.[]) | .url")

  case "${playlist}" in
    '') return 1 ;;
    *) mpv --no-config "${playlist}" 2> /dev/null | awk '/title/ { s = ""; for (i = 2; i <= NF; i++) s = s $i " "; cmd="(date +'%H:%M:%S')"; cmd | getline d; print d,"|",s; close(cmd) }' ;;
  esac
}

function version() {
  echo '0.3.1'
}

## Command routing ################################################################################
case "${cmd}" in
  --help|-h) help; exit 0 ;;
  --version|-v) version; exit 0 ;;
  channels|list|ls) channels; exit "$?" ;;
  listen|play) listen; exit "$?" ;;
  *) help; exit 1 ;;
esac