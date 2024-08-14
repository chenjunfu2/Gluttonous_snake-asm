mov ax,0B864H
mov es,ax
mov bx,颜色
mov cx,3
mov di,0

L1:
 mov dx,cx
 mov ah,cs:[bx]
 inc bx;下个颜色
 mov cx,80
 mov si,字符串

    L2:
     mov al,cs:[si]
     inc si
     mov es:[di],ax
     inc di
    loop L2

 mov cx,dx
loop L1

mov ax,4c00h
int 21h


颜色 db 00000001b,00100100b,00000010b
字符串 db '                                Welcome to nasm!                                '
