#include <xc.inc>
global	begin_Read,played
extrn	Note_Setup, N_l, N_h, Play_Note, play_melody, melody_setup
extrn 	keypad_Setup, keypad_Read, column_check, note_check, delay
extrn	LCD_Write_Message, delay_count, LCD_Clear, LCD_Setup
psect	udata_acs   ; reserve data space in access ram
songLen:    ds 1    ; reserve one byte for a counter variable	
smol_counter:    ds 1    ; reserve one byte for a counter variable
tiny_counter:    ds 1    ; reserve one byte for a counter variable
mini_counter:    ds 1   
save_note:	 ds 1
psect	udata_bank8 ; reserve data anywhere in RAM (here at 0x600)
	played:    ds 0x40 ; reserve 128 bytes for message data
psect	NoteRead_code,class=CODE
    
begin_Read:
    Z EQU 2
    lfsr    0, played ; reinitialises lfsr0 to prepare to store melody
    movlw   0x0
    movwf   songLen, A
    movwf   INDF0, A
start:
    movlw   0xFF
    movwf   delay_count,A
    call    delay
    call    keypad_Read ; read keypad
    movff   INDF2, note_check, A
    movlw   0x05
    subwf   column_check, W,A
    bz	    start ; nothing input then read again
    
    movlw   0x02
    CPFSGT  column_check,A ; otherwise determine the pressed note
    goto    Note_Loop2
    goto    Note_Loop
play: 
    call    Play_Note ; output the note for however long it is pressed
    movff   save_note, POSTINC0 ; saves the note in LFSR2
    incf    songLen, A ; increments the song length
    goto    start ; prrepares for next note
end_song: ; when game mode is pressed again
    movlw   0x0
    CPFSGT  songLen,A
    return
    lfsr    2, played
    movf   songLen, W,A
    call    LCD_Write_Message ; output the stored melody
    call    big_delay
    return ; exit
    
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
    goto    end_song ; if the game mode button is pressed begin the game
    goto    start
N_A:
    movlw   177
    movff   note_check, save_note
    goto    play
  
N_B:
    movlw   157
    movff   note_check, save_note
    goto    play
N_C:
    movlw   148
    movff   note_check, save_note
    goto    play
N_D:
    movlw   131
    movff   note_check, save_note
    goto    play
N_E:
    movlw   116
    movff   note_check, save_note
    goto    play
N_F:
    movlw   109
    movff   note_check, save_note
    goto    play
N_G:
    movlw   97
    movff   note_check, save_note
    goto    play
N_A2:
    movlw   86
    movff   note_check, save_note
    goto    play
N_B2:
    movlw   76
    movff   note_check, save_note
    goto    play
N_C2:
    movlw   71
    movff   note_check, save_note
    goto    play
N_D2:
    movlw   63
    movff   note_check, save_note
    goto    play
N_E2:
    movlw   56
    movff   note_check, save_note
    goto    play 
N_F2:
    movlw   52
    movff   note_check, save_note
    goto    play
N_G2:
    movlw   47
    movff   note_check, save_note
    goto    play
  
    ; goto current line in code
    
Sharp_loop: 
    movlw   0xFF
    movwf   delay_count, A
    call    big_delay
    call    keypad_Read
    movff   INDF2, note_check, A
    movlw   0x05
    subwf   column_check, W, A
    bz	    Sharp_loop
    movlw   0x2A    
    subwf   note_check, W, A
    bz	    Sharp_loop
    movlw   0x02
    CPFSGT  column_check, A
    goto    SharpNote_Loop2
    goto    SharpNote_Loop
    
SharpNote_Loop:
    movlw   0x41
    subwf   note_check, W, A
    bz	    N_A_sharp
    movlw   0x43
    subwf   note_check, W, A
    bz	    N_C_sharp
    movlw   0x44
    subwf   note_check, W, A
    bz	    N_D_sharp
    movlw   0x46
    subwf   note_check, W, A
    bz	    N_F_sharp
    movlw   0x47
    subwf   note_check, W, A
    bz	    N_G_sharp
    movlw   0x48
    subwf   note_check, W, A
    bz	    N_A2_sharp
    goto    start
    
SharpNote_Loop2:
    movlw   0x4A
    subwf   note_check, W, A
    bz	    N_C2_sharp
    movlw   0x4B
    subwf   note_check, W, A
    bz	    N_D2_sharp
    movlw   0x4D
    subwf   note_check, W, A
    bz	    N_F2_sharp
    movlw   0x4E
    subwf   note_check, W, A
    bz	    N_G2_sharp
    goto    start   
    
N_A_sharp:
    movlw   0x61
    movwf   save_note, A
    movlw   167
    goto    play
N_C_sharp:
    movlw   0x63
    movwf   save_note, A
    movlw   139
    goto    play
N_D_sharp:
    movlw   0x64
    movwf   save_note, A
    movlw   124
    goto    play
N_F_sharp:
    movlw   0x66
    movwf   save_note, A
    movlw   103
    goto    play
N_G_sharp:
    movlw   0x67
    movwf   save_note, A
    movlw   91
    goto    play
    
N_A2_sharp:
    movlw   0x68
    movwf   save_note, A
    movlw   81
    goto    play
N_C2_sharp:
    movlw   0x6A
    movwf   save_note, A
    movlw   67
    goto    play
N_D2_sharp:
    movlw   0x6B
    movwf   save_note, A
    movlw   59
    goto    play
N_F2_sharp:
    movlw   0x6D
    movwf   save_note, A
    movlw   49
    goto    play
N_G2_sharp:
    movlw   0x6E
    movwf   save_note, A
    movlw   43
    goto    play
    
big_delay:	
	movlw	0x0F
	movwf	smol_counter, A
	decfsz	delay_count, A	; decrement until zero
	bra	delay_smol
	return
delay_smol:
	movlw	0x0A
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

