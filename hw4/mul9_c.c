#include <stdio.h>

/* 作业 4：用函数调用和双重循环输出倒三角九九乘法表。 */
static void print_item(int row, int column)
{
    int product = row * column;          /* 对应汇编中的乘法指令。 */

    printf("%d*%d=%d", row, column, product);
    if (column < row) {                  /* 每行最后一项后面不加空格。 */
        if (product < 10) {
            printf("   ");               /* 一位数算式长 5，补足到 8 个字符。 */
        } else {
            printf("  ");                /* 两位数算式长 6，补足到 8 个字符。 */
        }
    }
}

int main(void)
{
    int row;                            /* 外层：被乘数从 9 递减到 1。 */
    int column;                         /* 内层：乘数从 1 递增到 row。 */

    puts("The 9mul9 table:");
    for (row = 9; row >= 1; --row) {
        for (column = 1; column <= row; ++column) {
            print_item(row, column);     /* 显式调用自定义函数。 */
        }
        putchar('\n');                  /* 一行输出完毕后换行。 */
    }

    return 0;
}
