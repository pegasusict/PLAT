#!/bin/bash
ID="~/.ssh/id_rsa"
PUB_KEY="~/.ssh/id_rsa.pub"
REMOTE_HOST=""
USER=""
PASS=""

gen_key() {
	echo "press enter 3 times (once on every question...)"
	ssh-keygen
}

upload_key() {
	ssh-copy-id -i "$PUB_KEY" "$USER@$REMOTE_HOST"
}
