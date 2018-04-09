#! /bin/bash
# mod: debug
# api: blib
# txt: The debug module enable or disable debug featuring.
# env: DEBUG: if true enable debug mode

${DEBUG:+set -x}
