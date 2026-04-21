#!/usr/bin/env bash
# Logging helpers for taw-kit scripts. Sourced, not executed.
# Emits English-prefixed lines with ANSI colors when stdout is a TTY.

if [ -t 1 ] && [ "${NO_COLOR:-}" != "1" ]; then
  _C_RED=$'\033[31m';   _C_YEL=$'\033[33m'
  _C_GRN=$'\033[32m';   _C_CYA=$'\033[36m'
  _C_DIM=$'\033[2m';    _C_OFF=$'\033[0m'
else
  _C_RED=''; _C_YEL=''; _C_GRN=''; _C_CYA=''; _C_DIM=''; _C_OFF=''
fi

info() { printf '%s[info]%s %s\n' "$_C_CYA" "$_C_OFF" "$*"; }
ok()   { printf '%s[ok]%s %s\n' "$_C_GRN" "$_C_OFF" "$*"; }
warn() { printf '%s[warn]%s %s\n' "$_C_YEL" "$_C_OFF" "$*" >&2; }
err()  { printf '%s[err]%s %s\n' "$_C_RED" "$_C_OFF" "$*" >&2; }
dim()  { printf '%s%s%s\n' "$_C_DIM" "$*" "$_C_OFF"; }
