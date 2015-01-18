include 'macro\proc32.inc'
include 'macro\struct.inc'
include 'macro\if.inc'

; format MS COFF
use32

; class graphicst
; extrn screenx:dword ; long screenx
; extrn screeny:dword ; long screeny
; extrn screenb:byte ; char screenb
; extrn screenf:byte ; char screenf
; extrn screenbright:byte ; char screenbright
; extrn clipx:dword ; long clipx[2]
; extrn clipy:dword ; long clipy[2]
; extrn dimy:dword ; int dimy
; ; init_displayst
; extrn init.display.grid_x:dword

; extrn addst ; (edx:this, string * str_orig, byte justification, space:ecx)

orig_base_addr = 401000h
new_base_addr = 401000h

delta = new_base_addr-orig_base_addr

label screenx dword at 0E32280h+delta
label screeny dword at 0E32284h+delta
label screenb byte at 0E32288h+delta
label screenf byte at 0E32289h+delta
label screenbright byte at 0E3228Ah+delta
label clipx dword at 0E322A4h+delta
label clipy dword at 0E322ACh+delta
label dimy dword at 0E325F0h+delta
label init.display.grid_x dword at 1C0AC2Ch+delta

addst = 7FDBD0h+delta

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

; public addcoloredst
org 7FDAA0h+delta

a = addcoloredst

proc addcoloredst uses esi, colorstr:DWORD ; str:EBX
locals
    slen dd ?
    somebuf string
    colorstr_s db ?
endl
    strlen ebx
    mov [slen], eax
    
    ; string somebuf = str
    mov [somebuf.len], eax
    .if eax<16
        mov [somebuf.capa], 15
        lea eax, [somebuf.buf]
        memcpy_dwords ebx, eax, 4
    .else
        mov [somebuf.capa], eax
        mov [somebuf.ptr], ebx
    .endif
    
    ; changecolor((colorstr[0] & 7),((colorstr[0] & 56))>>3,((colorstr[0] & 64))>>6);
    mov eax, [colorstr]
    mov al, [eax]
    mov [colorstr_s], al
    and al, 7
    mov [screenb], al
    
    mov al, [colorstr_s]
    shr al, 3
    push eax
    and al, 7
    mov [screenf], al
    
    pop eax
    shr al, 3
    mov [screenbright], al
    
    ; addst(someBuf);
    xor ecx, ecx ; space = 0
    push justify_left
    lea eax, [somebuf] ; str_orig = somebuf
    push eax
    mov edx, screenx ; this
    call addst
    
    ret
endp
