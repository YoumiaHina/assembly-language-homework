#include <stdio.h>

/* 作业 2：用两层循环打印小写字母，每行 13 个。 */
int main(void)
{
    int row;                   /* 行计数。 */
    int column;                /* 每行的字母计数。 */
    int letter = 'a';          /* 保存当前字母的 ASCII 码。 */

    for (row = 0; row < 2; ++row) {              /* 共打印两行。 */
        for (column = 0; column < 13; ++column) { /* 每行打印 13 个字母。 */
            putchar(letter);                    /* 输出当前字母。 */
            putchar(' ');                       /* 输出分隔空格。 */
            ++letter;                           /* 移到下一个字母。 */
        }
        putchar('\n');                          /* 每行结束后换行。 */
    }

    return 0;                                   /* 正常结束程序。 */
}
