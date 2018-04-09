#! /bin/bash
# mod: cache
# api: blib
# txt: The `cache` module provides a simple in-memory cache.
# use: cache::put "key" "val"
#      cache::get "key"

# fun: cache::get <key>
# api: blib
# txt: get the value of the key from the potion in-memory cache.
cache::get () {
  echo "${cache__contents["$1"]}"
}

# fun: cache::put <key> <value>
# api: blib
# txt: save the content of the specified key to the in-memory cache.
cache::put () {
  cache__contents["$1"]="$2"
}

declare -A cache__contents
