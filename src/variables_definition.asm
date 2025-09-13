/*
* variables_definition.asm
*
*  Created: 19/05/2023 17:29:51
*   Author: romai
*/ 
.dseg
;=== FIRST TABLE ROW: 16 BYTES FOR CONTROL VARIABLES ================================

;Flag Register
FREG:			.byte 1

;prescaler
mod_prescaler:	.byte 1

;morse variables
nb_empty:		.byte 1
nb_dot:			.byte 1

;letter index in table
ltr_col:		.byte 1
ltr_col_bit:	.byte 1

;variables for message print
current_ltr:	.byte 2
menu_print_ltr:	.byte 2
left_scroll:	.byte 1
right_scroll:	.byte 1
print_ctn:		.byte 1

;remote save variable
remote_command: .byte 1

; encoder variables
enc_old:		.byte 1

;temp variables
tmp0:			.byte 1

;=== SECOND TABLE ROW: MESSAGE LETTERS ================================
l00:			.byte 1
l01:			.byte 1
l02:			.byte 1
l03:			.byte 1
l04:			.byte 1
l05:			.byte 1
l06:			.byte 1
l07:			.byte 1
l08:			.byte 1
l09:			.byte 1
l10:			.byte 1
l11:			.byte 1
l12:			.byte 1
l13:			.byte 1
l14:			.byte 1
l15:			.byte 1
l16:			.byte 1
l17:			.byte 1
l18:			.byte 1
l19:			.byte 1
l20:			.byte 1
l21:			.byte 1
l22:			.byte 1
l23:			.byte 1
l24:			.byte 1
l25:			.byte 1
l26:			.byte 1
l27:			.byte 1
l28:			.byte 1
l29:			.byte 1
l30:			.byte 1
l31:			.byte 1
