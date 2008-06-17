#!/bin/sh -
#
# $Id: chk.nl,v 1.1.1.1 2002-01-11 00:21:35 apingel Exp $
#
# Check to make sure that there are no trailing newlines in __db_err calls.

# Run from the build directory.
[ -f db_config.h ] || {
	echo 'chk.code must be run from a build directory.'
	exit 1
}

cat << END_OF_CODE > t.c
#include <sys/types.h>

#include <errno.h>
#include <stdio.h>

void chk(FILE *, char *);

int
main(argc, argv)
	int argc;
	char *argv[];
{
	FILE *fp;

	while (*++argv != NULL) {
		if ((fp = fopen(*argv, "r")) == NULL) {
			fprintf(stderr, "%s: %s\n", *argv, strerror(errno));
			return (1);
		}
		chk(fp, *argv);
		(void)fclose(fp);
	}
	return (0);
}

void
chk(fp, name)
	FILE *fp;
	char *name;
{
	int ch, line, q;

	for (ch = 'a', line = 1;;) {
		if ((ch = getc(fp)) == EOF)
			return;
		if (ch == '\n') {
			++line;
			continue;
		}
		if (ch != '_') continue;
		if ((ch = getc(fp)) != '_') continue;
		if ((ch = getc(fp)) != 'd') continue;
		if ((ch = getc(fp)) != 'b') continue;
		if ((ch = getc(fp)) != '_') continue;
		if ((ch = getc(fp)) != 'e') continue;
		if ((ch = getc(fp)) != 'r') continue;
		if ((ch = getc(fp)) != 'r') continue;
		while ((ch = getc(fp)) != '"') {
			if (ch == EOF)
				return;
			if (ch == '\n')
				++line;
		}
		while ((ch = getc(fp)) != '"') {
			if (ch == EOF)
				return;
			if (ch == '\n')
				++line;
			if (ch == '\\\\')
				if ((ch = getc(fp)) != 'n')
					ungetc(ch, fp);
				else if ((ch = getc(fp)) != '"')
					ungetc(ch, fp);
				else
			printf("%s: <newline> at line %d\n", name, line);
		}
	}
}
END_OF_CODE

cc t.c -o t
./t ../*/*.[ch] ../*/*.cpp ../*/*.in
