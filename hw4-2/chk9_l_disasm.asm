; 作业 4（二）：chk9_l.exe 中 print_error 和 main 的真实反汇编。
; 平台：Windows x64；编译器：MinGW-w64 GCC 8.1.0；选项：-std=c11 -Wall -Wextra -Werror -O0 -g。
; 保留机器指令顺序，将跳转和调用目标换为符号；本文件用于阅读分析。
; Windows x64 的前四个整数或指针参数使用 RCX、RDX、R8、R9。
; 调用者为被调函数预留 32 字节影子空间；int 参数使用寄存器低 32 位。
; 两版的 row 位于 [RBP-4H]，column 位于 [RBP-8H]，均为 4 字节 int。
; 自动局部 table 是栈上连续的 81 字节，范围为 [RBP-60H] 至 [RBP-10H]。
; 地址 = RBP-60H + row*9 + column；每次进入 main 都执行逐项初始化。
; main 为此分配 128 字节；全局版仅分配 48 字节。数组生存期到本次调用返回。

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
    add rsp,0FFFFFFFFFFFFFF80H                   ; 立即数为补码 -128，ADD RSP,-128 等价于分配 128 字节栈空间。地址：40157EH。
    call __main                                  ; 调用 MinGW 运行时初始化辅助函数。地址：401582H。
    mov BYTE PTR [rbp-60H],7H                    ; 初始化 table[0][0] = 7，写入当前栈帧中的一个字节。地址：401587H。
    mov BYTE PTR [rbp-5FH],2H                    ; 初始化 table[0][1] = 2，写入当前栈帧中的一个字节。地址：40158BH。
    mov BYTE PTR [rbp-5EH],3H                    ; 初始化 table[0][2] = 3，写入当前栈帧中的一个字节。地址：40158FH。
    mov BYTE PTR [rbp-5DH],4H                    ; 初始化 table[0][3] = 4，写入当前栈帧中的一个字节。地址：401593H。
    mov BYTE PTR [rbp-5CH],5H                    ; 初始化 table[0][4] = 5，写入当前栈帧中的一个字节。地址：401597H。
    mov BYTE PTR [rbp-5BH],6H                    ; 初始化 table[0][5] = 6，写入当前栈帧中的一个字节。地址：40159BH。
    mov BYTE PTR [rbp-5AH],7H                    ; 初始化 table[0][6] = 7，写入当前栈帧中的一个字节。地址：40159FH。
    mov BYTE PTR [rbp-59H],8H                    ; 初始化 table[0][7] = 8，写入当前栈帧中的一个字节。地址：4015A3H。
    mov BYTE PTR [rbp-58H],9H                    ; 初始化 table[0][8] = 9，写入当前栈帧中的一个字节。地址：4015A7H。
    mov BYTE PTR [rbp-57H],2H                    ; 初始化 table[1][0] = 2，写入当前栈帧中的一个字节。地址：4015ABH。
    mov BYTE PTR [rbp-56H],4H                    ; 初始化 table[1][1] = 4，写入当前栈帧中的一个字节。地址：4015AFH。
    mov BYTE PTR [rbp-55H],7H                    ; 初始化 table[1][2] = 7，写入当前栈帧中的一个字节。地址：4015B3H。
    mov BYTE PTR [rbp-54H],8H                    ; 初始化 table[1][3] = 8，写入当前栈帧中的一个字节。地址：4015B7H。
    mov BYTE PTR [rbp-53H],0AH                   ; 初始化 table[1][4] = 10，写入当前栈帧中的一个字节。地址：4015BBH。
    mov BYTE PTR [rbp-52H],0CH                   ; 初始化 table[1][5] = 12，写入当前栈帧中的一个字节。地址：4015BFH。
    mov BYTE PTR [rbp-51H],0EH                   ; 初始化 table[1][6] = 14，写入当前栈帧中的一个字节。地址：4015C3H。
    mov BYTE PTR [rbp-50H],10H                   ; 初始化 table[1][7] = 16，写入当前栈帧中的一个字节。地址：4015C7H。
    mov BYTE PTR [rbp-4FH],12H                   ; 初始化 table[1][8] = 18，写入当前栈帧中的一个字节。地址：4015CBH。
    mov BYTE PTR [rbp-4EH],3H                    ; 初始化 table[2][0] = 3，写入当前栈帧中的一个字节。地址：4015CFH。
    mov BYTE PTR [rbp-4DH],6H                    ; 初始化 table[2][1] = 6，写入当前栈帧中的一个字节。地址：4015D3H。
    mov BYTE PTR [rbp-4CH],9H                    ; 初始化 table[2][2] = 9，写入当前栈帧中的一个字节。地址：4015D7H。
    mov BYTE PTR [rbp-4BH],0CH                   ; 初始化 table[2][3] = 12，写入当前栈帧中的一个字节。地址：4015DBH。
    mov BYTE PTR [rbp-4AH],0FH                   ; 初始化 table[2][4] = 15，写入当前栈帧中的一个字节。地址：4015DFH。
    mov BYTE PTR [rbp-49H],12H                   ; 初始化 table[2][5] = 18，写入当前栈帧中的一个字节。地址：4015E3H。
    mov BYTE PTR [rbp-48H],15H                   ; 初始化 table[2][6] = 21，写入当前栈帧中的一个字节。地址：4015E7H。
    mov BYTE PTR [rbp-47H],18H                   ; 初始化 table[2][7] = 24，写入当前栈帧中的一个字节。地址：4015EBH。
    mov BYTE PTR [rbp-46H],1BH                   ; 初始化 table[2][8] = 27，写入当前栈帧中的一个字节。地址：4015EFH。
    mov BYTE PTR [rbp-45H],4H                    ; 初始化 table[3][0] = 4，写入当前栈帧中的一个字节。地址：4015F3H。
    mov BYTE PTR [rbp-44H],8H                    ; 初始化 table[3][1] = 8，写入当前栈帧中的一个字节。地址：4015F7H。
    mov BYTE PTR [rbp-43H],0CH                   ; 初始化 table[3][2] = 12，写入当前栈帧中的一个字节。地址：4015FBH。
    mov BYTE PTR [rbp-42H],10H                   ; 初始化 table[3][3] = 16，写入当前栈帧中的一个字节。地址：4015FFH。
    mov BYTE PTR [rbp-41H],7H                    ; 初始化 table[3][4] = 7，写入当前栈帧中的一个字节。地址：401603H。
    mov BYTE PTR [rbp-40H],18H                   ; 初始化 table[3][5] = 24，写入当前栈帧中的一个字节。地址：401607H。
    mov BYTE PTR [rbp-3FH],1CH                   ; 初始化 table[3][6] = 28，写入当前栈帧中的一个字节。地址：40160BH。
    mov BYTE PTR [rbp-3EH],20H                   ; 初始化 table[3][7] = 32，写入当前栈帧中的一个字节。地址：40160FH。
    mov BYTE PTR [rbp-3DH],24H                   ; 初始化 table[3][8] = 36，写入当前栈帧中的一个字节。地址：401613H。
    mov BYTE PTR [rbp-3CH],5H                    ; 初始化 table[4][0] = 5，写入当前栈帧中的一个字节。地址：401617H。
    mov BYTE PTR [rbp-3BH],0AH                   ; 初始化 table[4][1] = 10，写入当前栈帧中的一个字节。地址：40161BH。
    mov BYTE PTR [rbp-3AH],0FH                   ; 初始化 table[4][2] = 15，写入当前栈帧中的一个字节。地址：40161FH。
    mov BYTE PTR [rbp-39H],14H                   ; 初始化 table[4][3] = 20，写入当前栈帧中的一个字节。地址：401623H。
    mov BYTE PTR [rbp-38H],19H                   ; 初始化 table[4][4] = 25，写入当前栈帧中的一个字节。地址：401627H。
    mov BYTE PTR [rbp-37H],1EH                   ; 初始化 table[4][5] = 30，写入当前栈帧中的一个字节。地址：40162BH。
    mov BYTE PTR [rbp-36H],23H                   ; 初始化 table[4][6] = 35，写入当前栈帧中的一个字节。地址：40162FH。
    mov BYTE PTR [rbp-35H],28H                   ; 初始化 table[4][7] = 40，写入当前栈帧中的一个字节。地址：401633H。
    mov BYTE PTR [rbp-34H],2DH                   ; 初始化 table[4][8] = 45，写入当前栈帧中的一个字节。地址：401637H。
    mov BYTE PTR [rbp-33H],6H                    ; 初始化 table[5][0] = 6，写入当前栈帧中的一个字节。地址：40163BH。
    mov BYTE PTR [rbp-32H],0CH                   ; 初始化 table[5][1] = 12，写入当前栈帧中的一个字节。地址：40163FH。
    mov BYTE PTR [rbp-31H],12H                   ; 初始化 table[5][2] = 18，写入当前栈帧中的一个字节。地址：401643H。
    mov BYTE PTR [rbp-30H],18H                   ; 初始化 table[5][3] = 24，写入当前栈帧中的一个字节。地址：401647H。
    mov BYTE PTR [rbp-2FH],1EH                   ; 初始化 table[5][4] = 30，写入当前栈帧中的一个字节。地址：40164BH。
    mov BYTE PTR [rbp-2EH],7H                    ; 初始化 table[5][5] = 7，写入当前栈帧中的一个字节。地址：40164FH。
    mov BYTE PTR [rbp-2DH],2AH                   ; 初始化 table[5][6] = 42，写入当前栈帧中的一个字节。地址：401653H。
    mov BYTE PTR [rbp-2CH],30H                   ; 初始化 table[5][7] = 48，写入当前栈帧中的一个字节。地址：401657H。
    mov BYTE PTR [rbp-2BH],36H                   ; 初始化 table[5][8] = 54，写入当前栈帧中的一个字节。地址：40165BH。
    mov BYTE PTR [rbp-2AH],7H                    ; 初始化 table[6][0] = 7，写入当前栈帧中的一个字节。地址：40165FH。
    mov BYTE PTR [rbp-29H],0EH                   ; 初始化 table[6][1] = 14，写入当前栈帧中的一个字节。地址：401663H。
    mov BYTE PTR [rbp-28H],15H                   ; 初始化 table[6][2] = 21，写入当前栈帧中的一个字节。地址：401667H。
    mov BYTE PTR [rbp-27H],1CH                   ; 初始化 table[6][3] = 28，写入当前栈帧中的一个字节。地址：40166BH。
    mov BYTE PTR [rbp-26H],23H                   ; 初始化 table[6][4] = 35，写入当前栈帧中的一个字节。地址：40166FH。
    mov BYTE PTR [rbp-25H],2AH                   ; 初始化 table[6][5] = 42，写入当前栈帧中的一个字节。地址：401673H。
    mov BYTE PTR [rbp-24H],31H                   ; 初始化 table[6][6] = 49，写入当前栈帧中的一个字节。地址：401677H。
    mov BYTE PTR [rbp-23H],38H                   ; 初始化 table[6][7] = 56，写入当前栈帧中的一个字节。地址：40167BH。
    mov BYTE PTR [rbp-22H],3FH                   ; 初始化 table[6][8] = 63，写入当前栈帧中的一个字节。地址：40167FH。
    mov BYTE PTR [rbp-21H],8H                    ; 初始化 table[7][0] = 8，写入当前栈帧中的一个字节。地址：401683H。
    mov BYTE PTR [rbp-20H],10H                   ; 初始化 table[7][1] = 16，写入当前栈帧中的一个字节。地址：401687H。
    mov BYTE PTR [rbp-1FH],18H                   ; 初始化 table[7][2] = 24，写入当前栈帧中的一个字节。地址：40168BH。
    mov BYTE PTR [rbp-1EH],20H                   ; 初始化 table[7][3] = 32，写入当前栈帧中的一个字节。地址：40168FH。
    mov BYTE PTR [rbp-1DH],28H                   ; 初始化 table[7][4] = 40，写入当前栈帧中的一个字节。地址：401693H。
    mov BYTE PTR [rbp-1CH],30H                   ; 初始化 table[7][5] = 48，写入当前栈帧中的一个字节。地址：401697H。
    mov BYTE PTR [rbp-1BH],38H                   ; 初始化 table[7][6] = 56，写入当前栈帧中的一个字节。地址：40169BH。
    mov BYTE PTR [rbp-1AH],7H                    ; 初始化 table[7][7] = 7，写入当前栈帧中的一个字节。地址：40169FH。
    mov BYTE PTR [rbp-19H],48H                   ; 初始化 table[7][8] = 72，写入当前栈帧中的一个字节。地址：4016A3H。
    mov BYTE PTR [rbp-18H],9H                    ; 初始化 table[8][0] = 9，写入当前栈帧中的一个字节。地址：4016A7H。
    mov BYTE PTR [rbp-17H],12H                   ; 初始化 table[8][1] = 18，写入当前栈帧中的一个字节。地址：4016ABH。
    mov BYTE PTR [rbp-16H],1BH                   ; 初始化 table[8][2] = 27，写入当前栈帧中的一个字节。地址：4016AFH。
    mov BYTE PTR [rbp-15H],24H                   ; 初始化 table[8][3] = 36，写入当前栈帧中的一个字节。地址：4016B3H。
    mov BYTE PTR [rbp-14H],2DH                   ; 初始化 table[8][4] = 45，写入当前栈帧中的一个字节。地址：4016B7H。
    mov BYTE PTR [rbp-13H],36H                   ; 初始化 table[8][5] = 54，写入当前栈帧中的一个字节。地址：4016BBH。
    mov BYTE PTR [rbp-12H],3FH                   ; 初始化 table[8][6] = 63，写入当前栈帧中的一个字节。地址：4016BFH。
    mov BYTE PTR [rbp-11H],48H                   ; 初始化 table[8][7] = 72，写入当前栈帧中的一个字节。地址：4016C3H。
    mov BYTE PTR [rbp-10H],51H                   ; 初始化 table[8][8] = 81，写入当前栈帧中的一个字节。地址：4016C7H。
    lea rcx,[rip+293CH]                          ; RCX 指向 40400EH 的表头 "x y"；此前已完成局部数组初始化。地址：4016CBH。
    call puts                                    ; 输出表头，puts 自动追加换行。地址：4016D2H。
    mov DWORD PTR [rbp-4H],0H                    ; row = 0，C 数组下标从 0 开始。地址：4016D7H。
    jmp loc_401743                               ; 先跳到外层循环条件检查。地址：4016DEH。

loc_4016e0:
    mov DWORD PTR [rbp-8H],0H                    ; column = 0，每行重新开始检查。地址：4016E0H。
    jmp loc_401739                               ; 先跳到内层循环条件检查。地址：4016E7H。

loc_4016e9:
    mov eax,DWORD PTR [rbp-8H]                   ; 读取 column。地址：4016E9H。
    movsxd rcx,eax                               ; 将 column 从 32 位有符号数扩展到 64 位 RCX。地址：4016ECH。
    mov eax,DWORD PTR [rbp-4H]                   ; 读取 row。地址：4016EFH。
    movsxd rdx,eax                               ; 将 row 符号扩展到 64 位 RDX。地址：4016F2H。
    mov rax,rdx                                  ; RAX = row，准备计算行偏移。地址：4016F5H。
    shl rax,3H                                   ; RAX = row * 8。地址：4016F8H。
    add rax,rdx                                  ; RAX = row * 9，每行占 9 字节。地址：4016FCH。
    add rax,rbp                                  ; 将当前栈帧的 RBP 加入地址计算。地址：4016FFH。
    add rax,rcx                                  ; 再加 column，RAX = RBP + row * 9 + column。地址：401702H。
    sub rax,60H                                  ; 减去 60H，得到局部 table 基址 RBP-60H 加线性偏移。地址：401705H。
    movzx eax,BYTE PTR [rax]                     ; 从栈上的 table[row][column] 读 1 字节，零扩展到 EAX。地址：401709H。
    movzx edx,al                                 ; EDX = 当前表项的无符号值，用于后续 int 比较。地址：40170CH。
    mov eax,DWORD PTR [rbp-4H]                   ; 读取 row，开始计算正确乘积。地址：40170FH。
    lea ecx,[rax+1H]                             ; ECX = row + 1，对应从 1 开始的行号。地址：401712H。
    mov eax,DWORD PTR [rbp-8H]                   ; 读取 column。地址：401715H。
    add eax,1H                                   ; EAX = column + 1，对应从 1 开始的列号。地址：401718H。
    imul eax,ecx                                 ; EAX = (row + 1) * (column + 1)，执行 int 乘法。地址：40171BH。
    cmp edx,eax                                  ; 比较实际表项 EDX 与正确乘积 EAX。地址：40171EH。
    je loc_401735                                ; 相等时跳过错误输出，直接处理下一列。地址：401720H。
    mov eax,DWORD PTR [rbp-8H]                   ; 发现错误，读取 column。地址：401722H。
    lea edx,[rax+1H]                             ; 第二个参数 EDX = column + 1，即输出列号 y。地址：401725H。
    mov eax,DWORD PTR [rbp-4H]                   ; 读取 row。地址：401728H。
    add eax,1H                                   ; EAX = row + 1，即输出行号 x。地址：40172BH。
    mov ecx,eax                                  ; 第一个参数 ECX = x。地址：40172EH。
    call print_error                             ; 调用 print_error(x, y)，计数变量保存在栈中。地址：401730H。

loc_401735:
    add DWORD PTR [rbp-8H],1H                    ; ++column，继续当前行。地址：401735H。

loc_401739:
    cmp DWORD PTR [rbp-8H],8H                    ; 比较 column 与 8。地址：401739H。
    jle loc_4016e9                               ; column <= 8 等价于 column < 9，继续内层循环。地址：40173DH。
    add DWORD PTR [rbp-4H],1H                    ; ++row，当前行的 9 项已全部检查。地址：40173FH。

loc_401743:
    cmp DWORD PTR [rbp-4H],8H                    ; 比较 row 与 8。地址：401743H。
    jle loc_4016e0                               ; row <= 8 时继续下一行，共扫描 81 项。地址：401747H。
    lea rcx,[rip+28C2H]                          ; RCX 指向 404012H 的字符串 "\naccomplish!"。地址：401749H。
    call puts                                    ; 输出空行和完成提示，再由 puts 追加换行。地址：401750H。
    mov eax,0H                                   ; 设置 main 的返回值为 0。地址：401755H。
    sub rsp,0FFFFFFFFFFFFFF80H                   ; 立即数为补码 -128，SUB RSP,-128 等价于释放 128 字节栈空间。地址：40175AH。
    pop rbp                                      ; 恢复调用者的 RBP。地址：40175EH。
    ret                                          ; 返回运行时调用者，局部自动数组的生存期结束。地址：40175FH。
main ENDP
END
