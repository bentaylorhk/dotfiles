#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2024
set -e

while read line
do
	echo "$line"
	sleep 0.1
done < "${1:-/dev/stdin}"
