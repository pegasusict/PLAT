#!/usr/bin/env bash
### root check
if [[ $(id -u) -ne 0 ]]; then echo "- Please run as root / sudo"; exit 1; fi

### FUNCTIONS ####################################################
alias ag="apt-get -qy"
upd() { ag update; }
inst() { ag install "$@"; }
verify_path() {
  [[ -w "${1}" ]] || mkdir -p "${1}"
  [[ -w "${1}" ]] then :; else echo "there is a problem with ${1}"; exit 1
}
add_repo_webmin() {
  echo -e "deb http://download.webmin.com/download/repository sarge contrib\n" > /apt/sources.list.d/webmin.list
  upd
  wget -q -O- http://www.webmin.com/jcameron-key.asc | apt-key add -
  upd
}
####################################################################
inst mc screen git gnupg1
verify_path "/etc/apt/sources.list.d"
add_repo_webmin
inst webmin
