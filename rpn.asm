	;; libcf_example.asm - example code using printf and atoi from the standard C library
	;;  Name: Kyle Fritz
	;;  Last edited 02/25/2015
	;;  Description: A Reverse Polish Notation calculator (RPN).
	;;  Assemble using NASM:  nasm -f elf -g -F stabs rpn.asm
	;;  Link with gcc:  gcc -m32 -g -o rpn rpn.o
	;;
	;; 	ONLY INTS WORK, NO FLOATS FOR DIVISION

	%define STDIN 0
	%define STDOUT 1
	%define SYSCALL_EXIT  1
	%define SYSCALL_READ  3
	%define SYSCALL_WRITE 4
	%define BUFLEN 255
	
	        SECTION .data	; initialized data section

numbers:	   db "52 7000000 +", 0 ; Numbers to convert
	;;  note the '0' at the end - all strings in C
	;;  are NULL-terminated, that is, there's a character
	;;  '0' at the end.

print_str:		db "Expression to calculate: ", 10, 0
	;;  Format string for printf
	;;  Note the use of the newline (10) and NULL (0)
	;;  characters.
	
	
result:		db "Result: %d", 10, 0
	
			SECTION .bss		; uninitialized data section
input:		resb BUFLEN	; buffer for read
equation:	resb BUFLEN	; converted string
rlen:		resb 4		; length


	
	        SECTION .text	; Code section.
	extern printf		; Request access to printf
	extern atoi		; Request access to atoi
	

	        global main	; let loader see entry point

main:	 nop			; Entry point- note NOT _start anymore
start:				; address for gdb
	push	print_str
	call	printf
	add	esp, 4
;;;   read user input
;;;	
	mov     eax, SYSCALL_READ ; read function
	mov     ebx, STDIN        ; Arg 1: file descriptor
	mov     ecx, input          ; Arg 2: address of input
	mov     edx, BUFLEN		  ; Arg 3: buffer length
	int     080h

	mov	esi, input

PUSH_NUM:
	push    esi
	call	atoi	;  Resulting number is in eax
	add     esp, 4  ; Pop esi from stack
	push    eax	
NEXT:
	mov	ebx, -9999
	call    INC_ESI
	inc     esi
	cmp     [esi], byte 10
	je      FINAL

	cmp     [esi], byte '+'
	je      ADD
	cmp	[esi], byte '-'
	jne	GO
	cmp	[esi+1], byte ' '
	je	SUB
GO:	
	cmp	[esi], byte '*'
	je	MUL
	cmp	[esi], byte '/'
	je	DIV
	
	push	esi
	call    atoi
	add	esp, 4
	push	eax

	cmp	ebx, -9999
	jne	AFTER
	je	NEXT
		
AFTER:	
	push	eax
	;; 	push    result	call    printf	add	esp, 4
	jmp	NEXT

ADD:
	mov	ebx, 0
	pop	eax
	pop	ebx
	add	eax, ebx
	jmp	AFTER
SUB:
	mov	ebx, 0
	pop	ebx
	pop	eax
	sub	eax, ebx
	jmp	AFTER
MUL:
	mov	ebx, 0
	pop	eax
	pop	ebx
	imul    ebx
	jmp	AFTER
DIV:
	mov     ebx, 0
	pop	ebx
	pop	eax
	cdq
	idiv    ebx
	jmp	AFTER

INC_ESI:
	inc     esi	
	cmp     [esi], byte ' '	
	jne     INC_ESI
	ret
	
;;;   final exit
;;;
	
FINAL:
	pop	eax
	push	eax
	push	result
	call	printf
	add	esp, 4
exit:
	mov     eax, SYSCALL_EXIT ; exit function
	mov     ebx, 0	; exit code, 0=normal
	int     080h	; ask kernel to take over
	
