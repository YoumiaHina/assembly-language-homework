; 作业 5：递归求斐波那契数。
; 输入 AX = n；FIB 通过 DI:DX:CX:BX:AX 返回 80 位结果，从高字到低字排列。
; 缓存已计算的结果，减少两次递归调用中的重复计算，支持 n <= 100。
.MODEL SMALL
.STACK 1000H

.DATA
    PROMPT  DB 'n (1..100): $'
    ERROR_MSG DB 'Invalid input: enter an integer from 1 to 100.',13,10,'$'
    PREFIX  DB 'F($'
    INFIX   DB ') = $'
    NEWLINE DB 13,10,'$'
    INPUT_BUF DB 80,0,80 DUP (0)
    N_VALUE DW 0
    READY   DB 1,1,99 DUP (0)
    MEMO    DW 5 DUP (0),1,4 DUP (0),495 DUP (0)
    BIGBUF  DW 5 DUP (0)
    DEC_BUF DB 26 DUP ('$')

.CODE
START:
    MOV AX, @DATA
    MOV DS, AX
    ; DOS 加载程序时设置栈段 SS；在第一次 CALL 前显式初始化 SP。
    MOV AX, SS
    CLI
    MOV SS, AX
    MOV SP, 1000H
    STI

    LEA DX, PROMPT
    MOV AH, 09H
    INT 21H
    LEA DX, INPUT_BUF
    MOV AH, 0AH
    INT 21H
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H

    XOR CX, CX
    MOV CL, INPUT_BUF+1
    CMP CX, 1
    JB BAD_INPUT
    CMP CX, 3
    JA BAD_INPUT
    LEA SI, INPUT_BUF+2
    XOR AX, AX
    MOV BX, 10
READ_DIGIT:
    MOV DL, [SI]
    CMP DL, '0'
    JB BAD_INPUT
    CMP DL, '9'
    JA BAD_INPUT
    SUB DL, '0'
    XOR DH, DH
    PUSH DX
    MUL BX
    POP DX
    ADD AX, DX
    INC SI
    LOOP READ_DIGIT
    CMP AX, 1
    JB BAD_INPUT
    CMP AX, 100
    JA BAD_INPUT
    MOV N_VALUE, AX

    LEA DX, PREFIX
    MOV AH, 09H
    INT 21H
    MOV AX, N_VALUE
    CALL PRINT_U16
    LEA DX, INFIX
    MOV AH, 09H
    INT 21H
    MOV AX, N_VALUE
FIB_CALL:
    CALL FIB
FIB_DONE:
    CALL PRINT_BIG
    LEA DX, NEWLINE
    MOV AH, 09H
    INT 21H
    MOV AX, 4C00H
    INT 21H

BAD_INPUT:
    LEA DX, ERROR_MSG
    MOV AH, 09H
    INT 21H
    MOV AX, 4C01H
    INT 21H

; 每层栈帧：返回 IP 占 2 字节，旧 BP、SI 各占 2 字节，局部变量占 12 字节。
; [BP-4] 保存 n；[BP-14] 至 [BP-6] 保存 F(n-1)，按低字到高字排列。
; 保存并恢复 BP 和 SI；AX、BX、CX、DX、DI 分别保存结果的 5 个字。
FIB PROC NEAR
    PUSH BP
    MOV BP, SP
    PUSH SI
    SUB SP, 12
    MOV [BP-4], AX
    MOV SI, AX
    CMP READY[SI], 0
    JE FIB_RECURSE

    ; 计算 SI = 10*n，使用 8086 支持的单次移位指令。
    SHL SI, 1
    MOV BX, SI
    SHL SI, 1
    SHL SI, 1
    ADD SI, BX
    MOV AX, MEMO[SI]
    MOV BX, MEMO[SI+2]
    MOV CX, MEMO[SI+4]
    MOV DX, MEMO[SI+6]
    MOV DI, MEMO[SI+8]
    JMP SHORT FIB_RETURN

FIB_RECURSE:
    DEC AX
FIRST_CALL:
    CALL FIB                    ; 递归求 F(n-1)；CALL 将 2 字节返回 IP 压入栈。
FIRST_DONE:
    MOV [BP-14], AX
    MOV [BP-12], BX
    MOV [BP-10], CX
    MOV [BP-8], DX
    MOV [BP-6], DI
    MOV AX, [BP-4]
    SUB AX, 2
SECOND_CALL:
    CALL FIB                    ; 递归求 F(n-2)，通常可以直接读取缓存。
SECOND_DONE:
    ADD AX, [BP-14]
    ADC BX, [BP-12]
    ADC CX, [BP-10]
    ADC DX, [BP-8]
    ADC DI, [BP-6]              ; 进位必须从最低字连续传递到最高字。

    PUSH DI                     ; 暂存结果的最高字，借用 DI 计算缓存偏移。
    MOV SI, [BP-4]
    MOV DI, SI
    SHL SI, 1
    SHL SI, 1
    ADD SI, DI
    SHL SI, 1
    POP DI
    MOV MEMO[SI], AX
    MOV MEMO[SI+2], BX
    MOV MEMO[SI+4], CX
    MOV MEMO[SI+6], DX
    MOV MEMO[SI+8], DI
    MOV SI, [BP-4]
    MOV READY[SI], 1
FIB_RETURN:
    ADD SP, 12
    POP SI
    POP BP
FIB_RET:
    RET                         ; 弹出返回 IP，使 SP 恢复到本次调用前的位置。
FIB ENDP

; 以十进制输出 16 位无符号整数，保存并恢复 AX、BX、CX、DX。
PRINT_U16 PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX, CX
    MOV BX, 10
U16_DIVIDE:
    XOR DX, DX
    DIV BX
    PUSH DX
    INC CX
    OR AX, AX
    JNZ U16_DIVIDE
U16_OUTPUT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP U16_OUTPUT
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_U16 ENDP

; 对 80 位结果的工作副本除以 10，按高字到低字的顺序处理。
; 每轮余数对应一个十进制数字，从 DEC_BUF 末尾向前写入。
PRINT_BIG PROC NEAR
    MOV BIGBUF, AX
    MOV BIGBUF+2, BX
    MOV BIGBUF+4, CX
    MOV BIGBUF+6, DX
    MOV BIGBUF+8, DI
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    LEA DI, DEC_BUF+25
    MOV BX, 10
BIG_DIVIDE:
    LEA SI, BIGBUF+8
    MOV CX, 5
    XOR DX, DX
BIG_WORD:
    MOV AX, [SI]
    DIV BX
    MOV [SI], AX
    SUB SI, 2
    LOOP BIG_WORD
    ADD DL, '0'
    DEC DI
    MOV [DI], DL
    MOV AX, BIGBUF
    OR AX, BIGBUF+2
    OR AX, BIGBUF+4
    OR AX, BIGBUF+6
    OR AX, BIGBUF+8
    JNZ BIG_DIVIDE
    MOV DX, DI
    MOV AH, 09H
    INT 21H
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_BIG ENDP

END START
