#! /bin/bash
# mod: config
# api: blib
# txt: The `config` module allows you to read configuration file in
#      properties format
# use: config::load configname ./config.properties
#      echo $(config::get configname key)

declare -A __config

# fun: config::load <table> <file>
# api: blib
# txt: read a configuration file passed as argument and save in the memory
#      with specific table name.
# opt: table: a name to identify the config table where file will be load.
# opt: file: path to a properties file to load.
config::load ()
{
  local line= key= val=
  while read line; do
    case "$line" in
      \#*|'') continue;;
    esac
    IFS=':' read key val <<< "$line"
    __config["$1.$key"]="$val"
  done < "$2"
}

# fun: config::get <table> <key> [default]
# api: blib
# txt: outputs the specified configuration key in the table passed as
#      argument. If key does not exists raise an error, unless default
#      is passed as argument, in that case return default values.
# opt: table: the table name where to search key.
# opt: key: the key to search in config table
# opt: default: default value to output if value is not found. By default
#      an error is raised.
config::get ()
{
  local val="${__config["$1.$2"]}"

  if [ "$3" ]; then
    [ "$val" ] && echo "$val" || echo "$3"
  else
    [ "$val" ] && echo "$val" || err::trace "Configuration key " \
                                            "$2 in table $1 not found"
  fi
}

# fun: config::iter <table> <pattern>
# api: blib
# txt: iterate over a specific configuration using pattern passed as
#      argument and outputs keys with match.
# opt: table: the table name to iterate
# opt: pattern: a glob pattern to match in config keys.
config::iter ()
{
  for key in "${!__config[@]}"; do
    case "$key" in
      ${1}.${2})

        echo "${key#${1}.}";;
    esac
  done
}
