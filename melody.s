#include <xc.inc>
global	melody_setup, play_melody, play_melody_loop, mel_check,melody4,melody4note,melody4time
global	melody1,melody1note,melody1time,melody2,melody2note,melody2time,mel_counter,melody3,melody3note,melody3time
extrn	note_check, Play_Note_mel, N_l, N_h, delay, wait
psect	udata_acs   ; named variables in access ram
	mel_check: ds 1
	timeh:	ds 1 ;upper value for timings
	timel: ds 1 ;lower value for timings
	curr_note: ds 1
	mel_counter: ds 1
	delay_count:ds 1    ; reserve one byte for counter in the delay routine
	smol_counter:    ds 1    ; reserve one byte for a counter variable
	tiny_counter:    ds 1    ; reserve one byte for a counter variable
	mini_counter:    ds 1   
	melody1: ds 1
	melody2: ds 1
	melody3: ds 1
	melody4: ds 1
psect	udata_bank6 ; reserve data anywhere in RAM (here at 0x600)
	melody1note:    ds 0x10 ; reserve 16 bytes for message data
	melody1time: ds 0x20 ; reserve 32 bytes for timings
	melody2note:    ds 0x10 
	melody2time: ds 0x20
	melody3note:    ds 0x10 
	melody3time: ds 0x20
	melody4note:    ds 0x10 
	melody4time: ds 0x20
psect	data    
	; ******* myTable, data in programme memory, and its length *****
melodyTable: ; stores the melodies and the length of each note in periods
	db	'A','C','D','D','D','E','F','F','F','G','E','E','D','C','C','D'
	db	0x00,0x5C,0x00,0x6D,0x00,0xF5,0x00,0xF5,0x00,0x7A,0x00,0x89,0x01,0x23,0x01,0x23
	db	0x00,0x91,0x00,0xA3,0x01,0x13,0x01,0x113,0x00,0x7A,0x00,0x6D,0x00,0x6D,0x00,0xF5 
	db	'c','f','g','H','g','f','D','D','f','g','H','g','f','c'
	db	0x00,0x73,0x00,0x9A,0x00,0xAD,0x00,0xB7,0x00,0xAD,0x00,0x9A,0x02,0xDC
	db	0x00,0x7A,0x00,0x9A,0x00,0xAD,0x00,0xB7,0x00,0xAD,0x00,0x9A,0x02,0xB2
	db	'G','K','J','I','H','N','K','J','I','H','N','K','J','I','J','H'
	db	0x01,0x88,0x02,0x4C,0x00,0x57,0x00,0x53,0x00,0x4A,0x03,0x10,0x01,0x26,0x00,0x57
	db	0x00,0x53,0x00,0x4A,0x03,0x10,0x01,0x26,0x00,0x57,0x00,0x53,0x00,0x4A,0x01,0xB8
	db	'E','f','G','f','H','G','f','E','I','j','K','K','j','H','j','I'
	db	0x01,0x8C,0x00,0xDE,0x00,0xEA,0x00,0xDE,0x01,0x08,0x00,0xEA,0x01,0x4D,0x03,0x7A
	db	0x01,0x29,0x01,0x4D,0x02,0xC1,0x01,0x61,0x01,0x4D,0x01,0x08,0x01,0x4D,0x03,0x7A
	align 2
	
psect	melody_code,class=CODE
melody_setup: ; set melody lengths
	movlw	0x10
	movwf	melody1,A
	movlw	0x0E
	movwf	melody2,A
	movlw	0x10
	movwf	melody3,A
	movlw	0x10
	movwf	melody4,A
	
	movlw	low highword(melodyTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(melodyTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(melodyTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL

	movf	melody1, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	lfsr	0, melody1note	; Load FSR0 with address in RAM
	call	mel_loop
	
	movf	melody1, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	lfsr	0, melody1time	; Load FSR0 with address in RAM
	call	mel_loop
	movf	melody1, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	call	mel_loop

	movf	melody2, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	lfsr	0, melody2note	; Load FSR0 with address in RAM
	call	mel_loop
	
	movf	melody2, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	lfsr	0, melody2time	; Load FSR0 with address in RAM
	call	mel_loop
	movf	melody2, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	call	mel_loop
	
	movf	melody3, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	lfsr	0, melody3note	; Load FSR0 with address in RAM
	call	mel_loop
	
	movf	melody3, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	lfsr	0, melody3time	; Load FSR0 with address in RAM
	call	mel_loop
	movf	melody3, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	call	mel_loop
	
	movf	melody4, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	lfsr	0, melody4note	; Load FSR0 with address in RAM
	call	mel_loop
	
	movf	melody4, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	lfsr	0, melody4time	; Load FSR0 with address in RAM
	call	mel_loop
	movf	melody4, W,A	; bytes to read
	movwf 	mel_counter, A		; our counter register
	call	mel_loop
	return
	
play_melody:
	movlw	0xFF ; sets PORTD to input
	movwf	TRISD, A
	call	big_delay
	movff	PORTD, mel_check
	movlw	0x00
	CPFSGT	mel_check,A ; goto selected melody
	bra	mel_1
	movlw	0x01
	CPFSGT	mel_check,A	
	bra	mel_2
	bra	mel_3
mel_1:
	movf	melody1, W ,A; initliases lfsr0 and lfsr1 at the locations for the notes and timings
	movwf	mel_counter, A ; sets the number of notes in the melody
	lfsr	0, melody1note
	lfsr	1, melody1time
	goto	play_melody_loop
mel_2:	
	movf	melody2, W,A
	movwf	mel_counter, A
	lfsr	0, melody2note
	lfsr	1, melody2time
	goto	play_melody_loop
	
mel_3:	
	movf	melody3, W,A
	movwf	mel_counter, A
	lfsr	0, melody3note
	lfsr	1, melody3time
	goto	play_melody_loop
	
play_melody_loop:
	movff	POSTINC0, curr_note
	movff	curr_note, note_check
	movff	POSTINC1, timeh
	movff	POSTINC1, timel
	movlw	0x60 ; determines whether or not a sharp note is to be played and moves location accordingly
	CPFSLT	curr_note,A
	goto	Sharp_Loop
	movlw	0x48
	CPFSGT	curr_note,A ; goes to different sets of notes to save processing
	goto	Note_Loop
	goto	Note_Loop2
	
start_mel:	
	movwf	wait, A ; sets the wait variable, determines the frequency
	movlw	0x00
	CPFSEQ	timeh,A
	call	big_play ; plays the notes of the time required
	call	small_play
	call	big_delay ; small break at end to make notes more defined
	decfsz	mel_counter,A ; if all notes have been played exit
	bra	play_melody_loop ;go to play next note
	return
	
big_play:
	movlw	0xFF ; plays note 256 times for each value in timeh
	call	Play_Note_mel
	decfsz	timeh,A
	bra	big_play
	return
	
small_play: ; plays note for every value in timel
	movf	timel,W,A
	call	Play_Note_mel
	return
	
Note_Loop:
    movlw   0x41
    subwf   note_check, W,A
    bz	    N_A
    movlw   0x42
    subwf   note_check, W,A
    bz	    N_B
    movlw   0x43
    subwf   note_check, W,A
    bz	    N_C
    movlw   0x44
    subwf   note_check, W,A
    bz	    N_D
    movlw   0x45
    subwf   note_check, W,A
    bz	    N_E
    movlw   0x46
    subwf   note_check, W,A
    bz	    N_F
    movlw   0x47
    subwf   note_check, W,A
    bz	    N_G
    movlw   0x48
    subwf   note_check, W,A
    bz	    N_A2
    
Note_Loop2:
   
    movlw   0x49
    subwf   note_check, W,A
    bz	    N_B2
    movlw   0x4A
    subwf   note_check, W,A
    bz	    N_C2
    movlw   0x4B
    subwf   note_check, W,A
    bz	    N_D2
    movlw   0x4C
    subwf   note_check, W,A
    bz	    N_E2
    movlw   0x4D
    subwf   note_check, W,A
    bz	    N_F2
    movlw   0x4E
    subwf   note_check, W,A
    bz	    N_G2
   
N_A:
    movlw   177
    goto    start_mel
  
N_B:
    movlw   157
    goto    start_mel
N_C:
    movlw   148
    goto    start_mel
N_D:
    movlw   131
    goto    start_mel
N_E:
    movlw   116
    goto    start_mel
N_F:
    movlw   109
    goto    start_mel
N_G:
    movlw   97
    goto    start_mel
N_A2:
    movlw   86
    goto    start_mel
N_B2:
    movlw   76
    goto    start_mel
N_C2:
    movlw   71
    goto    start_mel
N_D2:
    movlw   63
    goto    start_mel
N_E2:
    movlw   56
    goto    start_mel 
N_F2:
    movlw   52
    goto    start_mel
N_G2:
    movlw   47
    goto    start_mel
    
Sharp_Loop:
    movlw   0x61
    subwf   note_check, W,A
    bz	    N_A_sharp
    movlw   0x63
    subwf   note_check, W,A
    bz	    N_C_sharp
    movlw   0x64
    subwf   note_check, W,A
    bz	    N_D_sharp
    movlw   0x66
    subwf   note_check, W,A
    bz	    N_F_sharp
    movlw   0x67
    subwf   note_check, W,A
    bz	    N_G_sharp
    movlw   0x68
    subwf   note_check, W,A
    bz	    N_A2_sharp
    movlw   0x6A
    subwf   note_check, W,A
    bz	    N_C2_sharp
    movlw   0x6B
    subwf   note_check, W,A
    bz	    N_D2_sharp
    movlw   0x6D
    subwf   note_check, W,A
    bz	    N_F2_sharp
    movlw   0x6E
    subwf   note_check, W,A
    bz	    N_G2_sharp
    
N_A_sharp:
    movlw   167
    goto    start_mel
N_C_sharp:
    movlw   139
    goto    start_mel
N_D_sharp:
    movlw   124
    goto    start_mel
N_F_sharp:
    movlw   103
    goto    start_mel
N_G_sharp:
    movlw   91
    goto    start_mel
    
N_A2_sharp:
    movlw   81
    goto    start_mel
N_C2_sharp:
    movlw   67
    goto    start_mel
N_D2_sharp:
    movlw   59
    goto    start_mel
N_F2_sharp:
    movlw   49
    goto    start_mel
N_G2_sharp:
    movlw   43
    goto    start_mel   
mel_loop: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	mel_counter, A		; count down to zero
	bra	mel_loop		; keep going until finished
	return	
	
big_delay:	
	movlw	0x0F
	movwf	smol_counter, A
	decfsz	delay_count, A	; decrement until zero
	bra	delay_smol
	return
delay_smol:
	movlw	0x04
	movwf	mini_counter, A
	decfsz	smol_counter, A
	bra	delay_mini
	bra	big_delay
delay_mini:
	movlw	0x0F
	movwf	tiny_counter, A
	decfsz	mini_counter, A
	bra	delay_tiny
	bra	delay_smol
delay_tiny:
	decfsz	tiny_counter, A
	bra	delay_tiny
	bra	delay_mini   
		