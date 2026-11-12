#include <stdint.h>
#include <stdio.h>

/* 使用 5 个 16 位字完整保存 F(100)，按低字到高字排列。 */
typedef struct {
    uint16_t word[5];
} BigInt;

static BigInt memo[101] = {{{0}}, {{1}}};
static unsigned char ready[101] = {1, 1};

/* 按 F(n) = F(n-1) + F(n-2) 递归求解，并缓存已计算的结果。 */
static void fib(unsigned int n, BigInt *out)
{
    BigInt left;
    BigInt right;
    uint32_t carry = 0;
    unsigned int i;

    if (!ready[n]) {
        fib(n - 1, &left);
        fib(n - 2, &right);
        for (i = 0; i < 5; ++i) {
            uint32_t sum = (uint32_t)left.word[i] + right.word[i] + carry;
            memo[n].word[i] = (uint16_t)sum;
            carry = sum >> 16;
        }
        ready[n] = 1;
    }
    *out = memo[n];
}

/* 使用多字长除法反复除以 10，与 DOS 版本的 PRINT_BIG 对应。 */
static void print_big(const BigInt *value)
{
    BigInt work = *value;
    char digits[26];
    char *p = digits + sizeof digits - 1;
    unsigned int nonzero;

    *p = '\0';
    do {
        uint32_t remainder = 0;
        int i;

        nonzero = 0;
        for (i = 4; i >= 0; --i) {
            uint32_t part = (remainder << 16) | work.word[i];
            work.word[i] = (uint16_t)(part / 10);
            remainder = part % 10;
            nonzero |= work.word[i];
        }
        *--p = (char)('0' + remainder);
    } while (nonzero);
    fputs(p, stdout);
}

/* 读取 1 至 3 个十进制数字，并检查数值范围 1 <= n <= 100。 */
static int read_n(unsigned int *out)
{
    char line[128];
    unsigned int n = 0;
    unsigned int i = 0;

    if (fgets(line, sizeof line, stdin) == NULL) {
        return 0;
    }
    while (line[i] != '\0' && line[i] != '\n' && line[i] != '\r') {
        if (i == 3 || line[i] < '0' || line[i] > '9') {
            return 0;
        }
        n = n * 10 + (unsigned int)(line[i] - '0');
        ++i;
    }
    if (i == 0 || n < 1 || n > 100) {
        return 0;
    }
    *out = n;
    return 1;
}

int main(void)
{
    unsigned int n;
    BigInt result;

    fputs("n (1..100): ", stdout);
    fflush(stdout);
    if (!read_n(&n)) {
        puts("\nInvalid input: enter an integer from 1 to 100.");
        return 1;
    }
    putchar('\n');
    fib(n, &result);
    printf("F(%u) = ", n);
    print_big(&result);
    putchar('\n');
    return 0;
}
