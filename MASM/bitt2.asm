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
db  66h
db 0B8h
db 0B5h
db 0A3h
db    0
db    0

db  66h
db  89h
db 0C3h

db  66h
db 0C1h
db 0E0h
db  10h

db  66h
db 0C1h
db 0E8h
db  10h


	db 66h
	cmp ax,bx
	je jok
	;no:
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
