#!/bin/bash

if [ $# -ne 1 ]; then
   echo "Usage: createProject.sh [Project Name]"
   exit 1
fi

NAME=$1

mkdir $NAME
cd $NAME

cp ../../tools/templates/build/linux/Makefile.linux .
cp ../../tools/templates/build/win64/Makefile.win64 .

sed -i -e 's/myproject/framework/' Makefile.linux
sed -i -e 's/myproject/framework/' Makefile.win64
sed -i -e 's/makefile template/framework project/' Makefile.linux
sed -i -e 's/makefile template/framework project/' Makefile.win64

mkdir public
mkdir private
mkdir linux
mkdir win64
mkdir test

PLATFORM=`uname -s`

if [[ "$PLATFORM" == "Linux" ]]; then
    MAKE_SUFFIX=linux
else
    MAKE_SUFFIX=win64
fi

make -f Makefile.$MAKE_SUFFIX eclipse
