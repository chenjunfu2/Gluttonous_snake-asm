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

	;ָ��ǰ��db 66h���Ա��32bit������ax���eax
	mov ax,1010001110110101b

	mov cl,16
	db 66h
	shl ax,cl

	mov cl,16
	db 66h
	shr ax,cl

	test ax,ax;�����Ƿ�Ϊ0��Ϊ0��˵����16bit�Ĵ�����������32bit
	jnz jok;��Ϊ�����ok
	;�������no
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
