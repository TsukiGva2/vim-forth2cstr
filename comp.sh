#!/bin/sh

which nvim 1> /dev/null 2> /dev/null

if [ $? -eq 1 ] ; then
	echo "This script requires nvim, it is currently untested in vim."
	exit 1
fi

./library.sh

nvim -c "source unforth.vim" -c "edit example.fth" -c "Unforth ~/Arduino/libraries/forth2cstr/forth2cstr.h" -c "q" 1> /dev/null 2> /dev/null

