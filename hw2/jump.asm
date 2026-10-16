; 作业 2：使用条件跳转指令打印小写字母。
; 运行环境：MASM 5.0、8086、DOS。两层循环均使用 DEC 和 JNZ。
.MODEL SMALL
.STACK 100H

.CODE
START:
    MOV BL, 'a'           ; BL 保存当前要输出的字母。
    MOV CX, 2             ; 外层循环打印两行。

ROW_LOOP:
    PUSH CX               ; 保存外层计数，防止内层循环覆盖 CX。
    MOV CX, 13            ; 内层循环每行打印 13 个字母。

CHAR_LOOP:
    MOV DL, BL
    MOV AH, 02H           ; DOS 的 02H 功能输出 DL 中的字符。
    INT 21H               ; 输出当前字母。
    INC BL                ; ASCII 码加 1，得到下一个字母。

    MOV DL, ' '
    MOV AH, 02H
    INT 21H               ; 在字母后输出一个空格。

    DEC CX                ; CX 减 1，同时更新零标志 ZF。
    JNZ CHAR_LOOP         ; CX 不为 0，即 ZF 为 0 时继续内层循环。

    MOV DL, 0DH           ; 输出回车。
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH           ; 输出换行。
    MOV AH, 02H
    INT 21H

    POP CX                ; 恢复外层计数。
    DEC CX                ; 外层计数减 1。
    JNZ ROW_LOOP          ; 外层计数不为 0 时打印下一行。

    MOV AX, 4C00H         ; 返回 DOS，退出码为 0。
    INT 21H

END START
