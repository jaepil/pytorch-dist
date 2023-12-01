#!/usr/bin/env bash

NUMA_NODES=$(numactl --hardware | grep -P '(\d+) nodes' | awk '{print $(2)}')
if [ -z "$NUMA_NODES" ]; then
    NUMA_NODES=1
fi

if [ "$1" == "bash" ] || [ "$1" == "shell" ]; then
    set -ex

    # Wait forever to keep the container alive for the user to use shell.
    trap 'trap - INT; kill "$!"; exit' INT SIGTERM
    exec tail -f /dev/null & wait $!
fi

