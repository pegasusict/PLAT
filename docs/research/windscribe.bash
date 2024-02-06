#!/bin/bash
    declare -r SCRIPT="${${basename "${BASH_SOURCE[0]}"}%.*}"
    add_repo(){
        apt-key adv --keyserver keyserver.ubuntu.com --recv-key FDC247B7
        declare -r LINE="deb https://repo.windscribe.com/ubuntu zesty main"
        declare -r FILE="/etc/apt/sources.list"
        add_line_to_file $LINE $FILE
    }
    apt-get update
    apt-get install windscribe-cli
    windscribe login && windscribe connect
