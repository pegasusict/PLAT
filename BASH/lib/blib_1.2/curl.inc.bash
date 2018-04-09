#! /bin/bash
# mod: curl
# api: blib
# txt: The curl module offers a way to access to HTTP resources easily.

# fun: curl::get <url>
# api: blib
# txt: get an object from url and output it to stdout
# opt: url: any URL valid for curl.
# use: curl::get http://example.com
curl::get () {
  command curl -qsSL "$1"
}

# fun: curl::source <url>
# api: blib
# txt: sources a file from url
# use: curl::source http://mydomain.com/file.bash
curl::source () {
  case "$1" in
    *://*) source <(curl::get "$1");;
    *) source "$1" ;;
  esac
}
