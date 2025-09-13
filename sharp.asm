/*
 * sharp.asm
 *
 *  Created: 19/05/2023 16:13:56
 *   Author: romai
 */

read_sharp:
	clr		r23
	sbi		ADCSR,ADSC
	WB0		r23,0
	in		a0,ADCL
	in		a1,ADCH
	cpi a1, 3
	brlo read_end
	isthere:
	lds w, FREG
	ori w, (1<<DETECTED_FLAG)
	sts FREG, w
	read_end:
	clr w

	ret

