.186;ʹ��80186��pusha��popa
assume cs:code,ds:data,ss:stack,es:extra

;��������
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

;��չ��
extra segment
	map db map_size dup(dir_nu);��ͼ�����ʷ�ʽ��y*map_x+x
	key_map db 255 dup(key_nu);����ӳ�䣬���ʷ�ʽ��ɨ������
	last_input_pos db 0;���һ�ΰ�����¼
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


	;mov al,13h;320*200 256ɫ��ͼ��ģʽ:
	;mov ah,0;�������趨��ʾģʽ�ķ������
	;int 10h;�����ж�

	;mov cx,10;x����
	;mov dx,10;y����
	;mov al,1100b;����ɫ
	;mov ah,0ch;���Ƶ�
	;int 10h;�����ж�

	;����
	;mov ah,06h
	;mov al,0
	;mov ch,0  ;(0,0)
	;mov cl,0
	;mov dh,24  ;(24,79)
	;mov dl,79
	;;mov bh,07h ;�ڵװ���
	;int 10h

	
	;������ʾģʽΪ����ģʽ�������ַ�ģʽ�޷���ͼ
	;mov ax,00h
	;mov al,12h;640��480 16ɫ
	;mov al,13h;640��480 256ɫ

	mov ax,4f02h;����vga�Կ�
	mov bx,0103h;800��600 256ɫ
	;int 10h;����ͼ���ж�

	


	;mov ah,0fh;��ȡҳ�룬�洢��bh��
	;int 10h;����ͼ���ж�

	;mov bh,0;�ֶ�����ҳ��
	;mov al,10111111b;��ɫ
	;mov ah,0ch;���Ƶ�
	;int 10h

	;int 10 AH=0CH	AL=��ɫ��BH=ҳ�� CX=x��DX=y





	;������
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
	;	int 10h;����ͼ���ж�
	;
	;	inc cx
	;	jmp l1
	;	b1:
	;
	;	inc dx
	;	jmp l0
	;b0:

	;���Դ���
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

	;���ð���ӳ��
	mov byte ptr key_map[48h],key_up
	mov byte ptr key_map[50h],key_dn
	mov byte ptr key_map[4bh],key_lf
	mov byte ptr key_map[4dh],key_rg

	;���ü��̻ص�
	call install_int9h_routine

	;����ͷβ����
	;0,1
	mov word ptr snake_head_pos.x,0
	mov word ptr snake_head_pos.y,1

	;0,0
	mov word ptr snake_tail_pos.x,0
	mov word ptr snake_tail_pos.y,0

	;���õ�ͼ
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

	;��ʼ����2
	mov snake_length,2

	;��ʼ����ϣ���ʼ��Ϸѭ��
	;�Ƚ���һ�γ�ʼ����

	game_loop:
		;��Ϸ��ʱ���жϣ�ֱ��ʱ�䵽��Ž�����������̣���������ѭ���ȴ�
		;mov ah, 2ch;21h�ж϶�ʱ�书�ܣ�CH:CL=ʱ:�� DH:DL=��:1/100��
		;int 21h
		;͵����һ�ְ취��ֱ�����ж��ӳ٣�������sleep
		mov ah,86h
		mov cx,0h; CX��DX= ��ʱʱ�䣨��λ��΢�룩
		mov dx,3e80h;16000us=16ms(60fps/s)
		int 15h;�ȴ�16ms


		;��������л�ȡ�������������룬��������е������ɰ����ж�������ӣ�
		;��Ϊ̰����û�б�Ҫ����һ��Ϸ���ڶ���Ĳ��������Խ���¼���һ���������򣬼����г���Ϊ1
		;��������
		;jmp dat;�������ݣ�����ᱻ���ɴ���ִ��
		;table db snake_head,snake_body,snake_tail,snake_food
		;dat:
		;mov bh,0h
		;mov bl,last_input_pos
		;mov al,table[bx]
		;mov cx,8
		;mov dx,6
		;call draw_block

		;��������ı䷽��ע����Ҫ�Ӽ����ж����̹�������last_input_pos��ȡ
		;�ж�һ�µ�ǰ���򣬱��ⷴ�����ƶ�

		;��ȡ��ǰͷ�ķ���
		mov bx,word ptr snake_head_pos.x
		mov dx,word ptr snake_head_pos.y
		call get_map_pos

		;ȡ������
		mov bh,0h
		mov bl,al
		mov ah,dir_neg[bx];ah�洢��ͷ����ķ���

		;����last_input_pos��ֹ�ж��޸ĵ���ǰ��ͳһ
		mov cl,last_input_pos;cl�洢��ǰ��������

		cmp ah,cl;�����ǰ�����������ͷ������������ӹ����ı䣨����180��Ťͷ��
		je no_change_dir
		cmp ah,al;�����ǰ�����������ͷ����һ��Ҳ����ı�
		je no_change_dir
			mov bx,word ptr snake_head_pos.x
			mov dx,word ptr snake_head_pos.y
			call set_map_pos
		no_change_dir:



		;�ƶ����Ժ�����ʳ��ж���Ӯ������¼����Ӯ������Ҫ�Ⱥ���������ϣ���ͬʱ��¼�ƶ�����Ա�����Ż�







		;�����ߣ�ע���Ż������б�Ҫ�������β����������β������ԭ����ͷλ�û���Ϊ����
		;��������ͷ���˴�����Ե������ֱ�Ӹ��ǻ��ƣ��������ʳ������б�Ҫ�������ʳ�


		;�жϸղŵ���Ӯ�����ps����Ϊ��ײ����ӮΪ�߳��ȴ���ڵ�ͼ��С��


	jmp game_loop

;---------------------��������---------------------;
	return:
	mov ax, 4c00h
	int 21h
	ret
main endp

;---------------------��������---------------------;

	;���ƶ�
	;cl=dir,bx=x,dx=y
snake_move proc
	push ax

	;������������
	mov al,cl
	mov ch,4
	mul ch;ax=al*ch(4)������4byte�������������
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
	;bx=x,dx=y
surround proc
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

	;��ȡ��ͼ������ϵķ���
	;al=return bx=x,dx=y
get_map_pos proc

	;pos(bx)=y(dx)*map_x(ax)+x(bx)
	mov ax,map_x
	mul dx;dx:ax=ax*dx
	add bx,ax

	mov al,map[bx]

	ret
get_map_pos endp

	
	;��ͼ����ת������Ļ����(cx=x dx=y)
	;�޸�cx��dxΪԭ����ʮ��
pos_to_screen proc;ʹ��ax��bx��cx��dx
	push ax
	push bx

	mov ax,block_side
	mul dx;dx:ax=block_side(ax)*y(dx)
	mov bx,ax;���Ը�λdx��ֻ����ax���ݴ浽bx

	mov ax,block_side
	mul cx;dx:ax=block_side(ax)*x(cx)
	mov cx,ax;���Ը�λdx��ֻ����ax

	mov dx,bx;�Ѹղ�bx�ݴ��ֵ��ֵ��dx

	pop bx
	pop ax
	ret
pos_to_screen endp


	;AL=��ɫ CX=x DX=y
	;����һ��Ҫ�����ں���֮ǰ������ᱻ���ɴ���ִ�е�
	bsx dw 0
	bsy dw 0
draw_block proc
	pusha;����ͨ�üĴ���

	call pos_to_screen;����ת��

	mov bh,0
	mov ah,0ch;���Ƶ�
	;����block_side��С�ľ���

	mov bsx,cx
	mov bsy,dx

	add bsx,block_side
	add bsy,block_side
	
	;˫��forѭ��
	drb0:
	cmp dx,bsy
	jnb drb0_;�޷��Ų�С��ʱת��
		
		drb1:
		cmp cx,bsx
		jnb drb1_;�޷��Ų�С��ʱת��

		int 10h

		inc cx
		jmp drb1
		drb1_:
		sub cx,block_side;�ָ�cx�������С
	
	inc dx
	jmp drb0
	drb0_:

	popa;����ͨ�üĴ���
	ret
draw_block endp

install_int9h_routine proc
	pusha
	push es
	push ds

	;�����µ�int9h���̴��뵽��ȫ��
	;����es:di
	mov bx,0
	mov es,bx
	mov di,7E00H
	
	;����ds:si
	mov bx,cs
	mov ds,bx
	mov si,offset new_int9h
	
	mov cx,offset new_int9h_end-offset new_int9h;���ô��ʹ�С
	cld;���ô��ͷ���
	rep movsb;���� ds:si->es:di

	;����ԭ�ж����̵�ַ
	;�˴�es��Ϊ0�������ظ�����
	cli;���ж�

	mov ax,es:[9*4+0]	;�ݴ�ip
	mov word ptr es:[9*4+0],7e00h;�������жϵ�ַip
	mov es:[200h+0],ax	;����ip

	mov ax,es:[9*4+2]	;�ݴ�cs
	mov word ptr es:[9*4+2],0h;�������жϵ�ַcs
	mov es:[200h+2],ax	;����cs
	
	sti;���ж�

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

	mov ax,es:[200h+0];��ȡԭ�����жϵ�ַ
	mov es:[9*4+0],ax;�Ż��жϱ�

	mov ax,es:[200h+2]
	mov es:[9*4+2],ax

	sti

	pop es
	popa
	ret
uninstall_int9h_routine endp
;---------------------�ж�����---------------------;

new_int9h proc
	push ax
	in al,60H                       ;�Ӷ˿ڶ�ȡ����
	pushf							;�����־λ��call��int����������int��һ��pushf��ԭ�жϷ���ʱ��popf������pushf��պ���ƽջ��αװ��int�жϵ��ã�
	call dword ptr cs:[200H]		;����ԭ�ж�
	
		;ִ�лص�����
		push bx
		push es
		
		mov bx,extra
		mov es,bx
		
		mov ah,0h
		mov bx,ax
		mov ah,es:key_map[bx];ɨ��������������Ϊ����0Ϊ��Ч��1~4�ֱ�Ϊ4������
		
		test ah,ah;���Ա����ݣ����Ϊ0����Ч���������ԣ����򱣴�
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
		;mov bx,1									;����λ������ɫ������Ϣ
		;mov cx,2000							;������Ļ2000���ַ�
		;changeColor:
		;inc byte ptr es:[bx]
		;add bx,2
		;loop changeColor
		;pop cx
		;pop es
		;pop bx
		;int9h_ret:

	pop ax
	iret;�жϷ���
new_int9h_end:nop;���
new_int9h endp

code ends

end main

;8086  CPU �мĴ����ܹ�Ϊ 14 �����Ҿ�Ϊ 16 λ ��
;�� AX��BX��CX��DX��SP��BP��SI��DI��IP��FLAG��CS��DS��SS��ES �� 14 ����
;���� 14 ���Ĵ�������һ����ʽ�ַ�Ϊ��ͨ�üĴ��������ƼĴ����ͶμĴ�����
;
;ͨ�üĴ�����
;AX��BX��CX��DX ����Ϊ���ݼĴ�����
;AX (Accumulator)���ۼӼĴ�����Ҳ��֮Ϊ�ۼ�����
;BX (Base)������ַ�Ĵ�����
;CX (Count)���������Ĵ�����
;DX (Data)�����ݼĴ�����
;SP �� BP �ֳ���Ϊָ��Ĵ�����
;SP (Stack Pointer)����ջָ��Ĵ�����
;BP (Base Pointer)����ָ��Ĵ�����
;SI �� DI �ֳ���Ϊ��ַ�Ĵ�����
;SI (Source Index)��Դ��ַ�Ĵ�����
;DI (Destination Index)��Ŀ�ı�ַ�Ĵ�����
;
;���ƼĴ�����
;IP (Instruction Pointer)��ָ��ָ��Ĵ�����
;FLAG����־�Ĵ�����
;
;�μĴ�����
;CS (Code Segment)������μĴ�����
;DS (Data Segment)�����ݶμĴ�����
;SS (Stack Segment)����ջ�μĴ�����
;ES (Extra Segment)�����ӶμĴ�����


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