; 作业 2：ascii_c.exe 中 main 函数的反汇编。
; 目标平台：Windows 64 位；编译器：GCC 8.1.0；编译选项：-O0。
; 每条注释末尾注明本次构建中的原始指令地址。
; 局部变量：行计数 row 位于 [rbp-4]，列计数 column 位于 [rbp-8]。
; 当前字母 letter 位于 [rbp-0CH]；三个变量均占 4 字节。

EXTERN __main:PROC
EXTERN putchar:PROC
PUBLIC main

.CODE
main PROC
    push   rbp                           ; 保存调用者的帧指针 RBP。 地址：401550H。
    mov    rbp,rsp                       ; 用当前 RSP 建立本函数的帧指针。 地址：401551H。
    sub    rsp,30H                       ; 分配 48 字节栈空间，供局部变量和函数调用使用。 地址：401554H。
    call __main                          ; 调用 MinGW 运行时初始化辅助函数 __main。 地址：401558H。
    mov    DWORD PTR [rbp-0CH],61H       ; letter = 'a'；61H 是小写 a 的 ASCII 码。 地址：40155DH。
    mov    DWORD PTR [rbp-4H],0H         ; row = 0，初始化外层循环变量。 地址：401564H。
    jmp loc_4015a6                       ; 跳到外层循环条件检查，实现 for 循环先判断再执行。 地址：40156BH。

loc_40156d:
    mov    DWORD PTR [rbp-8H],0H         ; column = 0；每一行都重新初始化内层计数。 地址：40156DH。
    jmp loc_401592                       ; 跳到内层循环条件检查。 地址：401574H。

loc_401576:
    mov    eax,DWORD PTR [rbp-0CH]       ; 将局部变量 letter 读入 EAX。 地址：401576H。
    mov    ecx,eax                       ; 将 letter 放入 ECX，作为 putchar 的第一个 int 参数。 地址：401579H。
    call putchar                         ; 调用 putchar(letter)，输出当前字母。 地址：40157BH。
    mov    ecx,20H                       ; 将 20H（空格）放入参数寄存器 ECX。 地址：401580H。
    call putchar                         ; 调用 putchar(' ')，输出字母后的空格。 地址：401585H。
    add    DWORD PTR [rbp-0CH],1H        ; ++letter，准备输出下一个 ASCII 字母。 地址：40158AH。
    add    DWORD PTR [rbp-8H],1H         ; ++column，更新内层循环计数。 地址：40158EH。

loc_401592:
    cmp    DWORD PTR [rbp-8H],0CH        ; 比较 column 与 12；column <= 12 等价于 column < 13。 地址：401592H。
    jle loc_401576                       ; 有符号比较满足小于等于时跳回循环体，共执行 13 次。 地址：401596H。
    mov    ecx,0AH                       ; 将 0AH（换行）放入参数寄存器 ECX。 地址：401598H。
    call putchar                         ; 调用 putchar('\n')，结束当前行。 地址：40159DH。
    add    DWORD PTR [rbp-4H],1H         ; ++row，更新外层循环计数。 地址：4015A2H。

loc_4015a6:
    cmp    DWORD PTR [rbp-4H],1H         ; 比较 row 与 1；row <= 1 等价于 row < 2。 地址：4015A6H。
    jle loc_40156d                       ; row <= 1 时开始下一行；row 取 0、1，共两行。 地址：4015AAH。
    mov    eax,0H                        ; 将返回值 0 放入 EAX，对应 return 0。 地址：4015ACH。
    add    rsp,30H                       ; 释放本函数分配的 48 字节栈空间。 地址：4015B1H。
    pop    rbp                           ; 恢复调用者的帧指针 RBP。 地址：4015B5H。
    ret                                  ; 返回调用者，main 函数正常执行到此结束。 地址：4015B6H。
    nop                                  ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：4015B7H。
    nop                                  ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：4015B8H。
    nop                                  ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：4015B9H。
    nop                                  ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：4015BAH。
    nop                                  ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：4015BBH。
    nop                                  ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：4015BCH。
    nop                                  ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：4015BDH。
    nop                                  ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：4015BEH。
    nop                                  ; RET 后的填充 NOP，不属于 main 的正常执行路径。 地址：4015BFH。
main ENDP
END
