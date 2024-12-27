
assume cs:code,ds:data,ss:stack,es:extra

stack segment
	db 64 dup()
stack ends

data segment
	db 4 dup()
data ends

extra segment
	db 256 dup()
extra ends


code segment
main:
	;设置栈基地址和大小
	mov ax,stack
	mov ss,ax
	mov sp,1024
	;设置数据段基地址
	mov ax,data
	mov ds,ax
	;设置扩展段基地址
	mov ax,extra
	mov es,ax

	;设置图形模式
	mov ax,4f02h
	mov bx,0103h
	int 10h;调用图形中断
	
	;获取vesa信息
	mov ax,4f01h
	mov cx,0103h
	mov di,0h
	int 10h

	cmp al,4fh
	jne return
	cmp ah,0h;返回1是失败，0是成功
	jne return

	;把地址放入bx和dx
	mov bx,word ptr es:[di+28h]
	mov dx,word ptr es:[di+2Ah];视频像素地址

	mov es,bx;段地址放es

	mov al,00000010b
	mov cx,0ffffh
	mov di,dx;偏移地址放di
	rep stosb;串传送指令
	stosb;因为cx大小限制，stosb只会运行65535次，还差一次，手动补一次

loop:
	nop
	jmp loop

return:
	mov ax, 4c00h
	int 21h


code ends

end main