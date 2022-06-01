[org 0x7c00]

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

[bits 16]
;se inicia el proceso de paso a modo protegido
cli ;se deshabilitan las interrupciones

lgdt [gdt_descriptor]   ;se carga la GDT, cargando en el registro GDTR, el descriptor de la GDT

mov eax, cr0            ;se setea el bit 0 del CR0 en 1
or eax, 0x1
mov cr0, eax

jmp CODE_SEG : protected_mode  ;se salta a la seccion de codigo de 32 bits

;GDT
gdt_start:
    gdt_null:               ;descriptor nulo
    dd 0x0             
    dd 0x0
        
gdt_code:                   ;descriptor del segmento de codigo
                            ;base: 0x00000000
                            ;limite: 0x7ffff
    ;1st double word
    dw 0xFFFF               ;bits 0-15: parte baja del limite, en este caso, 0xffff
    dw 0x0                  ;bits 16-31: parte baja de la base, en este caso 0x0000
    ;2nd doble word
    db 0x0                  ;bits 0-7: bits 16-23 de la base, en este caso 0x00
    db 10011010b            ;flags: 10011010
                            ;bit 8: bit de presencia, lo setea la CPU al acceder,0
                            ;bit 9: como es de codigo, setea si es leible o no, 1
                            ;bit 10: bit conforming, 0 
                            ;bit 11: especifica si es de codigo (1) o data (0), 1 
                            ;bit 12: bit S, seteadompara segmentos normales (codigo, dato o pila), 1
                            ;bit 13-14: bits de nivel de privilegio, nivel 0, el mas alto, 00
                            ;bit 15: bit de presencia, seteado en 1.
    db 11000111b            ;flags + limit: 11001111
                            ;bits 16-19: parte alta del limite, en este caso, 0xf, 1111
                            ;bits 20: reservado para programador de sistemas, se ignora, 0
                            ;bits 21: reservado por intel, 0
                            ;bit 22: bit de size, indica que tendremos codigo de 32 bits, 1
                            ;bit 23: bit de granularidad, seteado los segmentos tienen limite de 4gb, 1
    db 0x0                  ;bit 24-31: parte alta de la base, en este caso 0x00

gdt_data:                   ;descriptor del segmento de data
                            ;base: 0x00080000
                            ;limite: 0x7ffff
    ;1st double word
    dw 0xFFFF               ;bits 0-15: parte baja del limite, en este caso, 0xffff
    dw 0x0                  ;bits 16-31: parte baja de la base, en este caso 0x0000
    ;2nd doble word
    db 0x08                 ;bits 0-7: bits 16-23 de la base, en este caso 0x08
    db 10010000b            ;flags: 10010010
                            ;bit 8: bit de presencia, lo setea la CPU al acceder, 0
                            ;bit 9: como es de data, setea si es escribible o no, 1
                            ;bit 10: bit conforming, 0
                            ;;bit 11: especifica si es de codigo (1) o data (0), 0
                            ;bit 12: bit S, seteado para segmentos normales (codigo, dato o pila), 1
                            ;bit 13-14: bits de nivel de privilegio, nivel 0, el mas alto, 00
                            ;bit 15: bit de presencia, seteado en 1.
    db 11000111b            ;flags + limit: 11001111
                            ;bits 16-19: parte alta del limite, en este caso, 0xf, 1111
                            ;bits 20: reservado para programador de sistemas, se ignora, 0
                            ;bits 21: reservado por intel, 0
                            ;bit 22: bit de size, indica que tendremos codigo de 32 bits, 1
                            ;bit 23: bit de granularidad, seteado los segmentos tienen limite de 4gb, 1
    db 0x0                  ;bit 24-31: parte alta de la base, en este caso 0x00
gdt_end:                   
                            
;GDT descriptor, especifica tamaño de la GDT y direccion de inicio
gdt_descriptor:
        dw gdt_end - gdt_start - 1 
        dd gdt_start               

[bits 32]
;inicializar los registros de segmento para actualizar cache
protected_mode:
    mov ax, DATA_SEG 
    mov ds, ax 
    mov ss, ax 
    mov es, ax
    mov fs, ax
    mov gs, ax
    ;inicilizar stack
    mov ebp, 0x7000       
    mov esp, ebp
 
    ;ya se esta en modo protegido
    ;probar escribir en una posicion del segmento de dato, desplazamiento 0x1
    mov ax, 0x4f
    mov bx, 0x1
    mov [bx], ax
 
times 510 -( $ - $$ ) db 0 ;rellenar con 0 hasta llegar a las firmas
dw 0xaa55   ;firmas