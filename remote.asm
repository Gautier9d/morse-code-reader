/*
 * remote.asm
 *
 *  Created: 27-05-23 22:43:06
 *   Author: romai
 */
; file ir_rc5.asm   target ATmega128L-4MHz-STK300
; purpose IR sensor decoding RC5 format

.equ		T1 = 1800				; bit period T1 = 1800 usec

read_remote:
	CLR2	b1,b0					; clear 2-byte register
	ldi			b2,14				; load bit-counter
	WAIT_US		(T1/4)				; wait a quarter period
	read_loop:
		P2C		PINE,IR				; move Pin to Carry (P2C)
		ROL2		b1,b0			; roll carry into 2-byte reg
		WAIT_US		(T1-4)			; wait bit period (- compensation)	
		DJNZ		b2,read_loop			; Decrement and Jump if Not Zero
	com		b0						; complement b0
	
	sts remote_command, b0			; store command
	ret