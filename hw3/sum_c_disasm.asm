; 作业 3：sum_c.exe 中 main 函数的真实反汇编。
; 目标平台：Windows 64 位；编译器：GCC 8.1.0；编译选项：-O0 -g。
; 以下保留原指令顺序，将跳转地址改为标签，并补充中文注释。
; 每条注释末尾注明本次构建中的原始指令地址。
; 局部变量：sum 位于 [rbp-4]，i 位于 [rbp-8]，均为 4 字节无符号整数。

EXTERN __main:PROC
EXTERN printf:PROC
PUBLIC main

.CODE
main PROC
    push rbp                            ; 保存调用者的帧指针 RBP。 地址：401550H。
    mov rbp,rsp                         ; 用当前 RSP 建立本函数的帧指针。 地址：401551H。
    sub rsp,30H                         ; 分配 48 字节栈空间，供局部变量、函数调用和对齐使用。 地址：401554H。
    call __main                         ; 调用 MinGW 运行时初始化辅助函数 __main。 地址：401558H。
    mov DWORD PTR [rbp-4H],0H           ; sum = 0，初始化累加结果。 地址：40155DH。
    mov DWORD PTR [rbp-8H],1H           ; i = 1，从第一个加数开始。 地址：401564H。
    jmp loc_401577                      ; 跳到循环条件检查，实现 for 循环先判断再执行。 地址：40156BH。

loc_40156d:
    mov eax,DWORD PTR [rbp-8H]          ; 将当前加数 i 读入 EAX。 地址：40156DH。
    add DWORD PTR [rbp-4H],eax          ; sum += i，直接更新栈上的 sum。 地址：401570H。
    add DWORD PTR [rbp-8H],1H           ; ++i，准备下一个加数。 地址：401573H。

loc_401577:
    cmp DWORD PTR [rbp-8H],64H          ; 比较 i 与 100；64H 是十进制 100。 地址：401577H。
    jbe loc_40156d                      ; 无符号比较满足 i <= 100 时跳回循环体。 地址：40157BH。
    mov eax,DWORD PTR [rbp-4H]          ; 读出最终的 sum，结果为 5050。 地址：40157DH。
    mov edx,eax                         ; 将 sum 放入 EDX，作为 printf 的第二个参数。 地址：401580H。
    lea rcx,[rip+2A77H]                 ; 将格式字符串 %u\n 的地址放入 RCX，作为第一个参数。 地址：401582H。
    call printf                         ; 调用 printf，按十进制输出 sum 并换行。 地址：401589H。
    mov eax,0H                          ; 将返回值 0 放入 EAX，对应 return 0。 地址：40158EH。
    add rsp,30H                         ; 释放本函数分配的 48 字节栈空间。 地址：401593H。
    pop rbp                             ; 恢复调用者的帧指针 RBP。 地址：401597H。
    ret                                 ; 返回调用者，main 函数结束。 地址：401598H。
    nop                                 ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：401599H。
    nop                                 ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：40159AH。
    nop                                 ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：40159BH。
    nop                                 ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：40159CH。
    nop                                 ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：40159DH。
    nop                                 ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：40159EH。
    nop                                 ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：40159FH。
main ENDP
END
