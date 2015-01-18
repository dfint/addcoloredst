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

; macro display_hex num 
; {
    ; bits = 32
    ; repeat bits/4
    ; d = '0' + num shr (bits-%*4) and 0Fh
    ; if d > '9'
        ; d = d + 'A'-'9'-1
    ; end if
    ; display d
    ; end repeat
; }

orig_base_addr = 401000h
new_base_addr = 401000h

delta = new_base_addr-orig_base_addr

; display_hex (0E32288h+delta)

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
    mov eax, [screenx]
    cmp eax, [init.display.grid_x]
    jge .skip
        xor esi, esi
        .while esi < [slen]
            .if signed [screenx]<0
                push esi
                add esi, [screenx]
                mov [screenx], 0
                cmp esi, [slen]
                pop esi
                jge .break
            .endif
            
            ; changecolor((colorstr[s] & 7),((colorstr[s] & 56))>>3,((colorstr[s] & 64))>>6);
            mov eax, [colorstr]
            mov al, [eax+esi]
            mov [colorstr_s], al
            and al, 7
            mov [screenf], al
            mov al, [colorstr_s]
            shr al, 3
            push eax
            and al, 7
            mov [screenb], al
            pop eax
            shr al, 3
            mov [screenbright], al
            
            ; string somebuf = str[s]
            xor eax, eax
            mov dword [somebuf.buf], eax
            mov al, [ebx+esi]
            mov [somebuf.buf], al
            mov [somebuf.len], 1
            mov [somebuf.capa], 15
            
            ; addst(someBuf);
            xor ecx, ecx ; space = 0
            push justify_left ; just = justify_left
            lea eax, [somebuf] ; str_orig = somebuf
            push eax
            mov edx, screenx ; this
            call addst
            
            mov [slen], eax
            mov eax, [screenx]
            cmp eax, [init.display.grid_x]
            jge .break
            
            inc esi
        .endw
        .break:
    .skip:
    ret
endp
