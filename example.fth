\ __MYTEMPO_FTH__

\ General overview

\ stack model:
\           __ TOP
\         /
\        v
\  ( a b c )

\ Tagged addresses are denoted by [ADDR_NAME]
\ the word for them is TAG, which puts the
\ address inside the function in the return stack.

\ Values greater than $7F have to be encoded using the 16-bit-encode word

\ type BigNumber -> 32-bit, format: $BF prefixed 16-bit value + 8-bit magnitude
\                   like: 0xBF[vvvv][mm], example: 0xBF004103 [65K]

\ #3  -> TAG NOP NOP    , 3-byte tagged   buffer, this is usually a placeholder for a CALL instruction;
\ #4  -> TAG NOP NOP NOP, 4-byte tagged   buffer, this is usually a placeholder for code, allowing 2 calls;
\ #_4 -> NOP NOP NOP NOP, 4-byte untagged buffer, this is usually a placeholder for raw data.

\ ======================

501 VALUE VERSION

\ User interaction-related words and state

6   VALUE mIN
7   VALUE aIN

VARIABLE Scr
VARIABLE mRL
VARIABLE Mac
VARIABLE mST
VARIABLE Aac
VARIABLE aST

: MainPressed?
	mIN IN 0 =
;

: AltPressed?
	aIN IN 0 =
;

: Button?
	DUP ROT SWAP
	NOT AND
;

: ScreenNext
	IF
		Scr @ 1 +
		7 MOD
		Scr !
	THEN
;

\ ======================

\ C-API Drawing instructions

: Label    5   API ;
: Forward  2   API ;
: BigNum   1   API ; ( ; biblically accurate dump of 65K in BigNumber format: 0xBF004103 )
: Number   4   API ;
: Value    6   API ;
: Ip       7   API ;
: Ms       3   API ;

: antenna
	A 1 Number COLON BigNum SPACE
	A 2 Number COLON BigNum Forward
	A 3 Number COLON BigNum SPACE
	A 4 Number COLON BigNum Forward
;

\ ======================

\ The screen

: Dis			( -- ; Screen buffer )
	#_4			( ; DATA buffer )
	#_4			( ; 16-byte chunk, able to store 4 BigNumbers )
	#_4
	#_4

	0       Label		( label-id ; Main label, shows device name )
	VERSION Number		( device-version )
	Forward

	#4 Forward		( ; [SCR_CODE1], allocated space for 2 calls, which is enough. )
	#4 Forward		( ; [SCR_CODE2] )

	3       Label NOP	( label-id ; Main label #2, shows device connectivity )
	0       Value		( value-id )
	Forward

	0 API			( 0 ; C-Api call #0: Draw screen )
;

' Dis VALUE DATA	( ; Address of beginning of screen data buffer )
  R>  VALUE 2-CODE	( ; Address of the second screen code buffer )
  R>  VALUE 1-CODE	( ; Address of the first screen code buffer )

\ ======================

\ Utility functions for memory access

: 16-bit-encode!	( int16 addr -- )
	$BF			( int16 addr Lit-opcode      ; $BF is the opcode for pushing 16-bit integers to the stack )
	OVER C!			( int16 addr Lit-opcode addr ; writes a single byte LIT instruction to addr )
	1 +			( int16 addr +1              ; offsets addr by 1, right next to the LIT opcode )
	!			( int16 addr'                ; writes a 2-byte, i.e. 16-bit, signed integer to addr' )
;

: F!			( m v iaddr -- )
	DUP >R			( m v iaddr       ; saves a copy of indexed-addr for later ) 
	16-bit-encode!		( m v iaddr       ; encodes value to specified DATA buffer index )
	R>			( m   iaddr       ; restores indexed-addr from Rstack )
	3 +			( m   iaddr +3    ; offsets the indexed address by 3 bytes )
	C!			( m   iaddr'      ; writes the single-byte magnitude right next to the encoded value )
;

: calc-align		( idx align -- iaddr ; calculates aligned offset of the specified index in the DATA buffer )
	*			( idx align   ; calculates ALIGN-byte *offset* )
	DATA +			( offset data ; calculates base DATA address + offset to get the indexed-address )
;

\ ======================

\ Aligned writes

: aligned-data!		( value idx align -- ; n-byte aligned 16-bit write to DATA buffer )
	calc-align		( value idx align )
	16-bit-encode!		( value iaddr     ; encodes value to specified DATA buffer index )
;

: aligned-data-C!	( value idx align -- ; n-byte aligned 8-bit write to DATA buffer )
	calc-align		( value idx align )
	C!			( value iaddr     ; encodes value to specified DATA buffer index )
;

: aligned-data-Big!	( m v idx -- ; 4-byte aligned BigNumber write to DATA buffer, refer to the BigNumber type )
	4 calc-align		( value idx align ; each BigNumber has a 3-byte encoded value + a single-byte magnitude )
	F!			( value iaddr     ; writes a BigNumber to the specified DATA index )
;

\ ======================

\ Calling Words

: prepare-call		( word-addr target-addr -- ; this function is specific to the [encode-]call! functions )
	>R			( word-addr        target-addr ; puts target-addr in a pokeball )
	$C000 OR		( word-addr        call-opcode ; creates a call instruction, C000 | Address )
	R>			( call-instruction             ; goes like "target-addr, i choose you!" )
;

: encode-call!  	( word-addr target-addr -- ; useful in code modifying words, encode a literal call instruction )
	prepare-call		( word-addr        target-addr ; )
	16-bit-encode!		( call-instruction target-addr ; encodes the created call instruction as a value to target-addr )
;

: call!			( word-addr target-addr -- ; writes a call instruction in target-addr )
	prepare-call		( word-addr        target-addr ; )
	!			( call-instruction target-addr ; writes the created call instruction, modifying target-addr )
;

\ ======================

\ Screen-specific words

: Antenna!  		( m1 v1 m2 v2 m3 v3 m4 v4 -- ; magnitude and value for each antenna )
	3 aligned-data-Big!	( m1 v1 m2 v2 m3 v3 m4 v4 idx align )
	2 aligned-data-Big!	( m1 v1 m2 v2 m3 v3       idx align )
	1 aligned-data-Big!	( m1 v1 m2 v2             idx align )
	0 aligned-data-Big!	( m1 v1                   idx align )
;

\ Example:
\	3 50 3 50 3 50 3 50 Antenna!
\	' antenna 1-CODE call!

\ ======================

\ Initialization

500 DLY
50 0 TMI Dis
1 TME

\ ======================

