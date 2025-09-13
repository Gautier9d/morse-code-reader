/*
 * table.asm
 *
 *  Created: 27-05-23 20:16:11
 *   Author: romai
 */
.equ TABLE_START = 0x130
.equ TABLE_WIDTH = 0x10

.equ END_LETTERS = TABLE_START

;======[ ALPHABET TABLE ]=====
; 1 SYMBOL LETTERS (ROW 0)
.equ Eaddr = TABLE_START
.equ Taddr = TABLE_START + 1

; 2 SYMBOLS LETTERS (ROW 1)
.equ Iaddr = TABLE_START + TABLE_WIDTH
.equ Naddr = TABLE_START + TABLE_WIDTH + 1
.equ Aaddr = TABLE_START + TABLE_WIDTH + 2
.equ Maddr = TABLE_START + TABLE_WIDTH + 3

; 3 SYMBOLS LETTERS (ROW 2)
.equ Saddr = TABLE_START + (2*TABLE_WIDTH)
.equ Daddr = TABLE_START + (2*TABLE_WIDTH) + 1
.equ Raddr = TABLE_START + (2*TABLE_WIDTH) + 2
.equ Gaddr = TABLE_START + (2*TABLE_WIDTH) + 3
.equ Uaddr = TABLE_START + (2*TABLE_WIDTH) + 4
.equ Kaddr = TABLE_START + (2*TABLE_WIDTH) + 5
.equ Waddr = TABLE_START + (2*TABLE_WIDTH) + 6
.equ Oaddr = TABLE_START + (2*TABLE_WIDTH) + 7

; 4 SYMBOLS LETTERS (ROW 3)
.equ Haddr = TABLE_START + (3*TABLE_WIDTH)
.equ Baddr = TABLE_START + (3*TABLE_WIDTH) + 1
.equ Laddr = TABLE_START + (3*TABLE_WIDTH) + 2
.equ Zaddr = TABLE_START + (3*TABLE_WIDTH) + 3
.equ Faddr = TABLE_START + (3*TABLE_WIDTH) + 4
.equ Caddr = TABLE_START + (3*TABLE_WIDTH) + 5
.equ Paddr = TABLE_START + (3*TABLE_WIDTH) + 6

.equ Vaddr = TABLE_START + (3*TABLE_WIDTH) + 8
.equ Xaddr = TABLE_START + (3*TABLE_WIDTH) + 9

.equ Qaddr = TABLE_START + (3*TABLE_WIDTH) + 11

.equ Yaddr = TABLE_START + (3*TABLE_WIDTH) + 13
.equ Jaddr = TABLE_START + (3*TABLE_WIDTH) + 14


;======[ ASCII ]=====
.equ ascii_top = 0x41

write_table:
	ldi r16, ascii_top
	TABLE_WRITE_IN Aaddr
	TABLE_WRITE_IN Baddr
	TABLE_WRITE_IN Caddr
	TABLE_WRITE_IN Daddr
	TABLE_WRITE_IN Eaddr
	TABLE_WRITE_IN Faddr
	TABLE_WRITE_IN Gaddr
	TABLE_WRITE_IN Haddr
	TABLE_WRITE_IN Iaddr
	TABLE_WRITE_IN Jaddr
	TABLE_WRITE_IN Kaddr
	TABLE_WRITE_IN Laddr
	TABLE_WRITE_IN Maddr
	TABLE_WRITE_IN Naddr
	TABLE_WRITE_IN Oaddr
	TABLE_WRITE_IN Paddr
	TABLE_WRITE_IN Qaddr
	TABLE_WRITE_IN Raddr
	TABLE_WRITE_IN Saddr
	TABLE_WRITE_IN Taddr
	TABLE_WRITE_IN Uaddr
	TABLE_WRITE_IN Vaddr
	TABLE_WRITE_IN Waddr
	TABLE_WRITE_IN Xaddr
	TABLE_WRITE_IN Yaddr
	TABLE_WRITE_IN Zaddr
	ret
