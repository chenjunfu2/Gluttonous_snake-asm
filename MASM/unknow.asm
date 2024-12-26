assume cs:uk49,ds:uk30,ss:uk29,es:uk46
uk0 equ 10
uk1 equ 80
uk2 equ 60
uk3 equ uk1*uk2
uk4 equ 800
uk5 equ 600
uk6 equ 4f02h
uk7 equ 0103h
uk8 equ 00001110b
uk9 equ 00001111b
uk10 equ 00000111b
uk11 equ 00000010b
uk12 equ 00000000b
uk13 equ 0
uk14 equ 2
uk15 equ 0 
uk16 equ 1 
uk17 equ 2 
uk18 equ 3 
uk19 equ 4 
uk20 equ 5 
uk21 equ uk15
uk22 equ uk16
uk23 equ uk17
uk24 equ uk18
uk25 equ uk19
uk26 equ 5
uk27 equ 6
uk28 equ 7
uk29 segment
db 1024 dup(0)
uk29 ends
uk30 segment
uk31 dw 2 dup()
uk32 db 1 dup()
uk33 dw 2 dup()
uk34 dw 2 dup()
uk35 dw 2 dup()
uk36 dw 2 dup()
uk37 db 1 dup()
uk38 db 1 dup()
uk39 dw 1 dup()
uk40 dw 1 dup()
uk41 db uk15,uk17,uk16,uk19,uk18
uk42 dw 0000h,0000h, 0000h,0ffffh, 0000h,0001h, 0ffffh,0000h, 0001h,0000h, 0000h,0000h
uk43 db uk3 dup()
uk44 dw 1 dup()
uk45 dw 1 dup()
uk30 ends
uk46 segment
uk47 db 255 dup(uk21)
uk48 db 1 dup()
uk46 ends
uk49 segment
uk50 proc
mov ax,uk29
mov ss,ax
mov sp,1024
mov ax,uk30
mov ds,ax
mov ax,uk46
mov es,ax
mov ax,uk6
mov bx,uk7
int 10h
call uk76
mov byte ptr uk47[48h],uk22
mov byte ptr uk47[50h],uk23
mov byte ptr uk47[4bh],uk24
mov byte ptr uk47[4dh],uk25
mov byte ptr uk47[39h],uk26
mov byte ptr uk47[19h],uk27
mov byte ptr uk47[10h],uk28
mov ah,2ch
int 21h
mov al,100
mul dh
mov dh,0h
add ax,dx
mov uk40,ax
uk51:
call uk78
call uk82
mov word ptr uk33.uk13,1
mov word ptr uk33.uk14,0
mov word ptr uk34.uk13,0
mov word ptr uk34.uk14,0
mov bx,word ptr uk33.uk13
mov dx,word ptr uk33.uk14
mov al,uk8
call uk91
mov cl,uk19
call uk92
mov bx,word ptr uk34.uk13
mov dx,word ptr uk34.uk14
mov al,uk10
call uk91
mov cl,uk19
call uk92
mov uk39,2
call uk83
mov word ptr uk31[0],1h
mov word ptr uk31[2],86a0h
mov byte ptr uk32,0h
mov byte ptr uk38,0h
mov uk48,10000000b
uk52:
uk53:
mov al,uk48
test al,al
jz uk53
mov uk48,0h
mov ah,83h
mov al,00h
lea bx,uk48
mov cx,word ptr uk31[0]
mov dx,word ptr uk31[2]
int 15h
mov bx,word ptr uk33.uk13
mov dx,word ptr uk33.uk14
call uk88
mov bh,0h
mov bl,cl
mov ah,uk41[bx]
mov al,cl
uk54:
call uk93
cmp cl,uk26
jb uk62
cmp cl,uk28
ja uk54
jmp uk59
uk55 dw offset uk56,offset uk57,offset uk58
uk59:
sub cl,uk26
mov bh,0h
mov bl,cl
shl bx,1
jmp word ptr uk55[bx]
uk56:
mov ch,uk38
test ch,ch
jnz uk60
mov uk38,1h
clc
rcr word ptr uk31[0],1
rcr word ptr uk31[2],1
rcr byte ptr uk32,1
jmp uk63
uk60:
mov uk38,0h
clc
rcl byte ptr uk32,1
rcl word ptr uk31[2],1
rcl word ptr uk31[0],1
jmp uk63
uk57:
uk61:
call uk93
cmp cl,uk28
je uk58
cmp cl,uk27
jne uk61
jmp uk52
uk58:
jmp uk73
uk62:
test cl,cl
jz uk63
cmp ah,cl
je uk63
cmp al,cl
je uk63
mov bx,word ptr uk33.uk13
mov dx,word ptr uk33.uk14
call uk92
mov al,cl
uk63:
mov bx,word ptr uk33.uk13
mov dx,word ptr uk33.uk14
mov cl,al
call uk96
call uk97
mov uk35.uk13,bx
mov uk35.uk14,dx
mov uk37,0
call uk88
cmp cl,uk15
je uk66
cmp cl,uk20
je uk65
cmp bx,uk34.uk13
jne uk64
cmp dx,uk34.uk14
jne uk64
jmp uk66
uk64:
jmp uk71
uk65:
mov uk37,1
uk66:
mov al,uk37
test al,al
jnz uk67
mov bx,word ptr uk34.uk13
mov dx,word ptr uk34.uk14
call uk88
call uk96
call uk97
mov uk36.uk13,bx
mov uk36.uk14,dx
mov bx,uk34.uk13
mov dx,uk34.uk14
mov cl,uk15
call uk92
mov al,uk12
call uk91
uk67:
mov bx,word ptr uk33.uk13
mov dx,word ptr uk33.uk14
mov al,uk9
call uk91
call uk88
mov bx,word ptr uk35.uk13
mov dx,word ptr uk35.uk14
mov al,uk8
call uk91
call uk92
mov word ptr uk33.uk13,bx
mov word ptr uk33.uk14,dx
mov al,uk37
test al,al
jnz uk68
mov bx,word ptr uk36.uk13
mov dx,word ptr uk36.uk14
mov al,uk10
call uk91
mov word ptr uk34.uk13,bx
mov word ptr uk34.uk14,dx
jmp uk70
uk68:
inc word ptr uk39
cmp word ptr uk39,uk3
jnae uk69
jmp uk72
uk69:
call uk83
uk70:
jmp uk52
uk71:
jmp uk74
uk72:
jmp uk74
jmp uk74
uk75 dw offset uk51,offset uk73
uk74:
call uk93
cmp cl,uk27
jb uk74
cmp cl,uk28
ja uk74
sub cl,uk27
mov bh,0h
mov bl,cl
shl bx,1
jmp word ptr uk75[bx]
uk73:
mov ax, 4c00h
int 21h
ret
uk50 endp
uk76 proc
push ax
push bx
push dx
mov ax,uk4
mov dx,uk5
mul dx
mov uk44,dx
mov uk45,ax
pop dx
pop bx
pop ax
ret
uk76 endp
uk77 proc
push ax
push bx
mov ax,4f05h
mov bx,0h
int 10h
pop bx
pop ax
ret
uk77 endp
uk78 proc
push ax
push bx
push cx
push dx
push es
push di
mov ax,0a000h
mov es,ax
cld
mov dx,0
uk79:
cmp dx,uk44
jae uk80
call uk77
mov al,uk12
mov cx,0ffffh
mov di,0h
rep stosb
stosb
inc dx
jmp uk79
uk80:
mov ax,uk45
test ax,ax
jz uk81
call uk77
mov al,uk12
mov cx,uk45
mov di,0h
rep stosb
uk81:
pop di
pop es
pop dx
pop cx
pop bx
pop ax
ret
uk78 endp
uk82 proc
push ax
push cx
push es
push di
mov ax,uk30
mov es,ax
lea ax,uk43
mov di,ax
mov al,uk15
mov cx,uk3
cld
rep stosb
pop di
pop es
pop cx
pop ax
ret
uk82 endp
uk83 proc
push ax
push bx
push cx
push dx
mov ax,uk3
sub ax,uk39
jz uk84
mov dx,ax
mov bx,uk40
mov ax,bx
mov cl,7
shl ax,cl
xor bx,ax
mov ax,bx
mov cl,9
shl ax,cl
xor bx,ax
mov ax,bx
mov cl,8
shl ax,cl
xor bx,ax
mov uk40,bx
mov ax,bx
mov bx,dx
mov dx,0
div bx
mov ax,dx
mov dx,0
uk85:
cmp dx,uk2
jae uk86
mov bx,0
uk87:
cmp bx,uk1
jae _b1
call uk88
test cl,cl
jnz uk89
test ax,ax
jnz uk90
mov al,uk11
call uk91
mov cl,uk20
call uk92
jmp uk84
uk90:
dec ax
uk89:
inc bx
jmp uk87
_b1:
inc dx
jmp uk85
uk86:
uk84:
pop dx
pop cx
pop bx
pop ax
ret
uk83 endp
uk93 proc
push ax
push bx
mov cl,0
mov bh,0h
uk94:
mov ah,01h
int 16h
jz uk95
mov ah,00h
int 16h
mov bl,ah
mov al,uk47[bx]
test al,al
jz uk94
mov cl,al
uk95:
pop bx
pop ax
ret
uk93 endp
uk96 proc
push ax
mov ah,0h
mov al,cl
shl ax,1
shl ax,1
xchg ax,bx
add ax,word ptr uk42[bx].uk13
add dx,word ptr uk42[bx].uk14
mov bx,ax
pop ax
ret
uk96 endp
uk97 proc
cmp bx,uk1
jnge uk98
sub bx,uk1
uk98:
cmp bx,0
jge uk99
add bx,uk1
uk99:
cmp dx,uk2
jnge uk100
sub dx,uk2
uk100:
cmp dx,0
jge uk101
add dx,uk2
uk101:
ret
uk97 endp
uk92 proc
push ax
push bx
push dx
mov ax,uk1
mul dx
add bx,ax
mov uk43[bx],cl
pop dx
pop bx
pop ax
ret
uk92 endp
uk88 proc
push ax
push bx
push dx
mov ax,uk1
mul dx
add bx,ax
mov cl,uk43[bx]
pop dx
pop bx
pop ax
ret
uk88 endp
uk102 proc
push ax
push cx
mov ax,uk0
mul dx
mov cx,ax
mov ax,uk0
mul bx
mov bx,ax
mov dx,cx
pop cx
pop ax
ret
uk102 endp
uk91 proc
push ax
push bx
push cx
push dx
push es
push di
push si
call uk102
mov cx,0a000h
mov es,cx
push ax
mov ax,uk4
mul dx
add ax,bx
adc dx,0h
mov bx,ax
pop ax
call uk77
cld
mov cx,uk0
uk103:
mov si,bx
add si,uk0
jnc uk104
push cx
mov di,bx
mov cx,uk0
sub cx,si
rep stosb
inc dx
call uk77
mov cx,si
rep stosb
pop cx
add bx,uk4
jmp uk105
uk104:
push cx
mov di,bx
mov cx,uk0
rep stosb
pop cx
add bx,uk4
jnc uk106
inc dx
call uk77
uk106:
uk105:
loop uk103
pop si
pop di
pop es
pop dx
pop cx
pop bx
pop ax
ret
uk91 endp
uk49 ends
end uk50