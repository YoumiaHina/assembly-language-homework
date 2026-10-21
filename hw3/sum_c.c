#include <stdio.h>

/* 作业 3（3）：用循环计算 1+2+...+100，再输出十进制结果。 */
int main(void)
{
    unsigned int sum = 0;             /* 保存累加结果，最大值为 5050。 */
    unsigned int i;

    for (i = 1; i <= 100; ++i) {
        sum += i;                     /* 对应汇编中的累加指令。 */
    }

    printf("%u\n", sum);              /* %u 以无符号十进制格式输出。 */
    return 0;
}
