#include <stdio.h>

/* 作业 4（二）：全局数组版本。数组具有静态存储期，位于程序的数据区。 */
unsigned char table[9][9] = {
    {7, 2, 3, 4, 5, 6, 7, 8, 9},
    {2, 4, 7, 8, 10, 12, 14, 16, 18},
    {3, 6, 9, 12, 15, 18, 21, 24, 27},
    {4, 8, 12, 16, 7, 24, 28, 32, 36},
    {5, 10, 15, 20, 25, 30, 35, 40, 45},
    {6, 12, 18, 24, 30, 7, 42, 48, 54},
    {7, 14, 21, 28, 35, 42, 49, 56, 63},
    {8, 16, 24, 32, 40, 48, 56, 7, 72},
    {9, 18, 27, 36, 45, 54, 63, 72, 81}
};

static void print_error(int x, int y)
{
    printf("%d %d  error\n", x, y);       /* 显示从 1 开始的行号和列号。 */
}

int main(void)
{
    int row;
    int column;

    puts("x y");
    for (row = 0; row < 9; ++row) {
        for (column = 0; column < 9; ++column) {
            /* 每项占 1 字节，偏移为 row * 9 + column。 */
            if (table[row][column] != (row + 1) * (column + 1)) {
                print_error(row + 1, column + 1);
            }
        }
    }
    puts("\naccomplish!");

    return 0;
}
