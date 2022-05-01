#include <xc.inc>
    global  Note_Setup, Play_Note, Play_Note_mel, delay_x1us
    global  N_l, N_h
    extrn   keypad_Read, note_check, OutputSine,wait
    psect	udata_acs   ; reserve data space in access ram
	N_h: ds 1
	N_l: ds 1
	dum: ds 1
	LoopLen: ds 1
	delay_cnt_low: ds 1
	delay_cnt_high: ds 1
    note_check_dum: ds 1
psect	Note_code,class=CODE
Note_Setup:
    movlw   0x0
    movwf   TRISJ, A ; sets TRISJ as output
    return
    
Play_Note_mel: ; plays note for length of time specified in the melody
    movwf   LoopLen,A
Note_Loop_mel:
    call    OutputSine ; outputs one wavelength of the sine wave
    decfsz  LoopLen,A
    bra	    Note_Loop_mel
    return
    
 Play_Note: ; sets the frequency
    movwf   wait, A
 Playit: ; outputs 20 period sinusoid pulse
    movlw   20
    movwf   LoopLen,A
    Sine:
    call    OutputSine
    decfsz  LoopLen,A
    bra	    Sine
    ;if the same button is still being pressed play it again- saves a lot of processing and allows sharp button to work
    movlw   0x01
    call    delay_x1us
    call    keypad_Read
    movff   INDF2, note_check_dum, A
    movf   note_check_dum, W,A
    subwf   note_check, W,A
    bz	    Playit
    return  
    
Play_Note1: ; old playnote using a square wave
    movlw   0x20
    movwf   LoopLen,A
Note_Loop1:
    movlw   0x01
    movwf   PORTJ, A
    call    N_delay
    movlw   0x00
    movwf   PORTJ, A
    call    N_delay
    decfsz  LoopLen,A
    bra	    Note_Loop1
    
    movlw   0x01
    call    delay_x1us
    call    keypad_Read
    movff   INDF2, note_check_dum, A
    movf   note_check_dum, W,A
    subwf   note_check, W,A
    bz	    Play_Note1
    return
    
N_delay: ; delay used to make square wave half period Nh,Nl
    call    N_256
Jump:
    movf    N_l, W, A
    call    delay_x1us
    return
N_256:
    movff   N_h, dum, A
N_inner:
    movlw   64
    call    delay_x4us
    decfsz  dum, A
    bra	    N_inner   
    return
    
delay_x1us: ; 1 us delay
	movwf	delay_cnt_low, A
lp2:
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	decf	delay_cnt_low, F, A
	bc	lp2
	return
delay_x4us: ;4us delay
	movwf	delay_cnt_low, A
	swapf	delay_cnt_low, F, A
	movlw	0x0f
	andwf	delay_cnt_low, W, A
	movwf	delay_cnt_high, A
	movlw	0xf0
	andwf	delay_cnt_low, F, A
	call	delay_basic
	return
delay_basic:
	movlw 0x00
lp1:
	decf	delay_cnt_low, F, A
	subwfb	delay_cnt_high, F, A
	bc	lp1
	return
	end
    
 
    


