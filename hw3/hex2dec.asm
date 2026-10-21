; 课堂练习：输入 1～2 位十六进制数，输出十进制数。
; 环境：8086 / MASM 5.0 / DOS。接受 0～9、A～F 和 a～f。
.MODEL SMALL
.STACK 100H

.DATA
    prompt    DB 'Please input a Hex number (1-2 digits):',0DH,0AH,'$'
    answer    DB 'The Dec number:',0DH,0AH,'$'
    error_msg DB 'Invalid input. Use 1-2 hex digits (0-9, A-F).',0DH,0AH,'$'
    crlf      DB 0DH,0AH,'$'
    ; 0AH 缓冲区：最大长度（含回车）、实际长度、字符区。
    input_buf DB 80,0,80 DUP (0)

.CODE
START:
    MOV AX, @DATA
    MOV DS, AX                  ; 初始化数据段。

READ_AGAIN:
    LEA DX, prompt
    MOV AH, 09H
    INT 21H
    MOV BYTE PTR input_buf+1, 0
    LEA DX, input_buf
    MOV AH, 0AH                 ; DOS 缓冲行输入，回车结束。
    INT 21H
    LEA DX, crlf
    MOV AH, 09H
    INT 21H

    XOR CX, CX
    MOV CL, input_buf+1         ; 实际字符数不含回车。
    JCXZ BAD_INPUT
    CMP CX, 2
    JA BAD_INPUT
    LEA SI, input_buf+2
    XOR BX, BX                 ; BX 保存已经转换的数值。

HEX_LOOP:
    MOV AL, [SI]
    CMP AL, '0'
    JB BAD_INPUT
    CMP AL, '9'
    JBE HEX_DIGIT
    AND AL, 0DFH               ; 将小写字母转换为大写。
    CMP AL, 'A'
    JB BAD_INPUT
    CMP AL, 'F'
    JA BAD_INPUT
    SUB AL, 'A'-10             ; A～F 转换为 10～15。
    JMP SHORT HEX_VALUE
HEX_DIGIT:
    SUB AL, '0'                ; 数字字符转换为 0～9。
HEX_VALUE:
    XOR AH, AH
    SHL BX, 1                  ; 8086 每次只立即移位 1 位。
    SHL BX, 1
    SHL BX, 1
    SHL BX, 1                  ; 原值乘 16。
    ADD BX, AX                 ; 新值 = 原值 * 16 + 当前位。
    INC SI
    LOOP HEX_LOOP

    LEA DX, answer
    MOV AH, 09H
    INT 21H
    MOV AX, BX
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

; 输入 AX（0～65535），按十进制输出。保存 AX、BX、CX、DX。
PRINT_DEC PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX, CX
    MOV BX, 10
DEC_DIVIDE:
    XOR DX, DX                 ; 被除数为 DX:AX，必须先清零 DX。
    DIV BX                     ; AX = 商，DX = 余数。
    PUSH DX                    ; 低位先入栈，输出时高位先出栈。
    INC CX
    CMP AX, 0
    JNE DEC_DIVIDE              ; 至少执行一次，因此 0 也能输出。
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
