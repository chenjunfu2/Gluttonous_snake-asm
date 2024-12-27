;下面的程序，分别在屏幕的第2、4、6、8行显示4句英文诗。
assume cs: code
code segment
    s1: db 'Good, better, best,' , '$'
    s2: db 'Never let it rest,', '$'
    s3: db 'Till good is better,', '$'
    s4: db 'And better,best.', '$'
    s: dw offset s1, offset s2, offset s3, offset s4
    row: db 2,4,6,8

    start:
        mov ax, cs
        mov ds, ax
        mov bx, offset s
        mov si, offset row
        mov cx, 4
        ok:
            ;int10h:(ah=2;置光标),第(bh)页,dh中放行号,dl中放列号
            ;push bx
            mov bh,0
            mov dh,ds:[si]
            mov dl,0
            mov ah,2
            int 10h
            ;pop bx

            ;int21h:(ah=9;光标位置显示字符串),ds:dx指向字符串;要显示的字符串需用“$"作为结束符
            mov dx,[bx]
            mov ah,9
            int 21h



            inc si
            add bx,2

            loop ok
        ;int21h:(ah=4c;不玩了，返回),al为返回码
        mov ax, 4c00h
        int 21h
code ends

end start