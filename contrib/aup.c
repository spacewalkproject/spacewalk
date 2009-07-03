#include <auparse.h>
#include <err.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int
main(int argc, char *argv[]) {
	auparse_state_t *aup_state;
	FILE *aufile = stdin;

	if (argc > 1
	    && strcmp(argv[1], "-")
	    && (!(aufile = fopen(argv[1], "r")))) {
		errx(EXIT_FAILURE, "failed fopen");
	}

	if ( (aup_state = auparse_init(AUSOURCE_FILE_POINTER, aufile)) == NULL) {
		errx(EXIT_FAILURE, "failed auparse_init");
	}

	while(auparse_next_event(aup_state) > 0) {
		printf("serial=%lu\n", auparse_get_serial(aup_state));
		printf("seconds=%lu\n", auparse_get_time(aup_state));

		do {
			do {
				printf("%s=%s\n",
					auparse_get_field_name(aup_state),
					auparse_interpret_field(aup_state)
				);
			} while(auparse_next_field(aup_state) > 0);

			printf("\n");
		} while(auparse_next_record(aup_state) > 0);
	}

	auparse_destroy(aup_state);

	/*fclose(aufile);*/

	return (0);
}
