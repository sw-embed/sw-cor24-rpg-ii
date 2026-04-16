; rpg2.s -- RPG-II Processor for COR24
; Prints "RPG-II\n" to UART and halts.
; UART data register at 0xFF0100 = -65280 signed
; UART status register at 0xFF0101 = -65279 signed
; TX busy: bit 7 of status (sign-extended: negative = busy)

_main:
	push	fp
	mov	fp,sp
	la	r2,-65280	; r2 = UART base address

	la	r1,_string
_loop:
	lb	r0,0(r1)	; load byte at *r1
	ceq	r0,z		; NUL terminator?
	brt	_done
	push	r0		; save character
_poll:
	lb	r0,1(r2)	; load UART status
	cls	r0,z		; C = (status < 0) = TX busy
	brt	_poll		; wait if busy
	pop	r0		; restore character
	sb	r0,0(r2)	; write to UART
	add	r1,1
	bra	_loop

_done:
	mov	sp,fp
	pop	fp
_halt:
	bra	_halt

_string:
	.byte	82,80,71,45,73,73,10,0
	; R  P  G  -  I  I  \n NUL
