\ stack model:
\           __ TOP
\         /
\        v
\  ( a b c )

\ Tagged addresses are denoted by [ADDR_NAME]
\ the word for them is TAG, which puts the
\ address inside the function in the return stack.

\ Values greater than $7F have to be encoded using the 16-bit-encode word

501 VALUE VERSION
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

: Label    5   API ;
: Forward  2   API ;
: FthNum   1   API ;
: Number   4   API ;
: Value    6   API ;
: Ip       7   API ;
: Ms       3   API ;

: antenna
	A 1 Number COLON FthNum SPACE
	A 2 Number COLON FthNum Forward
	A 3 Number COLON FthNum SPACE
	A 4 Number COLON FthNum Forward
;

: Dis
	NOP NOP NOP NOP		( ; DATA buffer )
	NOP NOP NOP NOP		( ; 16-byte chunk, able to store 4 ForthNumbers )
	NOP NOP NOP NOP
	NOP NOP NOP NOP

	0   Label		( label-id ; Main label, shows device name )
	VER Number		( device-version )
	Forward

	TAG NOP NOP NOP Forward	( ; [SCR_CODE1], allocated space for 2 calls, which is enough. )
	TAG NOP NOP NOP Forward	( ; [SCR_CODE2] )

	3   Label NOP		( label-id ; Main label #2, shows device connectivity )
	0   Value		( value-id )
	Forward

	0 API			( 0 ; C-Api call #0: Draw screen )
;

' Dis VALUE DATA	( ; Address of beginning of screen data buffer )
  R>  VALUE 2-CODE	( ; Address of the second screen code buffer )
  R>  VALUE 1-CODE	( ; Address of the first screen code buffer )

: 16-bit-encode!	( int16 addr -- )
	$BF			( int16 addr Lit-opcode      ; $BF is the opcode for pushing 16-bit integers to the stack )
	OVER C!			( int16 addr Lit-opcode addr ; writes a single byte LIT instruction to addr )
	1 +			( int16 addr +1              ; offsets addr by 1, right next to the LIT opcode )
	!			( int16 addr'                ; writes a 2-byte, i.e. 16-bit, signed integer to addr' )
;

: aligned-data!		( value idx align -- ; n-byte aligned 16-bit write to DATA buffer )
	*			( idx align   ; calculates ALIGN-byte *offset* )
	DATA +			( offset data ; calculates base DATA address + offset to get the indexed-address )
	16-bit-encode!		( iaddr       ; encodes value to specified DATA buffer index )
;

: byte-aligned-data!	( value idx align -- ; n-byte aligned 8-bit write to DATA buffer )
	*			( idx align   ; calculates ALIGN-byte *offset* )
	DATA +			( offset data ; calculates base DATA address + offset to get the indexed-address )
	C!			( iaddr       ; encodes value to specified DATA buffer index )
;

: Aligned-ForthNum!	( m v idx -- ; 4-byte aligned 16-bit write to DATA buffer + single-byte magnitude )
	4 *			( m v idx align   ; calculates ALIGN-byte *offset* )
	DATA +			( m v offset data ; calculates base DATA address + offset to get the indexed-address )
	DUP >R			( m v iaddr       ; saves a copy of indexed-addr for later ) 
	16-bit-encode!		( m v iaddr       ; encodes value to specified DATA buffer index )
	R>			( m   iaddr       ; restores indexed-addr from Rstack )
	3 +			( m   iaddr +3    ; offsets the indexed address by 3 bytes )
	C!			( m   iaddr'      ; writes the single-byte magnitude right next to the encoded value )
;

: Antenna!  		( m1 v1 m2 v2 m3 v3 m4 v4 -- ; magnitude and value for each antenna )
	3 write-ForthNum!   	( m1 v1 m2 v2 m3 v3 m4 v4 idx align )
	2 write-ForthNum!   	( m1 v1 m2 v2 m3 v3       idx align )
	1 write-ForthNum!	( m1 v1 m2 v2             idx align )
	0 write-ForthNum!	( m1 v1                   idx align )

	TAG NOP NOP		(             ; [ATN-PLC1] tagged placeholder for a 16-bit encoded CALL instruction )
	1-CODE !		( CODE-1-addr ; writes the 2-byte CALL instruction on the placeholder to CODE-1 )
;

: Compile!
;

' antenna			( addr-antenna )
$C000 OR			( addr-antenna CALL-opcode )
R> 16-bit-encode! 		( CALL-antenna tagged-addr ; fetching ATN-PLC1 and encoding a CALL instruction there )

500 DLY
50 0 TMI Dis
1 TME

