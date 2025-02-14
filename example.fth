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

\ functions tagged with an asterisk(*) need to be double checked for duplicate names, consider only the first 3 chars!!
\ they are also EXTERNAL, DO NOT CALL THEM IN THIS SOURCE CODE!

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

501 VALUE VERSION

\ The screen

: Dis			( -- ; Screen buffer )
	NOP NOP NOP NOP
	NOP NOP NOP NOP
	NOP NOP NOP NOP
	NOP NOP NOP NOP

	0       Label		( label-id ; Main label, shows device name )
	VERSION Number		( device-version )
	Forward

	TAG NOP NOP NOP Forward ( COMPILE TIME: tagged-addr )
	TAG NOP NOP NOP Forward ( COMPILE TIME: tagged-addr tagged-addr-2 )

	3       Label NOP	( label-id ; Main label #2, shows device connectivity )
	0       Value		( value-id )
	Forward

	0 API			( 0 ; C-Api call #0: Draw screen )
;

VALUE 2-CODE     ( tagged-addr tagged-addr-2 ; Address of the second screen code buffer )
VALUE 1-CODE     ( tagged-addr ; Address of the first screen code buffer )

' Dis VALUE DATA ( ; Address of beginning of screen data buffer )

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

: calc-align		( idx align addr -- iaddr ; calculates aligned offset of the specified index )
	>R			( idx align addr )
	*			( idx align      ; calculates ALIGN-byte *offset* )
	R>			( offset         )
	+			( offset addr    ; calculates base address + offset to get the indexed-address )
;

\ ======================

\ Aligned writes

: aligned-data!		( value idx align -- ; n-byte aligned 16-bit write to DATA buffer )
	DATA calc-align		( value idx align )
	16-bit-encode!		( value iaddr     ; encodes value to specified DATA buffer index )
;

: aligned-data-C!	( value idx align -- ; n-byte aligned 8-bit write to DATA buffer )
	DATA calc-align		( value idx align )
	C!			( value iaddr     ; encodes value to specified DATA buffer index )
;

: aligned-data-Big!	( m v idx -- ; 4-byte aligned BigNumber write to DATA buffer, refer to the BigNumber type )
	4			( value idx align ; this one has fixed alignment because 4 is the max size )
	DATA calc-align		( value idx align ; each BigNumber has a 3-byte encoded value + a single-byte magnitude )
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

: call! 		( word-addr target-addr -- ; writes a call instruction in target-addr )
	prepare-call		( word-addr        target-addr ; )
	!			( call-instruction target-addr ; writes the created call instruction, modifying target-addr )
;

: call-idx!		( word-addr idx code-addr -- ; writes a call instruction to aligned offset )
	>R			( word-addr idx align code-addr ; storing code-addr )
	2 R>			( word-addr idx align           ; retrieving code-addr, to reorder )
	calc-align		( word-addr idx align code-addr ; 2-byte call )
	call!			( word-addr indexed-addr )
;

\ ======================

\ Screen-specific words

: Antenna!   		( m1 v1 m2 v2 m3 v3 m4 v4 -- ; magnitude and value for each antenna )
	0 aligned-data-Big!	( m1 v1 m2 v2 m3 v3 m4 v4 idx )
	1 aligned-data-Big!	( m1 v1 m2 v2 m3 v3       idx )
	2 aligned-data-Big!	( m1 v1 m2 v2             idx )
	3 aligned-data-Big!	( m1 v1                   idx )
;

\ LABELS:
\ 0   PORTAL   My
\ 1   ATLETAS
\ 2   REGIST.
\ 3   COMUNICANDO
\ 4   LEITOR
\ 5   LTE/4G:
\ 6   WIFI:
\ 7   IP:
\ 8   LOCAL:
\ 9   PROVA:
\ 10  PING:
\ 11  HORA:
\ 12  USB:
\ 13  AGUARDE...
\ 14  ERRO TENTAR,
\ 15    NOVAMENTE
\
\ 16  RFID  -
\ 17  SERIE:
\ 18  SIST.
\
\ 19  PRESSIONE,
\ 20  PARA CONFIRMAR
\
\ 21  OFFLINE
\ 22  DATA:
\
\ VALUES:
\ 0   WEB
\ 1   CONECTAD
\ 2   DESLIGAD
\ 3   AUTOMATIC
\ 4   OK
\ 5   X
\ 6   A
\ 7   COLON

\ Examples:
\	Antenna:

\         3 50 1 500 1 650 3 5 Antenna!
\         ' antenna 1-CODE call!

\	Tags+Unicas:

\ 	  $22 12 1 aligned-data-C!
\ 	  $02 13 1 aligned-data-C!
\ 	  ' Label 0 2-CODE call-idx! ' Number 1 2-CODE call-idx!
\
\ 	  $22 14 1 aligned-data-C!
\ 	  $01 15 1 aligned-data-C!
\ 	  ' Label 0 1-CODE call-idx! ' Number 1 1-CODE call-idx!

\	Or in shorthand form:

\	  $22 14 1 adC
\	  $01 15 1 adC
\	  Lbl 0 1-C ci! Num 1 1-C ci!

\ ======================

\ User interaction-related words and state

VARIABLE action

VARIABLE current-screen
1 current-screen !

VARIABLE arrow-state
VARIABLE confirm-state

7 VALUE arrow-pin
6 VALUE confirm-pin

: arrow-pressed?
	arrow-pin IN 0 =
;

: confirm-pressed?
	confirm-pin IN 0 =
;

: next-screen
	current-screen @ ( ; fetch current screen )
	1 + 7 MOD	 ( current-screen +1 mod-7 )
	current-screen ! ( current-screen' )
;

\ NOTE: both DUP >R and *Addr* DUP @ >R have no practical effect on the main stack, chill.

: update-state		( button-pressed? state-addr -- new-state old-state )
	DUP @ >R		( button-pressed? state-addr ; )
	DUP   >R		( button-pressed? state-addr ; )
	!

	R>			( ; )
	R>			( new-state ; )
;

: update-arrow-state
	arrow-pressed? arrow-state
	update-state
;

: update-confirm-state
	confirm-pressed? confirm-state
	update-state
;

: clicked?	( new-state old-state -- clicked? ; checks if the button has just been clicked )
	NOT		( new-state old-state -- new-state ~old-state )
	AND		( new-state ~old-state )
;

: do-button		( -- )
	update-arrow-state
	clicked? IF
		next-screen
	THEN

	update-confirm-state
	clicked? IF
		-1 action !
	THEN
;

\ ======================

\ Extern signatures in alphabetical order

\            ___
1-CODE VALUE 1-C*	( ; extern )
2-CODE VALUE 2-C*	( ; extern )

\ ___
: Atn* Antenna!          ; ( I8 I16 I8 I16 I8 I16 I8 I16 ; extern )
: ad!* aligned-data!     ; ( I16      idx align          ; extern )
: adB* aligned-data-Big! ; ( I8 I16   idx                ; extern )
: adC* aligned-data-C!   ; ( I8       idx align          ; extern )
: ci!* call-idx!	 ; ( U16-addr idx U16-addr       ; extern )
: Dis* Dis               ; (                             ; extern )

' Label   VALUE Lbl* ( ; extern )
' Forward VALUE Fwd* ( ; extern )
' BigNum  VALUE Big* ( ; extern )
' Number  VALUE Num* ( ; extern )
' Value   VALUE Val* ( ; extern )
' Ip      VALUE IP-* ( ; extern )
' Ms      VALUE MS-* ( ; extern )
' antenna VALUE atn* ( ; extern )

\ ======================

\ Initialization

1500 DLY
\ 50 0 TMI Dis
\ 10 1 TMI do-button
1 TME

\ ======================

