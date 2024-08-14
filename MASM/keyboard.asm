DATAS SEGMENT
	;�˴��������ݶδ���  
DATAS ENDS

STACKS SEGMENT
	;�˴������ջ�δ���
STACKS ENDS

CODES SEGMENT
	ASSUME CS:CODES,DS:DATAS,SS:STACKS
START:
	MOV AX,DATAS
	MOV DS,AX
	call cpy_new_int9	;�����µ�in9���뵽��ȫ��
	call save_old_int9	;����ɵ��ƶ��ɵ�int9������0:200λ��
	call set_new_int9  	;�����µ�int9����Ӧλ�á�

	star:
		nop;��ѭ����ֹ�˳�
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
	mov word ptr es:[9*4],7E00H      	;��2���ֽڸ�ip
	mov word ptr es:[9*4+2],0           ;��2���ֽڸ�cs
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
	in al,60H                       ;�Ӷ˿ڶ�ȡ����
	;mov bx,es
	;mov es,es:[202H]
	pushf							;�����־λ
	call dword ptr cs:[200H]		;����ԭ�ж�
	;mov es,bx


	;������������ָ�������Ƚ�
	;�������ֱ���˳������ִ�иı���Ļ��ɫ
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
	mov bx,1									;����λ������ɫ������Ϣ
	mov cx,2000							;������Ļ2000���ַ�
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
