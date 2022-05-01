#include <xc.inc>
global	SetupSine, OutputSine, wait
extrn	delay_x1us
psect	udata_acs   ; named variables in access ram
	sinelencount:	ds 1
    counter: ds 1
    outcheck: ds 1
    delay_cnt_low: ds 1
    wait: ds 1
psect	data    
	; ******* myTable, data in programme memory, and its length *****
sineTable: ; lookup table for producing a sinusoid
    db 128, 136, 143, 151, 159, 167, 174, 182, 189, 196, 202, 209, 215, 220
    db 226, 231, 235, 239, 243, 246, 249, 251, 253, 254, 255, 255, 255, 254
    db 253, 251, 249, 246, 243, 239, 235, 231, 226, 220, 215, 209, 202, 196
    db 189, 182, 174, 167, 159, 151, 143, 136, 128, 119, 112, 104,  96,  88
    db 81,  73,  66,  59,  53,  46,  40,  35,  29,  24,  20,  16,  12,   9
    db 6,   4,   2,   1,   0,   0,   0,   1,   2,   4,   6,   9,  12,  16
    db 20,  24,  29,  35,  40,  46,  53,  59,  66,  73,  81,  88,  96, 104
    db 112, 119, 127
    align 2
    len EQU 100
psect	udata_bank7 ; reserve data anywhere in RAM (here at 0x400)
	sine:    ds 0x70 ; reserve 128 bytes for message data
psect	sine_code,class=CODE
SetupSine:
    movlw   0x00
    movwf   TRISF, A
    movlw   0x00
    movwf   TRISD,A
    
	movlw	low highword(sineTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(sineTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(sineTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL

	movf	len, W, A	; bytes to read
	movwf 	sinelencount, A		; our counter register
	lfsr	0, sine	; Load FSR0 with address in RAM
	call	sinetab_loop
	return
OutputSine:
Out:
    movlw   0x00 ; sets D to output
    movwf   TRISD, A
    lfsr    2, sine ; initialises lfsr2 as the correct spot
    movlw   100	; number of items in sinevlookup
    movwf   counter, A
loop: ; outputs each value from the lookup with specific timing determined by 'wait'
    movlw   0x01
    movwf   PORTF, A ; switches on DAC write
    movf    POSTINC2, W, A ; Writes sine value to Port D
    movwf   PORTD, A
    movf    wait, W, A ; waits for the required amount of time for the note
    call    delay_x1_4us
    movlw   0x00
    movwf   PORTF, A ; turns off DAC write
    decfsz  counter, A
    bra	    loop
    return
sinetab_loop: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	sinelencount, A		; count down to zero
	bra	sinetab_loop		; keep going until finished
	return	  
delay_x1_4us: ; quarter microsecond delay
	movwf	delay_cnt_low, A
lp2:
	nop
	decf	delay_cnt_low, F, A
	bc	lp2
	return

