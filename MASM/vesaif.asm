
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
	;����ջ����ַ�ʹ�С
	mov ax,stack
	mov ss,ax
	mov sp,1024
	;�������ݶλ���ַ
	mov ax,data
	mov ds,ax
	;������չ�λ���ַ
	mov ax,extra
	mov es,ax

	;����ͼ��ģʽ
	mov ax,4f02h
	mov bx,0103h
	int 10h;����ͼ���ж�
	
	;��ȡvesa��Ϣ
	mov ax,4f01h
	mov cx,0103h
	mov di,0h
	int 10h

	cmp al,4fh
	jne return
	cmp ah,0h;����1��ʧ�ܣ�0�ǳɹ�
	jne return

	;�ѵ�ַ����bx��dx
	mov bx,word ptr es:[di+28h]
	mov dx,word ptr es:[di+2Ah];��Ƶ���ص�ַ

	mov es,bx;�ε�ַ��es

	mov al,00000010b
	mov cx,0ffffh
	mov di,dx;ƫ�Ƶ�ַ��di
	rep stosb;������ָ��
	stosb;��Ϊcx��С���ƣ�stosbֻ������65535�Σ�����һ�Σ��ֶ���һ��

loop:
	nop
	jmp loop

return:
	mov ax, 4c00h
	int 21h


code ends

end main