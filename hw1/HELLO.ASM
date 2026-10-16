.MODEL SMALL
.STACK 100H

.DATA
HELLO DB 'Hello, world!', 0DH, 0AH, '$'

.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    LEA DX, HELLO
    MOV AH, 9
    INT 21H
    MOV AX, 4C00H
    INT 21H
END START
