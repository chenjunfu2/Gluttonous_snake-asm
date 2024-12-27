;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    .386
    IDEAL
    MODEL TINY
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    DATASEG
file:   db 'image.pcx',0    ;filename to load
buff:       
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    CODESEG
    STARTUPCODE

    scrxs   equ 800
    scrys   equ 600
    mov ax,103h ; VESA 800x600x256
    call    vesamod
    mov al,0
    call    vesapag

;   scrxs   equ 320
;   scrys   equ 200
;   mov ax,19   ; VGA 320x200x256
;   int 10h

    lea dx,[file]   ; load PCX into DS:buff, CX bytes
    call    fopen
    lea dx,[buff]
    mov cx,64000    ; some max value to fit into DS segment
    call    fread       ; CX is PCX real size
    call    fclose

    lea si,[buff]   ; decode directly to VRAM
    mov ax,0A000h
    mov es,ax
    mov di,0
    call    pcx
mainl0:
    mov ax,256  ; test keyboard
    int 16h
    jz  mainl0
    sub ax,ax   ; clear key buffer
    int 16h

    mov ax,3    ;|VGA 80x25 text
    int 16
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vesamod:pusha               ;set VESA videomode ax
    mov     bx,ax
    mov     ax,4f02h
    int     16
    popa
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
vesapag:pusha               ;al=page  switch vesa video page window A
    mov [cs:scrpag],al
    mov     dl,al
    sub     dh,dh
    sub     bx,bx
    mov     ax,4f05h    ; window A
    int     16
    popa
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  .386P
scrpag  db 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  .386P
hand    dw 0        ;###    handler...
ferr    db 0        ;###    DOS error code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fopen:  pusha       ;DS:DX = file name, [hand] <= file handle
    mov ax,3D02h
    int 21h
    mov bl,0
    jnc fopen0
    mov bl,al
    sub ax,ax
fopen0: mov [cs:hand],ax
    mov [cs:ferr],bl
    popa
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fclose: pusha       ;[hand] = file handle
    mov bx,[cs:hand]
    mov ah,3eh
    int 21h
    mov bl,0
    jnc fclose0
    mov bl,al
    sub ax,ax
fclose0:mov [cs:ferr],bl
    mov [cs:hand],ax
    popa
    ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fread:  pusha       ;DS:DX = adr, CX = lenght, [hand] = hand, CX => read
    mov bx,[cs:hand]
    mov ah,3Fh
    int 21h
    mov bl,0
    jnc fread0
    mov bl,al
    sub ax,ax
fread0: mov [cs:ferr],bl
    mov [cs:freadsz],ax
    popa
    mov cx,[cs:freadsz]
    ret
freadsz dw 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
pcx:    pusha           ;decode pcx at ds:si to es:di cx = PCX size
    push    ds
    push    es
    push    ecx
    push    edx

    push    si      ;set palette
    add si,cx
    sub si,768
    sub ax,ax   
pall0:  mov dx,3C8h
    mov al,ah
    out dx,al
    inc dx
    lodsb
    shr al,2
    out dx,al
    lodsb
    shr al,2
    out dx,al
    lodsb
    shr al,2
    out dx,al
    inc ah
    jnz pall0
    pop si

    mov ax,[ds:si+8]    ;get xs
    sub ax,[ds:si+4]
    inc ax
    mov [cs:pcxxs],ax
    mov [cs:pcxx],ax

    mov ax,[ds:si+10]   ;get ys
    sub ax,[ds:si+6]
    inc ax
    mov [cs:pcxys],ax   

    mul [cs:pcxxs]
    push    dx
    push    ax
    pop edx
    add si,128      ;src start after pcx header
    sub ecx,ecx     ;RLE decoder of PCX
pcxl0:  lodsb
    mov cx,1
    cmp al,192
    jb  pcxr0
    mov cl,al
    and cl,63
    lodsb
pcxr0:  mov bx,cx
pcxl1:  call    point

    dec [cs:pcxx]   ;correct next screen line position if end of PCX line
    jnz pcxr1   
    mov ax,[cs:pcxxs]
    mov [cs:pcxx],ax
    neg ax
    add ax,scrxs
    add di,ax
    jnc pcxr1
    ; page swith
    mov al,[cs:scrpag]
    inc al
    call    vesapag

pcxr1:  loop    pcxl1
    mov cx,bx
    sub edx,ecx
    jz  pcxesc
    jnc pcxl0

pcxesc: pop edx
    pop ecx
    pop es
    pop ds
    popa
    ret
pcxxs   dw  0   ;PCX resolution
pcxys   dw  0
pcxx    dw  0   ;actual X coordinate 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
point:  mov [es:di],al      ;point      ;estosb 
    inc di
    jnz pntesc
    ; page swith
    mov al,[cs:scrpag]
    inc al
    call    vesapag
pntesc: ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;