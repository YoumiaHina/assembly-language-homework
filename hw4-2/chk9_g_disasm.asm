; 作业 4（二）：chk9_g.exe 中 print_error 和 main 的真实反汇编。
; 平台：Windows x64；编译器：MinGW-w64 GCC 8.1.0；选项：-std=c11 -Wall -Wextra -Werror -O0 -g。
; 保留机器指令顺序，将跳转和调用目标换为符号；本文件用于阅读分析。
; Windows x64 的前四个整数或指针参数使用 RCX、RDX、R8、R9。
; 调用者为被调函数预留 32 字节影子空间；int 参数使用寄存器低 32 位。
; 两版的 row 位于 [RBP-4H]，column 位于 [RBP-8H]，均为 4 字节 int。
; 全局 table 是 81 字节的已初始化可写数组，位于 .data，基址为 403020H。
; 地址 = 403020H + row*9 + column；main 无须逐项初始化数组。
; 数组具有静态存储期，程序启动前完成初始化，main 返回后仍存在。

EXTERN __main:PROC
EXTERN printf:PROC
EXTERN puts:PROC
PUBLIC main

.CODE
; 参数 x 位于 [RBP+10H]，y 位于 [RBP+18H]。
print_error PROC
    push rbp                                     ; 保存调用者的帧指针 RBP。地址：401550H。
    mov rbp,rsp                                  ; 建立 print_error 的栈帧。地址：401551H。
    sub rsp,20H                                  ; 分配 32 字节影子空间，供 printf 调用使用。地址：401554H。
    mov DWORD PTR [rbp+10H],ecx                  ; 保存第一个 int 参数 x，栈槽为 [RBP+10H]。地址：401558H。
    mov DWORD PTR [rbp+18H],edx                  ; 保存第二个 int 参数 y，栈槽为 [RBP+18H]。地址：40155BH。
    mov eax,DWORD PTR [rbp+18H]                  ; 读取 y，暂存到 EAX。地址：40155EH。
    mov r8d,eax                                  ; printf 的第三个参数 R8D = y。地址：401561H。
    mov edx,DWORD PTR [rbp+10H]                  ; printf 的第二个参数 EDX = x。地址：401564H。
    lea rcx,[rip+2A92H]                          ; RCX 指向 404000H 的格式串 "%d %d  error\n"。地址：401567H。
    call printf                                  ; 调用 printf，输出错误坐标和换行。地址：40156EH。
    nop                                          ; 编译器保留的空操作。地址：401573H。
    add rsp,20H                                  ; 释放本函数分配的 32 字节影子空间。地址：401574H。
    pop rbp                                      ; 恢复调用者的 RBP。地址：401578H。
    ret                                          ; 弹出返回地址，回到 main 的调用点之后。地址：401579H。
print_error ENDP

main PROC
    push rbp                                     ; 保存调用者的帧指针。地址：40157AH。
    mov rbp,rsp                                  ; 建立 main 的栈帧。地址：40157BH。
    sub rsp,30H                                  ; 分配 48 字节，包含局部计数、影子空间和对齐。地址：40157EH。
    call __main                                  ; 调用 MinGW 运行时初始化辅助函数。地址：401582H。
    lea rcx,[rip+2A80H]                          ; RCX 指向 40400EH 的表头 "x y"。地址：401587H。
    call puts                                    ; 输出表头，puts 自动追加换行。地址：40158EH。
    mov DWORD PTR [rbp-4H],0H                    ; row = 0，C 数组下标从 0 开始。地址：401593H。
    jmp loc_401603                               ; 先跳到外层循环条件检查。地址：40159AH。

loc_40159c:
    mov DWORD PTR [rbp-8H],0H                    ; column = 0，每行重新开始检查。地址：40159CH。
    jmp loc_4015f9                               ; 先跳到内层循环条件检查。地址：4015A3H。

loc_4015a5:
    mov eax,DWORD PTR [rbp-8H]                   ; 读取 column。地址：4015A5H。
    movsxd rcx,eax                               ; 将 column 从 32 位有符号数扩展到 64 位 RCX。地址：4015A8H。
    mov eax,DWORD PTR [rbp-4H]                   ; 读取 row。地址：4015ABH。
    movsxd rdx,eax                               ; 将 row 符号扩展到 64 位 RDX。地址：4015AEH。
    mov rax,rdx                                  ; RAX = row，准备计算行偏移。地址：4015B1H。
    shl rax,3H                                   ; RAX = row * 8。地址：4015B4H。
    add rax,rdx                                  ; RAX = row * 9，每行占 9 字节。地址：4015B8H。
    lea rdx,[rax+rcx*1]                          ; RDX = row * 9 + column，得到线性字节偏移。地址：4015BBH。
    lea rax,[rip+1A5AH]                          ; RIP 相对寻址取得全局 table 基址 403020H，数组位于 .data。地址：4015BFH。
    add rax,rdx                                  ; RAX = 全局数组基址 + 线性偏移。地址：4015C6H。
    movzx eax,BYTE PTR [rax]                     ; 从 table[row][column] 读 1 字节，零扩展到 EAX。地址：4015C9H。
    movzx edx,al                                 ; EDX = 当前表项的无符号值，用于后续 int 比较。地址：4015CCH。
    mov eax,DWORD PTR [rbp-4H]                   ; 读取 row，开始计算正确乘积。地址：4015CFH。
    lea ecx,[rax+1H]                             ; ECX = row + 1，对应从 1 开始的行号。地址：4015D2H。
    mov eax,DWORD PTR [rbp-8H]                   ; 读取 column。地址：4015D5H。
    add eax,1H                                   ; EAX = column + 1，对应从 1 开始的列号。地址：4015D8H。
    imul eax,ecx                                 ; EAX = (row + 1) * (column + 1)，执行 int 乘法。地址：4015DBH。
    cmp edx,eax                                  ; 比较实际表项 EDX 与正确乘积 EAX。地址：4015DEH。
    je loc_4015f5                                ; 相等时跳过错误输出，直接处理下一列。地址：4015E0H。
    mov eax,DWORD PTR [rbp-8H]                   ; 发现错误，读取 column。地址：4015E2H。
    lea edx,[rax+1H]                             ; 第二个参数 EDX = column + 1，即输出列号 y。地址：4015E5H。
    mov eax,DWORD PTR [rbp-4H]                   ; 读取 row。地址：4015E8H。
    add eax,1H                                   ; EAX = row + 1，即输出行号 x。地址：4015EBH。
    mov ecx,eax                                  ; 第一个参数 ECX = x。地址：4015EEH。
    call print_error                             ; 调用 print_error(x, y)，计数变量保存在栈中。地址：4015F0H。

loc_4015f5:
    add DWORD PTR [rbp-8H],1H                    ; ++column，继续当前行。地址：4015F5H。

loc_4015f9:
    cmp DWORD PTR [rbp-8H],8H                    ; 比较 column 与 8。地址：4015F9H。
    jle loc_4015a5                               ; column <= 8 等价于 column < 9，继续内层循环。地址：4015FDH。
    add DWORD PTR [rbp-4H],1H                    ; ++row，当前行的 9 项已全部检查。地址：4015FFH。

loc_401603:
    cmp DWORD PTR [rbp-4H],8H                    ; 比较 row 与 8。地址：401603H。
    jle loc_40159c                               ; row <= 8 时继续下一行，共扫描 81 项。地址：401607H。
    lea rcx,[rip+2A02H]                          ; RCX 指向 404012H 的字符串 "\naccomplish!"。地址：401609H。
    call puts                                    ; 输出空行和完成提示，再由 puts 追加换行。地址：401610H。
    mov eax,0H                                   ; 设置 main 的返回值为 0。地址：401615H。
    add rsp,30H                                  ; 释放 main 分配的 48 字节栈空间。地址：40161AH。
    pop rbp                                      ; 恢复调用者的 RBP。地址：40161EH。
    ret                                          ; 返回运行时调用者。地址：40161FH。
main ENDP
END
