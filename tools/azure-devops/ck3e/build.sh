#!/usr/bin/env bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE_DIR="$( realpath "$DIR/../../../" )"

echo "== armhf-ubuntu Build =="

mkdir -p build && cd build

CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Debug \
    -DUA_ENABLE_AMALGAMATION=OFF \
    -DUA_BUILD_EXAMPLES=OFF"

# We first need to call cmake separately to generate the required source code. Then we can call the freeRTOS CMake
mkdir lib && cd lib
cmake \
    ${CMAKE_ARGS} \
    ${BASE_DIR}
if [ $? -ne 0 ] ; then exit 1 ; fi

make -j open62541-code-generation
if [ $? -ne 0 ] ; then exit 1 ; fi
