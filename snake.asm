;-----------------------chenjunfu2-----------------------;
;-----------------------2024/08/14-----------------------;
;Link:https://github.com/chenjunfu2/Gluttonous_snake-asm/;
;--------------------Gluttonous_snake--------------------;

assume cs:code,ds:data,ss:stack,es:extra

;常量数据
block_side equ 10;每个蛇方块的大小
map_x equ 80;地图大小x
map_y equ 60;地图大小y
map_size equ map_x*map_y
screen_x equ 800;屏幕大小x
screen_y equ 600;屏幕大小y
screen_mod_ax equ 4f02h;视频设置ax，超级vga显卡，0013h->320*200
screen_mod_bx equ 0103h;视频设置bx，800×600 256色

snake_head equ 00001110b;蛇头颜色
snake_body equ 00001111b;蛇身颜色
snake_tail equ 00000111b;蛇尾颜色
snake_food equ 00000010b;食物颜色
background equ 00000000b;背景颜色
x equ 0;用于访问坐标x
y equ 2;用于访问坐标y
dir_nu equ 0	 ;方向空
dir_up equ 1	 ;方向上
dir_dn equ 2	 ;方向下
dir_lf equ 3	 ;方向左
dir_rg equ 4	 ;方向右
dir_fd equ 5	 ;食物
key_nu equ dir_nu;按键空
key_up equ dir_up;按键上
key_dn equ dir_dn;按键下
key_lf equ dir_lf;按键左
key_rg equ dir_rg;按键右
key_sp equ 5;加速按键
key_pa equ 6;暂停按键
key_qu equ 7;退出按键


stack segment
	db 1024 dup(0)
stack ends

data segment
	snake_move_speed dw 2 dup();蛇移动速度
	speed_bit_save db 1 dup();加速位移数据保存（加速时相当于把snake_move_speed代表的等待时间除以二，右移，为了保留最低位以便退出加速时恢复）
	snake_head_pos dw 2 dup();蛇头当前位置
	snake_tail_pos dw 2 dup();蛇尾当前位置
	new_snake_head_pos dw 2 dup();新的蛇头位置
	new_snake_tail_pos dw 2 dup();新的蛇尾位置
	is_eat_food db 1 dup();当前是否吃到了食物
	is_fast_speed db 1 dup();当前是否是加速模式
	snake_length dw 1 dup();蛇长度（用来判断玩家胜利）
	random_seed dw 1 dup();随机数种子
	dir_neg db dir_nu,dir_dn,dir_up,dir_rg,dir_lf;移动方向反转表，只读
	dir_mov dw 0000h,0000h, 0000h,0ffffh, 0000h,0001h, 0ffffh,0000h, 0001h,0000h, 0000h,0000h;移动方向表，nu(0,0) up(0,-1) dn(0,1) lf(-1,0) rg(1,0) fd(0,0)只读
	map db map_size dup();地图，存储dir方向数据，访问方式：y*map_x+x
	vesa_page_count dw 1 dup();vesa页面数量，初始化后只读
	vesa_complete dw 1 dup();vesa不满一页的填充大小，初始化后只读
data ends

;扩展段
extra segment
	key_map db 255 dup(key_nu);按键映射表，访问方式：扫描码查表
	time_event db 1 dup();时间事件，用来确定游戏循环的game tick是否开始运行
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

	;设置图形模式
	mov ax,screen_mod_ax
	mov bx,screen_mod_bx
	int 10h;调用图形中断

	;设置vesa_page
	call init_vesa_page

	;设置按键映射
	mov byte ptr key_map[48h],key_up;48h 上 -> up Arrow
	mov byte ptr key_map[50h],key_dn;50h 下 -> down Arrow 
	mov byte ptr key_map[4bh],key_lf;4bh 左 -> left Arrow 
	mov byte ptr key_map[4dh],key_rg;4dh 右 -> right Arrow
	mov byte ptr key_map[39h],key_sp;39h 加速 -> space
	mov byte ptr key_map[19h],key_pa;19h 暂停 -> p
	mov byte ptr key_map[10h],key_qu;10h 退出 -> q

	;设置随机数种子（在食物生成之前设置）
	mov ah,2ch;21h中断读时间功能，CH:CL=时:分 DH:DL=秒:1/100秒
	int 21h
	;秒*100+1/100秒
	mov al,100
	mul dh;ax=al*dh
	mov dh,0h
	add ax,dx
	mov random_seed,ax

	restart:
	;清空屏幕
	call clear_screen

	;清空地图
	call clear_map

	;设置头尾坐标
	;0,1
	mov word ptr snake_head_pos.x,1
	mov word ptr snake_head_pos.y,0

	;0,0
	mov word ptr snake_tail_pos.x,0
	mov word ptr snake_tail_pos.y,0

	;设置地图
	mov bx,word ptr snake_head_pos.x
	mov dx,word ptr snake_head_pos.y
	mov al,snake_head
	call draw_block
	mov cl,dir_rg
	call set_map_pos


	mov bx,word ptr snake_tail_pos.x
	mov dx,word ptr snake_tail_pos.y
	mov al,snake_tail
	call draw_block
	mov cl,dir_rg
	call set_map_pos

	;生成食物之前设置初始长度2
	mov snake_length,2

	;设置食物（随机生成）
	call spawn_snake_food

	;设置循环速度
	mov word ptr snake_move_speed[0],1h
	mov word ptr snake_move_speed[2],86a0h
	mov byte ptr speed_bit_save,0h
	mov byte ptr is_fast_speed,0h

	;初始化完毕，开始游戏循环

	mov time_event,10000000b;时间事件初始为1
	game_loop:
		;游戏刻时间判断，直到时间到达，才进行下面的流程，否则无限循环等待
		time_event_test:;时间事件测试
		mov al,time_event
		test al,al
		jz time_event_test;如果为0则跳转回去继续测试
		mov time_event,0h;如果不为0则清零并运行，然后设置事件并等待下次测试
		;使用事件调用
		;该调用立即返回，循环检查time_event直到最高位7bit设为1
		;es:bx->time_event
		;cx:dx->ms
		mov ah,83h
		mov al,00h;设置，01为取消设置
		lea bx,time_event
		mov cx,word ptr snake_move_speed[0]
		mov dx,word ptr snake_move_speed[2]
		int 15h

		
		;判断一下当前方向，避免反方向移动
		;获取当前头的方向
		mov bx,word ptr snake_head_pos.x
		mov dx,word ptr snake_head_pos.y
		call get_map_pos

		;取反方向
		mov bh,0h
		mov bl,cl;cl蛇头方向
		mov ah,dir_neg[bx];ah存储当前蛇头方向的反向
		mov al,cl;al存储当前蛇头方向

		;从输入队列获取并处理所有输入放在cl中，输入队列中的数据由按键中断历程添加
		reget_key:
		call get_input;cl为当前按键信息
		;判断是不是特殊按键
		cmp cl,key_sp;加速
		jb no_special_key;小于key_sp，正常按键，否则判断是否是特殊按键
		cmp cl,key_qu
		ja reget_key;大于key_qu，非法按键，重获取

		;以下是特殊按键选择处理
		jmp switch
			switch_addr dw offset is_speed,offset is_pause,offset is_quit
		switch:
		sub cl,key_sp
		mov bh,0h
		mov bl,cl
		shl bx,1;bx*2（因为是dw数据2byte）
		jmp word ptr switch_addr[bx];直接根据查表结果

		is_speed:
			mov ch,is_fast_speed
			test ch,ch
			jnz mul_speed
				mov is_fast_speed,1h
				;把循环间隔除以二
				;带进位循环位移
				clc;清除cf
				rcr word ptr snake_move_speed[0],1;cf移入高位（此处为0），低位移入cf
				rcr word ptr snake_move_speed[2],1;cf移入高位（此处为上面的退位），低位移入cf
				rcr byte ptr speed_bit_save,1;cf存入最高位
				jmp no_change_dir
			mul_speed:
				mov is_fast_speed,0h
				;把循环间隔乘以二
				;带进位循环位移
				clc;清除cf
				rcl byte ptr speed_bit_save,1;最高位存入cf
				rcl word ptr snake_move_speed[2],1;cf移入低位（此处为0），高位移入cf
				rcl word ptr snake_move_speed[0],1;cf移入低位，高位移入cf
				jmp no_change_dir
		is_pause:;暂停，直接死循环读取直到恢复或退出
			pause_test:
				call get_input;cl为当前按键信息
				cmp cl,key_qu
				je is_quit;不能直接跳到return，太远了，利用is_quit进行二次跳转
				cmp cl,key_pa
			jne pause_test
			jmp game_loop;暂停结束，直接跳过本轮循环
		is_quit:;退出，直接跳转到末尾返回
			jmp return;返回
		no_special_key:


		test cl,cl;如果cl是0则没有按键，不改变方向
		jz no_change_dir
			;根据输入改变方向
			cmp ah,cl;如果当前按键方向和蛇头反方向相等则掠过不改变（不能180度扭头）
			je no_change_dir
			cmp al,cl;如果当前按键方向和蛇头方向一致也无需改变
			je no_change_dir
				mov bx,word ptr snake_head_pos.x
				mov dx,word ptr snake_head_pos.y
				call set_map_pos;当前cl就是新的方向
				mov al,cl;设置al为cl存储的新的方向
		no_change_dir:
		;否则不设置al，那么下面就会引用原先的蛇头方向

		;移动、吃和生成食物、判断输赢并仅记录（输赢处理需要等后续绘制完毕）
		;绘制蛇（注意优化：如有必要则擦除蛇尾，绘制新蛇尾，擦除原先蛇头位置绘制为蛇身，
		;绘制新蛇头（此处如果吃到事物会直接覆盖绘制，无需擦除食物），如有必要则绘制新食物）

		;更新蛇头
		mov bx,word ptr snake_head_pos.x
		mov dx,word ptr snake_head_pos.y
		mov cl,al;把蛇头方向放入cl进行下方调用移动
		call snake_move;根据蛇头方向移动一格
		call surround;进行环绕

		;存储新蛇头位置
		mov new_snake_head_pos.x,bx
		mov new_snake_head_pos.y,dx

		;输判断：新蛇头位置不等于蛇尾的情况下，地图上有数据，则说明碰撞蛇身，即允许碰撞蛇尾（因为蛇头前进的同时蛇尾也在移动
		mov is_eat_food,0;判断前先设置false
		call get_map_pos;获取新蛇头位置下的方向信息
		cmp cl,dir_nu;如果是空，则允许移动
		je allow_move
		cmp cl,dir_fd;如果是食物，则吃掉
		je eat_food
		;如果不是，判断坐标是不是等于蛇尾
		cmp bx,snake_tail_pos.x
		jne lose;如果还不等于，则说明吃掉蛇身，输
		cmp dx,snake_tail_pos.y
		jne lose;如果还不等于，则说明吃掉蛇身，输
		jmp allow_move;如果都等于，则允许移动
		lose:;输了
		jmp long_jmp_lose;二次远跳转
		eat_food:
		mov is_eat_food,1;吃到设置1
		allow_move:
		mov al,is_eat_food
		test al,al
		jnz no_clear_tail
			;没吃到食物则更新蛇尾
			mov bx,word ptr snake_tail_pos.x
			mov dx,word ptr snake_tail_pos.y
			call get_map_pos;获取蛇尾方向，存入cl给下一个调用
			call snake_move;根据蛇尾方向移动一格
			call surround;进行环绕

			;存储新蛇尾位置
			mov new_snake_tail_pos.x,bx
			mov new_snake_tail_pos.y,dx

			;清空原蛇尾位置
			mov bx,snake_tail_pos.x
			mov dx,snake_tail_pos.y
			mov cl,dir_nu
			call set_map_pos
			;绘制空方块（背景）
			mov al,background
			call draw_block
		no_clear_tail:
		mov bx,word ptr snake_head_pos.x
		mov dx,word ptr snake_head_pos.y
		mov al,snake_body
		call draw_block;绘制原蛇头为蛇身
		call get_map_pos;获取原位置蛇头方向信息，存入cl给下一个调用
		mov bx,word ptr new_snake_head_pos.x
		mov dx,word ptr new_snake_head_pos.y
		mov al,snake_head
		call draw_block;绘制新蛇头
		call set_map_pos;设置新位置蛇头方向信息
		;设置新蛇头坐标
		mov word ptr snake_head_pos.x,bx
		mov word ptr snake_head_pos.y,dx
		
		;判断是否吃掉食物
		mov al,is_eat_food
		test al,al
		jnz spawn_new_food
			;没吃到食物则设置新蛇尾位置
			mov bx,word ptr new_snake_tail_pos.x
			mov dx,word ptr new_snake_tail_pos.y
			mov al,snake_tail
			call draw_block;绘制原蛇身为蛇尾
			;设置新蛇尾坐标
			mov word ptr snake_tail_pos.x,bx
			mov word ptr snake_tail_pos.y,dx
			jmp leave_test
		spawn_new_food:
			;否则如果吃到了
			inc word ptr snake_length;递增蛇长度
			cmp word ptr snake_length,map_size;判断当前长度，如果赢了，则跳转到赢的位置
			jnae no_win
				jmp long_jmp_win
			no_win:
			;没赢则生成新食物
			call spawn_snake_food
		leave_test:
jmp game_loop

	;判断刚才的输赢情况（ps：输为碰撞蛇身，赢为蛇长度大等于地图大小）
	;输或赢则显示输赢情况和分数（最终长度）
	long_jmp_lose:
		;输了，输出信息（偷懒不做），然后等待重开或退出
		jmp wait_quit_or_restart
	long_jmp_win:
		;赢了，输出信息（偷懒不做），然后等待重开或退出
		jmp wait_quit_or_restart

	jmp wait_quit_or_restart;跳过数据
	switch_quit_or_restart dw offset restart,offset return
	;循环结束
	wait_quit_or_restart:
	call get_input;cl为当前按键信息
	;判断是不是退出或暂停（重开）按键
	cmp cl,key_pa;加速
	jb wait_quit_or_restart;小于key_pa，丢弃
	cmp cl,key_qu
	ja wait_quit_or_restart;大于key_qu，非法按键，重获取

	;以下是特殊按键选择处理
	sub cl,key_pa
	mov bh,0h
	mov bl,cl
	shl bx,1;bx*2（因为是dw数据2byte）
	jmp word ptr switch_quit_or_restart[bx];直接根据查表结果

;---------------------结束返回---------------------;
	return:
	mov ax, 4c00h
	int 21h
	ret
main endp

;---------------------函数定义---------------------;
init_vesa_page proc	;计算vesa_page_size
	push ax
	push bx
	push dx

	mov ax,screen_x
	mov dx,screen_y
	mul dx;dx:ax=ax*dx

	;因为一个段大小是65536，即1'0000'0000b大小，刚好不用做除法
	;dx高位相当于dx:ax除以65536的商，ax低位相当于dx:ax求模65536的值
	mov vesa_page_count,dx;dx高位字节相当于段数量
	mov vesa_complete,ax;ax低位相当于不满一个段的大小

	pop dx
	pop bx
	pop ax
	ret
init_vesa_page endp

;清空屏幕
clear_screen proc
	push ax
	push bx
	push cx
	push dx
	push es
	push di

	;设置一次段地址
	mov ax,0a000h;视频像素地址
	mov es,ax

	cld;清除DF标志位，rep正向移动
	mov cx,0
	cls_loop:
	cmp cx,vesa_page_count
	jae leave_cls_loop;cx<vesa_page_count循环

		;设置当前页面
		mov ax,4f05h
		mov bx,0h
		mov dx,cx
		int 10h

		;每次打印一页，然后换页
		push cx
		mov al,background
		mov cx,0ffffh
		mov di,0h
		rep stosb;串传送指令
		stosb;因为cx大小限制，stosb只会运行65535次，还差一次，手动补一次
		pop cx

	inc cx
	jmp cls_loop
	leave_cls_loop:

	mov ax,vesa_complete
	test ax,ax
	jz clear_screen_ret;如果补全大小为0则直接离开

		;设置当前页面
		mov ax,4f05h
		mov bx,0h
		mov dx,cx
		int 10h

		mov al,background
		mov cx,vesa_complete
		mov di,0h
		rep stosb;串传送指令
		;stosb;

	clear_screen_ret:
	pop di
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
clear_screen endp

;清空地图
clear_map proc;无参数
	push ax
	push cx
	push es
	push di

	mov ax,data;地图填充dir_nu（0）
	mov es,ax
	lea ax,map
	mov di,ax

	mov al,dir_nu
	mov cx,map_size
	cld;清除DF标志位，rep正向移动
	rep stosb;串传送指令

	pop di
	pop es
	pop cx
	pop ax
	ret
clear_map endp

;刷出食物并绘制
spawn_snake_food proc;无参数
	push ax
	push bx
	push cx
	push dx

	;计算剩余空间
	mov ax,map_size
	sub ax,snake_length;sub根据目标操作数修改ZF标志位，可以直接判断
	jz spawn_snake_food_ret;如果剩余空间为0则没有办法生成食物，直接返回

	mov dx,ax;保存ax

	;在0到ax之间生成均匀随机数
	;使用xorshift算法，这三个常量的选择需要注意，不是所有的都可以，16bit下选择798
	;x ^= x << 7;
	;x ^= x >> 9;
	;x ^= x << 8;

	mov bx,random_seed

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

	mov random_seed,bx

	;进行求模
	;dx=dx:ax%bx
	mov ax,bx
	mov bx,dx;原ax
	mov dx,0
	div bx
	mov ax,dx


	;扫描地图，找到第ax个空位并记录，相当于均匀的在这些空位上生成一个食物

	mov dx,0
	_l0:
	cmp dx,map_y
	jae _b0
	
		mov bx,0
		_l1:
		cmp bx,map_x
		jae _b1
			;获取地图数据
			call get_map_pos
			test cl,cl
			jnz no_spawn;不为0代表有东西，不能生成在这里
				;为0则可生成，递减ax
				test ax,ax;判断ax是否为0
				jnz no_direct
					;ax为0说明当前是第ax个空位
					;食物生成在当前这里，bx和dx所指的位置
					mov al,snake_food;绘制新食物
					call draw_block
					mov cl,dir_fd
					call set_map_pos;设置地图
					jmp spawn_snake_food_ret;结束生成
				no_direct:
				dec ax;不是目标位置，递减ax
			no_spawn:
		inc bx
		jmp _l1
		_b1:
	
	inc dx
	jmp _l0
	_b0:

	spawn_snake_food_ret:
	pop dx
	pop cx
	pop bx
	pop ax
	ret
spawn_snake_food endp

;使用int16和中断获取键盘输入
get_input proc;无参数，cl=return
		push ax
		push bx
		mov cl,0
		mov bh,0h
		get_input_loop:
			mov ah,01h;功能号
			int 16h;检查是否有字符可用(ZF=0)
			jz no_input;(ZF=1)没有输入，直接跳过
			;否则有输入，循环读取直到没有输入或有合法输入
			mov ah,00h
			int 16h;ah->扫描码，al->ASCII
		
			mov bl,ah
			mov al,key_map[bx];扫描码查表，表内数据为方向，0为无效，否则有效
		
			test al,al;测试表数据，如果为0则无效按键，循环，否则执行
		jz get_input_loop
		mov cl,al;有输入则保存到cl退出循环
		no_input:;如果跳转至此则cl为0返回
		pop bx
		pop ax
		ret
get_input endp

;蛇移动
snake_move proc	;cl=dir,bx=x,dx=y
	push ax

	;对索引做倍增
	mov ah,0h
	mov al,cl
	shl ax,1;两次左移，相当于乘以4
	shl ax,1;ax=ax*(4)（用于4byte表项访问索引）
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
surround proc;bx=x,dx=y
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
set_map_pos proc;cl=dir,bx=x,dx=y
	push ax
	push bx
	push dx
	;pos(bx)=y(dx)*map_x(ax)+x(bx)
	mov ax,map_x
	mul dx;dx:ax=ax*dx
	add bx,ax

	;map[pos(bx)]=dir(cl)
	mov map[bx],cl
	pop dx
	pop bx
	pop ax
	ret
set_map_pos endp

;获取地图坐标点上的方向
get_map_pos proc;cl=return bx=x,dx=y
	push ax
	push bx
	push dx
	;pos(bx)=y(dx)*map_x(ax)+x(bx)
	mov ax,map_x
	mul dx;dx:ax=ax*dx
	add bx,ax

	mov cl,map[bx]
	pop dx
	pop bx
	pop ax
	ret
get_map_pos endp

	
;地图坐标转换到屏幕坐标，修改bx和dx为原来的十倍
pos_to_screen proc;(bx=x dx=y)
	push ax
	push cx

	mov ax,block_side
	mul dx;dx:ax=block_side(ax)*y(dx)
	mov cx,ax;忽略高位dx，只保存ax，暂存到cx

	mov ax,block_side
	mul bx;dx:ax=block_side(ax)*x(bx)
	mov bx,ax;忽略高位dx，只保存ax，到bx

	mov dx,cx;把刚才cx暂存的值y赋值给dx

	pop cx
	pop ax
	ret
pos_to_screen endp



;绘制方块
draw_block proc;al=颜色 bx=x dx=y
	push ax
	push bx
	push cx
	push dx
	push es
	push di

	call pos_to_screen;调用转换

	;绘制block_side大小的矩形
	;从Y(dx)*screen_x位置开始，绘制一行，然后起始位置递增screen_x，绘制下一行

	mov cx,0a000h
	mov es,cx;视频像素地址作为段地址

	push ax;保存颜色信息

	;计算当前页面号
	mov ax,screen_x
	mul dx;dx:ax=Y(dx)*screen_x(ax)+x(bx)
	add ax,bx;加上x偏移量
	adc dx,0h;带进位加到dx（高位）

	;dx是页面号，ax是偏移量
	mov cx,ax;偏移量放入cx

	;设置当前页面号为dx
	mov ax,4f05h;功能号放ax
	mov bx,0h;bx为0设置页面
	int 10h

	pop ax;恢复颜色信息

	mov bx,cx;偏移量放入bx
	cld;清除DF标志位，rep正向移动
	mov cx,block_side;循环block_side次（绘制block_side行）
	draw_y_loop:
		mov di,bx;设置到bx代表的起始地址
		
		push cx;保存cx
		;这里al就是颜色，无需改变
		mov cx,block_side;填充block_side大小的一行
		rep stosb;代替int10h的绘图功能
		pop cx;恢复cx

		add bx,screen_x;bx递增screen_x大小，相当于到下一行
		jnc no_change_page;没溢出不管
			;bx溢出，切换到下一个页面
			push ax
			push bx
			;切换到到下一个页面（dx+1）
			mov ax,4f05h;功能号放ax
			mov bx,0h;bx为0设置页面
			inc dx;页面号递增，已经知道溢出了，就没必要再用adc，直接inc即可
			int 10h
			pop bx
			pop ax
		no_change_page:
	loop draw_y_loop

	pop di
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	ret
draw_block endp

code ends

end main