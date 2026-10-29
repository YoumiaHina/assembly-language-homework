; 作业 4：mul9_c.exe 中 print_item 和 main 的真实反汇编。
; 平台：Windows 64 位；编译器：MinGW-w64 GCC 8.1.0。
; Windows x64 用 RCX、RDX、R8、R9 传递前四个整数或指针参数。
; int 参数使用对应的低 32 位，调用者还要为被调函数预留 32 字节影子空间。
; 此处 C 的有符号 int 乘法生成 IMUL；DOS 手写汇编使用 MUL。

EXTERN __main:PROC
EXTERN printf:PROC
EXTERN puts:PROC
EXTERN putchar:PROC
PUBLIC main

.CODE
; 参数：row 位于 [rbp+10H]，column 位于 [rbp+18H]。
; 局部变量 product 位于 [rbp-4H]，三者均为 4 字节 int。
print_item PROC
    push rbp                            ; 保存调用者的帧指针。地址：401550H。
    mov rbp,rsp                         ; 建立当前函数的栈帧。地址：401551H。
    sub rsp,30H                         ; 分配 48 字节，容纳局部量、影子空间和对齐。地址：401554H。
    mov DWORD PTR [rbp+10H],ecx          ; 将第一个参数 row 存到参数的栈槽。地址：401558H。
    mov DWORD PTR [rbp+18H],edx          ; 将第二个参数 column 存到参数的栈槽。地址：40155BH。
    mov eax,DWORD PTR [rbp+10H]          ; EAX = row。地址：40155EH。
    imul eax,DWORD PTR [rbp+18H]         ; EAX = row * column，执行有符号乘法。地址：401561H。
    mov DWORD PTR [rbp-4H],eax           ; product = row * column。地址：401565H。
    mov edx,DWORD PTR [rbp-4H]           ; 暂时将 product 读入 EDX。地址：401568H。
    mov eax,DWORD PTR [rbp+18H]          ; 暂时将 column 读入 EAX。地址：40156BH。
    mov r9d,edx                         ; printf 的第四个参数为 product。地址：40156EH。
    mov r8d,eax                         ; printf 的第三个参数为 column。地址：401571H。
    mov edx,DWORD PTR [rbp+10H]          ; printf 的第二个参数为 row。地址：401574H。
    lea rcx,[rip+2A82H]                 ; 第一参数指向 404000H 的格式串 "%d*%d=%d"。地址：401577H。
    call printf                         ; 输出当前算式。地址：40157EH。
    mov eax,DWORD PTR [rbp+18H]          ; printf 后重新从栈中读取 column。地址：401583H。
    cmp eax,DWORD PTR [rbp+10H]          ; 有符号比较 column 与 row。地址：401586H。
    jge loc_4015ab                      ; column >= row 时跳过分隔空格。地址：401589H。
    cmp DWORD PTR [rbp-4H],9H            ; 比较 product 与 9，判断是否为一位数。地址：40158BH。
    jg loc_40159f                       ; product > 9 时跳到两空格分支。地址：40158FH。
    lea rcx,[rip+2A71H]                 ; RCX 指向 404009H 的三个空格字符串。地址：401591H。
    call printf                         ; 一位数算式后补三个空格。地址：401598H。
    jmp loc_4015ab                      ; 跳过另一个分支，进入函数收尾。地址：40159DH。

loc_40159f:
    lea rcx,[rip+2A67H]                 ; RCX 指向 40400DH 的两个空格字符串。地址：40159FH。
    call printf                         ; 两位数算式后补两个空格。地址：4015A6H。

loc_4015ab:
    nop                                 ; 编译器保留的空操作指令。地址：4015ABH。
    add rsp,30H                         ; 释放本函数分配的 48 字节栈空间。地址：4015ACH。
    pop rbp                             ; 恢复调用者的帧指针。地址：4015B0H。
    ret                                 ; 弹出 64 位返回地址，回到 main 的调用点后。地址：4015B1H。
print_item ENDP

; main 的局部变量：row 位于 [rbp-4H]，column 位于 [rbp-8H]。
main PROC
    push rbp                            ; 保存运行时调用者的帧指针。地址：4015B2H。
    mov rbp,rsp                         ; 建立 main 的栈帧。地址：4015B3H。
    sub rsp,30H                         ; 分配局部变量、影子空间和对齐所需的栈空间。地址：4015B6H。
    call __main                         ; 调用 MinGW 运行时初始化辅助函数。地址：4015BAH。
    lea rcx,[rip+2A4AH]                 ; RCX 指向 404010H 的标题 "The 9mul9 table:"。地址：4015BFH。
    call puts                           ; 输出标题，puts 会自动追加换行。地址：4015C6H。
    mov DWORD PTR [rbp-4H],9H            ; row = 9，初始化外层循环。地址：4015CBH。
    jmp loc_401604                      ; 先检查外层循环条件。地址：4015D2H。

loc_4015d4:
    mov DWORD PTR [rbp-8H],1H            ; column = 1，每行重新初始化内层循环。地址：4015D4H。
    jmp loc_4015ee                      ; 先检查内层循环条件。地址：4015DBH。

loc_4015dd:
    mov edx,DWORD PTR [rbp-8H]           ; 第二个 int 参数 EDX = column。地址：4015DDH。
    mov eax,DWORD PTR [rbp-4H]           ; 从栈中读取当前 row。地址：4015E0H。
    mov ecx,eax                         ; 第一个 int 参数 ECX = row。地址：4015E3H。
    call print_item                     ; 调用自定义函数，返回到 4015EAH。地址：4015E5H。
    add DWORD PTR [rbp-8H],1H            ; ++column，继续当前行。地址：4015EAH。

loc_4015ee:
    mov eax,DWORD PTR [rbp-8H]           ; 读取 column，准备检查内层循环条件。地址：4015EEH。
    cmp eax,DWORD PTR [rbp-4H]           ; 比较 column 与 row。地址：4015F1H。
    jle loc_4015dd                      ; column <= row 时输出下一项。地址：4015F4H。
    mov ecx,0AH                         ; putchar 的第一个参数为换行符 '\n'。地址：4015F6H。
    call putchar                        ; 当前行输出结束后换行。地址：4015FBH。
    sub DWORD PTR [rbp-4H],1H            ; --row，被乘数从 9 向 1 递减。地址：401600H。

loc_401604:
    cmp DWORD PTR [rbp-4H],0H            ; 比较 row 与 0。地址：401604H。
    jg loc_4015d4                       ; row > 0 等价于 row >= 1，继续下一行。地址：401608H。
    mov eax,0H                          ; EAX = 0，对应 return 0。地址：40160AH。
    add rsp,30H                         ; 释放 main 分配的 48 字节栈空间。地址：40160FH。
    pop rbp                             ; 恢复调用者的帧指针。地址：401613H。
    ret                                 ; main 返回运行时调用者。地址：401614H。
    nop                                 ; RET 后的对齐填充，不在正常执行路径内。地址：401615H。
    nop                                 ; 同上。地址：401616H。
    nop                                 ; 同上。地址：401617H。
    nop                                 ; 同上。地址：401618H。
    nop                                 ; 同上。地址：401619H。
    nop                                 ; 同上。地址：40161AH。
    nop                                 ; 同上。地址：40161BH。
    nop                                 ; 同上。地址：40161CH。
    nop                                 ; 同上。地址：40161DH。
    nop                                 ; 同上。地址：40161EH。
    nop                                 ; 同上。地址：40161FH。
main ENDP
END
