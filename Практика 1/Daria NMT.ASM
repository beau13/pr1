format binary as 'img'

org 0x7C00

jmp start

name db "Nazina", 0 ; Data for name
name1 db "Darya", 0 ; Data for name1
name2 db "Sergeevna", 0 ; Data for name2

group db "NMT-323901", 0 ; Data for group

; Setting up the stack segment
start:
    cli                 ; Disable interrupts
    mov ax, 0           ; Initialize stack segment
    mov ss, ax
    mov sp, 0xFFFF      ; Set stack pointer to the top
    sti                 ; Enable interrupts

    mov ax, 0x13        ; Switch to mode 320x200 256-color
    int 0x10
    mov ax, 0x0010      ; Set text graphics mode
    int 0x10

    ; Drawing an equilateral triangle
    mov cx, 80          ; X coordinate in the left half of the screen
    mov dx, 20          ; Y coordinate, placed high to encompass full height
    mov bx, 100         ; Height of the triangle
    call draw_triangle

    ; Set background color
    mov ah, 0x0B        ; Function for setting background color
    mov bl, 0x09        ; Blue background
    int 0x10

    ; Text output
    mov ah, 0x13        ; Function for text output
    mov al, 0           ; Color - black
    mov bh, 0           ; Screen page
    mov bl, 14          ; Text color: yellow
    mov dl, 69          ; Column (towards the end of the screen)
    mov dh, 21          ; Row
    push cs
    pop es
    mov bp, name
    mov cx, 6
    int 0x10
    mov ah, 0x13
    mov al, 0
    mov bh, 0
    mov bl, 14
    mov dl, 69
    mov dh, 22
    push cs
    pop es
    mov bp, name1
    mov cx, 5
    int 0x10
    mov ah, 0x13
    mov al, 0
    mov bh, 0
    mov bl, 14
    mov dl, 69
    mov dh, 23
    push cs
    pop es
    mov bp, name2
    mov cx, 9
    int 0x10
    mov ah, 0x13
    mov al, 0
    mov bh, 0
    mov bl, 14
    mov dl, 69
    mov dh, 24
    push cs
    pop es
    mov bp, group
    mov cx, 10
    int 0x10

hang:
    jmp hang
draw_triangle:
    pusha
    mov bp, cx            ; Save the original x coordinate for comparison

    ; Triangle drawing loop
triangle_loop:
    push cx
    mov ax, bx            ; ax for drawing lines of decreasing lengths sequentially
    shr ax, 1
    sub cx, ax            ; Subtraction to get the initial x coordinate
    add ax, bp            ; Addition to get the final x coordinate

    ; Drawing a horizontal line
draw_line:
    cmp cx, ax            ; Check if the initial x (cx) is less than the final x (ax)
    jae line_done         ; If the end is reached or passed, the line is done
    push ax
    push bx
    push dx

    mov ah, 0x0C          ; Function to draw a pixel
    mov al, 0x0F          ; Color - white
    int 0x10              ; BIOS interrupt

    pop dx
    pop bx
    pop ax
    inc cx                ; Move to the next pixel on the right
    jmp draw_line         ; Repeat the loop for the next pixel

line_done:
    pop cx
    add dx, 1             ; Move to the line above
    add cx, 1             ; Shift the initial x by one pixel to the right
    dec bx                ; Decrease the remaining height
    jnz triangle_loop     ; Continue if there is more to draw in the triangle

    popa                   ; Restore registers
    ret

; Fill the remaining part of the boot sector with zeros and the magic number
times 510-($-$$) db 0
dw 0xAA55
