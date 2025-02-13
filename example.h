#ifndef __example_FTH__
#define __example_FTH__
const char code[] PROGMEM =
#define NL "\n"
    "501 VAL v33" NL "6 VAL v94" NL "7 VAL v72" NL "VAR v8" NL "VAR v52" NL
    "VAR v76" NL "VAR v80" NL "VAR v79" NL "VAR v17" NL ": w68" NL
    "v94 IN 0 =" NL ";" NL ": w8" NL "v72 IN 0 =" NL ";" NL ": w97" NL
    "DUP ROT SWP" NL "NOT AND" NL ";" NL ": w59" NL "IF" NL "v8 @ 1 +" NL
    "7 MOD" NL "v8 !" NL "THN" NL ";" NL ": w0 5 API ;" NL ": w87 2 API ;" NL
    ": w75 1 API ;" NL ": w64 4 API ;" NL ": w70 6 API ;" NL ": w72 7 API ;" NL
    ": w33 3 API ;" NL ": w28" NL "7 6 API  1 w64  8 6 API  w75  6 6 API " NL
    "7 6 API  2 w64  8 6 API  w75 w87" NL
    "7 6 API  3 w64  8 6 API  w75  6 6 API " NL
    "7 6 API  4 w64  8 6 API  w75 w87" NL ";" NL ": w86" NL "NOP NOP NOP NOP" NL
    "NOP NOP NOP NOP" NL "NOP NOP NOP NOP" NL "NOP NOP NOP NOP" NL "0 w0" NL
    "v33 w64" NL "w87" NL "TAG NOP NOP NOP w87" NL "TAG NOP NOP NOP w87" NL
    "3 w0 NOP" NL "0 w70" NL "w87" NL "0 API" NL ";" NL "' w86 VAL v36" NL
    "R> VAL v73" NL "R> VAL v50" NL ": w84" NL "$BF" NL "OVR C!" NL "1 +" NL
    "!" NL ";" NL ": w90" NL "DUP >R" NL "w84" NL "R>" NL "3 +" NL "C!" NL
    ";" NL ": w27" NL "*" NL "v36 +" NL ";" NL ": w48" NL "w27" NL "w84" NL
    ";" NL ": w34" NL "w27" NL "C!" NL ";" NL ": w18" NL "4 w27" NL "w90" NL
    ";" NL ": w52" NL ">R" NL "$C000 OR" NL "R>" NL ";" NL ": w19" NL "w52" NL
    "w84" NL ";" NL ": w76" NL "w52" NL "!" NL ";" NL ": w67" NL "3 w18" NL
    "2 w18" NL "1 w18" NL "0 w18" NL ";" NL "500 DLY" NL "50 0 TMI w86" NL
    "1 TME" NL
    // w68	->	MainPressed?
    // w8	->	AltPressed?
    // w97	->	Button?
    // w59	->	ScreenNext
    // w0	->	Label
    // w87	->	Forward
    // w75	->	BigNum
    // w64	->	Number
    // w70	->	Value
    // w72	->	Ip
    // w33	->	Ms
    // w28	->	antenna
    // w86	->	Dis
    // w84	->	16-bit-encode!
    // w90	->	F!
    // w27	->	calc-align
    // w48	->	aligned-data!
    // w34	->	aligned-data-C!
    // w18	->	aligned-data-Big!
    // w52	->	prepare-call
    // w19	->	encode-call!
    // w76	->	call!
    // w67	->	Antenna!
    // v33	->	VERSION
    // v94	->	mIN
    // v72	->	aIN
    // v8	->	Scr
    // v52	->	mRL
    // v76	->	Mac
    // v80	->	mST
    // v79	->	Aac
    // v17	->	aST
    // v36	->	DATA
    // v73	->	2-CODE
    // v50	->	1-CODE
    ;
#endif
