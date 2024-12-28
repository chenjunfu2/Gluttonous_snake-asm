assume cs:code,ds:data

data segment
	cp db 'start',0dh,0ah,'$'
	ok db 'ok',0dh,0ah,'$'
	no db 'no',0dh,0ah,'$'
data ends

code segment
start:
	mov ax,data
	mov ds,ax

	lea dx,cp
	mov ah,09h
	int 21h

	;指令前加db 66h可以变成32bit，比如ax变成eax
	mov ax,1010001110110101b

	mov cl,16
	db 66h
	shl ax,cl

	mov cl,16
	db 66h
	shr ax,cl

	test ax,ax;测试是否为0，为0则说明是16bit寄存器，否则是32bit
	jnz jok;不为零输出ok
	;否则输出no
	lea dx,no
	mov ah,09h
	int 21h

	jmp return
	jok:
	lea dx,ok
	mov ah,09h
	int 21h

return:
	mov ax,4c00h 
	int 21h
code ends

end start
