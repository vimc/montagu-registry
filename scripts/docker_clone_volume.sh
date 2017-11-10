#!/bin/bash

# The MIT License (MIT)
#
# Copyright (c) 2016 Guido Diepen
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Author: Guido Diepen

# Convenience script that can help me to easily create a clone of a
# given data volume. The script is mainly useful if you are using
# named volumes

# https://www.guidodiepen.nl/2016/05/cloning-docker-data-volumes/
# https://github.com/gdiepen/docker-convenience-scripts

# First check if the user provided all needed arguments
if [ "$1" = "" ]
then
        echo "Please provide a source volume name"
        exit
fi

if [ "$2" = "" ]
then
        echo "Please provide a destination volume name"
        exit
fi


# Check if the source volume name does exist
docker volume inspect $1 > /dev/null 2>&1
if [ "$?" != "0" ]
then
        echo "The source volume \"$1\" does not exist"
        exit
fi

# Now check if the destinatin volume name does not yet exist
docker volume inspect $2 > /dev/null 2>&1

if [ "$?" = "0" ]
then
        echo "The destination volume \"$2\" already exists"
        exit
fi

echo "Creating destination volume \"$2\"..."
docker volume create --name $2
echo "Copying data from source volume \"$1\" to destination volume \"$2\"..."
docker run --rm \
           -i \
           -t \
           -v $1:/from \
           -v $2:/to \
           alpine ash -c "cd /to ; cp -a /from/* ."
