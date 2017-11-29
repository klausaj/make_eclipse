#!/bin/sh

H_FILES=`find . -type f -name *.h | grep -v Intermediate | grep -v CMakeFiles`
CPP_FILES=`find . -type f -name *.cpp | grep -v Intermediate | grep -v CMakeFiles`

ALL_FILES="$H_FILES $CPP_FILES"

clang-format -i -style=file $ALL_FILES
uncrustify -c tools/config/uncrustify/uncrustify.cfg --replace --no-backup $ALL_FILES
