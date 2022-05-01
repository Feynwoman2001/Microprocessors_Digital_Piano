#include <xc.inc>
    ;external subroutines
global	note_check, delay, delay_count, big_delay
extrn	begin_Read, play_game
extrn	LCD_Setup, LCD_Write_Message, LCD_Write_Hex, LCD_Clear,LCD_Hex_Nib; 	  
extrn	Note_Setup, N_l, N_h, Play_Note, play_melody, melody_setup
extrn 	keypad_Setup, keypad_Read, column_check, SetupSine, OutputSine, game_setup
	
psect	udata_acs   ; reserve data space in access ram
counter:    ds 1    ; reserve one byte for a counter variable
delay_count:ds 1    ; reserve one byte for counter in the delay routine
smol_counter:    ds 1    ; reserve one byte for a counter variable
tiny_counter:    ds 1    ; reserve one byte for a counter variable
mini_counter:    ds 1   ; reserve one byte for a counter variable
k:	ds 1
note_check: ds 1


psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup:	bcf	CFGS	; point to Flash program memory  
	bsf	EEPGD 	; access Flash program memory
	call    LCD_Setup	;setup LCD
	call	Note_Setup	;Setup note generation
	call	keypad_Setup	;setup keypad
	call	melody_setup	;setup preset melodies
	call	SetupSine   ;setup sine wave generation
	call	game_setup  ;setup game mode
	Z EQU 2	;Z on status wasnt working so 
	goto	start
	
	; ******* Main programme ****************************************	
start:
    movlw   0xFF
    call    delay
    call    keypad_Read	;reads keypad input and puts it in FSR2
    movff   INDF2, note_check, A
    movlw   0x05
    subwf   column_check, W,A
    bz	    start ;if nothing is input read it again
    
    movlw   0x02 
    CPFSGT  column_check,A ;if the input is in the second two columns skip
    goto    Note_Loop2
    goto    Note_Loop
    
Note_Loop: ;Branches to the timing definition for whatever note is selected
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
    goto    start
    
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
    BTFSC   STATUS, Z, A
    goto    N_G2
    movlw   0x2A
    subwf   note_check, W,A
    BTFSC   STATUS, Z, A
    goto    Sharp_loop ; if the sharp button is pressed goto the sharp loop
    movlw   0x37
    subwf   note_check, W,A
    BTFSC   STATUS, Z, A
    call    play_game ; if the game mode button is pressed begin the game
    goto    start
N_A: ; sets timeing parameters for A and plays the note
    movlw   177
    call    Play_Note
    goto    start
  
N_B: ; sets timeing parameters and plays the note
    movlw   157
    call    Play_Note
    goto    start
N_C:; sets timeing parameters and plays the note
    movlw   148
    call    Play_Note
    goto    start
N_D: ; sets timeing parameters and plays the note
    movlw   131
    call    Play_Note
    goto    start
N_E:; sets timeing parameters and plays the note
    movlw   116
    call    Play_Note
    goto    start
N_F:; sets timeing parameters and plays the note
    movlw   109
    call    Play_Note
    goto    start
N_G:; sets timeing parameters and plays the note
    movlw   97
    call    Play_Note
    goto    start
N_A2:; sets timeing parameters and plays the note
    movlw   86
    call    Play_Note
    goto    start
N_B2:; sets timeing parameters and plays the note
    movlw   76
    call    Play_Note
    goto    start
N_C2:; sets timeing parameters and plays the note
    movlw   71
    call    Play_Note
    goto    start
N_D2:; sets timeing parameters and plays the note
    movlw   63
    call    Play_Note
    goto    start
N_E2:; sets timeing parameters and plays the note
    movlw   56
    call    Play_Note
    goto    start 
N_F2:; sets timeing parameters and plays the note
    movlw   52
    call    Play_Note
    goto    start
N_G2:; sets timeing parameters and plays the note
    movlw   47
    call    Play_Note
    goto    start
  
    ; goto current line in code
    
Sharp_loop: ; Redos above code but takes you into a sharp timing loop for a button input
    movlw   0xFF
    movwf   delay_count,A
    call    big_delay
    call    keypad_Read
    movff   INDF2, note_check, A
    movlw   0x05
    subwf   column_check, W,A
    bz	    Sharp_loop
    movlw   0x2A    
    subwf   note_check, W,A
    bz	    Sharp_loop
    movlw   0x02
    CPFSGT  column_check,A
    goto    SharpNote_Loop2
    goto    SharpNote_Loop
    
SharpNote_Loop:
    movlw   0x41
    subwf   note_check, W,A
    bz	    N_A_sharp
    movlw   0x43
    subwf   note_check, W,A
    bz	    N_C_sharp
    movlw   0x44
    subwf   note_check, W,A
    bz	    N_D_sharp
    movlw   0x46
    subwf   note_check, W,A
    bz	    N_F_sharp
    movlw   0x47
    subwf   note_check, W,A
    bz	    N_G_sharp
    movlw   0x48
    subwf   note_check, W,A
    bz	    N_A2_sharp
    goto    start
    
SharpNote_Loop2:
    movlw   0x4A
    subwf   note_check, W,A
    bz	    N_C2_sharp
    movlw   0x4B
    subwf   note_check, W,A
    bz	    N_D2_sharp
    movlw   0x4D
    subwf   note_check, W,A
    bz	    N_F2_sharp
    movlw   0x4E
    subwf   note_check, W,A
    bz	    N_G2_sharp
    goto    start   
    ; Defines timings for sharp notes and plays the notes
N_A_sharp:
    movlw   167
    call    Play_Note
    goto    start
N_C_sharp:
    movlw   139
    call    Play_Note
    goto    start
N_D_sharp:
    movlw   124
    call    Play_Note
    goto    start
N_F_sharp:
    movlw   103
    call    Play_Note
    goto    start
N_G_sharp:
    movlw   91
    call    Play_Note
    goto    start
    
N_A2_sharp:
    movlw   81
    call    Play_Note
    goto    start
N_C2_sharp:
    movlw   67
    call    Play_Note
    goto    start
N_D2_sharp:
    movlw   59
    call    Play_Note
    goto    start
N_F2_sharp:
    movlw   49
    call    Play_Note
    goto    start
N_G2_sharp:
    movlw   43
    call    Play_Note
    goto    start
  
	
	; a delay subroutine if you need one, times around loop in delay_count
delay:	decfsz	delay_count, A	; decrement until zero
	bra	delay
	return
	; A large embedded delay
big_delay:
	movlw	0x0F
	movwf	smol_counter, A
	decfsz	delay_count, A	; decrement until zero
	bra	delay_smol
	return
delay_smol:
	movlw	0x0F
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

	end	rst