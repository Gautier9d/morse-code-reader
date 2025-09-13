;
; main.asm
;
; Created: 19/05/2023 15:54:57
; Author : romai
;

 .include "macros.asm"
 .include "definitions.asm"

;=== CONSTANTS ========
.equ MENU_REFRESH_RATE_MS = 10

.equ INIT_PRESCALER  = 4
.equ MIN_PRESCALER   = 1
.equ MAX_PRESCALER   = 7
.equ EMPTY_BIT_LIMIT = 3

.equ DOT  = 46
.equ DASH = 95

.equ MAX_SYMBOLS	= 4
.equ NBL_PRINT		= 0x10
.equ NBL_LETTERS	= 0x20
.equ NB_SHORT		= 1
.equ NB_DASH		= 3
.equ NB_NEXT_SYMBOL = 1
.equ NB_NEXT_LETTER = 3
.equ NB_NEXT_WORD	= 7

;=== REMOTE ===========
.equ SIGNAL_POWER	= 0x0C
.equ SIGNAL_MUTE	= 0x0D

.equ SIGNAL_PLUS	= 0x10
.equ SIGNAL_MINUS	= 0x11

.equ SIGNAL_UP		= 0x20
.equ SIGNAL_DOWN	= 0x21

.equ SIGNAL_1		= 0x01
.equ SIGNAL_2		= 0x02
.equ SIGNAL_3		= 0x03

;=== FREG FLAGS ============
.equ MENU_FLAG		= 0
.equ DETECTED_FLAG	= 1
.equ UPDATE_FLAG	= 2
.equ CONTENT_FLAG	= 3
.equ INC_PRESC_FLAG	= 4
.equ DEC_PRESC_FLAG	= 5
.equ SAVE_MSG_FLAG	= 6
.equ CLR_MSG_FLAG	= 7

.cseg
.org	0
	jmp reset

.org INT7addr
	jmp int7_isr

.org OVF0addr
	jmp tim0_ovf

.org ADCCaddr
	jmp ADCCaddr_sra

.org	0x30

int7_isr:
	in _sreg, SREG

	rcall read_remote		; reading remote command
	lds _w, remote_command

	check_signal_up:
	cpi _w, SIGNAL_UP
	brne check_signal_down
	FREG_SET MENU_FLAG	; set menu flag
	rjmp int7_end

	check_signal_down:
	cpi _w, SIGNAL_DOWN
	brne check_signal_plus
	FREG_CLR MENU_FLAG	; clear menu flag
	rjmp int7_end

	check_int7_exit:
	lds _w, FREG
	sbrs _w, MENU_FLAG
	rjmp int7_end

	check_signal_plus:
	cpi _w, SIGNAL_PLUS
	brne check_signal_min
	FREG_SET INC_PRESC_FLAG	; set prescaler increment flag
	rjmp int7_end
	
	check_signal_min:
	cpi _w, SIGNAL_MINUS
	brne check_signal_mute
	FREG_SET DEC_PRESC_FLAG	; set prescaler decrement flag
	rjmp int7_end
	
	check_signal_mute:
	cpi _w, SIGNAL_MUTE
	brne int7_end
	FREG_SET CLR_MSG_FLAG	; set message clear flag

	int7_end:
	out SREG, _sreg
	reti

tim0_ovf:
	in _sreg, SREG			; store SREG

	; Set update flag
	FREG_SET UPDATE_FLAG

	; save a0 in tmp0
	sts tmp0, a0

	lds _w, FREG		; check detection
	sbrc _w, DETECTED_FLAG	; detection->new_dot	no_detection->new_empty
	rjmp new_dot

	new_empty:
	lds _w, nb_empty
	cpi _w, NB_NEXT_SYMBOL - 1
	brne check_next_letter
	
	; 1 EMPTY
	lds _w, nb_dot			; - check nb dot
	cpi _w, 1
	brsh PC+2
	rjmp inc_nb_empty
	clr _w					; - clear nb_dot
	sts nb_dot, _w			
	lds _w, ltr_col_bit		
	cpi _w, MAX_SYMBOLS		; - check max symbols
	brlo inc_ltr_col_bit
	rjmp inc_nb_empty
	inc_ltr_col_bit:		; - increment table column bit to modify
	inc _w
	sts ltr_col_bit, _w
	rjmp inc_nb_empty

	check_next_letter:
	cpi _w, 1			
	brne PC+2
	rjmp inc_nb_empty
	cpi _w, NB_NEXT_LETTER - 1
	breq empty_3
	rjmp check_next_word
	empty_3:					; 3 EMPTY
	lds _w, FREG			; decode letter only if there is content
	sbrs _w, CONTENT_FLAG
	rjmp inc_nb_empty
	lds _w, ltr_col_bit			
	dec _w
	ldi a0, TABLE_WIDTH
	mul _w, a0					; table row = (letter col bit - 1) * TABLE_WIDTH  (result goes in r0)
	mov _w, r0
	lds a0, ltr_col				; table col = letter column
	add _w, a0					; table offset = table row + table column
	ldi zl, low(TABLE_START)
	ldi zh, high(TABLE_START)
	add zl, _w					; add offset to table start
	ld _w, z					; get table value

	BNLAST_LTR store_ltr		; branch if not last letter
	sts tmp0, _w				; store letter to write in tmp0
	ldi _w, SPACE				; if so clear l0-15 and write in l00
	SET_ALL_LTRS _w, NBL_PRINT

	LDSZ current_ltr
	lds _w, tmp0
	st z+, _w
	STSZ current_ltr
	rjmp reset_ltr

	store_ltr:
	st z+, _w
	STSZ current_ltr		; store current letter address from pointer z

	reset_ltr:					; reset table column bit letter row and letter column
	clr _w
	sts ltr_col, _w
	sts ltr_col_bit, _w

	rjmp inc_nb_empty

	check_next_word:
	lds _w, FREG
	sbrs _w, CONTENT_FLAG
	rjmp inc_nb_empty
	lds _w, nb_empty
	cpi _w, NB_NEXT_WORD - 1
	brlo inc_nb_empty
	breq empty_7
	rjmp end_timer
	empty_7:				; 7 EMPTY
	BNLAST_LTR write_space
	ldi _w, SPACE			; if last letter reset all letters
	SET_ALL_LTRS _w, NBL_PRINT
	rjmp inc_nb_empty

	write_space:
	LDSZ current_ltr
	ldi _w, SPACE
	st z+, _w
	STSZ current_ltr

	inc_nb_empty:
	lds _w, nb_empty		; inc nb_empty
	sbrs _w, EMPTY_BIT_LIMIT
	inc _w
	sts nb_empty, _w
	rjmp end_timer

	new_dot:
	lds _w, nb_dot			; load nb_dot
	cpi _w, 0				; check first dot:
	brne check_dash
	; 1 DOT
	FREG_SET CONTENT_FLAG

	clr _w					;	- clear nb_empty
	sts nb_empty, _w		
	rjmp inc_nb_dot
	
	check_dash:				
	cpi _w, 1				
	breq inc_nb_dot
	cpi _w, NB_DASH-1
	brne reset_detected
	; 3 DOT
	lds _w, ltr_col_bit		; if 3rd dot set table column bit
	cpi _w, 4
	brlo PC+2
	rjmp inc_nb_dot
	ldi a0, 0x01
	b_loop:
		cpi _w, 0
		breq end_loop
		lsl a0
		dec _w
		rjmp b_loop
	end_loop:
	lds	_w, ltr_col
	or _w, a0
	sts ltr_col, _w

	inc_nb_dot:				; increment nb_dot
	lds _w, nb_dot
	inc _w
	sts nb_dot, _w

	reset_detected:
	FREG_CLR DETECTED_FLAG

	end_timer:
	; clear tmp values
	clr _w
	sts tmp0, _w

	; restore register a
	lds a0, tmp0
	out SREG, _sreg			; restore SREG
	reti

ADCCaddr_sra :
	ldi r23,0x01
	reti

.include "variables_definition.asm"
.include "variables_control.asm"
.include "encoder.asm"
.include "sharp.asm"
.include "remote.asm"
.include "table.asm"

reset :
	LDSP	RAMEND
	OUTI	DDRB,0xff
	
	;turn off leds
	OUTI LED, 0xff

	sei
	rcall	LCD_init
	rcall	encoder_init
	OUTI	ADCSR,(1<<ADEN) + (1<<ADIE) + 6
	OUTI	ADMUX,3

	sei
	;config INT7
	OUTI EIMSK, (1<<7)
	in w, EICRB
	ori w,  (1<<ISC71)
	andi w, ~(1<<ISC70)
	out EICRB, w

	;config timer0 overflow
	OUTI ASSR,(1<<AS0)
	OUTI TCCR0, INIT_PRESCALER
	
	rcall LCD_clear
	rcall LCD_home

	rcall variables_init

	rjmp  menu

.include "lcd.asm"
.include "printf.asm"

clr_a:
	clr a0
	clr a1
	clr a2
	clr a3
	ret

menu:
	in w, TIMSK
	andi w, 0b11111110
	out TIMSK, w

	rcall LCD_clear
	rcall LCD_home

	;set first letter to print to l00
	SET_MENU_PRNT_LTR l00

	; check for message scroll flag from encoder
	check_encoder_scroll:
	OUTI LED, 0xff
	rcall read_encoder

	check_scroll_left:
	lds w, left_scroll
	cpi w, 0xff
	brne check_scroll_right
	; check left limit
	LDSZ menu_print_ltr
	cpi zl, low(l16)
	brne mp_next
	cpi zh, high(l16)
	brne mp_next
	rjmp update_prescaler
	; point menu print to next letter
	mp_next:
	OUTI LED, 0b00001111
	LDSZ menu_print_ltr
	adiw z, 1
	STSZ menu_print_ltr
	clr w
	sts left_scroll, w
	rjmp update_prescaler
	
	check_scroll_right:
	lds w, right_scroll
	cpi w, 0xff
	brne update_prescaler
	LDSZ menu_print_ltr
	cpi zl, low(l00)
	brne mp_prev
	cpi zh, high(l00)
	brne mp_prev
	rjmp update_prescaler
	; point menu print to previous letter
	mp_prev:
	OUTI LED, 0b11110000
	LDSZ menu_print_ltr
	sbiw z, 1
	STSZ menu_print_ltr
	clr w
	sts right_scroll, w
	
	update_prescaler:
	/*	Read prescaler change commands	*/
	lds a0, FREG

	check_presc_inc:
	sbrs a0, INC_PRESC_FLAG
	rjmp check_presc_dec
	lds w, mod_prescaler
	cpi w, MAX_PRESCALER
	brne inc_presc
	FREG_CLR INC_PRESC_FLAG
	rjmp check_msg_mute
	inc_presc:
	INCS mod_prescaler
	FREG_CLR INC_PRESC_FLAG
	rjmp set_new_presc

	check_presc_dec:
	sbrs a0, DEC_PRESC_FLAG
	rjmp check_msg_mute
	lds w, mod_prescaler
	cpi w, MIN_PRESCALER
	brne dec_presc
	FREG_CLR DEC_PRESC_FLAG
	rjmp check_msg_mute
	dec_presc:
	DECS mod_prescaler
	FREG_CLR DEC_PRESC_FLAG

	set_new_presc:
	lds w, mod_prescaler
	out TCCR0, w

	check_msg_mute:
	lds w, FREG
	sbrs w, CLR_MSG_FLAG		; check CLR_MESSAGE flag
	rjmp display_menu			; if flag not set jump to display menu
	ldi w, SPACE
	SET_ALL_LTRS w, NBL_LETTERS	; if flag set clear l00-l15
	FREG_CLR CLR_MSG_FLAG		; reset flag

	display_menu:
	LCD_PRNT_LETTERS menu_print_ltr

	rcall clr_a
	lds a0, mod_prescaler
	LDIZ menu_print_ltr
	ld a1, z
	subi a1, 0x10

	PRINTF LCD
	.db CR, CR, "presc:", FDEC, a, "     s:", FDEC, 19, "  ", 0

	check_menu_exit:
	WAIT_MS MENU_REFRESH_RATE_MS
	lds w, FREG
	sbrc w, MENU_FLAG
	rjmp check_encoder_scroll

	in w, TIMSK
	ori w,(1<<TOIE0)
	out TIMSK, w
	clr w
	sts nb_dot, w
	sts nb_empty, w
	sts ltr_col, w
	sts ltr_col_bit, w
	FREG_CLR CONTENT_FLAG

	rcall LCD_clear
	rcall LCD_home
	rjmp reading

check_menu:
	;check menu control variable
	lds w, FREG
	sbrc w, MENU_FLAG
	rjmp menu
	rjmp reading

reading:
	rcall read_sharp				; reading distance sensor

	print_morse:
	rcall clr_a
	lds a0, l00
	lds a1, l01
	lds a2, l02
	lds a3, l03

	;Only update LCD if UPDATE_FLAG set
	lds w, FREG
	sbrs w, UPDATE_FLAG
	rjmp reading_end

	display_letters:
	LCD_PRNT_LETTERS menu_print_ltr

	;display debug variables
	display_debug:
	rcall clr_a
	lds a0, FREG
	lds a1, nb_dot
	lds a2, nb_empty
	PRINTF LCD
	.db "d:", FDEC, 19, " e:", FDEC, 20, 0

	reset_update_flag:
	FREG_CLR UPDATE_FLAG

	reading_end:
	rjmp check_menu
