#!/bin/bash
cat ./words.txt | tr '[:upper:]' '[:lower:]' | grep -oE '[a-z]+' | sort | uniq -c | sort -nr | head -n 1 | awk '{print $1, $2}'
