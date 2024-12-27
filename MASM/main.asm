assume cs:code,ds:data,ss:stack

data segment
	db 32 dup (' ')
	db 'W','e','l','c','o','m','e',' ','t','o',' ','m','a','s','m','!'
	db 32 dup (' ')
data ends

stack segment
	db 00000010b,00100100b,01110001b
stack ends

code segment
	start:
		mov ax,data
		mov ds,ax
		mov ax,stack
		mov ss,ax
		mov sp,0

		mov ax,0B864H
		mov es,ax

		mov cx,3

		l0:
			mov di,cx

			pop ax
			dec sp
			mov ah,al

			mov cx,80
			mov si,0
			l1:
				mov al,ds:[si]
				shl si,1
				mov es:[si],ax;mov es:[si*2],ax
				shr si,1
				inc si
				loop l1
			mov ax,es
			add ax,0Ah
			mov es,ax

			mov cx,di
			loop l0

		mov ax, 4c00h
		int 21h
code ends

end start