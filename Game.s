#include <xc.inc>
global	play_game,game_setup
extrn	play_melody_loop, big_delay,LCD_Clear,LCD_Write_Message,mel_check,begin_Read
extrn	melody1,melody1note,melody1time,melody2,melody2note,melody2time,mel_counter,melody3,melody3note,melody3time
extrn	LCD_Send_Byte_I,played,melody4,melody4note,melody4time
psect	data    
	; ******* myTable, data in programme memory, and its length *****
gameTable:
	db	'S','U','C','C','E','S','S','!'
	db	'F','A','I','L','U','R','E','!'
	align 2
psect	udata_bank8 ; reserve data anywhere in RAM (here at 0x600)
	s:    ds 0x09
	fail:	ds 0x09
	
psect	udata_acs   ; named variables in access ram
EndLen: ds 1
    end_count: ds 1
    loop:ds 1
psect	game_code,class=CODE
game_setup:
	movlw	0x08
	movwf	EndLen, A
	
	movlw	low highword(gameTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(gameTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(gameTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL

	movf	EndLen, W, A	; bytes to read
	movwf 	end_count, A		; our counter register
	lfsr	0, s	; Load FSR0 with address in RAM
	call	game_loop
	movf	EndLen, W, A	; bytes to read
	movwf 	end_count, A		; our counter register
	lfsr	0, fail	; Load FSR0 with address in RAM
	call	game_loop
game_loop: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	end_count, A		; count down to zero
	bra	game_loop		; keep going until finished
	return
play_game:
play_melody:
	movlw	0xFF
	movwf	TRISD, A
	call	big_delay
	movff	PORTD, mel_check ; d
	movlw	0x00
	CPFSGT	mel_check, A ; goto selected melody
	bra	mel_1
	movlw	0x01
	CPFSGT	mel_check, A	
	bra	mel_2
	movlw	0x02
	CPFSGT	mel_check, A
	bra	mel_3
	bra	mel_4
mel_1:
	movf	melody1, W, A
	movwf	mel_counter, A
	lfsr	0, melody1note
	lfsr	1, melody1time
	call	play_melody_loop
	call	LCD_Clear
	movff	melody1, mel_counter
	lfsr	2, melody1note
	lfsr	1, melody1note
	goto	Output_mel
mel_2:	
	movf	melody2, W, A
	movwf	mel_counter, A
	lfsr	0, melody2note
	lfsr	1, melody2time
	call	play_melody_loop
	call	LCD_Clear
	movff	melody2, mel_counter
	lfsr	2, melody2note
	lfsr	1, melody2note
	goto	Output_mel
mel_3:	
	movf	melody3, W, A
	movwf	mel_counter, A
	lfsr	0, melody3note
	lfsr	1, melody3time
	call	play_melody_loop
	call	LCD_Clear
	movff	melody3, mel_counter
	lfsr	2, melody3note
	lfsr	1, melody3note
	goto	Output_mel
mel_4:	
	movf	melody4, W, A
	movwf	mel_counter, A
	lfsr	0, melody4note
	lfsr	1, melody4time
	call	play_melody_loop
	call	LCD_Clear
	movff	melody4, mel_counter
	lfsr	2, melody4note
	lfsr	1, melody4note
	goto	Output_mel
Output_mel:
	movf	mel_counter, W, A
	call	LCD_Write_Message
	movlw	11000000B
	call	LCD_Send_Byte_I
	call	begin_Read
	lfsr	0, played
	movlw	0x04
	movwf	loop, A
delay_loop:
	call	big_delay
	decfsz	loop, A
	bra delay_loop
	call	LCD_Clear
check_msg:
	movf	POSTINC0, W, A
	subwf	POSTINC1, W, A
	BTFSS	STATUS,	2, A
	goto	Fail
	decfsz	mel_counter, A
	bra	check_msg
	goto	Success	
	return
Fail:
    movf   EndLen, W, A
    lfsr    2,	fail
    call    LCD_Write_Message
    return
Success:
    movf  EndLen, W, A
    lfsr    2,	s
    call    LCD_Write_Message
    return

