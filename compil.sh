#!/bin/bash
IFS='.' read -ra f <<< "$1"
./myc $f.h $f.c < $1
gcc $f.h $f.c -o $f
./$f
echo "End of execution"