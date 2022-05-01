#include <xc.inc>

global	keypad_Setup, keypad_Read, column_check
extrn	LCD_Write_Message,LCD_Clear
psect	udata_acs   ; named variables in access ram
	column:	ds 1
	row:	ds 1
	kypd_counter:	ds 1
	kypd_delay_counter: ds 1
	kypd_smol_counter: ds 1
	kypd_tiny_counter: ds 1
	column_check: ds 1
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
	row1:    ds 0x40 ; reserve 128 bytes for message data
	row2:   ds 0x40 
	row3:   ds 0x40
	row4:   ds 0x40    
psect	data    
	; ******* myTable, data in programme memory, and its length *****
kypdTable:
	db	'M','I','E','A'
	db	'N','J','F','B'
	db	'7','K','G','C'
	db	'*','L','H','D'
	align	2	
psect	kypd_code,class=CODE
keypad_Setup:
	movlb	0x0F
	bsf	REPU
	movlb	0x00
	clrf	LATE, A
	
	movlw	low highword(kypdTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(kypdTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(kypdTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL

	movlw	0x04	; bytes to read
	movwf 	kypd_counter, A		; our counter register
	lfsr	0, row1	; Load FSR0 with address in RAM	
	call kypd_loop
	
	movlw	0x04	; bytes to read
	movwf 	kypd_counter, A		; our counter register
	lfsr	0, row2	; Load FSR0 with address in RAM	
	call kypd_loop
	
	movlw	0x04	; bytes to read
	movwf 	kypd_counter, A		; our counter register
	lfsr	0, row3	; Load FSR0 with address in RAM	
	call kypd_loop
	
	movlw	0x04	; bytes to read
	movwf 	kypd_counter, A		; our counter register
	lfsr	0, row4	; Load FSR0 with address in RAM	
	call kypd_loop
	
	lfsr	0, 0x544
	movlw	0x0
	movwf	POSTINC0, A
	
	return
	
keypad_Read:
	movlw	0x0F
	movwf	TRISE, A
	call	testrow ; sets fsr2 to the correct row
	movlw	0xF0
	movwf	TRISE, A
	movlw	0x0A
	movwf	kypd_delay_counter, A
	call	kypd_doolay
	call	testcolumn ; returns the column number
	movff	column, column_check, A
	movlw	0xFF
	movwf	TRISE, A
Test: ; increments the FSR2 to the correct location
	decfsz	column, A
	bra	keypad_loc
	return
keypad_loc:
	incf	FSR2, F, A
	bra Test
testrow: ; starts lfsr 2 at the correct row in memory for the stored keypad value
	lfsr	2, 0x540
	btfss	PORTE, 0b0011, a
	lfsr	2, row1
	btfss	PORTE, 0b0010, a
	lfsr	2, row2
	btfss	PORTE, 0b0001, a
	lfsr	2, row3
	btfss	PORTE, 0b0000, a
	lfsr	2, row4
	return
testcolumn: ; returns the column number the button press is located in
	movlw	0x005
	btfss	PORTE, 0b0111, a
	movlw	0x001
	btfss	PORTE, 0b0110, a
	movlw	0x002
	btfss	PORTE, 0b0101, a
	movlw	0x003
	btfss	PORTE, 0b0100, a
	movlw	0x004
	movwf	column, A
	return
	
kypd_loop: 	
	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	kypd_counter, A		; count down to zero
	bra	kypd_loop		; keep going until finished
	return	
	
kypd_delay:	
	movlw	0xFF
	movwf	kypd_smol_counter, A
	decfsz	kypd_delay_counter, A	; decrement until zero
	bra	kypd_smol
	return
kypd_smol:
	movlw	0xFF
	movwf	kypd_tiny_counter, A
	decfsz	kypd_smol_counter, A
	bra	kypd_tiny
	bra	kypd_delay
kypd_tiny:
	decfsz	kypd_tiny_counter, A
	bra	kypd_smol
	bra	kypd_tiny
kypd_doolay:
	decfsz	kypd_delay_counter, A
	bra	kypd_doolay
	return
    end

