.386

assume cs:code,ss:stack

stack segment
    db 128 dup ()
stack ends

code segment
start:
	mov ax,stack
	mov ss,ax

	mov eax,10
	add eax,8
	mov ebx,eax

return:
	mov ax,4c00h 
    int 21h
code ends

end start