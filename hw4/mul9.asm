; 作业 4：乘法指令和过程调用，输出倒三角九九乘法表。
; 环境：8086 / MASM 5.0 / DOS。每列宽 8 个字符，行末不加空格。
; 主程序用 BX 保存行数、SI 保存列数，内外两层 LOOP 共用 CX。
; 子过程用 PUSH / POP 保存和恢复寄存器，CALL / RET 完成调用和返回。
.MODEL SMALL
.STACK 100H

.DATA
    heading DB 'The 9mul9 table:',0DH,0AH,'$'

.CODE
START:
    MOV AX, @DATA
    MOV DS, AX                 ; 初始化数据段，供 DOS 09H 功能使用。
    LEA DX, heading
    MOV AH, 09H
    INT 21H

    MOV BX, 9                  ; 第一行的被乘数为 9，之后每行减 1。
    MOV CX, 9                  ; 外层循环一共输出 9 行。
ROW_LOOP:
    PUSH CX                    ; 保存外层计数，内层循环也要使用 CX。
    MOV CX, BX                 ; 第 BX 行输出 BX 个算式。
    MOV SI, 1                  ; 每行的乘数都从 1 开始。
COLUMN_LOOP:
    CALL PRINT_ITEM            ; 输入 BX、SI；返回时保持主程序的寄存器。
    INC SI
    LOOP COLUMN_LOOP           ; 输出 BX*1 到 BX*BX。

    CALL PRINT_CRLF
    POP CX                     ; 恢复外层循环计数。
    DEC BX                     ; 下一行的被乘数减 1。
    LOOP ROW_LOOP              ; 从第 9 行递减到第 1 行。

    MOV AX, 4C00H
    INT 21H                    ; 正常返回 DOS，避免顺序进入子过程。

; 输入：BX = 行数（1～9），SI = 列数（1～BX）。输出一个乘法算式。
; 保存 AX、BX、CX、DX；SI 只读。FLAGS 不保证保持。
PRINT_ITEM PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX                    ; 主程序的内层 LOOP 仍需要原来的 CX。
    PUSH DX

    MOV AX, BX
    MUL SI                     ; 无符号字乘法：DX:AX = AX * SI，乘积为 1～81。
    MOV CX, AX                 ; 暂存乘积；字符输出会使用 AH 和 DL。

    MOV DL, BL
    ADD DL, '0'                ; 行数转为 ASCII 数字。
    CALL PRINT_CHAR
    MOV DL, '*'
    CALL PRINT_CHAR
    MOV DX, SI
    ADD DL, '0'                ; 列数转为 ASCII 数字。
    CALL PRINT_CHAR
    MOV DL, '='
    CALL PRINT_CHAR

    MOV AX, CX
    CALL PRINT_DEC             ; 将乘积转为十进制，正确输出一位数和两位数。
    CMP SI, BX
    JE ITEM_DONE               ; 每行最后一项不输出分隔空格。
    MOV DL, ' '
    CALL PRINT_CHAR
    CALL PRINT_CHAR            ; 两位数算式长 6，补 2 个空格。
    CMP CX, 10
    JAE ITEM_DONE
    CALL PRINT_CHAR            ; 一位数算式长 5，再补 1 个空格。

ITEM_DONE:
    POP DX
    POP CX                     ; 恢复内层循环计数。
    POP BX                     ; PRINT_DEC 内部会使用 BX 作除数。
    POP AX                     ; 出栈顺序与入栈顺序相反。
    RET                        ; 弹出 CALL 保存的返回 IP，回到调用点后。
PRINT_ITEM ENDP

; 输入：AX = 无符号整数（0～65535）。输出十进制，不输出前导零。
; 保存 AX、BX、CX、DX。过程内部也使用 CX，不能覆盖调用者的计数。
PRINT_DEC PROC NEAR
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX, CX                 ; CX 统计十进制位数。
    MOV BX, 10
DEC_DIVIDE:
    XOR DX, DX                 ; DIV BX 的被除数为 DX:AX，先清高 16 位。
    DIV BX                     ; AX = 商，DX = 余数（0～9）。
    PUSH DX                    ; 低位先入栈，输出时从高位开始出栈。
    INC CX
    CMP AX, 0
    JNE DEC_DIVIDE             ; 至少执行一次，所以输入 0 也能输出。
DEC_OUTPUT:
    POP DX
    ADD DL, '0'
    CALL PRINT_CHAR
    LOOP DEC_OUTPUT
    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_DEC ENDP

; 输入：DL = 字符。DOS 02H 功能会改写 AL，因此保存整个 AX。
; 其他通用寄存器保持，FLAGS 不保证保持。
PRINT_CHAR PROC NEAR
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    RET
PRINT_CHAR ENDP

; 输出 DOS 回车换行。保存 DX，AX 由 PRINT_CHAR 保存。
PRINT_CRLF PROC NEAR
    PUSH DX
    MOV DL, 0DH
    CALL PRINT_CHAR
    MOV DL, 0AH
    CALL PRINT_CHAR
    POP DX
    RET
PRINT_CRLF ENDP

END START
