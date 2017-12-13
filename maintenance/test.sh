#!/bin/bash
"$(lxc list -c ns | grep -i running)" = containers
containers = "(${egrep '\ba-zA-Z{1}a-zA-Z0-9\-{,61}a-zA-Z0-9{1}\b' $active_containers)"
print "$containers"