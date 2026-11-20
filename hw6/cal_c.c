#include <stdio.h>
#include <string.h>

/* 数据段传参：first_day 直接读取这两个全局变量。 */
static unsigned int year_value;
static unsigned int month_value;
static const unsigned int month_days[12] = {
    31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
};
static const char *const month_names[12] = {
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
};

/* 公历闰年规则，1900 年是平年，2000 年是闰年。 */
static unsigned int is_leap(unsigned int year)
{
    return year % 400 == 0 || (year % 4 == 0 && year % 100 != 0);
}

/* 对应汇编版的栈传参过程，返回指定月份的天数。 */
static unsigned int month_length(unsigned int year, unsigned int month)
{
    return month_days[month - 1] + (month == 2 ? is_leap(year) : 0);
}

/* 从星期一开始逐年、逐月累加；星期日的列号为 0。 */
static unsigned int first_day(void)
{
    unsigned int weekday = 1;
    unsigned int year;
    unsigned int month;

    for (year = 1900; year < year_value; ++year) {
        weekday = (weekday + 1 + is_leap(year)) % 7;
    }
    for (month = 1; month < month_value; ++month) {
        weekday = (weekday + month_length(year_value, month)) % 7;
    }
    return weekday;
}

/* 按位解析输入，拒绝空行、非数字、超长输入和越界数值。 */
static int read_number(const char *prompt, unsigned int minimum,
                       unsigned int maximum, unsigned int max_digits,
                       unsigned int *out)
{
    char line[82];
    size_t length;
    size_t i;
    unsigned int value = 0;

    fputs(prompt, stdout);
    fflush(stdout);
    if (fgets(line, sizeof line, stdin) == NULL) {
        return 0;
    }
    putchar('\n');
    length = strcspn(line, "\r\n");
    if (length == 0 || length > max_digits) {
        return 0;
    }
    for (i = 0; i < length; ++i) {
        if (line[i] < '0' || line[i] > '9') {
            return 0;
        }
        value = value * 10 + (unsigned int)(line[i] - '0');
    }
    if (value < minimum || value > maximum) {
        return 0;
    }
    *out = value;
    return 1;
}

/* 每格两位数字，格间一个空格，周六结束后换行。 */
static void print_calendar(unsigned int year, unsigned int month,
                           unsigned int days, unsigned int weekday)
{
    unsigned int column = weekday;
    unsigned int day;
    unsigned int i;

    printf("\n%u  %s\nSu Mo Tu We Th Fr Sa\n", year, month_names[month - 1]);
    for (i = 0; i < weekday; ++i) {
        fputs("   ", stdout);
    }
    for (day = 1; day <= days; ++day) {
        printf("%2u", day);
        ++column;
        if (column == 7) {
            putchar('\n');
            column = 0;
        } else if (day < days) {
            putchar(' ');
        }
    }
    if (column != 0) {
        putchar('\n');
    }
}

int main(void)
{
    unsigned int days;
    unsigned int weekday;

    if (!read_number("Please input year (1900-2099): ", 1900, 2099, 4,
                     &year_value) ||
        !read_number("Please input month (1-12): ", 1, 12, 2, &month_value)) {
        puts("Invalid input.");
        return 1;
    }
    days = month_length(year_value, month_value);
    weekday = first_day();
    print_calendar(year_value, month_value, days, weekday);
    return 0;
}
