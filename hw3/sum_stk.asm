; 作业 3（1）：计算 1+2+...+100，累加结果保存在栈中。
; 用 SS:[BP-2] 保存结果，整个求和循环直接更新该栈单元。
.MODEL SMALL
.STACK 100H

.CODE
START:
    PUSH BP
    MOV BP, SP                 ; 建立栈帧，BP 寻址默认使用 SS。
    SUB SP, 2                  ; 在栈上分配一个 16 位字。
    MOV WORD PTR [BP-2], 0
    MOV BX, 1
    MOV CX, 100
SUM_LOOP:
    ADD WORD PTR [BP-2], BX    ; 每次都在栈内更新累加结果。
    INC BX
    LOOP SUM_LOOP

    MOV AX, [BP-2]             ; 从栈内取出 5050，准备显示。
    CALL PRINT_DEC             ; 子程序压栈位于局部变量下方。
    MOV SP, BP                 ; 释放局部变量，恢复调用前的栈。
    POP BP
    MOV DL, 0DH
    MOV AH, 02H
    INT 21H
    MOV DL, 0AH
    MOV AH, 02H
    INT 21H
    MOV AX, 4C00H
    INT 21H

; 输入 AX（0～65535），保存 AX、BX、CX、DX，保持 BP 不变。
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
