; 作业 4（二）：检查九九乘法表，输出错误数据的行号 x 和列号 y。
; 环境：8086 / MASM 5.0 / DOS。坐标从 1 开始，只检查并定位错误。
; BX 保存行号，DI 保存列号，SI 指向当前表项，CX 用作双重 LOOP 的计数。
.MODEL SMALL
.STACK 100H

.DATA
    ; 每个表项占 1 字节，每行连续存放 9 项，与题目中的数据一致。
    table DB 7,2,3,4,5,6,7,8,9
          DB 2,4,7,8,10,12,14,16,18
          DB 3,6,9,12,15,18,21,24,27
          DB 4,8,12,16,7,24,28,32,36
          DB 5,10,15,20,25,30,35,40,45
          DB 6,12,18,24,30,7,42,48,54
          DB 7,14,21,28,35,42,49,56,63
          DB 8,16,24,32,40,48,56,7,72
          DB 9,18,27,36,45,54,63,72,81
    heading   DB 'x y',0DH,0AH,'$'
    error_msg DB '  error',0DH,0AH,'$'
    done_msg  DB 0DH,0AH,'accomplish!',0DH,0AH,'$'

.CODE
START:
    MOV AX, @DATA
    MOV DS, AX                 ; DS 必须先指向数据段，才能读取 table。
    LEA DX, heading
    MOV AH, 09H
    INT 21H

    LEA SI, table              ; DS:[SI] 是第一个表项，而不是表项的数值。
    MOV BX, 1                  ; x = 1，按行检查。
    MOV CX, 9                  ; 外层循环共 9 行。
ROW_LOOP:
    PUSH CX                    ; 保存外层计数，内层循环也要使用 CX。
    MOV DI, 1                  ; y = 1，每行都从第一列开始。
    MOV CX, 9                  ; 每行必须检查 9 项，包括上三角部分。
COLUMN_LOOP:
    MOV AX, BX
    MUL DI                     ; DX:AX = x * y，正确乘积为 1～81。
    CMP AL, [SI]               ; 表项是字节，乘积小于 256，只需比较 AL。
    JE NEXT_ITEM
    CALL PRINT_ERROR           ; 定位错误；返回后仍保留行号、列号和循环状态。
NEXT_ITEM:
    INC SI                     ; 下一个字节；偏移 = (x-1)*9 + (y-1)。
    INC DI
    LOOP COLUMN_LOOP
    POP CX                     ; 恢复外层计数。
    INC BX
    LOOP ROW_LOOP              ; 扫描全部 81 项。

    LEA DX, done_msg
    MOV AH, 09H
    INT 21H
    MOV AX, 4C00H
    INT 21H                    ; 正常退出，避免顺序执行子过程。

; 输入：BX = 行号 x，DI = 列号 y（均为 1～9）。输出 "x y  error"。
; 保存 AX、BX、DX；CX、SI、DI 保持不变，FLAGS 不保证保持。
PRINT_ERROR PROC NEAR
    PUSH AX
    PUSH BX                    ; 子过程要借用主程序保存行号的 BX。
    PUSH DX
    MOV DL, BL
    ADD DL, '0'
    CALL PRINT_CHAR            ; 输出行号。
    MOV DL, ' '
    CALL PRINT_CHAR
    MOV BX, DI                 ; 借用 BX 取列号，覆盖了主程序中的行号。
    MOV DL, BL
    ADD DL, '0'
    CALL PRINT_CHAR            ; 输出列号。
    LEA DX, error_msg
    MOV AH, 09H
    INT 21H                    ; 输出 error 和回车换行。
    POP DX
    POP BX                     ; 恢复主程序的行号，继续后面的乘法检查。
    POP AX                     ; 出栈顺序与入栈顺序相反。
    RET                        ; 弹出返回 IP，回到 CALL 后的 NEXT_ITEM。
PRINT_ERROR ENDP

; 输入：DL = ASCII 字符。DOS 02H 功能会改写 AL，因此保存整个 AX。
PRINT_CHAR PROC NEAR
    PUSH AX
    MOV AH, 02H
    INT 21H
    POP AX
    RET
PRINT_CHAR ENDP

END START
