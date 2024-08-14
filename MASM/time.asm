;编程，以“ 年/月/日时:分:秒” 的格式，显示当前的日期、时间。
;秒:0 分:2 时:4 日:7 月:8 年:9
assume cs:code,ds:data

data segment
    read_addr db 9,8,7,4,2,0
    oupt_char db '/','/',' ',':',':',0
data ends

code segment
    start:
        mov bx,data
        mov ds,bx
        mov si,0;初始化地址

        l0:
            mov al,ds:[si]
            mov dl,ds:[si+6]

            inc si
            call data_get
            call data_process
            call print

            cmp si,6
            jb l0

        mov ax,4c00h
        int 21h

    data_get:
        ;获取数据(al;要读入数据地址)
        out 70h,al
        in al,71h
        ret

    data_process:
        ;处理数据(al;传入数据，cl;占用)
        mov ah,al;先处理ah
        mov cl,4
        shr ah,cl
        and al,00001111b;处理al，把高位的ab码删掉
        or ax,0011000000110000b
        ret

        ;3个字符，分别是ah、al和dl
        opt db 3 dup(0)
    print:
        mov [opt+0],ah
        mov [opt+1],al
        mov [opt+2],dl

        mov ah,2h

        mov dl,[opt+0]
        int 21h
        mov dl,[opt+1]
        int 21h
        mov dl,[opt+2]
        int 21h

        ret

code ends

end start