DATAS SEGMENT
	;此处输入数据段代码  
DATAS ENDS

STACKS SEGMENT
	;此处输入堆栈段代码
STACKS ENDS

CODES SEGMENT
	ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
	MOV AX,DATAS
	MOV DS,AX
	call cpy_new_int9	;设置新的in9代码到安全区
	call save_old_int9	;保存旧的移动旧的int9向量到0:200位置
	call set_new_int9  	;设置新得int9到对应位置。

	star:
		nop;死循环防止退出
	jmp star


	MOV AH,4CH
	INT 21H

;============================================    
set_new_int9:
	mov bx,0
	mov es,bx
	cli
	;mov word ptr es:[9*4],offset new_int9
	;mov word ptr es:[9*4+2],cs
	mov word ptr es:[9*4],7E00H      	;低2个字节给ip
	mov word ptr es:[9*4+2],0           ;高2个字节给cs
	sti
	ret    
;============================================    
save_old_int9:
	mov bx,0
	mov es,bx
	cli
	push es:[9*4]         ;ip
	push es:[9*4+2]		;cs
	pop es:[202H]		;cs
	pop es:[200H]		;ip
	sti
	ret    
;============================================
new_int9:
	push ax
	in al,60H                       ;从端口读取数据
	;mov bx,es
	;mov es,es:[202H]
	pushf							;保存标志位
	call dword ptr cs:[200H]		;调用原中断
	;mov es,bx


	;读到得内容与指定按键比较
	;不相等则直接退出，相等执行改变屏幕颜色
	cmp al,48h						
	je change						
	cmp al,50h	
	je change	
	cmp al,4Bh	
	je change		
	cmp al,4Dh	
	je change
	jmp int9Ret	

	change:
	call change_screen_color
	
int9Ret:
	pop ax
	iret 	
;============================================        
change_screen_color:
	push bx
	push es
	push cx

	mov bx,0B800H
	mov es,bx
	mov bx,1									;奇数位保存颜色属性信息
	mov cx,2000							;整个屏幕2000个字符
changeColor:
	inc byte ptr es:[bx]
	add bx,2
	loop changeColor
	pop cx
	pop es
	pop bx
	ret
			
new_int9_end: nop    
;============================================
cpy_new_int9:
	mov bx,0
	mov es,bx
	mov di,7E00H
	
	mov bx,cs
	mov ds,bx
	mov si,OFFSET new_int9
	
	mov cx,OFFSET new_int9_end-OFFSET new_int9

	cld
	rep movsb
	ret
;============================================    
CODES ENDS
	END START
