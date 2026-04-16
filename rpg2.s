; rpg2.s -- RPG-II Processor for COR24
; Step 002: Card deck reader with _read_record subroutine.
; Reads 80-byte records from a memory-backed deck descriptor.
; Prints first 10 bytes of each record to UART, then halts.
; UART data register at 0xFF0100 = -65280 signed
; UART status register at 0xFF0101 = -65279 signed
; TX busy: bit 7 of status (sign-extended: negative = busy)
;
; Deck descriptor layout (12 bytes):
;   +0: base address (24-bit)
;   +3: record length (24-bit)
;   +6: record count (24-bit)
;   +9: current index (24-bit)
;
; Memory layout:
;   0x080000: test deck (loaded via --load-binary)

_main:
	push	fp
	mov	fp,sp
	la	r2,-65280

_read_loop:
	la	r0,_deck_desc
	push	r0
	la	r0,_read_record
	jal	r1,(r0)
	add	sp,3

	ceq	r0,z
	brt	_all_done

	push	r0
	la	r0,_emit_10
	jal	r1,(r0)
	add	sp,3

	la	r0,_emit_crlf
	jal	r1,(r0)

	bra	_read_loop

_all_done:
	mov	sp,fp
	pop	fp
_halt:
	bra	_halt

; _read_record: Read next record from deck.
; Arg (on stack): deck_desc pointer
; Returns: r0 = address of record in deck, or 0 on EOF
_read_record:
	push	fp
	push	r2
	push	r1
	mov	fp,sp

	lw	r2,9(fp)

	lw	r1,6(r2)
	lw	r0,9(r2)
	clu	r0,r1
	brf	_eof

	lw	r0,0(r2)
	lw	r1,9(r2)
	push	r2
	lw	r2,3(r2)
	mul	r1,r2
	add	r0,r1
	pop	r2

	lw	r1,9(r2)
	add	r1,1
	sw	r1,9(r2)

	bra	_ret

_eof:
	la	r0,0

_ret:
	mov	sp,fp
	pop	r1
	pop	r2
	pop	fp
	jmp	(r1)

; _emit_10: Print 10 bytes from address to UART.
; Arg (on stack): pointer to bytes
_emit_10:
	push	fp
	push	r2
	push	r1
	mov	fp,sp

	lw	r2,9(fp)
	la	r1,10

_next_byte:
	ceq	r1,z
	brt	_done10

	lbu	r0,0(r2)
	push	r2
	push	r1
	push	r0
	la	r0,_emit_char
	jal	r1,(r0)
	add	sp,3
	pop	r1
	pop	r2

	add	r2,1
	add	r1,-1
	bra	_next_byte

_done10:
	mov	sp,fp
	pop	r1
	pop	r2
	pop	fp
	jmp	(r1)

; _emit_crlf: Print CR+LF to UART.
_emit_crlf:
	push	fp
	mov	fp,sp
	push	r1

	lc	r0,13
	push	r0
	la	r0,_emit_char
	jal	r1,(r0)
	add	sp,3

	lc	r0,10
	push	r0
	la	r0,_emit_char
	jal	r1,(r0)
	add	sp,3

	pop	r1
	mov	sp,fp
	pop	fp
	jmp	(r1)

; _emit_char: Write one byte to UART (with TX busy-wait).
; Arg (on stack): byte value
_emit_char:
	push	fp
	push	r1
	mov	fp,sp

	lw	r0,6(fp)
	la	r2,-65280

_poll:
	lb	r1,1(r2)
	cls	r1,z
	brt	_poll

	sb	r0,0(r2)

	mov	sp,fp
	pop	r1
	pop	fp
	jmp	(r1)

_deck_desc:
	.word	524288
	.word	80
	.word	3
	.word	0
