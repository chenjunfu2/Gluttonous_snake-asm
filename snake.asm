.186;使用80186的pusha和popa
assume cs:code,ds:data,ss:stack,es:extra

;常量数据
block_side equ 10
map_x equ 80
map_y equ 60
map_size equ map_x*map_y
screen_x equ map_x*block_side
screen_y equ map_y*block_side
screen_size equ screen_x*screen_y
snake_head equ 00001110b
snake_body equ 00001111b
snake_tail equ 00000111b
snake_food equ 00000010b
background equ 00000000b
x equ 0
y equ 2
dir_nu equ 0
dir_up equ 1
dir_dn equ 2
dir_lf equ 3
dir_rg equ 4
key_nu equ dir_nu
key_up equ dir_up
key_dn equ dir_dn
key_lf equ dir_lf
key_rg equ dir_rg

stack segment
	db 1024 dup(0)
stack ends

data segment
	snake_head_pos dd 0
	snake_tail_pos dd 0
	snake_length dw 0
	dir_neg db dir_nu,dir_dn,dir_up,dir_rg,dir_lf
	dir_mov dw 0000h,0000h, 0000h,0ffffh, 0000h,0001h, 0ffffh,0000h, 0001h,0000h;(0,0) (0,-1) (0,1) (-1,0) (1,0)
data ends

;扩展段
extra segment
	map db map_size dup(dir_nu);地图，访问方式：y*map_x+x
	key_map db 255 dup(key_nu);按键映射，访问方式：扫描码查表
	last_input_pos db 0;最后一次按键记录
extra ends


;段大小最大为65535

code segment	
main proc
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

;---------------------程序开始---------------------;


	;mov al,13h;320*200 256色的图形模式:
	;mov ah,0;是用来设定显示模式的服务程序
	;int 10h;调用中断

	;mov cx,10;x坐标
	;mov dx,10;y坐标
	;mov al,1100b;淡红色
	;mov ah,0ch;绘制点
	;int 10h;调用中断

	;清屏
	;mov ah,06h
	;mov al,0
	;mov ch,0  ;(0,0)
	;mov cl,0
	;mov dh,24  ;(24,79)
	;mov dl,79
	;;mov bh,07h ;黑底白字
	;int 10h

	
	;设置显示模式为点阵模式，否则字符模式无法绘图
	;mov ax,00h
	;mov al,12h;640×480 16色
	;mov al,13h;640×480 256色

	mov ax,4f02h;超级vga显卡
	mov bx,0103h;800×600 256色
	;int 10h;调用图形中断

	


	;mov ah,0fh;获取页码，存储在bh内
	;int 10h;调用图形中断

	;mov bh,0;手动设置页码
	;mov al,10111111b;颜色
	;mov ah,0ch;绘制点
	;int 10h

	;int 10 AH=0CH	AL=颜色，BH=页码 CX=x，DX=y





	;绘制蛇
	;mov al,snake_head
	;mov cx,1
	;mov dx,6
	;call draw_block
	;
	;mov al,snake_body
	;mov cx,2
	;mov dx,6
	;call draw_block
	;
	;mov al,snake_body
	;mov cx,3
	;mov dx,6
	;call draw_block
	;
	;mov al,snake_tail
	;mov cx,4
	;mov dx,6
	;call draw_block
	;
	;mov al,snake_food
	;mov cx,8
	;mov dx,6
	;call draw_block


	;mov dx,0
	;l0:
	;cmp dx,600
	;jge b0
	;
	;	mov cx,0
	;	l1:
	;	cmp cx,800
	;	jge b1
	;
	;	int 10h;调用图形中断
	;
	;	inc cx
	;	jmp l1
	;	b1:
	;
	;	inc dx
	;	jmp l0
	;b0:

	;测试代码
	;mov cl,1
	;mov bx,5
	;mov dx,7
	;call snake_move
	;
	;mov cl,2
	;mov bx,5
	;mov dx,7
	;call snake_move
	;
	;mov cl,3
	;mov bx,5
	;mov dx,7
	;call snake_move
	;
	;mov cl,4
	;mov bx,5
	;mov dx,7
	;call snake_move

	;设置按键映射
	mov byte ptr key_map[48h],key_up
	mov byte ptr key_map[50h],key_dn
	mov byte ptr key_map[4bh],key_lf
	mov byte ptr key_map[4dh],key_rg

	;设置键盘回调
	call install_int9h_routine

	;设置头尾坐标
	;0,1
	mov word ptr snake_head_pos.x,0
	mov word ptr snake_head_pos.y,1

	;0,0
	mov word ptr snake_tail_pos.x,0
	mov word ptr snake_tail_pos.y,0

	;设置地图
	mov bx,word ptr snake_head_pos.x
	mov dx,word ptr snake_head_pos.y
	mov cl,dir_rg
	call set_map_pos
	;call get_map_pos;test


	mov bx,word ptr snake_tail_pos.x
	mov dx,word ptr snake_tail_pos.y
	mov cl,dir_rg
	call set_map_pos
	;call get_map_pos;test

	;初始长度2
	mov snake_length,2

	;初始化完毕，开始游戏循环
	;先进行一次初始绘制

	game_loop:
		;游戏刻时间判断，直到时间到达，才进行下面的流程，否则无限循环等待
		;mov ah, 2ch;21h中断读时间功能，CH:CL=时:分 DH:DL=秒:1/100秒
		;int 21h
		;偷懒换一种办法，直接用中断延迟，类似于sleep
		mov ah,86h
		mov cx,0h; CX：DX= 延时时间（单位是微秒）
		mov dx,3e80h;16000us=16ms(60fps/s)
		int 15h;等待16ms


		;从输入队列获取并处理所有输入，输入队列中的数据由按键中断历程添加，
		;因为贪吃蛇没有必要保留一游戏刻内多余的操作，所以仅记录最后一个操作方向，即队列长度为1
		;按键测试
		;jmp dat;跳过数据，否则会被当成代码执行
		;table db snake_head,snake_body,snake_tail,snake_food
		;dat:
		;mov bh,0h
		;mov bl,last_input_pos
		;mov al,table[bx]
		;mov cx,8
		;mov dx,6
		;call draw_block

		;根据输入改变方向，注意需要从键盘中断历程共享数据last_input_pos读取
		;判断一下当前方向，避免反方向移动

		;获取当前头的方向
		mov bx,word ptr snake_head_pos.x
		mov dx,word ptr snake_head_pos.y
		call get_map_pos

		;取反方向
		mov bh,0h
		mov bl,al
		mov ah,dir_neg[bx];ah存储蛇头方向的反向

		;保存last_input_pos防止中断修改导致前后不统一
		mov cl,last_input_pos;cl存储当前按键方向

		cmp ah,cl;如果当前按键方向和蛇头反方向相等则掠过不改变（不能180度扭头）
		je no_change_dir
		cmp ah,al;如果当前按键方向和蛇头方向一致也无需改变
		je no_change_dir
			mov bx,word ptr snake_head_pos.x
			mov dx,word ptr snake_head_pos.y
			call set_map_pos
		no_change_dir:



		;移动、吃和生成食物、判断输赢并仅记录（输赢处理需要等后续绘制完毕），同时记录移动情况以便绘制优化







		;绘制蛇（注意优化：如有必要则擦除蛇尾，绘制新蛇尾，擦除原先蛇头位置绘制为蛇身，
		;绘制新蛇头（此处如果吃到事物会直接覆盖绘制，无需擦除食物），如有必要则绘制新食物）


		;判断刚才的输赢情况（ps：输为碰撞蛇身，赢为蛇长度大等于地图大小）


	jmp game_loop

;---------------------结束返回---------------------;
	return:
	mov ax, 4c00h
	int 21h
	ret
main endp

;---------------------函数定义---------------------;

	;蛇移动
	;cl=dir,bx=x,dx=y
snake_move proc
	push ax

	;对索引做倍增
	mov al,cl
	mov ch,4
	mul ch;ax=al*ch(4)（用于4byte表项访问索引）
	xchg ax,bx;交换ax和bx

	;查表
	add ax,word ptr dir_mov[bx].x;根据表项改变x和y
	add dx,word ptr dir_mov[bx].y;

	;保存返回
	mov bx,ax
	pop ax
	ret
snake_move endp

	;越界环绕
	;bx=x,dx=y
surround proc
	cmp bx,map_x
	jnge x_add
	sub bx,map_x;如果大等于map_x则减去
	x_add:
	cmp bx,0
	jge x_end
	add bx,map_x;如果小于0则加上
	x_end:

	cmp dx,map_y
	jnge y_add
	sub dx,map_y;如果大等于map_y则减去
	y_add:
	cmp dx,0
	jge y_end
	add dx,map_y;如果小于0则加上
	y_end:

	ret
surround endp


	;设置地图坐标点上的方向
	;cl=dir,bx=x,dx=y
set_map_pos proc

	;pos(bx)=y(dx)*map_x(ax)+x(bx)
	mov ax,map_x
	mul dx;dx:ax=ax*dx
	add bx,ax

	;map[pos(bx)]=dir(cl)
	mov map[bx],cl

	ret
set_map_pos endp

	;获取地图坐标点上的方向
	;al=return bx=x,dx=y
get_map_pos proc

	;pos(bx)=y(dx)*map_x(ax)+x(bx)
	mov ax,map_x
	mul dx;dx:ax=ax*dx
	add bx,ax

	mov al,map[bx]

	ret
get_map_pos endp

	
	;地图坐标转换到屏幕坐标(cx=x dx=y)
	;修改cx和dx为原来的十倍
pos_to_screen proc;使用ax、bx、cx、dx
	push ax
	push bx

	mov ax,block_side
	mul dx;dx:ax=block_side(ax)*y(dx)
	mov bx,ax;忽略高位dx，只保存ax，暂存到bx

	mov ax,block_side
	mul cx;dx:ax=block_side(ax)*x(cx)
	mov cx,ax;忽略高位dx，只保存ax

	mov dx,bx;把刚才bx暂存的值赋值给dx

	pop bx
	pop ax
	ret
pos_to_screen endp


	;AL=颜色 CX=x DX=y
	;数据一定要定义在函数之前，否则会被当成代码执行到
	bsx dw 0
	bsy dw 0
draw_block proc
	pusha;保存通用寄存器

	call pos_to_screen;调用转换

	mov bh,0
	mov ah,0ch;绘制点
	;绘制block_side大小的矩形

	mov bsx,cx
	mov bsy,dx

	add bsx,block_side
	add bsy,block_side
	
	;双重for循环
	drb0:
	cmp dx,bsy
	jnb drb0_;无符号不小于时转移
		
		drb1:
		cmp cx,bsx
		jnb drb1_;无符号不小于时转移

		int 10h

		inc cx
		jmp drb1
		drb1_:
		sub cx,block_side;恢复cx到传入大小
	
	inc dx
	jmp drb0
	drb0_:

	popa;弹出通用寄存器
	ret
draw_block endp

install_int9h_routine proc
	pusha
	push es
	push ds

	;拷贝新的int9h例程代码到安全区
	;设置es:di
	mov bx,0
	mov es,bx
	mov di,7E00H
	
	;设置ds:si
	mov bx,cs
	mov ds,bx
	mov si,offset new_int9h
	
	mov cx,offset new_int9h_end-offset new_int9h;设置传送大小
	cld;设置传送方向
	rep movsb;传送 ds:si->es:di

	;保存原中断例程地址
	;此处es仍为0，无需重复设置
	cli;关中断

	mov ax,es:[9*4+0]	;暂存ip
	mov word ptr es:[9*4+0],7e00h;设置新中断地址ip
	mov es:[200h+0],ax	;保存ip

	mov ax,es:[9*4+2]	;暂存cs
	mov word ptr es:[9*4+2],0h;设置新中断地址cs
	mov es:[200h+2],ax	;保存cs
	
	sti;开中断

	pop ds
	pop es
	popa
	ret
install_int9h_routine endp

uninstall_int9h_routine proc
	pusha
	push es

	mov bx,0
	mov es,bx

	cli

	mov ax,es:[200h+0];获取原来的中断地址
	mov es:[9*4+0],ax;放回中断表

	mov ax,es:[200h+2]
	mov es:[9*4+2],ax

	sti

	pop es
	popa
	ret
uninstall_int9h_routine endp
;---------------------中断例程---------------------;

new_int9h proc
	push ax
	in al,60H                       ;从端口读取数据
	pushf							;保存标志位（call和int的区别在于int多一个pushf，原中断返回时会popf，这里pushf后刚好能平栈，伪装成int中断调用）
	call dword ptr cs:[200H]		;调用原中断
	
		;执行回调操作
		push bx
		push es
		
		mov bx,extra
		mov es,bx
		
		mov ah,0h
		mov bx,ax
		mov ah,es:key_map[bx];扫描码查表，表内数据为方向，0为无效，1~4分别为4个方向
		
		test ah,ah;测试表数据，如果为0则无效按键，忽略，否则保存
		jz int9h_ret
		mov es:last_input_pos,ah
		
		int9h_ret:
		pop es
		pop bx

		;cmp al,48h						
		;je change						
		;cmp al,50h	
		;je change	
		;cmp al,4Bh	
		;je change		
		;cmp al,4Dh	
		;je change
		;jmp int9h_ret	
		;
		;change:
		;push bx
		;push es
		;push cx
		;
		;mov bx,0B800H
		;mov es,bx
		;mov bx,1									;奇数位保存颜色属性信息
		;mov cx,2000							;整个屏幕2000个字符
		;changeColor:
		;inc byte ptr es:[bx]
		;add bx,2
		;loop changeColor
		;pop cx
		;pop es
		;pop bx
		;int9h_ret:

	pop ax
	iret;中断返回
new_int9h_end:nop;标记
new_int9h endp

code ends

end main

;8086  CPU 中寄存器总共为 14 个，且均为 16 位 。
;即 AX，BX，CX，DX，SP，BP，SI，DI，IP，FLAG，CS，DS，SS，ES 共 14 个。
;而这 14 个寄存器按照一定方式又分为了通用寄存器，控制寄存器和段寄存器。
;
;通用寄存器：
;AX，BX，CX，DX 称作为数据寄存器：
;AX (Accumulator)：累加寄存器，也称之为累加器；
;BX (Base)：基地址寄存器；
;CX (Count)：计数器寄存器；
;DX (Data)：数据寄存器；
;SP 和 BP 又称作为指针寄存器：
;SP (Stack Pointer)：堆栈指针寄存器；
;BP (Base Pointer)：基指针寄存器；
;SI 和 DI 又称作为变址寄存器：
;SI (Source Index)：源变址寄存器；
;DI (Destination Index)：目的变址寄存器；
;
;控制寄存器：
;IP (Instruction Pointer)：指令指针寄存器；
;FLAG：标志寄存器；
;
;段寄存器：
;CS (Code Segment)：代码段寄存器；
;DS (Data Segment)：数据段寄存器；
;SS (Stack Segment)：堆栈段寄存器；
;ES (Extra Segment)：附加段寄存器；


;INT 09h (9)              Keyboard
; 
;The keyboard generates an INT 9 every time a key is pushed or released.
; 
;Notes:  This is a hardware interrupt (IRQ 1) activated by the make or break of every keystroke.
;The default INT 9 handler in the ROM reads the make and break scan codes from the keyboard and converts them into actions or key codes as follows:
;
;For ASCII keys, when a make code is encountered, the ASCII code and the scan code for the key are placed in the 32-byte keyboard buffer, which is located at 0:41Eh. The ASCII code and scan code are placed in the buffer at the location addressed by the Keyboard Buffer Tail Pointer (0:041Ch). The Keyboard Buffer Tail Pointer is then incremented by 2, and if it points past the end of the buffer, it is adjusted so that it points to the beginning of the buffer.
;If Ctrl, Alt, or Shift has been pressed, the Shift Status (0:0417h) and Extended Shift Status (0:0418h) bytes are updated.
;If the Ctrl-Alt-Del combination has been pressed, the Reset Flag (0:0472h) is set to 1234h and control is given to the power-on self test (POST). Because the Reset Flag is 1234h, the POST routine bypasses the memory test.
;If the Pause key sequence has been entered, this interrupt enters an indefinite loop. The loop is broken as soon as a valid ASCII keystroke is entered. (The PC Convertible issues an INT 15h, Service 41h (Wait on External Event), to execute its pause loop.)
;If the Print Screen key sequence is entered, an INT 05h (Print Screen) is executed.
;If the Control-Break key sequence is entered, an INT 1Bh (Control-Break) is executed.
;For XTs dated 1/10/86 and after, ATs, XT-286s, and PC Convertibles, the INT 9h handler generates an INT 15h, function 91h (Interrupt Complete) to signal that a keystroke is available. Also, on these machines, a make or break of the Sys Req key generates an INT 15h, function 85h (System Request Key Pressed).
;For ATs dated 6/10/85 and after, XT-286s, and PC Convertibles, an INT 15h, function 4Fh (Keyboard Intercept) is executed after the scan code has been read from the keyboard port (60h). This allows the user to redefine or remove a keystroke.
;
;INT 16 provides a standard way to read characters from the keyboard buffer that have been placed there by the INT 9 handler in ROM.