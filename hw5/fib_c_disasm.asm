; 作业 5：fib_c.exe 中四个自定义函数的真实反汇编及逐条注释。
; 平台：Windows x64；编译器：MinGW-w64 GCC 8.1.0。
; 编译选项：-std=c11 -Wall -Wextra -Werror -O0 -g。
; Windows x64 用 RCX、RDX、R8、R9 传前四个整数或指针参数。
; CALL 压入 8 字节返回地址；调用者预留 32 字节影子空间。
; DOS 手写程序的 NEAR CALL 压入 2 字节，两者采用各自的调用约定。

EXTERN __main:PROC
EXTERN fwrite:PROC
EXTERN fflush:PROC
EXTERN fputs:PROC
EXTERN fgets:PROC
EXTERN puts:PROC
EXTERN printf:PROC
EXTERN putchar:PROC
PUBLIC main

.CODE
; n：[RBP+10H]；out：[RBP+18H]；left：[RBP-16H]；right：[RBP-20H]。
; carry：[RBP-4H]；i：[RBP-8H]；sum：[RBP-0CH]。每层连同 CALL 和 PUSH RBP 共 80 字节。
fib PROC
    push rbp                                       ; 保存调用者的 RBP。地址：401550H。
    mov rbp,rsp                                    ; 建立 fib 的栈帧。地址：401551H。
    sub rsp,40H                                    ; 分配 64 字节，包含局部变量和 32 字节影子空间。地址：401554H。
    mov DWORD PTR [rbp+10H],ecx                    ; 保存第一个参数 n，位于 [RBP+10H]。地址：401558H。
    mov QWORD PTR [rbp+18H],rdx                    ; 保存第二个参数 out，位于 [RBP+18H]。地址：40155BH。
    mov DWORD PTR [rbp-4H],0H                      ; 初始化 carry = 0。地址：40155FH。
    mov eax,DWORD PTR [rbp+10H]                    ; 读取 n，写 EAX 同时清零 RAX 的高 32 位。地址：401566H。
    lea rdx,[rip+2EB0H]                            ; 取得全局 ready 数组的地址。地址：401569H。
    movzx eax,BYTE PTR [rax+rdx*1]                 ; 读取 ready[n]，将 1 字节零扩展到 EAX。地址：401570H。
    test al,al                                     ; 检查 ready[n] 是否非零。地址：401574H。
    jne loc_401613                                 ; 命中缓存，跳到结果复制部分。地址：401576H。
    mov eax,DWORD PTR [rbp+10H]                    ; 读取当前 n。地址：40157CH。
    lea ecx,[rax-1H]                               ; 第一参数 ECX = n-1。地址：40157FH。
    lea rax,[rbp-16H]                              ; 取得局部 left 的地址 [RBP-16H]。地址：401582H。
    mov rdx,rax                                    ; 第二参数 RDX = &left。地址：401586H。
    call fib                                       ; 第一次递归：fib(n-1, &left)，返回地址为 40158EH。地址：401589H。
    mov eax,DWORD PTR [rbp+10H]                    ; 重新读取保存在本层栈帧中的 n。地址：40158EH。
    lea ecx,[rax-2H]                               ; 第一参数 ECX = n-2。地址：401591H。
    lea rax,[rbp-20H]                              ; 取得局部 right 的地址 [RBP-20H]。地址：401594H。
    mov rdx,rax                                    ; 第二参数 RDX = &right。地址：401598H。
    call fib                                       ; 第二次递归：fib(n-2, &right)，返回地址为 4015A0H。地址：40159BH。
    mov DWORD PTR [rbp-8H],0H                      ; 初始化字下标 i = 0。地址：4015A0H。
    jmp loc_4015ff                                 ; 先检查五字加法循环的条件。地址：4015A7H。

loc_4015a9:
    mov eax,DWORD PTR [rbp-8H]                     ; 读取当前下标 i。地址：4015A9H。
    movzx eax,WORD PTR [rbp+rax*2-16H]             ; 读取 left.word[i]，字数组的步长为 2 字节。地址：4015ACH。
    movzx edx,ax                                   ; 将左操作数零扩展到 32 位。地址：4015B1H。
    mov eax,DWORD PTR [rbp-8H]                     ; 再次读取 i。地址：4015B4H。
    movzx eax,WORD PTR [rbp+rax*2-20H]             ; 读取 right.word[i]。地址：4015B7H。
    movzx eax,ax                                   ; 将右操作数零扩展到 32 位。地址：4015BCH。
    add edx,eax                                    ; EDX = left.word[i] + right.word[i]。地址：4015BFH。
    mov eax,DWORD PTR [rbp-4H]                     ; 读取上一字留下的 carry。地址：4015C1H。
    add eax,edx                                    ; EAX = 两个字之和 + carry。地址：4015C4H。
    mov DWORD PTR [rbp-0CH],eax                    ; 将 32 位 sum 保存在 [RBP-0CH]。地址：4015C6H。
    mov eax,DWORD PTR [rbp-0CH]                    ; 读取 sum，准备写入当前结果字。地址：4015C9H。
    mov r8d,eax                                    ; R8D 暂存 sum，后续只写入其低 16 位 R8W。地址：4015CCH。
    mov ecx,DWORD PTR [rbp-8H]                     ; ECX = i。地址：4015CFH。
    mov edx,DWORD PTR [rbp+10H]                    ; EDX = n。地址：4015D2H。
    mov rax,rdx                                    ; RAX = n，开始计算二维数组偏移。地址：4015D5H。
    shl rax,2H                                     ; RAX = 4*n。地址：4015D8H。
    add rax,rdx                                    ; RAX = 5*n。地址：4015DCH。
    add rax,rcx                                    ; RAX = 5*n+i，以 16 位字为单位。地址：4015DFH。
    lea rdx,[rax+rax*1]                            ; RDX = 10*n+2*i，转换为字节偏移。地址：4015E2H。
    lea rax,[rip+2A33H]                            ; 取得全局 memo 的地址 404020H。地址：4015E6H。
    mov WORD PTR [rdx+rax*1],r8w                   ; memo[n].word[i] = sum 的低 16 位。地址：4015EDH。
    mov eax,DWORD PTR [rbp-0CH]                    ; 重新读取 32 位 sum。地址：4015F2H。
    shr eax,10H                                    ; 逻辑右移 16 位，提取进位。地址：4015F5H。
    mov DWORD PTR [rbp-4H],eax                     ; carry = sum >> 16，结果为 0 或 1。地址：4015F8H。
    add DWORD PTR [rbp-8H],1H                      ; ++i，处理下一个更高的字。地址：4015FBH。

loc_4015ff:
    cmp DWORD PTR [rbp-8H],4H                      ; 比较 i 与 4。地址：4015FFH。
    jbe loc_4015a9                                 ; i <= 4 时继续，共处理 5 个字。地址：401603H。
    mov eax,DWORD PTR [rbp+10H]                    ; 读取 n。地址：401605H。
    lea rdx,[rip+2E11H]                            ; 取得 ready 数组地址。地址：401608H。
    mov BYTE PTR [rax+rdx*1],1H                    ; ready[n] = 1，标记本项计算完成。地址：40160FH。

loc_401613:
    mov rdx,QWORD PTR [rbp+18H]                    ; RDX = out，准备把缓存复制给调用者。地址：401613H。
    mov ecx,DWORD PTR [rbp+10H]                    ; ECX = n。地址：401617H。
    mov rax,rcx                                    ; RAX = n。地址：40161AH。
    shl rax,2H                                     ; RAX = 4*n。地址：40161DH。
    add rax,rcx                                    ; RAX = 5*n。地址：401621H。
    add rax,rax                                    ; RAX = 10*n，即 BigInt 数组的字节偏移。地址：401624H。
    mov rcx,rax                                    ; RCX 暂存缓存项偏移。地址：401627H。
    lea rax,[rip+29EFH]                            ; 取得 memo 基址。地址：40162AH。
    mov r8,QWORD PTR [rcx+rax*1]                   ; 读取 memo[n] 的低 8 字节，即前 4 个字。地址：401631H。
    mov QWORD PTR [rdx],r8                         ; 将前 4 个字复制到 *out。地址：401635H。
    movzx eax,WORD PTR [rcx+rax*1+8H]              ; 读取 memo[n] 的最后 1 个字。地址：401638H。
    mov WORD PTR [rdx+8H],ax                       ; 将最高字写入 out->word[4]，完成 10 字节结构体复制。地址：40163DH。
    nop                                            ; 编译器生成的空操作。地址：401641H。
    add rsp,40H                                    ; 释放 64 字节栈空间。地址：401642H。
    pop rbp                                        ; 恢复调用者的 RBP。地址：401646H。
    ret                                            ; 弹出 8 字节返回地址，回到调用点之后。地址：401647H。
fib ENDP

; work：[RBP-22H]；digits：[RBP-40H]；p：[RBP-8H]。
; 除以常数 10 被编译为乘 CCCCCCCDH 后取高位并右移，余数用 part-10*商计算。
print_big PROC
    push rbp                                       ; 保存调用者的 RBP。地址：401648H。
    mov rbp,rsp                                    ; 建立 print_big 的栈帧。地址：401649H。
    sub rsp,60H                                    ; 分配 96 字节，存放工作副本、字符数组和调用空间。地址：40164CH。
    mov QWORD PTR [rbp+10H],rcx                    ; 保存参数 value 的指针。地址：401650H。
    mov rax,QWORD PTR [rbp+10H]                    ; RAX = value。地址：401654H。
    mov rdx,QWORD PTR [rax]                        ; 读取输入大整数的前 8 字节。地址：401658H。
    mov QWORD PTR [rbp-22H],rdx                    ; 复制到 work 的前 4 个字，[RBP-22H] 是 work 基址。地址：40165BH。
    movzx eax,WORD PTR [rax+8H]                    ; 读取输入大整数的最高字。地址：40165FH。
    mov WORD PTR [rbp-1AH],ax                      ; 复制到 work.word[4]，保持原始输入不变。地址：401663H。
    lea rax,[rbp-40H]                              ; 取得 digits 数组的首地址 [RBP-40H]。地址：401667H。
    add rax,19H                                    ; 加 25，指向字符数组的最后一个单元。地址：40166BH。
    mov QWORD PTR [rbp-8H],rax                     ; 保存指针 p = digits+25。地址：40166FH。
    mov rax,QWORD PTR [rbp-8H]                     ; 读取 p。地址：401673H。
    mov BYTE PTR [rax],0H                          ; 写入字符串终止符 '\0'。地址：401677H。

loc_40167a:
    mov DWORD PTR [rbp-10H],0H                     ; 每轮长除法开始时初始化 remainder = 0。地址：40167AH。
    mov DWORD PTR [rbp-0CH],0H                     ; 初始化 nonzero = 0。地址：401681H。
    mov DWORD PTR [rbp-14H],4H                     ; 从最高字开始，初始化 i = 4。地址：401688H。
    jmp loc_4016f9                                 ; 先检查 i >= 0。地址：40168FH。

loc_401691:
    mov eax,DWORD PTR [rbp-10H]                    ; 读取上一个字产生的余数。地址：401691H。
    shl eax,10H                                    ; 左移 16 位，作为下一次被除数的高位。地址：401694H。
    mov edx,eax                                    ; EDX 暂存 remainder << 16。地址：401697H。
    mov eax,DWORD PTR [rbp-14H]                    ; 读取有符号下标 i。地址：401699H。
    cdqe                                           ; 将 EAX 符号扩展到 RAX，用于地址计算。地址：40169CH。
    movzx eax,WORD PTR [rbp+rax*2-22H]             ; 读取 work.word[i]。地址：40169EH。
    movzx eax,ax                                   ; 将该字零扩展到 32 位。地址：4016A3H。
    or eax,edx                                     ; 拼成 part = (remainder << 16) | work.word[i]。地址：4016A6H。
    mov DWORD PTR [rbp-18H],eax                    ; 将 part 保存到 [RBP-18H]。地址：4016A8H。
    mov eax,DWORD PTR [rbp-18H]                    ; 读取 part，准备求无符号商。地址：4016ABH。
    mov edx,0CCCCCCCDH                             ; 装入常数 CCCCCCCDH，用于精确计算无符号除以 10。地址：4016AEH。
    mul edx                                        ; 无符号乘法，32 位 part 乘常数，64 位积放在 EDX:EAX。地址：4016B3H。
    mov eax,edx                                    ; 取乘积的高 32 位。地址：4016B5H。
    shr eax,3H                                     ; 再右移 3 位，EAX = part / 10。地址：4016B7H。
    mov edx,eax                                    ; EDX 暂存商，其低 16 位将写入工作数组。地址：4016BAH。
    mov eax,DWORD PTR [rbp-14H]                    ; 读取 i。地址：4016BCH。
    cdqe                                           ; 将 i 符号扩展到 64 位。地址：4016BFH。
    mov WORD PTR [rbp+rax*2-22H],dx                ; work.word[i] = part / 10。地址：4016C1H。
    mov ecx,DWORD PTR [rbp-18H]                    ; ECX = part，准备求余数。地址：4016C6H。
    mov edx,0CCCCCCCDH                             ; 再次装入除以 10 所用的常数。地址：4016C9H。
    mov eax,ecx                                    ; EAX = part。地址：4016CEH。
    mul edx                                        ; 再次计算 part 与常数的 64 位乘积。地址：4016D0H。
    shr edx,3H                                     ; EDX = part / 10。地址：4016D2H。
    mov eax,edx                                    ; EAX = 商。地址：4016D5H。
    shl eax,2H                                     ; EAX = 4*商。地址：4016D7H。
    add eax,edx                                    ; EAX = 5*商。地址：4016DAH。
    add eax,eax                                    ; EAX = 10*商。地址：4016DCH。
    sub ecx,eax                                    ; ECX = part - 10*商，即 part % 10。地址：4016DEH。
    mov eax,ecx                                    ; EAX = 余数。地址：4016E0H。
    mov DWORD PTR [rbp-10H],eax                    ; 保存 remainder，传给下一个更低的字。地址：4016E2H。
    mov eax,DWORD PTR [rbp-14H]                    ; 读取 i。地址：4016E5H。
    cdqe                                           ; 将 i 符号扩展到 64 位。地址：4016E8H。
    movzx eax,WORD PTR [rbp+rax*2-22H]             ; 读取当前字的商。地址：4016EAH。
    movzx eax,ax                                   ; 将商零扩展到 32 位。地址：4016EFH。
    or DWORD PTR [rbp-0CH],eax                     ; 累计 nonzero，只要有一个字非零就继续外层除法。地址：4016F2H。
    sub DWORD PTR [rbp-14H],1H                     ; --i，向更低的字移动。地址：4016F5H。

loc_4016f9:
    cmp DWORD PTR [rbp-14H],0H                     ; 比较 i 与 0。地址：4016F9H。
    jns loc_401691                                 ; i 非负时继续，从字 4 到字 0 共处理 5 次。地址：4016FDH。
    mov eax,DWORD PTR [rbp-10H]                    ; 读取本轮最终余数，即十进制最低位。地址：4016FFH。
    add eax,30H                                    ; 加 ASCII 码 30H，转成数字字符。地址：401702H。
    sub QWORD PTR [rbp-8H],1H                      ; --p，字符从数组末尾向前写入。地址：401705H。
    mov edx,eax                                    ; DL 暂存要写入的字符。地址：40170AH。
    mov rax,QWORD PTR [rbp-8H]                     ; RAX = p。地址：40170CH。
    mov BYTE PTR [rax],dl                          ; *p = 当前数字字符。地址：401710H。
    cmp DWORD PTR [rbp-0CH],0H                     ; 检查工作副本的商是否仍非零。地址：401712H。
    jne loc_40167a                                 ; 非零时再除以 10，生成下一个数字。地址：401716H。
    mov ecx,1H                                     ; 参数 ECX = 1，获取标准输出流。地址：40171CH。
    mov rax,QWORD PTR [rip+2DD8H]                  ; 从导入表读取 __acrt_iob_func 函数指针。地址：401721H。
    call rax                                       ; 间接调用运行时函数，RAX 返回 stdout。地址：401728H。
    mov rdx,rax                                    ; 第二参数 RDX = stdout。地址：40172AH。
    mov rax,QWORD PTR [rbp-8H]                     ; RAX = p，即有效数字字符串的起始位置。地址：40172DH。
    mov rcx,rax                                    ; 第一参数 RCX = p。地址：401731H。
    call fputs                                     ; fputs(p, stdout)，输出完整十进制数。地址：401734H。
    nop                                            ; 编译器生成的空操作。地址：401739H。
    add rsp,60H                                    ; 释放 96 字节栈空间。地址：40173AH。
    pop rbp                                        ; 恢复调用者的 RBP。地址：40173EH。
    ret                                            ; 返回调用者。地址：40173FH。
print_big ENDP

; out：[RBP+10H]；line：[RBP-90H]；n：[RBP-4H]；i：[RBP-8H]。
read_n PROC
    push rbp                                       ; 保存调用者的 RBP。地址：401740H。
    mov rbp,rsp                                    ; 建立 read_n 的栈帧。地址：401741H。
    sub rsp,0B0H                                   ; 分配 176 字节，包括 128 字节输入数组和调用空间。地址：401744H。
    mov QWORD PTR [rbp+10H],rcx                    ; 保存输出参数 out。地址：40174BH。
    mov DWORD PTR [rbp-4H],0H                      ; 初始化 n = 0。地址：40174FH。
    mov DWORD PTR [rbp-8H],0H                      ; 初始化 i = 0。地址：401756H。
    mov ecx,0H                                     ; 参数 ECX = 0，获取标准输入流。地址：40175DH。
    mov rax,QWORD PTR [rip+2D97H]                  ; 读取 __acrt_iob_func 函数指针。地址：401762H。
    call rax                                       ; 间接调用，RAX 返回 stdin。地址：401769H。
    mov rdx,rax                                    ; RDX 暂存 stdin。地址：40176BH。
    lea rax,[rbp-90H]                              ; 取得输入数组 line 的地址 [RBP-90H]。地址：40176EH。
    mov r8,rdx                                     ; 第三参数 R8 = stdin。地址：401775H。
    mov edx,80H                                    ; 第二参数 EDX = 128，即输入缓冲区大小。地址：401778H。
    mov rcx,rax                                    ; 第一参数 RCX = line。地址：40177DH。
    call fgets                                     ; fgets(line, 128, stdin)，读取一行。地址：401780H。
    test rax,rax                                   ; 检查 fgets 是否返回空指针。地址：401785H。
    jne loc_4017e7                                 ; 读取成功时跳到循环条件检查。地址：401788H。
    mov eax,0H                                     ; 读取失败，准备返回 0。地址：40178AH。
    jmp loc_40183b                                 ; 跳到 read_n 的统一返回处。地址：40178FH。

loc_401794:
    cmp DWORD PTR [rbp-8H],3H                      ; 检查 i 是否已等于 3。地址：401794H。
    je loc_4017b8                                  ; 超过 3 个字符时输入无效。地址：401798H。
    mov eax,DWORD PTR [rbp-8H]                     ; 读取 i。地址：40179AH。
    movzx eax,BYTE PTR [rbp+rax*1-90H]             ; 读取 line[i]。地址：40179DH。
    cmp al,2FH                                     ; 比较字符与 '/'，即 ASCII 2FH。地址：4017A5H。
    jle loc_4017b8                                 ; 字符小于 '0' 时输入无效。地址：4017A7H。
    mov eax,DWORD PTR [rbp-8H]                     ; 读取 i。地址：4017A9H。
    movzx eax,BYTE PTR [rbp+rax*1-90H]             ; 再次读取 line[i]。地址：4017ACH。
    cmp al,39H                                     ; 比较字符与 '9'。地址：4017B4H。
    jle loc_4017bf                                 ; 字符不大于 '9' 时进入数字转换。地址：4017B6H。

loc_4017b8:
    mov eax,0H                                     ; 检验失败，设置返回值为 0。地址：4017B8H。
    jmp loc_40183b                                 ; 跳到统一返回处。地址：4017BDH。

loc_4017bf:
    mov edx,DWORD PTR [rbp-4H]                     ; EDX = 当前 n。地址：4017BFH。
    mov eax,edx                                    ; EAX = n。地址：4017C2H。
    shl eax,2H                                     ; EAX = 4*n。地址：4017C4H。
    add eax,edx                                    ; EAX = 5*n。地址：4017C7H。
    add eax,eax                                    ; EAX = 10*n。地址：4017C9H。
    mov edx,eax                                    ; EDX 暂存 10*n。地址：4017CBH。
    mov eax,DWORD PTR [rbp-8H]                     ; 读取 i。地址：4017CDH。
    movzx eax,BYTE PTR [rbp+rax*1-90H]             ; 读取当前数字字符。地址：4017D0H。
    movsx eax,al                                   ; 将 char 符号扩展到 int；此前已确认字符为 '0' 至 '9'。地址：4017D8H。
    add eax,edx                                    ; EAX = 10*n + 字符的 ASCII 码。地址：4017DBH。
    sub eax,30H                                    ; 减去 '0'，得到新的十进制整数。地址：4017DDH。
    mov DWORD PTR [rbp-4H],eax                     ; 更新 n。地址：4017E0H。
    add DWORD PTR [rbp-8H],1H                      ; ++i，移到下一个字符。地址：4017E3H。

loc_4017e7:
    mov eax,DWORD PTR [rbp-8H]                     ; 读取 i，开始检查循环终止字符。地址：4017E7H。
    movzx eax,BYTE PTR [rbp+rax*1-90H]             ; 读取 line[i]。地址：4017EAH。
    test al,al                                     ; 检查是否为字符串终止符。地址：4017F2H。
    je loc_401814                                  ; 遇到 '\0' 时结束数字解析。地址：4017F4H。
    mov eax,DWORD PTR [rbp-8H]                     ; 读取 i。地址：4017F6H。
    movzx eax,BYTE PTR [rbp+rax*1-90H]             ; 再次读取 line[i]。地址：4017F9H。
    cmp al,0AH                                     ; 检查是否为换行符 0AH。地址：401801H。
    je loc_401814                                  ; 遇到换行时结束数字解析。地址：401803H。
    mov eax,DWORD PTR [rbp-8H]                     ; 读取 i。地址：401805H。
    movzx eax,BYTE PTR [rbp+rax*1-90H]             ; 再次读取 line[i]。地址：401808H。
    cmp al,0DH                                     ; 检查是否为回车符 0DH。地址：401810H。
    jne loc_401794                                 ; 普通字符则回到循环体，继续检查数字。地址：401812H。

loc_401814:
    cmp DWORD PTR [rbp-8H],0H                      ; 检查是否一个数字都没有读取。地址：401814H。
    je loc_401826                                  ; 空输入返回失败。地址：401818H。
    cmp DWORD PTR [rbp-4H],0H                      ; 检查 n 是否为 0。地址：40181AH。
    je loc_401826                                  ; n=0 时返回失败。地址：40181EH。
    cmp DWORD PTR [rbp-4H],64H                     ; 比较 n 与 100。地址：401820H。
    jbe loc_40182d                                 ; n <= 100 时输入合法。地址：401824H。

loc_401826:
    mov eax,0H                                     ; 范围不合法，返回 0。地址：401826H。
    jmp loc_40183b                                 ; 跳到统一返回处。地址：40182BH。

loc_40182d:
    mov rax,QWORD PTR [rbp+10H]                    ; RAX = out。地址：40182DH。
    mov edx,DWORD PTR [rbp-4H]                     ; EDX = 已解析的 n。地址：401831H。
    mov DWORD PTR [rax],edx                        ; *out = n，将合法结果写给调用者。地址：401834H。
    mov eax,1H                                     ; 设置返回值 1，表示读取成功。地址：401836H。

loc_40183b:
    add rsp,0B0H                                   ; 释放 176 字节栈空间。地址：40183BH。
    pop rbp                                        ; 恢复调用者的 RBP。地址：401842H。
    ret                                            ; 返回调用者。地址：401843H。
read_n ENDP

; n：[RBP-4H]；result：[RBP-0EH]，占 10 字节。
main PROC
    push rbp                                       ; 保存调用者的 RBP。地址：401844H。
    mov rbp,rsp                                    ; 建立 main 的栈帧。地址：401845H。
    sub rsp,30H                                    ; 分配 48 字节，包含 n、result 和影子空间。地址：401848H。
    call __main                                    ; 调用 MinGW 的运行时初始化辅助函数。地址：40184CH。
    mov ecx,1H                                     ; 参数 ECX = 1，获取标准输出流。地址：401851H。
    mov rax,QWORD PTR [rip+2CA3H]                  ; 读取 __acrt_iob_func 函数指针。地址：401856H。
    call rax                                       ; 间接调用并返回 stdout。地址：40185DH。
    mov r9,rax                                     ; fwrite 的第四参数 R9 = stdout。地址：40185FH。
    mov r8d,0CH                                    ; 第三参数 R8D = 12，即提示字符串的长度。地址：401862H。
    mov edx,1H                                     ; 第二参数 EDX = 1，即每项 1 字节。地址：401868H。
    lea rcx,[rip+378CH]                            ; 第一参数 RCX 指向提示字符串。地址：40186DH。
    call fwrite                                    ; 输出提示；编译器将固定字符串的 fputs 转为 fwrite。地址：401874H。
    mov ecx,1H                                     ; 参数 ECX = 1，获取标准输出流。地址：401879H。
    mov rax,QWORD PTR [rip+2C7BH]                  ; 读取 __acrt_iob_func 函数指针。地址：40187EH。
    call rax                                       ; 调用并返回 stdout。地址：401885H。
    mov rcx,rax                                    ; 第一参数 RCX = stdout。地址：401887H。
    call fflush                                    ; fflush(stdout)，立即显示输入提示。地址：40188AH。
    lea rax,[rbp-4H]                               ; 取得局部 n 的地址 [RBP-4H]。地址：40188FH。
    mov rcx,rax                                    ; 第一参数 RCX = &n。地址：401893H。
    call read_n                                    ; read_n(&n)，读取并校验输入。地址：401896H。
    test eax,eax                                   ; 检查 read_n 的返回值。地址：40189BH。
    jne loc_4018b2                                 ; 非零时进入正常计算分支。地址：40189DH。
    lea rcx,[rip+376AH]                            ; RCX 指向输入错误提示字符串。地址：40189FH。
    call puts                                      ; puts 输出错误提示和换行。地址：4018A6H。
    mov eax,1H                                     ; 设置 main 的返回值为 1。地址：4018ABH。
    jmp loc_4018f7                                 ; 跳到 main 的统一返回处。地址：4018B0H。

loc_4018b2:
    mov ecx,0AH                                    ; 参数 ECX = 换行符 0AH。地址：4018B2H。
    call putchar                                   ; 输出换行。地址：4018B7H。
    mov ecx,DWORD PTR [rbp-4H]                     ; 第一参数 ECX = n。地址：4018BCH。
    lea rax,[rbp-0EH]                              ; 取得局部 result 的地址 [RBP-0EH]。地址：4018BFH。
    mov rdx,rax                                    ; 第二参数 RDX = &result。地址：4018C3H。
    call fib                                       ; fib(n, &result)，计算目标项。地址：4018C6H。
    mov eax,DWORD PTR [rbp-4H]                     ; 读取 n。地址：4018CBH。
    mov edx,eax                                    ; printf 的第二参数 EDX = n。地址：4018CEH。
    lea rcx,[rip+3769H]                            ; 第一参数 RCX 指向格式串 "F(%u) = "。地址：4018D0H。
    call printf                                    ; 输出结果前缀。地址：4018D7H。
    lea rax,[rbp-0EH]                              ; 取得 result 的地址。地址：4018DCH。
    mov rcx,rax                                    ; 第一参数 RCX = &result。地址：4018E0H。
    call print_big                                 ; print_big(&result)，输出 80 位结果的十进制表示。地址：4018E3H。
    mov ecx,0AH                                    ; 参数 ECX = 换行符。地址：4018E8H。
    call putchar                                   ; 输出换行。地址：4018EDH。
    mov eax,0H                                     ; 设置 main 的返回值为 0。地址：4018F2H。

loc_4018f7:
    add rsp,30H                                    ; 释放 48 字节栈空间。地址：4018F7H。
    pop rbp                                        ; 恢复调用者的 RBP。地址：4018FBH。
    ret                                            ; 返回运行时调用者。地址：4018FCH。
    nop                                            ; RET 后的对齐填充。地址：4018FDH。
    nop                                            ; RET 后的对齐填充。地址：4018FEH。
    nop                                            ; RET 后的对齐填充。地址：4018FFH。
main ENDP
END
