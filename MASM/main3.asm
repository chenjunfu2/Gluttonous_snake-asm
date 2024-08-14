assume cs:code

stack segment
    db 16 dup (0)
stack ends

data segment
    db 8 dup(0)
data ends

code segment
    start:
        mov ax,stack
        mov ss,ax
        mov sp,16;自己加的栈
        mov bx,data

        mov ax,4240H
        mov dx,000FH
        mov cx,0AH
        call divdw
        
        mov ax, 4c00h 
        int 21h

        divdw:
            ;名称:divdw
            ;功能:进行不会产生溢出的除法运算，被除数为dword型，除数为word型，结果为dword型。
            ;参数:(ax)=dword型数据的低16位
            ;   (dx)=dword型数据的高16位
            ;   (cx)=除数
            ;返回:(dx)=结果的高16位，(ax)=结果的低16位
            ;   (cx)=余数

            ;push ax;低位等会算，(sp)-2
            mov [bx+0],ax
            mov ax,dx
            mov dx,0
            div cx;此时ax是商，dx是余数

            ;push ax;保存商
            mov [bx+2],ax
            mov ax,dx
            ;add sp,2
            ;pop ax
            mov ax,[bx+0]
            div cx

            mov cx,dx
            mov dx,[bx+2]
            ;sub sp,4
            ;pop dx
            ;add sp,2

            ret
code ends

end start