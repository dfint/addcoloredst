include 'macro\proc32.inc'
include 'macro\struct.inc'
include 'macro\if.inc'

; format MS COFF
use32

orig_base_addr = 401000h
new_base_addr = 401000h

delta = new_base_addr-orig_base_addr

struct graphicst        ; (sizeof=0x380)
    screenx         dd ?
    screeny         dd ?
    screenf         db ?
    screenb         db ?
    screenbright    db ?
    padding_byte    db ?
    screen          dd ?                    ; offset
    screentexpos    dd ?                    ; offset
    screentexpos_addcolor dd ?              ; offset
    screentexpos_grayscale dd ?
    screentexpos_cf dd ?
    screentexpos_cbr dd ?
    clipx           dd 2 dup(?)
    clipy           dd 2 dup(?)
    tex_pos         dd ?
    rect_id         dd ?
    print_time      dq 100 dup(?)
    print_index     dd ?
    display_frames  db ?
    field_361       db ?
    force_full_display_count dw ?
    original_rect   db ?
    field_365       db 3 dup(?)
    field_368       dd ?
    dimx            dd ?
    dimy            dd ?
    mouse_x         dd ?
    mouse_y         dd ?                    ; offset
    screen_limit    dd ?                    ; offset
ends

struct string
    union
        buf db 16 dup (?)
        ptr dd ?
    ends
    len dd ?
    capa dd ?
    pad dd ?
ends

; enum justification
justify_left = 0
justify_center = 1
justify_right = 2
justify_cont = 3
not_truetype = 4

; section '.text' code

macro strlen str
{
    push edi
    mov edi, str
    xor ecx, ecx
    dec ecx
    xor eax, eax
    repne scasb
    pop edi
    not ecx
    dec ecx
    mov eax, ecx
}

macro init_string this*, c_str*, len
{
    if len eq
        strlen c_str
    else
        mov eax, len
    end if
    
    mov ecx, c_str
    mov [strbuf.len], eax
    .if eax<16
        mov [strbuf.capa], 15
        lea eax, [strbuf.buf]
        memcpy_dwords ecx, eax, 4
    .else
        mov [strbuf.capa], eax
        mov [strbuf.ptr], ecx
    .endif
}

macro memcpy_dwords src, dest, n
{
    push edi
    push esi
    mov edi, dest
    mov esi, src
    mov ecx, n
    rep movsd
    pop esi
    pop edi
}

macro changecolor this, colorbyte
{
    virtual at this
        gps graphicst
    end virtual
    
    mov al, colorbyte
    push eax
    and al, 7
    mov [gps.screenf], al
    
    pop eax
    shr al, 3
    push eax
    and al, 7
    mov [gps.screenb], al
    
    pop eax
    shr al, 3
    mov [gps.screenbright], al
}

addst = 8C6C50h+delta

; public addcoloredst
org 8C66E0h+delta

a = addcoloredst ; Add explicit reference to the procedure to force compilier not to eliminate the code of the porcedure

proc addcoloredst uses ebx esi edi, str:DWORD, colorstr:DWORD ; this:EAX
locals
    strbuf string
    colorstr_item db ?
endl
    mov edi, eax ; this
    
    init_string strbuf, [str]
    
    ; changecolor(colorstr[0] & 7, (colorstr[0] >> 3) & 7, colorstr[0] >> 6);
    mov eax, [colorstr]
    changecolor edi, [eax]
    
    ; addst(this<edx>, strbuf, just=justify_left, space<ecx>=0);
    xor ecx, ecx ; space = 0
    push justify_left
    lea eax, [strbuf] ; str_orig = strbuf
    push eax
    mov edx, edi ; this
    call addst
    
    ret
endp
