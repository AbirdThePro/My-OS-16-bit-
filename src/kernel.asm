[BITS 16]
[ORG 0x7E00]

dw 1100110011110000b ; this is used to verify that the boot succeeded

kernel:

mov al, [0x7DFD]
mov [disk], al

call shell_clear

shell:

call shell_clear_command

mov si, msg
mov di, command
mov bx, 64
call input

mov si, command
call print
call nl

jmp shell

cli
hlt

msg: db "My-OS-User1-$ ", 0

command:
	times 64 db 32
	db 0

shell_clear:
	call clear_screen
	jmp shell

shell_clear_command:
	mov di, command
.loop:
	mov al, 32
	stosb
	cmp byte [di], 0
	je .end
	jmp .loop
.end:
	ret

shell_echo:
	call print
	jmp shell

print:
	mov ah, 0x0E
.loop:
	lodsb
	cmp al, 0
	je .end
	int 0x10
	jmp .loop
.end:
	ret

input:
	call print
	xor cx, cx
.loop:
	cmp cx, bx
	je .end
	mov ah, 0x00
	int 0x16
	cmp al, 0
	je .loop
	cmp al, 13
	je .end
	cmp al, 8
	je .backspace
	mov ah, 0x0E
	int 0x10
	stosb
	inc cx
	jmp .back
.backspace:
		cmp cx, 0
		je .back
		call backspace
		dec cx
.back:
		jmp .loop
.end:
	mov al, 0
	stosb
	call nl
	ret

nl:
	mov ah, 0x0E
	mov al, 10
	int 0x10
	mov al, 13
	int 0x10
	ret

backspace:
	mov ah, 0x0E
	mov al, 8
	int 0x10
	mov al, 32
	int 0x10
	mov al, 8
	int 0x10
	ret

clear_screen:
	mov ah, 0x00
	mov al, 0x03
	int 0x10
	ret

compare_strings:
	add cx, 1
.loop:
	dec cx
	cmp cx, 0
	je .endTrue
	cmp ax, bx
	je .loop
	jmp .endFalse
.endTrue:
	mov ax, 0
	ret
.endFalse:
	mov ax, 1
	ret

disk_read:
	mov ah, 0x02
	mov al, 1
	mov bx, 0x0000
	mov es, bx
	mov bx, di
	mov ch, 0
	mov dh, 0
	mov dl, [0x7DFD]
	int 0x13

disk: db 0

times 2048-($-$$) db 0
