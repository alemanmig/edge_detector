#!usr/bin/env bash

export SNPS_SCRIPTS=/home/jvergara/snps_scripts

# Run the corresponding script for each tool
for f in "$SNPS_SCRIPTS"/*.sh; do
	source "$f"
done

# TB Environment Variables
export GIT_ROOT="$(git rev-parse --show-toplevel)"
export UVM_WORK="$GIT_ROOT/work/tb"
