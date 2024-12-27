;BITS 16

data segment
modeInfo db 256 dup(0);TIMES
ORG 100h
data ends

assume cs:code,ds:data;,ss:stack,es:extra
code segment
start:
mov ax, ds
mov es, ax 

;Set video mode
mov ax, 4f02h
mov bx, 105h
int 10h

;Get video mode info
mov ax, 4f01h
mov cx, 105h
lea di, modeInfo 
int 10h

;Assume first window is valid 
mov ax, word ptr es:[di+08h]
mov es, ax

;Example of how to change the window 
mov ax, 4f05h
xor bx, bx
mov dx, 5       ;This is granularity units
int 10h

xor di, di 
mov al, 0f1h
mov cx, 3*1024*20

rep stosb

;Wait for key
xor ax, ax
int 16h

;Restore DOS text mode
;mov ax, 0003h
;int 10h

;Exit
mov ax, 4c00h
int 21h
code ends


end start