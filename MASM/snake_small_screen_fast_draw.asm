;-----------------------chenjunfu2-----------------------;
;-----------------------2024/08/14-----------------------;
;Link:https://github.com/chenjunfu2/Gluttonous_snake-asm/;
;--------------------Gluttonous_snake--------------------;

assume cs:code,ds:data,ss:stack,es:extra

;debugģʽ
debug equ 0
;��������
block_side equ 10;ÿ���߷���Ĵ�С
map_x equ 32;��ͼ��Сx
map_y equ 20;��ͼ��Сy
map_size equ map_x*map_y
screen_x equ 320;��Ļ��Сx
screen_y equ 200;��Ļ��Сy
screen_size equ screen_x*screen_y
snake_head equ 00001110b;��ͷ��ɫ
snake_body equ 00001111b;������ɫ
snake_tail equ 00000111b;��β��ɫ
snake_food equ 00000010b;ʳ����ɫ
background equ 00000000b;������ɫ
x equ 0;���ڷ�������x
y equ 2;���ڷ�������y
dir_nu equ 0	 ;�����
dir_up equ 1	 ;������
dir_dn equ 2	 ;������
dir_lf equ 3	 ;������
dir_rg equ 4	 ;������
dir_fd equ 5	 ;ʳ��
key_nu equ dir_nu;������
key_up equ dir_up;������
key_dn equ dir_dn;������
key_lf equ dir_lf;������
key_rg equ dir_rg;������
key_sp equ 5;���ٰ���
key_pa equ 6;��ͣ����
key_qu equ 7;�˳�����


stack segment
	db 1024 dup(0)
stack ends

data segment
	snake_move_speed dw 2 dup();���ƶ��ٶ�
	speed_bit_save db 1 dup();����λ�����ݱ��棨����ʱ�൱�ڰ�snake_move_speed����ĵȴ�ʱ����Զ������ƣ�Ϊ�˱������λ�Ա��˳�����ʱ�ָ���
	snake_head_pos dw 2 dup();��ͷ��ǰλ��
	snake_tail_pos dw 2 dup();��β��ǰλ��
	new_snake_head_pos dw 2 dup();�µ���ͷλ��
	new_snake_tail_pos dw 2 dup();�µ���βλ��
	is_eat_food db 1 dup();��ǰ�Ƿ�Ե���ʳ��
	is_fast_speed db 1 dup();��ǰ�Ƿ��Ǽ���ģʽ
	snake_length dw 1 dup();�߳��ȣ������ж����ʤ����
	random_seed dw 1 dup();���������
	dir_neg db dir_nu,dir_dn,dir_up,dir_rg,dir_lf;�ƶ�����ת��ֻ��
	dir_mov dw 0000h,0000h, 0000h,0ffffh, 0000h,0001h, 0ffffh,0000h, 0001h,0000h, 0000h,0000h;�ƶ������nu(0,0) up(0,-1) dn(0,1) lf(-1,0) rg(1,0) fd(0,0)ֻ��
	map db map_size dup();��ͼ���洢dir�������ݣ����ʷ�ʽ��y*map_x+x
data ends

;��չ��
extra segment
	key_map db 255 dup(key_nu);����ӳ������ʷ�ʽ��ɨ������
	time_event db 1 dup();ʱ���¼�������ȷ����Ϸѭ����game tick�Ƿ�ʼ����
extra ends


;�δ�С���Ϊ65535

code segment	
main proc
	;����ջ����ַ�ʹ�С
	mov ax,stack
	mov ss,ax
	mov sp,1024
	;�������ݶλ���ַ
	mov ax,data
	mov ds,ax
	;������չ�λ���ַ
	mov ax,extra
	mov es,ax

;---------------------����ʼ---------------------;

	mov al,debug
	test al,al
	jnz no_set_screen;debugģʽ��Ҫ�޸���Ļ
	mov ah,00h;����ͼ��ģʽ
	mov al,13h;320*200 256ɫ
	int 10h;����ͼ���ж�
	no_set_screen:

	;���ð���ӳ��
	mov byte ptr key_map[48h],key_up;48h �� -> up Arrow
	mov byte ptr key_map[50h],key_dn;50h �� -> down Arrow 
	mov byte ptr key_map[4bh],key_lf;4bh �� -> left Arrow 
	mov byte ptr key_map[4dh],key_rg;4dh �� -> right Arrow
	mov byte ptr key_map[39h],key_sp;39h ���� -> space
	mov byte ptr key_map[19h],key_pa;19h ��ͣ -> p
	mov byte ptr key_map[10h],key_qu;10h �˳� -> q

	;������������ӣ���ʳ������֮ǰ���ã�
	mov ah,2ch;21h�ж϶�ʱ�书�ܣ�CH:CL=ʱ:�� DH:DL=��:1/100��
	int 21h
	;��*100+1/100��
	mov al,100
	mul dh;ax=al*dh
	mov dh,0h
	add ax,dx
	mov random_seed,ax

	restart:
	;�����Ļ
	call clear_screen

	;��յ�ͼ
	call clear_map

	;����ͷβ����
	;0,1
	mov word ptr snake_head_pos.x,1
	mov word ptr snake_head_pos.y,0

	;0,0
	mov word ptr snake_tail_pos.x,0
	mov word ptr snake_tail_pos.y,0

	;���õ�ͼ
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

	;����ʳ��֮ǰ���ó�ʼ����2
	mov snake_length,2

	;����ʳ�������ɣ�
	call spawn_snake_food

	;����ѭ���ٶ�
	mov word ptr snake_move_speed[0],1h
	mov word ptr snake_move_speed[2],86a0h
	mov byte ptr speed_bit_save,0h
	mov byte ptr is_fast_speed,0h

	;��ʼ����ϣ���ʼ��Ϸѭ��

	mov time_event,10000000b;ʱ���¼���ʼΪ1
	game_loop:
		;��Ϸ��ʱ���жϣ�ֱ��ʱ�䵽��Ž�����������̣���������ѭ���ȴ�
		time_event_test:;ʱ���¼�����
		mov al,time_event
		test al,al
		jz time_event_test;���Ϊ0����ת��ȥ��������
		mov time_event,0h;�����Ϊ0�����㲢���У�Ȼ�������¼����ȴ��´β���
		;ʹ���¼�����
		;�õ����������أ�ѭ�����time_eventֱ�����λ7bit��Ϊ1
		;es:bx->time_event
		;cx:dx->ms
		mov ah,83h
		mov al,00h;���ã�01Ϊȡ������
		lea bx,time_event
		mov cx,word ptr snake_move_speed[0]
		mov dx,word ptr snake_move_speed[2]
		int 15h

		
		;�ж�һ�µ�ǰ���򣬱��ⷴ�����ƶ�
		;��ȡ��ǰͷ�ķ���
		mov bx,word ptr snake_head_pos.x
		mov dx,word ptr snake_head_pos.y
		call get_map_pos

		;ȡ������
		mov bh,0h
		mov bl,cl;cl��ͷ����
		mov ah,dir_neg[bx];ah�洢��ǰ��ͷ����ķ���
		mov al,cl;al�洢��ǰ��ͷ����

		;��������л�ȡ�����������������cl�У���������е������ɰ����ж��������
		reget_key:
		call get_input;clΪ��ǰ������Ϣ
		;�ж��ǲ������ⰴ��
		cmp cl,key_sp;����
		jb no_special_key;С��key_sp�����������������ж��Ƿ������ⰴ��
		cmp cl,key_qu
		ja reget_key;����key_qu���Ƿ��������ػ�ȡ

		;���������ⰴ��ѡ����
		jmp switch
			switch_addr dw offset is_speed,offset is_pause,offset is_quit
		switch:
		sub cl,key_sp
		mov bh,0h
		mov bl,cl
		shl bx,1;bx*2����Ϊ��dw����2byte��
		jmp word ptr switch_addr[bx];ֱ�Ӹ��ݲ����

		is_speed:
			mov ch,is_fast_speed
			test ch,ch
			jnz mul_speed
				mov is_fast_speed,1h
				;��ѭ��������Զ�
				;����λѭ��λ��
				clc;���cf
				rcr word ptr snake_move_speed[0],1;cf�����λ���˴�Ϊ0������λ����cf
				rcr word ptr snake_move_speed[2],1;cf�����λ���˴�Ϊ�������λ������λ����cf
				rcr byte ptr speed_bit_save,1;cf�������λ
				jmp no_change_dir
			mul_speed:
				mov is_fast_speed,0h
				;��ѭ��������Զ�
				;����λѭ��λ��
				clc;���cf
				rcl byte ptr speed_bit_save,1;���λ����cf
				rcl word ptr snake_move_speed[2],1;cf�����λ���˴�Ϊ0������λ����cf
				rcl word ptr snake_move_speed[0],1;cf�����λ����λ����cf
				jmp no_change_dir
		is_pause:;��ͣ��ֱ����ѭ����ȡֱ���ָ����˳�
			pause_test:
				call get_input;clΪ��ǰ������Ϣ
				cmp cl,key_qu
				je is_quit;����ֱ������return��̫Զ�ˣ�����is_quit���ж�����ת
				cmp cl,key_pa
			jne pause_test
			jmp game_loop;��ͣ������ֱ����������ѭ��
		is_quit:;�˳���ֱ����ת��ĩβ����
			jmp return;����
		no_special_key:


		test cl,cl;���cl��0��û�а��������ı䷽��
		jz no_change_dir
			;��������ı䷽��
			cmp ah,cl;�����ǰ�����������ͷ������������ӹ����ı䣨����180��Ťͷ��
			je no_change_dir
			cmp al,cl;�����ǰ�����������ͷ����һ��Ҳ����ı�
			je no_change_dir
				mov bx,word ptr snake_head_pos.x
				mov dx,word ptr snake_head_pos.y
				call set_map_pos;��ǰcl�����µķ���
				mov al,cl;����alΪcl�洢���µķ���
		no_change_dir:
		;��������al����ô����ͻ�����ԭ�ȵ���ͷ����

		;�ƶ����Ժ�����ʳ��ж���Ӯ������¼����Ӯ������Ҫ�Ⱥ���������ϣ�
		;�����ߣ�ע���Ż������б�Ҫ�������β����������β������ԭ����ͷλ�û���Ϊ����
		;��������ͷ���˴�����Ե������ֱ�Ӹ��ǻ��ƣ��������ʳ������б�Ҫ�������ʳ�

		;������ͷ
		mov bx,word ptr snake_head_pos.x
		mov dx,word ptr snake_head_pos.y
		mov cl,al;����ͷ�������cl�����·������ƶ�
		call snake_move;������ͷ�����ƶ�һ��
		call surround;���л���

		;�洢����ͷλ��
		mov new_snake_head_pos.x,bx
		mov new_snake_head_pos.y,dx

		;���жϣ�����ͷλ�ò�������β������£���ͼ�������ݣ���˵����ײ������������ײ��β����Ϊ��ͷǰ����ͬʱ��βҲ���ƶ�
		mov is_eat_food,0;�ж�ǰ������false
		call get_map_pos;��ȡ����ͷλ���µķ�����Ϣ
		cmp cl,dir_nu;����ǿգ��������ƶ�
		je allow_move
		cmp cl,dir_fd;�����ʳ���Ե�
		je eat_food
		;������ǣ��ж������ǲ��ǵ�����β
		cmp bx,snake_tail_pos.x
		jne lose;����������ڣ���˵���Ե�������
		cmp dx,snake_tail_pos.y
		jne lose;����������ڣ���˵���Ե�������
		jmp allow_move;��������ڣ��������ƶ�
		lose:;����
		jmp long_jmp_lose;����Զ��ת
		eat_food:
		mov is_eat_food,1;�Ե�����1
		allow_move:
		mov al,is_eat_food
		test al,al
		jnz no_clear_tail
			;û�Ե�ʳ���������β
			mov bx,word ptr snake_tail_pos.x
			mov dx,word ptr snake_tail_pos.y
			call get_map_pos;��ȡ��β���򣬴���cl����һ������
			call snake_move;������β�����ƶ�һ��
			call surround;���л���

			;�洢����βλ��
			mov new_snake_tail_pos.x,bx
			mov new_snake_tail_pos.y,dx

			;���ԭ��βλ��
			mov bx,snake_tail_pos.x
			mov dx,snake_tail_pos.y
			mov cl,dir_nu
			call set_map_pos
			;���ƿշ��飨������
			mov al,background
			call draw_block
		no_clear_tail:
		mov bx,word ptr snake_head_pos.x
		mov dx,word ptr snake_head_pos.y
		mov al,snake_body
		call draw_block;����ԭ��ͷΪ����
		call get_map_pos;��ȡԭλ����ͷ������Ϣ������cl����һ������
		mov bx,word ptr new_snake_head_pos.x
		mov dx,word ptr new_snake_head_pos.y
		mov al,snake_head
		call draw_block;��������ͷ
		call set_map_pos;������λ����ͷ������Ϣ
		;��������ͷ����
		mov word ptr snake_head_pos.x,bx
		mov word ptr snake_head_pos.y,dx
		
		;�ж��Ƿ�Ե�ʳ��
		mov al,is_eat_food
		test al,al
		jnz spawn_new_food
			;û�Ե�ʳ������������βλ��
			mov bx,word ptr new_snake_tail_pos.x
			mov dx,word ptr new_snake_tail_pos.y
			mov al,snake_tail
			call draw_block;����ԭ����Ϊ��β
			;��������β����
			mov word ptr snake_tail_pos.x,bx
			mov word ptr snake_tail_pos.y,dx
			jmp leave_test
		spawn_new_food:
			;��������Ե���
			inc word ptr snake_length;�����߳���
			cmp word ptr snake_length,map_size;�жϵ�ǰ���ȣ����Ӯ�ˣ�����ת��Ӯ��λ��
			jnae no_win
				jmp long_jmp_win
			no_win:
			;ûӮ��������ʳ��
			call spawn_snake_food
		leave_test:
jmp game_loop

	;�жϸղŵ���Ӯ�����ps����Ϊ��ײ����ӮΪ�߳��ȴ���ڵ�ͼ��С��
	;���Ӯ����ʾ��Ӯ����ͷ��������ճ��ȣ�
	long_jmp_lose:
		;���ˣ������Ϣ��͵����������Ȼ��ȴ��ؿ����˳�
		jmp wait_quit_or_restart
	long_jmp_win:
		;Ӯ�ˣ������Ϣ��͵����������Ȼ��ȴ��ؿ����˳�
		jmp wait_quit_or_restart

	jmp wait_quit_or_restart;��������
	switch_quit_or_restart dw offset restart,offset return
	;ѭ������
	wait_quit_or_restart:
	call get_input;clΪ��ǰ������Ϣ
	;�ж��ǲ����˳�����ͣ���ؿ�������
	cmp cl,key_pa;����
	jb wait_quit_or_restart;С��key_pa������
	cmp cl,key_qu
	ja wait_quit_or_restart;����key_qu���Ƿ��������ػ�ȡ

	;���������ⰴ��ѡ����
	sub cl,key_pa
	mov bh,0h
	mov bl,cl
	shl bx,1;bx*2����Ϊ��dw����2byte��
	jmp word ptr switch_quit_or_restart[bx];ֱ�Ӹ��ݲ����

;---------------------��������---------------------;
	return:
	mov ax, 4c00h
	int 21h
	ret
main endp

;---------------------��������---------------------;
;�����Ļ
clear_screen proc
	push ax
	push cx
	push es
	push di
	
	;��Ƶ���ص�ַ
	mov ax,0a000h
	mov es,ax
	mov ax,0h
	mov di,ax

	mov al,background;��ɫ
	mov cx,screen_x*screen_y;������Ļ��С
	cld;���DF��־λ��rep�����ƶ�
	rep stosb;������ָ��

	pop di
	pop es
	pop cx
	pop ax
	ret
clear_screen endp

;��յ�ͼ
clear_map proc;�޲���
	push ax
	push cx
	push es
	push di

	mov ax,data;��ͼ���dir_nu��0��
	mov es,ax
	lea ax,map
	mov di,ax

	mov al,dir_nu
	mov cx,map_size
	cld;���DF��־λ��rep�����ƶ�
	rep stosb;������ָ��

	pop di
	pop es
	pop cx
	pop ax
	ret
clear_map endp

;ˢ��ʳ�ﲢ����
spawn_snake_food proc;�޲���
	push ax
	push bx
	push cx
	push dx

	;����ʣ��ռ�
	mov ax,map_size
	sub ax,snake_length;sub����Ŀ��������޸�ZF��־λ������ֱ���ж�
	jz spawn_snake_food_ret;���ʣ��ռ�Ϊ0��û�а취����ʳ�ֱ�ӷ���

	mov dx,ax;����ax

	;��0��ax֮�����ɾ��������
	;ʹ��xorshift�㷨��������������ѡ����Ҫע�⣬�������еĶ����ԣ�16bit��ѡ��798
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

	;������ģ
	;dx=dx:ax%bx
	mov ax,bx
	mov bx,dx;ԭax
	mov dx,0
	div bx
	mov ax,dx


	;ɨ���ͼ���ҵ���ax����λ����¼���൱�ھ��ȵ�����Щ��λ������һ��ʳ��

	mov dx,0
	_l0:
	cmp dx,map_y
	jae _b0
	
		mov bx,0
		_l1:
		cmp bx,map_x
		jae _b1
			;��ȡ��ͼ����
			call get_map_pos
			test cl,cl
			jnz no_spawn;��Ϊ0�����ж�������������������
				;Ϊ0������ɣ��ݼ�ax
				test ax,ax;�ж�ax�Ƿ�Ϊ0
				jnz no_direct
					;axΪ0˵����ǰ�ǵ�ax����λ
					;ʳ�������ڵ�ǰ���bx��dx��ָ��λ��
					mov al,snake_food;������ʳ��
					call draw_block
					mov cl,dir_fd
					call set_map_pos;���õ�ͼ
					jmp spawn_snake_food_ret;��������
				no_direct:
				dec ax;����Ŀ��λ�ã��ݼ�ax
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

;ʹ��int16���жϻ�ȡ��������
get_input proc;�޲�����cl=return
		push ax
		push bx
		mov cl,0
		mov bh,0h
		get_input_loop:
			mov ah,01h;���ܺ�
			int 16h;����Ƿ����ַ�����(ZF=0)
			jz no_input;(ZF=1)û�����룬ֱ������
			;���������룬ѭ����ȡֱ��û��������кϷ�����
			mov ah,00h
			int 16h;ah->ɨ���룬al->ASCII
		
			mov bl,ah
			mov al,key_map[bx];ɨ��������������Ϊ����0Ϊ��Ч��������Ч
		
			test al,al;���Ա����ݣ����Ϊ0����Ч������ѭ��������ִ��
		jz get_input_loop
		mov cl,al;�������򱣴浽cl�˳�ѭ��
		no_input:;�����ת������clΪ0����
		pop bx
		pop ax
		ret
get_input endp

;���ƶ�
snake_move proc	;cl=dir,bx=x,dx=y
	push ax

	;������������
	mov ah,0h
	mov al,cl
	shl ax,1;�������ƣ��൱�ڳ���4
	shl ax,1;ax=ax*(4)������4byte�������������
	xchg ax,bx;����ax��bx

	;���
	add ax,word ptr dir_mov[bx].x;���ݱ���ı�x��y
	add dx,word ptr dir_mov[bx].y;

	;���淵��
	mov bx,ax
	pop ax
	ret
snake_move endp

;Խ�绷��
surround proc;bx=x,dx=y
	cmp bx,map_x
	jnge x_add
		sub bx,map_x;��������map_x���ȥ
	x_add:
	cmp bx,0
	jge x_end
		add bx,map_x;���С��0�����
	x_end:

	cmp dx,map_y
	jnge y_add
		sub dx,map_y;��������map_y���ȥ
	y_add:
	cmp dx,0
	jge y_end
		add dx,map_y;���С��0�����
	y_end:

	ret
surround endp


;���õ�ͼ������ϵķ���
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

;��ȡ��ͼ������ϵķ���
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

	
;��ͼ����ת������Ļ���꣬�޸�cx��dxΪԭ����ʮ��
pos_to_screen proc;(bx=x dx=y)
	push ax
	push cx

	mov ax,block_side
	mul dx;dx:ax=block_side(ax)*y(dx)
	mov cx,ax;���Ը�λdx��ֻ����ax���ݴ浽cx

	mov ax,block_side
	mul bx;dx:ax=block_side(ax)*x(bx)
	mov bx,ax;���Ը�λdx��ֻ����ax����bx

	mov dx,cx;�Ѹղ�cx�ݴ��ֵy��ֵ��dx

	pop cx
	pop ax
	ret
pos_to_screen endp


;���Ʒ���
draw_block proc;al=��ɫ bx=x dx=y
	push ax
	push bx
	push cx
	push dx
	push es
	push di

	call pos_to_screen;����ת��

	;����block_side��С�ľ���
	;��Y(dx)*screen_xλ�ÿ�ʼ������һ�У�Ȼ����ʼλ�õ���screen_x��������һ��

	mov cl,al;������ɫ��Ϣ
	
	;start_addr(bx)=Y(dx)*screen_x(ax)+X(bx)
	mov ax,screen_x
	mul dx
	add ax,bx
	mov bx,ax;bx�洢��ʼ��ַ

	mov al,cl;�ָ���ɫ��Ϣ

	mov dx,0a000h
	mov es,dx;��Ƶ���ص�ַ��Ϊ�ε�ַ

	cld;���DF��־λ��rep�����ƶ�
	mov cx,block_side;ѭ��block_side�Σ�����block_side�У�
	draw_y_loop:
		mov di,bx;���õ�bx�������ʼ��ַ
		
		mov dx,cx;����cx
		;����al������ɫ������ı�
		mov cx,block_side;���block_side��С��һ��
		rep stosb;����int10h�Ļ�ͼ����
		mov cx,dx;�ָ�cx

		add bx,screen_x;bx����screen_x��С���൱�ڵ���һ��
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