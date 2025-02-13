func! Remove(string)

	silent! exe '%substitute/' . a:string . '//g'
endf

func! AbbrevPrimitives()

 	" substitution table
	silent! %s/VALUE/VAL/g
	silent! %s/NEXT/NXT/g
	silent! %s/THEN/THN/g
	silent! %s/BEGIN/BGN/g
	silent! %s/REPEAT/RPT/g
	silent! %s/UNTIL/UTL/g
	silent! %s/WHILE/WHL/g
	silent! %s/ALLOT/ALO/g
	silent! %s/VARIABLE/VAR/g
	silent! %s/SWAP/SWP/g    
	silent! %s/OVER/OVR/g    
endf

let g:varnames_used = ""

func! Mangle(word_def, prefix)

	" pattern for calls to that word
	let l:word_call = '\<' . a:word_def . '\>'

	" new name
	let l:generated_name = a:prefix . (rand() % 100)

	while g:varnames_used =~ l:generated_name
		echo "Detected duplicate name, randomizing"

		let l:generated_name = a:prefix . (rand() % 100)
	endw

	let g:varnames_used = g:varnames_used . l:generated_name . ';'

	" exe 'g/'    . l:word_call . '/normal! 0O//' . a:word_def
	exe '%sub/' . l:word_call . '/' . l:generated_name  . '/g'
endf

func! MangleWord() " this function must be called only on lines with a forth word definition

	" get the defined word
	let l:word_def = matchstr(getline('.'), '[0-9A-Za-z\-!@?]\+')

	" mangle it
	cal Mangle(l:word_def, 'w')
endf

func! MangleVar()

	" get the defined word
	let l:var_def = matchstr(getline('.'), '\(VARIABLE\|VALUE\)\s\+\zs[0-9A-Za-z\-!@?]\+')

	" mangle it
	cal Mangle(l:var_def, 'v')
endf

func! Forth()

	" My shorthands:
	
	" 3-byte tagged buffer
	silent! %s/#3/TAG NOP NOP/

	" 4-byte tagged buffer
	silent! %s/#4/TAG NOP NOP NOP/

	" 4-byte untagged buffer
	silent! %s/#_4/NOP NOP NOP NOP/

	" actual forth stuff

	" Mangle word names to avoid conflicts
	g/^:/cal MangleWord()
	g/VARIABLE\|VALUE/cal MangleVar()

	" remove quotes
	cal Remove('"')

	" remove comments in the form: \ something something
	cal Remove('\\.*')

	" remove comments in the form: ( something )
	cal Remove('(.*)')

	" remove blank lines
	g/^\s*$/d

	" remove trailing whitespace
	cal Remove('\s*$')

	" remove excess whitespace
	%s/\( \)\+/\1/g

	cal AbbrevPrimitives()

 	" Text Decorations
	silent! %s/\<A\>/ 7 6 API /g
	silent! %s/\<SPACE\>/ 6 6 API /g
	silent! %s/\<COLON\>/ 8 6 API /g  

	" remove everything after 3 letters of each word
	cal Remove('\<[A-Za-z\-!@?]\{1,3\}\zs[A-Za-z\-!@?]*\>')

	" quote everything
	%normal! I"
	%normal! A" NL

 	" write code variable
	normal! gg0O#define NL "\n"
	normal! gg0Oconst char code[] PROGMEM =

	" write guards
	exe 'normal!' 'gg0O#define __' . expand('%') . '_FTH__'
	exe 'normal!' 'gg0O#ifndef __' . expand('%') . '_FTH__'

	" close variable/guard
	normal! G0o;
	normal! G0o#endif

	" save to new file
	execute 'w!' expand('%') . ".h"

	" restore original
	undo
endf

