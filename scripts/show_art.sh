#!/bin/bash
# Benjamin Michael Taylor (bentaylorhk)
# 2025
set -e

clear
head -c $(stat --format=%s "$1") "$1"
read -s -n1
