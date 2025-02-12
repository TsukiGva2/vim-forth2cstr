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

func! Mangle() " this function must be called only on lines with a forth word definition

	" get the defined word
	let l:str = matchstr(getline('.'), '[0-9A-Za-z\-!@?]\+')
	exe '%s/' . l:str . '/f' . (rand() % 100) . '/g'
endf

func! Forth()

	g/: \zs[A-Za-z\-!@?]\+\ze/cal Mangle()

	" remove prefixes like 'aligned' 'int16' 16-bit
	cal Remove('\<\(aligned\|int..\|..-bit\)-')

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

	" remove number prefixes
	cal Remove('\<[0-9][A-Za-z\-!@?]\{1,2\}\zs[A-Za-z\-!@?]*\>')

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

