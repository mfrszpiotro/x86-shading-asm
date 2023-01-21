%macro  prologue 1 
        push    ebp 
        mov     ebp,esp 
        sub     esp, %1 
%endmacro

global shade

; symbolic adressess and variables
; r,g,b separated in order to simplify usage of color value
; for memory opt. i would recommend keeping those in one 32bit address
%define		r1				[ebp+8]
%define		g1				[ebp+12]
%define		b1				[ebp+16]
%define		r2				[ebp+20]
%define		g2				[ebp+24]
%define		b2				[ebp+28]
%define		r3				[ebp+32]
%define		g3				[ebp+36]
%define		b3				[ebp+40]
%define     imageDataArray	[ebp+44] ;or 20
%define		triangle_start	27
%define		triangle_break	697
%define		y1miny2			203
%define		y1miny3			135
%define 	triangle_end	231

shade:
;************************************************************************
;*							PREPARATION PART							*
;************************************************************************

    ; Setting up working environment (no local vars)
    prologue 0

start:
    ; pushing used registers onto stack
    push    esi
	push	ecx
	push	edi
	push	edx
	push	ebx

	; ebx is occupied within whole print_lines_loop
	xor		ebx, ebx
	mov		bx, 558			;phong part
	ror		ebx, 16 		;rotate to range+phong
	;mov		bx, 0		;just for checking, not needed
	;rol		ebx, 16 	;rotate back to phong part


	; ecx is occupied within whole print_lines_loop: Ys - actual height and lhsX start
	xor		ecx, ecx
	mov		cx, triangle_start ;cx for Ys 
	ror		ecx, 16 ;rotate to lhsX
	mov     cx, 492	;cx for lhsX start - when not used it should remain on this state for clarity

	;start from the triangle_startth scanline
	mov		eax, 960
	rol		ecx, 16		; cx is Ys counter
	mul		cx			; multiplied by Ys, now eax contains the next line distance. 
	ror		ecx, 16		; cx is lhsX counter
	mov		edi, imageDataArray
	add		edi, eax
	xor		edx, edx
	mov		dx, cx
	add		edi, edx	; edi starts at triangle_startth line where the triangle shoul start (somewhat in the middle of the line)

;************************************************************************
;*								MAIN PART								*
;************************************************************************

print_lines_lop:

; eax, ebx, higher edx are free to go

	;point esi to the next line where triangle should start
	mov		esi, edi

	;if Ys is at the end of the triangle scanline, exit
is_exit:
	rol		ecx, 16		; Ys counter
	cmp		cx, triangle_end
	ror		ecx, 16		; lhsX start
	jge		exit

print_line_lop:
; calculate	if cx exceeded rhs
	;first calculate rhs
	calc_rhs:
	rol		ecx, 16		; Ys counter
	xor		eax, eax
	mov		ax, cx		; rhs is equal to...
	sub		ax, triangle_start		; cx should work here as a counter from 0 to 190 (later it will break)
	ror		ecx, 16		; lhsX start
	mov		dx, 3
	mul		dx			;NOTE: Mul uses dx to multiply!!!
	add		ax, 492		; 492 + (Ys-triangle_start)*3
	rol		ecx, 16		; Ys counter
	cmp		cx,	96		; check if the range should start going backwards (req. to obtain triangle)
	ror		ecx, 16		; lhsX start
	jl		skip_rhs_chg

break_rhs:
	xor		edx, edx
	mov		dx, ax
	sub		dx, triangle_break
	mov		ax, triangle_break
	sub		ax, dx
	sub		ax, cx		; cx should be lhsX here
	rol		ebx, 16 	;rotate to phong part
	mov		bx, 0		;no phong part addition after breaking
	ror		ebx, 16 	;rotate back to range+phong
	mov		bx, ax
	jmp		color_begin

skip_rhs_chg:
	;range for this scanline (Xb*3)
	sub		ax, cx		; cx should be lhsX here
	rol		ebx, 16 	;rotate to phong part
	mov		dx, bx		;copy phong
	ror		ebx, 16 	;rotate back to range (here it is only range because phong part was subtracted at the end of color calc)
	mov		bx, ax		;new_range
	add		bx, dx		;bx = new_range + phong

;*********************************************************************************************;
color_begin:
;*********************************************************************************************;


	xor 	eax, eax
	xor 	edx, edx
	;mov		dx, 0		;free
	ror		edx, 16 		;rotate to rgb counter
	mov		dx, 1			;start counter from blue
	;rol		edx, 16 	;rotate back to free

INPUT_COLOR:
calc_left_Ia:
	xor 	eax, eax
	cmp		dx, 1
	cmove	ax, b1
	cmp		dx, 2
	cmove	ax, g1
	cmp		dx, 3
	cmove	ax, r1
	mov		ah, 0
	push 	eax
	fild	DWORD[esp]
	pop		eax
	;Ys - Y2
	rol		ecx, 16		; Ys counter
	mov		al, cl
	ror		ecx, 16		; lhsX start
	sub		al, triangle_start
	push 	eax
	fild	DWORD[esp]
	pop		eax
	;Y1 - Y2
	mov		al, y1miny2
	push 	eax
	fild	DWORD[esp]
	pop		eax

	fdiv	st1, st0 ;ys-y2 / y1-y2 = mid
	fstp	st0		 ;pop y1-y2
	fmul	st1, st0 ;res = mid*b1
	fstp	st0		 ;pop mid
	;there is only res on the st0 and nothing else

calc_right_Ia:
	cmp		dx, 1
	cmove	ax, b2
	cmp		dx, 2
	cmove	ax, g2
	cmp		dx, 3
	cmove	ax, r2
	mov		ah, 0
	push 	eax
	fild	DWORD[esp]
	pop		eax
	;Y1 - Ys
	rol		ecx, 16		; Ys counter
	rol		edx, 16		; rotate to free
	mov		dx, cx		; dx is Ys
	ror		ecx, 16		; lhsX start
	mov		ax, triangle_end	;ax is Y1
	sub		ax, dx
	ror		edx, 16		; rotate to counter	
	push 	eax
	fild	DWORD[esp]
	pop		eax
	;Y1 - Y2
	mov		eax, y1miny2
	push 	eax
	fild	DWORD[esp]
	pop		eax

	fdiv	st1, st0 ;y1-ys / y1-y2 = mid
	fstp	st0		 ;pop y1-y2
	fmul	st1, st0 ;res = mid*r2
	fstp	st0		 ;pop mid

calc_Ia:
	fadd	st1, st0 ;ba = left+right
	fstp	st0		 ;pop right
	;now at st0 is only ba

calc_left_Ip:
	;ba already in st0
	;Xb - Xp
	xor		eax, eax
	rol		edx, 16	 ;rotate to free
	mov		dx,	bx 	 ;x range
	add		dx, cx	 ;Xb = range + Xa

	mov		eax, esi
	sub		eax, edi ;distance till range
	add		ax,	cx	 ;Xp = distance till range + Xa

	sub		dx, ax 	 ;Xb-Xp
	mov		ax, dx 	 ;Xb-Xp still
	ror		edx, 16	 ;rotate to counter
	push 	eax
	fild	DWORD[esp]
	pop		eax
	
	mov		ax, bx	 ;range = Xb-Xa
	push 	eax
	fild	DWORD[esp]
	pop		eax

	fdiv	st1, st0 ;Xb-Xp / Xb-Xa = mid
	fstp	st0		 ;pop Xb-Xa
	fmul	st1, st0 ;res = mid*ra
	fstp	st0		 ;pop mid
	;now at st0 is only left_rp

	xor eax, eax

calc_left_Ib:
	cmp		dx, 1
	cmove	ax, b1
	cmp		dx, 2
	cmove	ax, g1
	cmp		dx, 3
	cmove	ax, r1
	mov		ah, 0
	push 	eax
	fild	DWORD[esp]
	pop		eax
	;Ys - Y3
	rol		ecx, 16		; Ys counter
	mov		al, cl
	ror		ecx, 16		; lhsX start
	sub		eax, 96
	push 	eax
	fild	DWORD[esp]
	pop		eax
	;Y1 - Y3
	xor		eax, eax
	mov		al, y1miny3;
	push 	eax
	fild	DWORD[esp]
	pop		eax

	fdiv	st1, st0 ;ys-y3 / y1-y3 = mid
	fstp	st0		 ;pop y1-y3
	fmul	st1, st0 ;res = mid*b1
	fstp	st0		 ;pop mid

calc_right_Ib:
	cmp		dx, 1
	cmove	ax, b3
	cmp		dx, 2
	cmove	ax, g3
	cmp		dx, 3
	cmove	ax, r3
	mov		ah, 0
	push 	eax
	fild	DWORD[esp]
	pop		eax
	;Y1 - Ys
	rol		ecx, 16		; Ys 
	rol		edx, 16		; rotate to free
	mov		dx, cx		; Ys
	ror		ecx, 16		; lhsX start
	mov		ax, triangle_end	;Y1
	sub		ax, dx
	ror		edx, 16 	; rotate to counter
	push 	eax
	fild	DWORD[esp]
	pop		eax
	;Y1 - Y3
	mov		eax, y1miny3
	push 	eax
	fild	DWORD[esp]
	pop		eax

	fdiv	st1, st0 ;y1-ys / y1-y3 = mid
	fstp	st0		 ;pop y1-y3
	fmul	st1, st0 ;res = mid*r3
	fstp	st0		 ;pop mid

calc_Ib:
	fadd	st1, st0 ;ra = left-right
	fstp	st0		 ;pop right

calc_right_Ip:
	;rb already in st0
	;Xb - Xp
	xor		eax, eax
	rol		edx, 16		; rotate to free
	mov		dx, cx	 	;Xa
	mov		eax, esi	
	sub		eax, edi 	;distance till range
	add		ax,	cx	 	;Xp = distance till range + Xa
	sub		ax, dx 		;Xp-Xa
	ror		edx, 16 	;rotate to counter
	push 	eax
	fild	DWORD[esp]
	pop		eax
	
	mov		ax, bx	 ;range = Xb-Xa
	push 	eax
	fild	DWORD[esp]
	pop		eax

	fdiv	st1, st0 ;Xp-Xa / Xb-Xa = mid
	fstp	st0		 ;pop Xb-Xa
	fmul	st1, st0 ;res = mid*rb
	fstp	st0		 ;pop mid

	xor eax, eax
	push eax
	fadd st1, st0
	fstp 	st0
	fistp	DWORD[esp]
	pop		eax
	mov		[esi], eax

color_end:
	add		esi, 1	 ;increase buffer pointer
	add		dx, 1	 ;increase counter
	cmp		dx, 3	 ;if above 3 then end adding rgb colors
	jle		INPUT_COLOR

end_small_lop:
	;check if esi distance from edi exceeded the scanline triangle range
	xor		edx, edx
	xor 	eax, eax
	rol		ebx, 16	;switch to phong part to add or sub
	mov		ax,	bx
	ror		ebx, 16 ;switch to range+phong
	mov		dx, bx	;store range+phong
	sub		dx, ax	;only range here
	mov		eax, esi
	sub		eax, edi
	cmp		eax, edx
	jle		print_line_lop

end_big_lop:
	;fixing phong part
	rol		ecx, 16		; Ys counter
 	xor		eax, eax
 	mov		ax, cx 		;Ys
 	sub		ax, 20		;Ys - 20
	ror		ecx, 16		; lhsX counter
	rol		ebx, 16		;modifiyng phong variable (Starting from 513)
 	cmp		ax, 15
 	jle		zero_phase
 	cmp		ax, 27
 	jle		first_phase
	cmp		ax, 34
 	jle		second_phase
 	cmp		ax, 42
 	jle		third_phase
 	cmp		ax,	60
 	jle		fourth_phase
	sub		bx, 3
fourth_phase:
	add		bx, 1
third_phase:
 	add		bx, 1
second_phase:
 	add		bx, 11
first_phase:
 	sub		bx, 14
zero_phase:
 	sub		bx, 4
	ror		ebx, 16		;back to using range+phong in color calculations

	rol		ecx, 16		; Ys counter
	add		cx, 1
	;calculate lhs as 492 - (Ys-triangle_start)/3
	xor		eax, eax
	mov		ax, cx
	ror		ecx, 16		; lhsX start
	sub		ax, triangle_start
	mov		dl, 3
	div		dl
	cmp		ah, 0
	jne		skip_lhs_chg
	;only if (Ys-triangle_start)%3 == 0
	sub		cx, 3
	sub		edi, 3
skip_lhs_chg:
	;move edi to the next start of the triangle
	add		edi, 960
	jmp		print_lines_lop

exit:
    ; restore register's state
	pop 	ebx
	pop		edx
	pop		edi
	pop		ecx
    pop     esi
	
    ; return back to C caller         
    mov     esp, ebp
    pop     ebp
    ret
