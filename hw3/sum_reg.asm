; 作业 3（1）：计算 1+2+...+100，累加结果保存在 AX 寄存器。
; 5050 = 13BAH，超过 8 位范围，必须使用 16 位寄存器。
.MODEL SMALL
.STACK 100H

.CODE
START:
    XOR AX, AX                 ; AX = 0，保存累加结果。
    MOV BX, 1                  ; BX 保存当前加数。
    MOV CX, 100                ; 一共累加 100 次。
SUM_LOOP:
    ADD AX, BX                 ; 结果始终保存在 AX。
    INC BX
    LOOP SUM_LOOP

    CALL PRINT_DEC             ; 将 AX 中的 5050 转成字符输出。
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H
    MOV AX, 4C00H
    INT 21H

; 输入 AX（0～65535），保存 AX、BX、CX、DX。
; 临时用栈逆序排列数字，求和阶段的结果保存在 AX 中。
PRINT_DEC PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX, CX
    MOV BX, 10
DEC_DIVIDE:
    XOR DX, DX
    DIV BX                     ; DX:AX / 10，余数为一个十进制数字。
    PUSH DX
    INC CX
    CMP AX, 0
    JNE DEC_DIVIDE
DEC_OUTPUT:
    POP DX
    ADD DL, '0'                ; 数值 0～9 转成 ASCII 字符。
    MOV AH, 02H
    INT 21H
    LOOP DEC_OUTPUT
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DEC ENDP

END START
