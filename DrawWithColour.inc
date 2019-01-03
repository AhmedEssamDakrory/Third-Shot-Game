DrawWithColour MACRO x1,y1,x2,y2,clr
local again,DrawRow

PUSHA
mov cx, x1
mov dx, y1
mov al, clr
mov ah, 0ch

mov bx, y2
sub bx, y1
mov si, bx

MOV BH, 0

again:
mov cx, x1

DrawRow:
MOV BH,0
int 10H
inc cx
cmp cx,x2
JBE DrawRow

dec si
inc dx
cmp si,0
jnz again

POPA

ENDM DrawWithColour