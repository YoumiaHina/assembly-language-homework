; 作业 3（2）：输入 n（1～100），输出 1+2+...+n 的十进制结果。
; 使用 INT 21H 的 0AH 功能读入一行，再将 ASCII 数字转换为数值。
.MODEL SMALL
.STACK 100H

.DATA
    prompt    DB 'Please input n (1-100):',0DH,0AH,'$'
    answer    DB 'The sum is:',0DH,0AH,'$'
    error_msg DB 'Invalid input. Use an integer from 1 to 100.',0DH,0AH,'$'
    crlf      DB 0DH,0AH,'$'
    input_buf DB 80,0,80 DUP (0)

.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
READ_AGAIN:
    LEA DX, prompt
    MOV AH, 09H
    INT 21H
    MOV BYTE PTR input_buf+1, 0
    LEA DX, input_buf
    MOV AH, 0AH
    INT 21H
    LEA DX, crlf
    MOV AH, 09H
    INT 21H

    XOR CX, CX
    MOV CL, input_buf+1
    JCXZ BAD_INPUT
    CMP CX, 3
    JA BAD_INPUT
    LEA SI, input_buf+2
    XOR AX, AX
    MOV BX, 10
INPUT_LOOP:
    MOV DL, [SI]
    CMP DL, '0'
    JB BAD_INPUT
    CMP DL, '9'
    JA BAD_INPUT
    SUB DL, '0'
    XOR DH, DH
    MOV DI, DX                 ; 保存当前数字，避免 MUL 改写 DX。
    MUL BX
    ADD AX, DI                 ; 新值 = 原值 * 10 + 当前位。
    CMP AX, 100
    JA BAD_INPUT               ; 最多三位，运算不会超出 16 位。
    INC SI
    LOOP INPUT_LOOP
    CMP AX, 1
    JB BAD_INPUT               ; 0 不在题目规定范围内。

    MOV CX, AX                 ; CX = n，控制循环次数。
    XOR AX, AX
    MOV BX, 1
SUM_LOOP:
    ADD AX, BX
    INC BX
    LOOP SUM_LOOP

    PUSH AX                    ; 保存结果，防止 MOV AH,09H 改写。
    LEA DX, answer
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_DEC
    LEA DX, crlf
    MOV AH, 09H
    INT 21H
    MOV AX, 4C00H
    INT 21H
BAD_INPUT:
    LEA DX, error_msg
    MOV AH, 09H
    INT 21H
    JMP READ_AGAIN

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
    PUSH DX
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
