; 作业 3（1）：计算 1+2+...+100，累加结果保存在数据段 total 中。
.MODEL SMALL
.STACK 100H

.DATA
    total DW 0                 ; 16 位字变量，通过 DS 访问。

.CODE
START:
    MOV AX, @DATA
    MOV DS, AX                 ; DOS EXE 启动后必须初始化 DS。
    MOV WORD PTR total, 0
    MOV BX, 1
    MOV CX, 100
SUM_LOOP:
    ADD total, BX              ; 直接更新数据段中的累加结果。
    INC BX
    LOOP SUM_LOOP

    MOV AX, total              ; 只在输出时将结果取到 AX。
    CALL PRINT_DEC
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H
    MOV AX, 4C00H
    INT 21H

; 输入 AX（0～65535），保存 AX、BX、CX、DX。
PRINT_DEC PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX, CX
    MOV BX, 10
DEC_DIVIDE:
    XOR DX, DX
    DIV BX
    PUSH DX                    ; 余数依次入栈，逆序后得到正确位序。
    INC CX
    CMP AX, 0
    JNE DEC_DIVIDE
DEC_OUTPUT:
    POP DX
    ADD DL, '0'
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
