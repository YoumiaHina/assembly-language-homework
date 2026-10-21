; 课堂练习追加要求：十进制转换为十六进制。
; 输入 1～5 位十进制数字，数值范围 0～65535；输出大写十六进制。
.MODEL SMALL
.STACK 100H

.DATA
    prompt    DB 'Please input a Dec number (0-65535):',0DH,0AH,'$'
    answer    DB 'The Hex number:',0DH,0AH,'$'
    error_msg DB 'Invalid input. Use a decimal number from 0 to 65535.',0DH,0AH,'$'
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
    CMP CX, 5
    JA BAD_INPUT
    LEA SI, input_buf+2
    XOR AX, AX                 ; AX 保存已经转换的数值。
    MOV BX, 10
DEC_LOOP:
    MOV DL, [SI]
    CMP DL, '0'
    JB BAD_INPUT
    CMP DL, '9'
    JA BAD_INPUT
    SUB DL, '0'
    XOR DH, DH
    MOV DI, DX                 ; MUL 会改写 DX，先保存当前数字。
    MUL BX                     ; DX:AX = 原值 * 10。
    CMP DX, 0
    JNE BAD_INPUT              ; 高 16 位非零表示乘法溢出。
    ADD AX, DI
    JC BAD_INPUT               ; 加上当前位后也要检查进位。
    INC SI
    LOOP DEC_LOOP

    PUSH AX                    ; 09H 输出提示时会使用 AH。
    LEA DX, answer
    MOV AH, 09H
    INT 21H
    POP AX
    CALL PRINT_HEX
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

; 输入 AX（0～65535），输出 1～4 位十六进制数，不补前导零。
; 保存 AX、BX、CX、DX。除以 16 取余，逆序输出。
PRINT_HEX PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX, CX
    MOV BX, 16
HEX_DIVIDE:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    CMP AX, 0
    JNE HEX_DIVIDE
HEX_OUTPUT:
    POP DX
    CMP DL, 9
    JBE HEX_NUMBER
    ADD DL, 'A'-10             ; 10～15 转成 A～F。
    JMP SHORT HEX_PRINT
HEX_NUMBER:
    ADD DL, '0'
HEX_PRINT:
    MOV AH, 02H
    INT 21H
    LOOP HEX_OUTPUT
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_HEX ENDP

END START
