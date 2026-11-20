; 作业 6：cal_c.exe 中六个自定义函数的真实反汇编与中文注释。
; 编译器：MinGW-w64 GCC 8.1.0；平台：Windows x64。
; 编译选项：-std=c11 -Wall -Wextra -Werror -O0 -g。
; 来源：objdump -d -Mintel --insn-width=16 cal_c.exe。
; 保留指令顺序和地址，仅将调用、跳转目标改为符号，将十六进制数改用 H 后缀。
; 本文件供阅读分析，RIP 相对偏移对应本次构建，不能交给 MASM 5.0 汇编。
; Windows x64 前四个整数或指针参数使用 RCX、RDX、R8、R9，第五参数及以后使用栈。
; 调用者预留 32 字节影子空间；此平台 CALL 压入 8 字节返回地址。
; DOS 源码的 NEAR/FAR 分段调用采用 8086 约定，应分别分析。

EXTERN __main:PROC
EXTERN fputs:PROC
EXTERN fflush:PROC
EXTERN fgets:PROC
EXTERN strcspn:PROC
EXTERN printf:PROC
EXTERN fwrite:PROC
EXTERN putchar:PROC
EXTERN puts:PROC
PUBLIC main

.CODE
; 参数 year：[RBP+10H]。取模常数 400、100、4 分别变为乘法移位或按位与。
is_leap PROC
    push rbp                                       ; 保存调用者的 RBP。地址：401550H。
    mov rbp,rsp                                    ; 建立 is_leap 栈帧。地址：401551H。
    mov DWORD PTR [rbp+10H],ecx                    ; 保存寄存器参数 year，位于 [RBP+10H]。地址：401554H。
    mov ecx,DWORD PTR [rbp+10H]                    ; ECX = year，准备计算 year % 400。地址：401557H。
    mov edx,51EB851FH                              ; 装入除以 400 和 100 共用的乘法常数 51EB851FH。地址：40155AH。
    mov eax,ecx                                    ; EAX = year。地址：40155FH。
    mul edx                                        ; 无符号乘法，64 位积保存在 EDX:EAX。地址：401561H。
    mov eax,edx                                    ; 取乘积的高 32 位。地址：401563H。
    shr eax,7H                                     ; 再右移 7 位，得到 year / 400。地址：401565H。
    imul eax,eax,190H                              ; 商乘以 400。地址：401568H。
    sub ecx,eax                                    ; ECX = year - 400*商，即 year % 400。地址：40156EH。
    mov eax,ecx                                    ; EAX = 余数。地址：401570H。
    test eax,eax                                   ; 检查余数是否为 0。地址：401572H。
    je loc_40159c                                  ; 能被 400 整除时，直接返回闰年。地址：401574H。
    mov eax,DWORD PTR [rbp+10H]                    ; 再次读取 year。地址：401576H。
    and eax,3H                                     ; 取低两位，等价于无符号 year % 4。地址：401579H。
    test eax,eax                                   ; 检查能否被 4 整除。地址：40157CH。
    jne loc_4015a3                                 ; 不能被 4 整除时返回平年。地址：40157EH。
    mov ecx,DWORD PTR [rbp+10H]                    ; ECX = year，准备计算 year % 100。地址：401580H。
    mov edx,51EB851FH                              ; 装入乘法常数。地址：401583H。
    mov eax,ecx                                    ; EAX = year。地址：401588H。
    mul edx                                        ; 计算乘积 EDX:EAX。地址：40158AH。
    mov eax,edx                                    ; 取乘积高 32 位。地址：40158CH。
    shr eax,5H                                     ; 右移 5 位，得到 year / 100。地址：40158EH。
    imul eax,eax,64H                               ; 商乘以 100。地址：401591H。
    sub ecx,eax                                    ; 求出 year % 100。地址：401594H。
    mov eax,ecx                                    ; EAX = 余数。地址：401596H。
    test eax,eax                                   ; 检查是否整百年。地址：401598H。
    je loc_4015a3                                  ; 整百年且不能被 400 整除，返回平年。地址：40159AH。

loc_40159c:
    mov eax,1H                                     ; 返回值 EAX = 1，表示闰年。地址：40159CH。
    jmp loc_4015a8                                 ; 跳到统一返回处。地址：4015A1H。

loc_4015a3:
    mov eax,0H                                     ; 返回值 EAX = 0，表示平年。地址：4015A3H。

loc_4015a8:
    pop rbp                                        ; 恢复调用者的 RBP。地址：4015A8H。
    ret                                            ; 弹出 8 字节返回地址，返回调用者。地址：4015A9H。
is_leap ENDP

; 此函数帧指针采用偏移形式，year：[RBP-40H]，month：[RBP-38H]。
month_length PROC
    push rbp                                       ; 保存调用者的 RBP。地址：4015AAH。
    push rbx                                       ; 保存非易失寄存器 RBX，用于跨调用保留月份天数。地址：4015ABH。
    sub rsp,28H                                    ; 分配 40 字节，包含影子空间和对齐。地址：4015ACH。
    lea rbp,[rsp+80H]                              ; 设置带偏移的帧指针，本函数 RBP = RSP+80H。地址：4015B0H。
    mov DWORD PTR [rbp-40H],ecx                    ; 保存第一个参数 year，位于 [RBP-40H]。地址：4015B8H。
    mov DWORD PTR [rbp-38H],edx                    ; 保存第二个参数 month，位于 [RBP-38H]。地址：4015BBH。
    mov eax,DWORD PTR [rbp-38H]                    ; 读取 month。地址：4015BEH。
    sub eax,1H                                     ; 月份减 1，转换为数组下标。地址：4015C1H。
    mov eax,eax                                    ; 对 EAX 自赋值，清零 RAX 的高 32 位。地址：4015C4H。
    lea rdx,[rax*4+0H]                             ; RDX = (month-1)*4，每个 unsigned int 占 4 字节。地址：4015C6H。
    lea rax,[rip+3A2BH]                            ; 取得 month_days 数组地址。地址：4015CEH。
    mov ebx,DWORD PTR [rdx+rax*1]                  ; EBX 保存该月平年天数，调用 is_leap 后仍然保留。地址：4015D5H。
    cmp DWORD PTR [rbp-38H],2H                     ; 检查月份是否为 2。地址：4015D8H。
    jne loc_4015e8                                 ; 非二月跳过闰年计算。地址：4015DCH。
    mov ecx,DWORD PTR [rbp-40H]                    ; 第一参数 ECX = year。地址：4015DEH。
    call is_leap                                   ; 调用 is_leap，EAX 返回是否闰年。地址：4015E1H。
    jmp loc_4015ed                                 ; 跳到天数相加处。地址：4015E6H。

loc_4015e8:
    mov eax,0H                                     ; 非二月不追加天数，EAX = 0。地址：4015E8H。

loc_4015ed:
    add eax,ebx                                    ; 返回值 = 基础天数 + 闰年二月增加的 1 天。地址：4015EDH。
    add rsp,28H                                    ; 释放 40 字节栈空间。地址：4015EFH。
    pop rbx                                        ; 恢复 RBX。地址：4015F3H。
    pop rbp                                        ; 恢复 RBP。地址：4015F4H。
    ret                                            ; 返回调用者。地址：4015F5H。
month_length ENDP

; 全局变量传参。weekday：[RBP-4H]，year：[RBP-8H]，month：[RBP-0CH]。
first_day PROC
    push rbp                                       ; 保存调用者的 RBP。地址：4015F6H。
    mov rbp,rsp                                    ; 建立 first_day 的栈帧。地址：4015F7H。
    sub rsp,30H                                    ; 分配 48 字节，包含局部变量和影子空间。地址：4015FAH。
    mov DWORD PTR [rbp-4H],1H                      ; weekday = 1，以星期一为起点。地址：4015FEH。
    mov DWORD PTR [rbp-8H],76CH                    ; year = 1900。地址：401605H。
    jmp loc_401652                                 ; 先检查年份循环条件。地址：40160CH。

loc_40160e:
    mov eax,DWORD PTR [rbp-8H]                     ; 读取当前循环年份 year。地址：40160EH。
    mov ecx,eax                                    ; 第一参数 ECX = year。地址：401611H。
    call is_leap                                   ; 判断当前年份是否闰年。地址：401613H。
    mov edx,eax                                    ; EDX 暂存闰年标记。地址：401618H。
    mov eax,DWORD PTR [rbp-4H]                     ; 读取 weekday。地址：40161AH。
    add eax,edx                                    ; 加上闰年标记。地址：40161DH。
    lea edx,[rax+1H]                               ; EDX = weekday + is_leap(year) + 1。地址：40161FH。
    mov eax,edx                                    ; EAX = 待对 7 取余的数。地址：401622H。
    imul rax,rax,24924925H                         ; 与常数 24924925H 相乘，开始计算无符号除以 7。地址：401624H。
    shr rax,20H                                    ; 取乘积高 32 位，得到商的初步估计。地址：40162BH。
    mov ecx,edx                                    ; ECX = 原数。地址：40162FH。
    sub ecx,eax                                    ; ECX = 原数 - 初步估计。地址：401631H。
    shr ecx,1                                      ; 将差值逻辑右移 1 位。地址：401633H。
    add eax,ecx                                    ; 与初步估计相加，修正商。地址：401635H。
    shr eax,2H                                     ; 再右移 2 位，得到原数 / 7。地址：401637H。
    mov DWORD PTR [rbp-4H],eax                     ; 暂存商到 weekday 的栈槽。地址：40163AH。
    mov ecx,DWORD PTR [rbp-4H]                     ; ECX = 商。地址：40163DH。
    mov eax,ecx                                    ; EAX = 商。地址：401640H。
    shl eax,3H                                     ; EAX = 8*商。地址：401642H。
    sub eax,ecx                                    ; EAX = 7*商。地址：401645H。
    sub edx,eax                                    ; EDX = 原数 - 7*商，即原数 % 7。地址：401647H。
    mov eax,edx                                    ; EAX = 余数。地址：401649H。
    mov DWORD PTR [rbp-4H],eax                     ; 更新 weekday，保持在 0 至 6。地址：40164BH。
    add DWORD PTR [rbp-8H],1H                      ; ++year。地址：40164EH。

loc_401652:
    mov eax,DWORD PTR [rip+69D8H]                  ; 通过 RIP 相对寻址读取全局 year_value。地址：401652H。
    cmp DWORD PTR [rbp-8H],eax                     ; 比较当前 year 和目标年份。地址：401658H。
    jb loc_40160e                                  ; year < year_value 时继续年份循环。地址：40165BH。
    mov DWORD PTR [rbp-0CH],1H                     ; month = 1。地址：40165DH。
    jmp loc_4016ad                                 ; 先检查月份循环条件。地址：401664H。

loc_401666:
    mov eax,DWORD PTR [rip+69C4H]                  ; 第一参数的值来自全局 year_value。地址：401666H。
    mov edx,DWORD PTR [rbp-0CH]                    ; 第二参数 EDX = 当前 month。地址：40166CH。
    mov ecx,eax                                    ; 第一参数 ECX = 目标年份。地址：40166FH。
    call month_length                              ; 调用 month_length，求前一个月的天数。地址：401671H。
    mov edx,eax                                    ; EDX 暂存该月天数。地址：401676H。
    mov eax,DWORD PTR [rbp-4H]                     ; 读取 weekday。地址：401678H。
    add edx,eax                                    ; EDX = weekday + 当月天数。地址：40167BH。
    mov eax,edx                                    ; EAX = 待对 7 取余的数。地址：40167DH。
    imul rax,rax,24924925H                         ; 乘以除以 7 所用的常数。地址：40167FH。
    shr rax,20H                                    ; 取乘积高 32 位。地址：401686H。
    mov ecx,edx                                    ; ECX = 原数。地址：40168AH。
    sub ecx,eax                                    ; 减去初步商估计。地址：40168CH。
    shr ecx,1                                      ; 差值右移 1 位。地址：40168EH。
    add eax,ecx                                    ; 修正商。地址：401690H。
    shr eax,2H                                     ; 右移 2 位，得到原数 / 7。地址：401692H。
    mov DWORD PTR [rbp-4H],eax                     ; 暂存商。地址：401695H。
    mov ecx,DWORD PTR [rbp-4H]                     ; ECX = 商。地址：401698H。
    mov eax,ecx                                    ; EAX = 商。地址：40169BH。
    shl eax,3H                                     ; EAX = 8*商。地址：40169DH。
    sub eax,ecx                                    ; EAX = 7*商。地址：4016A0H。
    sub edx,eax                                    ; EDX = 原数 % 7。地址：4016A2H。
    mov eax,edx                                    ; EAX = 余数。地址：4016A4H。
    mov DWORD PTR [rbp-4H],eax                     ; 更新 weekday。地址：4016A6H。
    add DWORD PTR [rbp-0CH],1H                     ; ++month。地址：4016A9H。

loc_4016ad:
    mov eax,DWORD PTR [rip+6981H]                  ; 读取全局 month_value。地址：4016ADH。
    cmp DWORD PTR [rbp-0CH],eax                    ; 比较循环月份和目标月份。地址：4016B3H。
    jb loc_401666                                  ; month < month_value 时继续月份循环。地址：4016B6H。
    mov eax,DWORD PTR [rbp-4H]                     ; EAX 返回月初星期列号。地址：4016B8H。
    add rsp,30H                                    ; 释放 48 字节栈空间。地址：4016BBH。
    pop rbp                                        ; 恢复 RBP。地址：4016BFH。
    ret                                            ; 返回调用者。地址：4016C0H。
first_day ENDP

; 前四个参数：[RBP+10H] 至 [RBP+28H]；第五参数 out：[RBP+30H]。
; 局部变量 line：[RBP-70H]，value：[RBP-0CH]，length：[RBP-18H]，i：[RBP-8H]。
read_number PROC
    push rbp                                       ; 保存调用者的 RBP。地址：4016C1H。
    mov rbp,rsp                                    ; 建立 read_number 的栈帧。地址：4016C2H。
    sub rsp,90H                                    ; 分配 144 字节，包含输入数组和调用空间。地址：4016C5H。
    mov QWORD PTR [rbp+10H],rcx                    ; 保存第一参数 prompt。地址：4016CCH。
    mov DWORD PTR [rbp+18H],edx                    ; 保存第二参数 minimum。地址：4016D0H。
    mov DWORD PTR [rbp+20H],r8d                    ; 保存第三参数 maximum。地址：4016D3H。
    mov DWORD PTR [rbp+28H],r9d                    ; 保存第四参数 max_digits。地址：4016D7H。
    mov DWORD PTR [rbp-0CH],0H                     ; 初始化 value = 0。地址：4016DBH。
    mov ecx,1H                                     ; ECX = 1，准备获取 stdout。地址：4016E2H。
    mov rax,QWORD PTR [rip+2982H]                  ; 读取运行时的 __acrt_iob_func 函数指针。地址：4016E7H。
    call rax                                       ; 间接调用，RAX 返回标准输出流。地址：4016EEH。
    mov rdx,rax                                    ; 第二参数 RDX = stdout。地址：4016F0H。
    mov rcx,QWORD PTR [rbp+10H]                    ; 第一参数 RCX = prompt。地址：4016F3H。
    call fputs                                     ; 输出输入提示。地址：4016F7H。
    mov ecx,1H                                     ; ECX = 1，获取 stdout。地址：4016FCH。
    mov rax,QWORD PTR [rip+2968H]                  ; 读取运行时函数指针。地址：401701H。
    call rax                                       ; 间接调用，返回 stdout。地址：401708H。
    mov rcx,rax                                    ; 第一参数 RCX = stdout。地址：40170AH。
    call fflush                                    ; fflush 刷新缓冲，使提示立即显示。地址：40170DH。
    mov ecx,0H                                     ; ECX = 0，准备获取 stdin。地址：401712H。
    mov rax,QWORD PTR [rip+2952H]                  ; 读取运行时函数指针。地址：401717H。
    call rax                                       ; 间接调用，返回 stdin。地址：40171EH。
    mov rdx,rax                                    ; RDX 暂存输入流指针。地址：401720H。
    lea rax,[rbp-70H]                              ; 取得 line 数组地址 [RBP-70H]。地址：401723H。
    mov r8,rdx                                     ; 第三参数 R8 = stdin。地址：401727H。
    mov edx,52H                                    ; 第二参数 EDX = 82，即输入数组容量。地址：40172AH。
    mov rcx,rax                                    ; 第一参数 RCX = line。地址：40172FH。
    call fgets                                     ; 调用 fgets 读取一行。地址：401732H。
    test rax,rax                                   ; 检查读取结果是否为空指针。地址：401737H。
    jne loc_401746                                 ; 成功时继续解析。地址：40173AH。
    mov eax,0H                                     ; 失败时准备返回 0。地址：40173CH。
    jmp loc_401811                                 ; 跳到统一返回处。地址：401741H。

loc_401746:
    mov ecx,0AH                                    ; ECX = 换行符。地址：401746H。
    call putchar                                   ; 输出换行。地址：40174BH。
    lea rax,[rbp-70H]                              ; 取得输入数组地址。地址：401750H。
    lea rdx,[rip+39A5H]                            ; 第二参数 RDX 指向回车、换行字符集合。地址：401754H。
    mov rcx,rax                                    ; 第一参数 RCX = line。地址：40175BH。
    call strcspn                                   ; strcspn 求回车或换行之前的字符个数。地址：40175EH。
    mov QWORD PTR [rbp-18H],rax                    ; 保存 length，size_t 在此平台占 8 字节。地址：401763H。
    cmp QWORD PTR [rbp-18H],0H                     ; 检查 length 是否为 0。地址：401767H。
    je loc_401777                                  ; 空输入返回失败。地址：40176CH。
    mov eax,DWORD PTR [rbp+28H]                    ; 读取 max_digits。地址：40176EH。
    cmp QWORD PTR [rbp-18H],rax                    ; 比较输入长度和最大位数。地址：401771H。
    jbe loc_401781                                 ; 位数合法时继续。地址：401775H。

loc_401777:
    mov eax,0H                                     ; 返回值设置为 0。地址：401777H。
    jmp loc_401811                                 ; 跳到统一返回处。地址：40177CH。

loc_401781:
    mov QWORD PTR [rbp-8H],0H                      ; 初始化 i = 0。地址：401781H。
    jmp loc_4017e2                                 ; 先检查数字解析循环条件。地址：401789H。

loc_40178b:
    lea rax,[rbp-70H]                              ; 取得 line 基址。地址：40178BH。
    mov rdx,QWORD PTR [rbp-8H]                     ; 读取 i。地址：40178FH。
    add rax,rdx                                    ; 计算 &line[i]。地址：401793H。
    movzx eax,BYTE PTR [rax]                       ; 读取一个字符，零扩展到 EAX。地址：401796H。
    cmp al,2FH                                     ; 与 ASCII 2FH 比较，即检查是否小于 '0'。地址：401799H。
    jle loc_4017af                                 ; 字符小于 '0' 时返回失败。地址：40179BH。
    lea rax,[rbp-70H]                              ; 再次取得 line 基址。地址：40179DH。
    mov rdx,QWORD PTR [rbp-8H]                     ; 读取 i。地址：4017A1H。
    add rax,rdx                                    ; 计算当前字符地址。地址：4017A5H。
    movzx eax,BYTE PTR [rax]                       ; 读取 line[i]。地址：4017A8H。
    cmp al,39H                                     ; 与 '9' 比较。地址：4017ABH。
    jle loc_4017b6                                 ; 字符不大于 '9' 时进入数值累加。地址：4017ADH。

loc_4017af:
    mov eax,0H                                     ; 返回值设置为 0。地址：4017AFH。
    jmp loc_401811                                 ; 非数字输入跳到返回处。地址：4017B4H。

loc_4017b6:
    mov edx,DWORD PTR [rbp-0CH]                    ; EDX = value。地址：4017B6H。
    mov eax,edx                                    ; EAX = value。地址：4017B9H。
    shl eax,2H                                     ; EAX = 4*value。地址：4017BBH。
    add eax,edx                                    ; EAX = 5*value。地址：4017BEH。
    add eax,eax                                    ; EAX = 10*value。地址：4017C0H。
    mov ecx,eax                                    ; ECX 暂存 10*value。地址：4017C2H。
    lea rax,[rbp-70H]                              ; 取得 line 基址。地址：4017C4H。
    mov rdx,QWORD PTR [rbp-8H]                     ; 读取 i。地址：4017C8H。
    add rax,rdx                                    ; 定位当前字符。地址：4017CCH。
    movzx eax,BYTE PTR [rax]                       ; 读取 line[i]。地址：4017CFH。
    movsx eax,al                                   ; 将 char 扩展为 int；此前已经确认字符为数字。地址：4017D2H。
    add eax,ecx                                    ; 与 10*value 相加。地址：4017D5H。
    sub eax,30H                                    ; 减去 '0' 的 ASCII 码，得到新 value。地址：4017D7H。
    mov DWORD PTR [rbp-0CH],eax                    ; 保存 value。地址：4017DAH。
    add QWORD PTR [rbp-8H],1H                      ; ++i。地址：4017DDH。

loc_4017e2:
    mov rax,QWORD PTR [rbp-8H]                     ; 读取当前下标 i。地址：4017E2H。
    cmp rax,QWORD PTR [rbp-18H]                    ; 比较 i 与 length。地址：4017E6H。
    jb loc_40178b                                  ; i < length 时继续。地址：4017EAH。
    mov eax,DWORD PTR [rbp-0CH]                    ; 读取 value。地址：4017ECH。
    cmp eax,DWORD PTR [rbp+18H]                    ; 与 minimum 比较。地址：4017EFH。
    jb loc_4017fc                                  ; 低于下限时返回失败。地址：4017F2H。
    mov eax,DWORD PTR [rbp-0CH]                    ; 再次读取 value。地址：4017F4H。
    cmp eax,DWORD PTR [rbp+20H]                    ; 与 maximum 比较。地址：4017F7H。
    jbe loc_401803                                 ; 未超过上限时保存结果。地址：4017FAH。

loc_4017fc:
    mov eax,0H                                     ; 返回值设置为 0。地址：4017FCH。
    jmp loc_401811                                 ; 范围无效，跳到返回处。地址：401801H。

loc_401803:
    mov rax,QWORD PTR [rbp+30H]                    ; 读取第五参数 out，它由调用者通过栈传入，位于 [RBP+30H]。地址：401803H。
    mov edx,DWORD PTR [rbp-0CH]                    ; EDX = value。地址：401807H。
    mov DWORD PTR [rax],edx                        ; *out = value。地址：40180AH。
    mov eax,1H                                     ; 返回 1，表示读取成功。地址：40180CH。

loc_401811:
    add rsp,90H                                    ; 释放 144 字节栈空间。地址：401811H。
    pop rbp                                        ; 恢复 RBP。地址：401818H。
    ret                                            ; 返回调用者。地址：401819H。
read_number ENDP

; year、month、days、weekday 依次保存到 [RBP+10H]、[RBP+18H]、[RBP+20H]、[RBP+28H]。
; 局部变量 column：[RBP-4H]，day：[RBP-8H]，i：[RBP-0CH]。
print_calendar PROC
    push rbp                                       ; 保存调用者的 RBP。地址：40181AH。
    mov rbp,rsp                                    ; 建立 print_calendar 的栈帧。地址：40181BH。
    sub rsp,30H                                    ; 分配 48 字节。地址：40181EH。
    mov DWORD PTR [rbp+10H],ecx                    ; 保存第一参数 year。地址：401822H。
    mov DWORD PTR [rbp+18H],edx                    ; 保存第二参数 month。地址：401825H。
    mov DWORD PTR [rbp+20H],r8d                    ; 保存第三参数 days。地址：401828H。
    mov DWORD PTR [rbp+28H],r9d                    ; 保存第四参数 weekday。地址：40182CH。
    mov eax,DWORD PTR [rbp+28H]                    ; 读取 weekday。地址：401830H。
    mov DWORD PTR [rbp-4H],eax                     ; 初始化 column = weekday。地址：401833H。
    mov eax,DWORD PTR [rbp+18H]                    ; 读取 month。地址：401836H。
    sub eax,1H                                     ; 转为从 0 开始的月份下标。地址：401839H。
    mov eax,eax                                    ; 清零 RAX 高 32 位。地址：40183CH。
    lea rdx,[rax*8+0H]                             ; 每个月份名指针占 8 字节，计算指针数组偏移。地址：40183EH。
    lea rax,[rip+3853H]                            ; 取得 month_names 基址。地址：401846H。
    mov rax,QWORD PTR [rdx+rax*1]                  ; 读取对应月份名指针。地址：40184DH。
    mov r8,rax                                     ; printf 第三参数 R8 = 月份名。地址：401851H。
    mov edx,DWORD PTR [rbp+10H]                    ; printf 第二参数 EDX = year。地址：401854H。
    lea rcx,[rip+38A5H]                            ; 第一参数 RCX 指向标题和星期表头格式串。地址：401857H。
    call printf                                    ; 输出年份、月份名和星期表头。地址：40185EH。
    mov DWORD PTR [rbp-0CH],0H                     ; 初始化前导空格循环的 i = 0。地址：401863H。
    jmp loc_401898                                 ; 先检查循环条件。地址：40186AH。

loc_40186c:
    mov ecx,1H                                     ; ECX = 1，获取 stdout。地址：40186CH。
    mov rax,QWORD PTR [rip+27F8H]                  ; 读取运行时函数指针。地址：401871H。
    call rax                                       ; 间接调用并返回 stdout。地址：401878H。
    mov r9,rax                                     ; fwrite 的第四参数 R9 = stdout。地址：40187AH。
    mov r8d,3H                                     ; 第三参数 R8D = 3，输出三个空格。地址：40187DH。
    mov edx,1H                                     ; 第二参数 EDX = 1，每项一个字节。地址：401883H。
    lea rcx,[rip+3892H]                            ; 第一参数 RCX 指向三个空格。地址：401888H。
    call fwrite                                    ; 输出一个空白日期格。地址：40188FH。
    add DWORD PTR [rbp-0CH],1H                     ; ++i。地址：401894H。

loc_401898:
    mov eax,DWORD PTR [rbp-0CH]                    ; 读取 i。地址：401898H。
    cmp eax,DWORD PTR [rbp+28H]                    ; 比较 i 与月初列号 weekday。地址：40189BH。
    jb loc_40186c                                  ; i < weekday 时继续补空格。地址：40189EH。
    mov DWORD PTR [rbp-8H],1H                      ; 初始化 day = 1。地址：4018A0H。
    jmp loc_4018ed                                 ; 先检查日期循环条件。地址：4018A7H。

loc_4018a9:
    mov eax,DWORD PTR [rbp-8H]                     ; 读取 day。地址：4018A9H。
    mov edx,eax                                    ; printf 第二参数 EDX = day。地址：4018ACH。
    lea rcx,[rip+3870H]                            ; 第一参数 RCX 指向宽度为 2 的无符号整数格式串。地址：4018AEH。
    call printf                                    ; 输出右对齐的日期。地址：4018B5H。
    add DWORD PTR [rbp-4H],1H                      ; ++column。地址：4018BAH。
    cmp DWORD PTR [rbp-4H],7H                      ; 检查是否已输出满 7 列。地址：4018BEH。
    jne loc_4018d7                                 ; 未满一周时跳到格间空格处理。地址：4018C2H。
    mov ecx,0AH                                    ; ECX = 换行符。地址：4018C4H。
    call putchar                                   ; 周六结束后换行。地址：4018C9H。
    mov DWORD PTR [rbp-4H],0H                      ; column = 0，新的一周从星期日开始。地址：4018CEH。
    jmp loc_4018e9                                 ; 跳到日期递增处。地址：4018D5H。

loc_4018d7:
    mov eax,DWORD PTR [rbp-8H]                     ; 读取 day。地址：4018D7H。
    cmp eax,DWORD PTR [rbp+20H]                    ; 比较 day 与总天数。地址：4018DAH。
    jae loc_4018e9                                 ; 最后一天后跳过格间空格。地址：4018DDH。
    mov ecx,20H                                    ; ECX = 空格字符。地址：4018DFH。
    call putchar                                   ; 输出日期之间的空格。地址：4018E4H。

loc_4018e9:
    add DWORD PTR [rbp-8H],1H                      ; ++day。地址：4018E9H。

loc_4018ed:
    mov eax,DWORD PTR [rbp-8H]                     ; 读取 day。地址：4018EDH。
    cmp eax,DWORD PTR [rbp+20H]                    ; 与总天数比较。地址：4018F0H。
    jbe loc_4018a9                                 ; day <= days 时继续输出。地址：4018F3H。
    cmp DWORD PTR [rbp-4H],0H                      ; 检查最后一行是否已经换行。地址：4018F5H。
    je loc_401905                                  ; column = 0 时跳过补充换行。地址：4018F9H。
    mov ecx,0AH                                    ; ECX = 换行符。地址：4018FBH。
    call putchar                                   ; 给未满一周的最后一行补上换行。地址：401900H。

loc_401905:
    nop                                            ; 编译器生成的空操作。地址：401905H。
    add rsp,30H                                    ; 释放 48 字节栈空间。地址：401906H。
    pop rbp                                        ; 恢复 RBP。地址：40190AH。
    ret                                            ; 返回调用者。地址：40190BH。
print_calendar ENDP

; days：[RBP-4H]，weekday：[RBP-8H]。第五参数使用调用前的 [RSP+20H]。
main PROC
    push rbp                                       ; 保存调用者的 RBP。地址：40190CH。
    mov rbp,rsp                                    ; 建立 main 的栈帧。地址：40190DH。
    sub rsp,40H                                    ; 分配 64 字节，包含局部变量、影子空间和第五参数位置。地址：401910H。
    call __main                                    ; 调用 MinGW 运行时初始化辅助函数。地址：401914H。
    lea rax,[rip+6710H]                            ; 取得全局 year_value 的地址。地址：401919H。
    mov QWORD PTR [rsp+20H],rax                    ; 第五参数 &year_value 写入调用前的 [RSP+20H]。地址：401920H。
    mov r9d,4H                                     ; 第四参数 R9D = 4，年份最多 4 位。地址：401925H。
    mov r8d,833H                                   ; 第三参数 R8D = 2099。地址：40192BH。
    mov edx,76CH                                   ; 第二参数 EDX = 1900。地址：401931H。
    lea rcx,[rip+37F3H]                            ; 第一参数 RCX 指向年份输入提示。地址：401936H。
    call read_number                               ; 调用 read_number 读取年份。地址：40193DH。
    test eax,eax                                   ; 检查返回值。地址：401942H。
    je loc_401973                                  ; 失败时直接进入错误分支，体现逻辑或的短路求值。地址：401944H。
    lea rax,[rip+66E7H]                            ; 取得全局 month_value 的地址。地址：401946H。
    mov QWORD PTR [rsp+20H],rax                    ; 第五参数 &month_value 写入栈上的参数位置。地址：40194DH。
    mov r9d,2H                                     ; 第四参数 R9D = 2，月份最多 2 位。地址：401952H。
    mov r8d,0CH                                    ; 第三参数 R8D = 12。地址：401958H。
    mov edx,1H                                     ; 第二参数 EDX = 1。地址：40195EH。
    lea rcx,[rip+37E6H]                            ; 第一参数 RCX 指向月份输入提示。地址：401963H。
    call read_number                               ; 调用 read_number 读取月份。地址：40196AH。
    test eax,eax                                   ; 检查返回值。地址：40196FH。
    jne loc_401986                                 ; 成功时进入日历计算分支。地址：401971H。

loc_401973:
    lea rcx,[rip+37F2H]                            ; RCX 指向输入错误提示。地址：401973H。
    call puts                                      ; 输出错误提示。地址：40197AH。
    mov eax,1H                                     ; 设置返回值为 1。地址：40197FH。
    jmp loc_4019c9                                 ; 跳到 main 的统一返回处。地址：401984H。

loc_401986:
    mov edx,DWORD PTR [rip+66A8H]                  ; 第二参数 EDX = month_value。地址：401986H。
    mov eax,DWORD PTR [rip+669EH]                  ; 读取 year_value。地址：40198CH。
    mov ecx,eax                                    ; 第一参数 ECX = year_value。地址：401992H。
    call month_length                              ; 调用 month_length 取得当月天数。地址：401994H。
    mov DWORD PTR [rbp-4H],eax                     ; 保存 days，位于 [RBP-4H]。地址：401999H。
    call first_day                                 ; 调用 first_day，通过全局变量传参。地址：40199CH。
    mov DWORD PTR [rbp-8H],eax                     ; 保存 weekday，位于 [RBP-8H]。地址：4019A1H。
    mov edx,DWORD PTR [rip+668AH]                  ; 读取 month_value。地址：4019A4H。
    mov eax,DWORD PTR [rip+6680H]                  ; 读取 year_value。地址：4019AAH。
    mov r8d,DWORD PTR [rbp-8H]                     ; R8D 暂存 weekday。地址：4019B0H。
    mov ecx,DWORD PTR [rbp-4H]                     ; ECX 暂存 days。地址：4019B4H。
    mov r9d,r8d                                    ; 第四参数 R9D = weekday。地址：4019B7H。
    mov r8d,ecx                                    ; 第三参数 R8D = days。地址：4019BAH。
    mov ecx,eax                                    ; 第一参数 ECX = year，第二参数 EDX 已为 month。地址：4019BDH。
    call print_calendar                            ; 调用 print_calendar 输出月历。地址：4019BFH。
    mov eax,0H                                     ; 设置返回值为 0。地址：4019C4H。

loc_4019c9:
    add rsp,40H                                    ; 释放 64 字节栈空间。地址：4019C9H。
    pop rbp                                        ; 恢复 RBP。地址：4019CDH。
    ret                                            ; 返回运行时调用者。地址：4019CEH。
    nop                                            ; RET 之后的对齐填充。地址：4019CFH。
main ENDP
END
