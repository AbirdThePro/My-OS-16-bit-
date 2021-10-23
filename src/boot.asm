[BITS 16]
[ORG 0x7C00]

boot1:

mov word [0x7E00], 0 ; make sure error check zone is cleared

mov [disk], dl ; save drive number

; set up stack
cli
mov ax, 0x2000
mov ss, ax
mov sp, 0x1000
mov bp, sp
sti

; enable A20 line
mov ax, 0x2401
int 0x15

; set VGA text mode
mov ah, 0x00
mov al, 0x03
int 0x10

mov si, msg
call print

mov ah, 0x00
mov dl, [disk]
int 0x13

mov ah, 0x02
mov al, 0x02
mov bx, 0x0000
mov es, bx
mov bx, 0x7E00
mov ch, 0
mov cl, 2
mov dh, 0
mov dl, [disk]
int 0x13

mov word ax, [0x7E00]
cmp ax, 1100110011110000b
jne bootError

mov si, msg2
call print

cli
mov ah, 0x00
unlock:
	int 0x16
	cmp al, 0
	je unlock
sti

jmp [es:bx+2]

bootError:

mov si, msg3
call print

cli
hlt

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

msg: db "Booting...", 10, 13, 0
msg2: db "OS ready. Press any key to unlock. ", 0
msg3:
	db 10, 13, "There was an error while loading the kernel."
	db 10, 13, "Please reboot the machine.", 0

disk: db 0

times 510-($-$$) db 0
dw 0xAA55
