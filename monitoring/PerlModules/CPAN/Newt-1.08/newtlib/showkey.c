#include <stdio.h>
#include <slang.h>

int main(void) {
    char n = 0;
    int i;
    char * buf;

    SLtt_get_terminfo();
    SLang_init_tty(4, 0, 0);

    buf = SLtt_tgetstr("ku");
    if (!buf) {
	printf("termcap entry not found for kl\n\r");
    } else {
	printf("termcap entry found for kl: %s", buf);
	while (*buf) {
	    printf("0x%02x ", *buf++);
	}
	printf("\n\r");
    }

    printf("\n\r");

    printf("Press a key: ");
    fflush(stdout);
   
    SLang_input_pending(50);

    printf("\n\r");
    printf("You pressed: ");

    while (SLang_input_pending(1)) {
	i = SLang_getkey();
	printf("0x%02x ", i);
    }

    printf("\n\r");

    SLang_reset_tty();
}
