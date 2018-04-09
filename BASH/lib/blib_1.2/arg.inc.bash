#! /bin/bash
# mod: arg
# api: blib
# txt: The `arg` module provides a number of functions to parse arguments
#      from command line.
#
#      To use `arg` module you need to create handler functions which will
#      be call during the parser process. The handler functions sould return
#      the number of parameters comsumed from the parameter list. See
#      example below for more information.
# use: opt_quiet () {
#          QUIET=true; return 1; # we consum only the -q param
#      }
#      create () { echo "$arguments" }
#
#      arg::opt MAIN -q --quiet   opt_quiet   'do not output messages'
#
#      arg::action create create 'create new things'
#      arg::param create "arguments+"  'argument to create subcommand'
#
#      arg::parse "$@"


declare -A arg__opt_long
declare -A arg__opt_short
declare -A arg__opt_help
declare -A arg__actions
declare -A arg__actions_help
declare -A arg__param

# fun: arg::opt <action> <short> <long> <handler> [help]
# api: blib
# txt: set an option for a specific action argument.
# opt: action: the action for which the option will be added
# opt: short: the short form of the option (usually prefixed by ``-``)
# opt: long: the long form of the option (usually prefixed by ``--``)
# opt: handler: function to handler when option is present.
arg::opt () {
  arg__opt_short["$1,${2#-}"]="$4"
  arg__opt_long["$1,${3#--}"]="$4"
  arg__opt_help["$1,${2#-},${3#--}"]="$5"
}

# fun: arg::parse::opt::fail <cmdline>
# txt: exit program with error 2 (cmdline error) interpreting cmdline passed
#      as argument.
# opt: cmdline: the cmdline which fails.
arg::parse::opt::fail () {
  echo "unrecognized command line option '${1}'" >&2
  E=2 arg::usage >&2
}

# fun: arg::parse::opt::long <action> <option> [option argument]
# txt: set the specific long option for the action passed as argument. The
#      option can be suffixed with a colon (:) to specify a mandatory
#      argument.
arg::parse::opt::long () {
  local opt="${2#--}"
  local fun="${arg__opt_long["$1,$opt"]}"
  [ "$fun" ] || 
    local fun="${arg__opt_long["$1,$opt:"]}"

  if [ "$fun" ]; then
    "$fun" "$3"
  else
    arg::parse::opt::fail "${2%:}"
  fi
}

# fun: arg::parse::opt::short <action> <option> [option argument]
# txt: set the specific short option for the action passed as argument. The
#      option can be suffixed with a colon (:) to specify a mandatory
#      argument.
arg::parse::opt::short () {
  local opt="${2#-}"
  local fun="${arg__opt_short["$1,$opt"]}"
  [ "$fun" ] || 
    local fun="${arg__opt_short["$1,$opt:"]}"
  if [ "$fun" ]; then
    $fun "$3"
  else
    arg::parse::opt::fail "${2%:}"
  fi
}

# fun: arg::action <action> <handler> [help_message]
# api: blib
# txt: set a new action in argument parser.
# opt: action: the action name to add to the parser
# opt: handler: the function name to use as handler for this action.
# opt: help_message: a message to print on usage.
arg::action () {
  arg::opt "$1" -h --help "arg::usage::action::explain $1" \
    "print help message about $1 action"
  arg__actions["${1}"]="$2"
  arg__actions_help["${1}"]="$3"
}

# fun: arg::usage::action <action>
# txt: print usage information for the action passed as argument.
arg::usage::action::explain () {
  local summ="usage: $0 ${1//MAIN/}"
  local text=""
  local param=""

  for key in "${!arg__opt_help[@]}"; do
    IFS=',' read -r action short long <<<"${key}"
    [ "$action" != "$1" ] && continue
    local help_str="${arg__opt_help["$key"]}"

    if [ "${short: -1}" == ":" ]; then
      local argname="${long%:}"
      local argname="${argname/-/_}"
      local argname=" ${argname^^}"
    else
      local argname=''
    fi
    summ+=" [-${short%:}${argname}]"

    if [ "${argname}" ]; then
      text+="$(printf "  %-20s" \
               "-${short%:}${argname}, --${long%:}${argname}")"
      text+=$'\n'
      text+="$(printf "  %-20s %s" '' "${help_str}")"
    else
      text+="$(printf "  %-20s %s" \
               "-${short%:}${argname}, --${long%:}" \
               "${help_str}")"
    fi
    text+=$'\n'
  done

  local spam=''
  for key in "${!arg__param[@]}"; do
    IFS=',' read -r action par <<<"${key}"
    [ "$action" != "$1" ] && continue
    local help_str="${arg__param["$key"]}"
    param+="$(printf "  %-20s %s" "${par}" "${help_str}")"
    param+=$'\n'
    case "$par" in
      *\?|*'*') spam+="${spam:+ }[${par}]";;
      *) spam+="${spam:+ }<${par}>";;
    esac
  done

  if [ "$1" == "MAIN" ]; then
    local sact=''
    for action in "${!arg__actions[@]}"; do
      [ "$action" == "MAIN" ] && continue
      sact+="${sact:+, }$action"
      actions+="$(printf "  %-20s %s" \
                  "${action}" \
                  "${arg__actions_help["$action"]}")"
      actions+=$'\n'
    done
  fi
  echo "$summ${sact:+" \{$sact\}"}${spam:+ $spam}"
  echo

  [ "$1" == "MAIN" ] && [ "${arg__actions_help["MAIN"]}" ] &&
    echo "${arg__actions_help["MAIN"]}" && echo

  if [ "$actions" ]; then
    echo "command line actions:"
    echo "$actions"
  fi
  if [ "$param" ]; then
    echo "positional parameters:"
    echo "$param"
  fi
  if [ "$text" ]; then
    echo "optional arguments:"
    echo "$text"
  fi

  exit "${E:-0}"
}

# fun: arg:::main::help <text>
# api: blib
# txt: Set the main help for the program
# opt: text: the main help string for the program
arg::main::help () {
  arg__actions_help["MAIN"]="$1"
}

# fun: arg:::main::action <fun>
# api: blib
# txt: Set the function handler for main action, used when no action
#      defined.
# opt: fun: the handler for the MAIN action.
arg::main::action () {
  arg__actions["MAIN"]="$1"
}

# fun: arg::usage
# api: blib
# txt: print main usage information
# env: E: the error code to return to OS on exit.
arg::usage () {
  arg::usage::action::explain MAIN
}

# fun: arg::parse::action <action> [arguments]
# txt: parse arguments starting with action passed as argument.
arg::parse::action () {
  local action="$1"; shift;
  while [ $# -ne 0 ]; do
    case "$1" in
      --*=*)
        arg::parse::opt::long "$action" "${1%=*}" "${1#*=}"; shift;;
      --*) arg::parse::opt::long "$action" "$@"; shift $?;;
      -*) arg::parse::opt::short "$action" "$@"; shift $?;;
      *) break;;
    esac
  done
  if [ "$action" == "MAIN" ]; then
    if [ "${arg__actions["MAIN"]}" ]; then
      arg::parse::arg MAIN "$@"; shift $?
    else
      arg::parse::action "$@";
    fi
    return
  else
    arg::parse::arg "$action" "$@"; shift $?
  fi

}

# fun: arg::parse::arg <action> [arguments]
# txt: parse arguments (not options) for specific action passed as argument.
arg::parse::arg () {
  local action="$1"; shift
  if [ -z "$action" ]; then
    echo "missing action command" >&2
    arg::usage >&2
    exit 2
  fi
  local handler="${arg__actions["$action"]}"
  [ "$handler" ] || arg::parse::opt::fail "$action"

  count=0
  for param in "${!arg__param[@]}"; do
    IFS=, read -r a name <<< "${param}"
    if [ "$action" == "$a" ]; then
      case "$name" in
        *+) ((count++));;
        *\?|*'*') ;;
        *) ((count++));;
      esac
    fi
  done

  if [ $# -lt $count ]; then
    echo "missing arguments: $# found, $count expected" >&2
    arg::usage::action::explain "$action" >&2
    exit 2
  fi

  $handler "$@"
}

# fun: arg::parse [arguments]
# api: blib
# txt: parse arguments according with previous configured parser.
arg::parse () {
  arg::opt MAIN -h --help 'arg::usage' 'print help message'
  arg::parse::action MAIN "$@"
}

# fun: arg::param <action> <parameter_name> [help_str]
# api: blib
# txt: add position parameter to parser.
# opt: action: action where add the parameter
# opt: parameter_name: the name of the paramenter
# opt: help_str: a help string for the parameter to show in usage
arg::param () {
  arg__param["$1,$2"]="$3"
}
