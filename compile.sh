#!/bin/sh

if [ $# -lt 2 ] ; then
	echo "usage: $0 <source file> <output c header>"
	exit
fi

which nvim 1> /dev/null 2> /dev/null

if [ $? -eq 1 ] ; then
	echo "This script requires nvim, it is currently untested in vim."
	exit 1
fi

./library.sh

nvim --clean -c "source unforth.vim" -c "edit $1" -c "Unforth $2" -c "q" 1> /dev/null 2> /dev/null

