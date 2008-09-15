#include <slang.h>

void printall(int offset) {
    int n = 0;
    int i, j;

    SLsmg_gotorc(0, offset);
    SLsmg_write_string("  0 1 2 3 4 5 6 7 8 9 A B C D E F");
    for (i = 0; i < 16; i++) {
	SLsmg_gotorc(i + 1, offset);
	SLsmg_printf("%x", i);
	for (j = 0; j < 16; j++) {
	    SLsmg_gotorc(i + 1, (j + 1) * 2 + offset);
	    SLsmg_write_char(n++);
	}
    }
}

int main(void) {
    char n = 0;

    SLtt_get_terminfo();

    SLtt_Use_Ansi_Colors = 1;

    SLsmg_init_smg();
    SLang_init_tty(4, 0, 0);

    SLsmg_cls();

    printall(0);
    SLsmg_set_char_set(1);
    printall(40);

    SLsmg_refresh();
    SLang_getkey();

    SLsmg_gotorc(SLtt_Screen_Rows - 1, 0);
    SLsmg_refresh();
    SLsmg_reset_smg();
    SLang_reset_tty();

    return 0;
}
