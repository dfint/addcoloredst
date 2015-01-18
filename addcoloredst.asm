include 'macro\proc32.inc'
include 'macro\struct.inc'
include 'macro\if.inc'

format MS COFF

; class graphicst
extrn screenx:dword ; long screenx
extrn screeny:dword ; long screeny
extrn screenb:byte ; char screenb
extrn screenf:byte ; char screenf
extrn screenbright:byte ; char screenbright
extrn clipx:dword ; long clipx[2]
extrn clipy:dword ; long clipy[2]
extrn dimy:dword ; int dimy
; init_displayst
extrn init.display.grid_x:dword

extrn addst ; (edx:this, string * str_orig, byte justification, space:ecx)

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

section '.text' code

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

public addcoloredst

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
            mov edx, screenx
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
