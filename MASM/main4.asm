assume cs:code

data segment
    db 10 dup (0)
data ends

code segment
    start:
        mov ax,12666
        mov bx,data
        mov ds,bx
        mov si,0
        call dtoc

        mov dh,8
        mov dl,3
        mov cl,2
        
        call show_str

        mov ax, 4c00h 
        int 21h        

        dtoc:
            ;子程序描述
            ;名称：dtoc
            ;功能：将 word型数据转变为表示十进制数的字符串，字符串以0为结尾符。
            ;参数：（ax）=word 型数据
            ;   ds:si指向字符串的首地址
            ;返回：无
            mov bl,10
            mov cl,0
            l0:
                call divdw

                mov ds:[si],bh
                add byte ptr ds:[si],30H
                inc si
                ;用来判断
                mov ch,bh
                mov ah,00
                jcxz break
                loop l0

    
        divdw:
            ;名称:divdw
            ;功能:进行不会产生溢出的除法运算，被除数为word型，除数为byte型，结果为byte型。
            ;参数:(al)=dword型数据的低8位
            ;   (ah)=dword型数据的高8位
            ;   (bl)=除数
            ;返回:(ah)=结果的高8位，(al)=结果的低8位
            ;   (bh)=余数

            mov ds:[si],al
            mov al,ah
            mov ah,0
            div bl;此时ax是商，dx是余数

            mov ds:[si].1,al;保存商
            mov al,ah
            mov al,ds:[si]
            div bl

            mov bh,ah
            mov al,ds:[si].1

            ret

        show_str:
            ;名称:show_str
            ;功能:在指定的位置，用指定的颜色，显示一个用O结束的字符串。
            ;参数:(dh)=行号(取值范围0~24)，(dl)=列号(取值范围O~79)， (cl)=颜色，ds:si指向字符串的首地址
            ;返回:无
            ;应用举例:在屏幕的8 行3 列，用绿色显示data 段中的字符串。

            ;计算下行号（段位置）
            mov al,0Ah
            mul dh
            mov ah,0B8h

            mov es,ax

            ;计算列号偏移位置
            mov bl,dl
            dec bl
            mov bh,0
            add bx,bx

            ;准备颜色
            mov ah,cl

            continue:
                ;读取数据并且判断
                mov cl,ds:[si]
                mov ch,0
                jcxz break

                mov al,ds:[si]
                mov es:[bx][si],ax
                inc bx
                inc si
                jmp continue

            break:
                ret

code ends
end start