/*
 * variables_control.asm
 *
 *  Created: 28-05-23 12:40:21
 *   Author: romai
 */
 
 ;=== RESERVED MEMORY AREA IN SRAM =====
.equ RESERVED_MEMORY_AREA_START = 0x0100
.equ RESERVED_MEMORY_AREA_END	= 0x0170

.cseg
 variables_init:
	; CLEAR RESERVED MEMORY AREA (0x0100 - 0x0160)
	clr w
	LDIZ RESERVED_MEMORY_AREA_START					; point z at sram start (our table row 1)
	mclr_loop:										; memory clear loop
		cpi zl, low(RESERVED_MEMORY_AREA_END)
		brne m_clear
		cpi zh, high(RESERVED_MEMORY_AREA_END)
		brne m_clear
		rjmp end_mclr_loop
		m_clear:
		st z+, w
		rjmp mclr_loop
	end_mclr_loop:
	
	; INIT LETTERS
	ldi w, SPACE
	LDIZ SRAM_START + TABLE_WIDTH	; point z at table row 2
	r2_loop:						; init write row2 loop
		cpi zl, low(l31+1)
		brne r2_write
		cpi zh, high(l31+1)
		brne r2_write
		rjmp end_r2_loop
		r2_write:
		st z+, w
		rjmp r2_loop
	end_r2_loop:
	
	; set prescaler
	ldi w, INIT_PRESCALER
	sts mod_prescaler, w
	
	; set MENU and UPDATE Flag
	ldi w, 0b00000101
	sts FREG, w
	
	; set current and print letters to l00
	SET_CRNT_LTR l00
	SET_MENU_PRNT_LTR l00

	rcall write_table
	ret
