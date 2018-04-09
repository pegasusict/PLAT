#! /bin/bash
# mod: err
# api: blib
# txt: The `err` module offers a way to stop potion execution with
#      a traceback.

# fun: err::trace
# api: blib
# txt: print to stderr a traceback of an error.
# use: false || err::trace "Error because of false"
err::trace () {
  echo "${COLOR_FAIL}Traceback (most recent call last):${COLOR_NONE}" >&4
  for ((i=0;; i++)); do
    read -r line fun file < <(caller $i)
    if [ "$line" ]; then
      echo "${COLOR_FAIL} File '$file', line $line, in $fun${COLOR_NONE}" >&4
    else
      break
    fi
  done
  out::fail "$1"
  exit 127
}
