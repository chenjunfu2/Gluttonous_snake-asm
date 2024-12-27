;用于生成A～Z字符，delay调显示速率
;安装int9说明：如果检查为esc键，则变色
assume cs:code

stack segment
    db 128 dup (0)
stack ends

data segment
    db 4 dup (0)
data ends

code segment
    start: 
        mov ax,stack
        mov ss,ax

        ;安装int9
        mov ax,data
        mov ds,ax

        mov ax,0
        mov es,ax

        push es:[9*4];IP
        pop ds:[0]
        push es:[9*4+2];CS
        pop ds:[2]

        cli
        mov word ptr es:[9*4], offset int9
        mov es:[9*4+2],cs
        sti

        ;程序开始
        lp:
        mov sp,128
        mov ax,0b800h 
        mov es,ax
        mov ah,'a'
    s:   
        mov es:[160*12+40*2],ah
        call delay
        inc ah
        cmp ah,'z'
        jna s

        jmp lp
        mov ax, 4c00h 
        int 21h
    delay:
        push ax
        push dx
        mov dx,5h
        mov ax,0h
    s1:
        sub ax,1
        sbb dx,0
        cmp ax,0
        jne s1
        cmp dx,0
        jne s1
        pop dx
        pop ax
        ret

    int9:
        push ax
        push bx
        push cx
        push es
        push ds

        in al,60h

        ;mov bx,data
        ;mov ds,bx
        ;mov bx,ds:[0]
        ;mov ds,ds:[2]

        pushf;保存标志寄存器，平栈（原int例程有iret）
        ;call ds:[bx]
        call dword ptr ds:[0]
        cmp al,01h
        jne int9ret

    	mov bx,0B800H
    	mov es,bx
    	mov bx,1						    ;奇数位保存颜色属性信息
    	mov cx,2000							;整个屏幕2000个字符
        changeColor:
    	inc byte ptr es:[bx]
    	add bx,2
    	loop changeColor

        ;mov ax, 0b800h
        ;mov es, ax
        ;inc byte ptr es:[160*12+40*2+1]

    int9ret:
        pop ds
        pop es
        pop cx
        pop bx
        pop ax
        iret

code ends

end start