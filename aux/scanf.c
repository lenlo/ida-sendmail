/*
**  SCANF -- Program to scan & extract input lines.
**  Copyright (c) 1987, 1988 Lennart Lovstrand
**  CIS Dept, Univ of Linkoping, Sweden
**
**  Use it, abuse it, but don't sell it.
**
**  Very simple version 0.11 of Tue Aug 23 12:01:10 BST 1988
*/

#include "useful.h"
#include <stdio.h>
#include <ctype.h>

main(argc, argv)
    int argc;
    char **argv;
{
    char buf[BUFSIZ], val[BUFSIZ];
    FILE *input;
    bool ignore_case = FALSE;

    if (argc > 1 && strcmp(argv[1], "-i") == 0) {
	ignore_case = TRUE;
	argc--; argv++;
    }

    if (argc < 2 || argc > 3) {
	fprintf(stderr, "usage: scanf [-i] scanf_pattern [file]\n");
	exit(1);
    }

    if (ignore_case)
	lower(argv[1]);

    if (argc == 2)
	input = stdin;
    else {
	input = fopen(argv[2], "r");
	if (input == NULL) {
	    perror(argv[2]);
	    exit(1);
	}
    }

    while (fgets(buf, sizeof(buf), input) != NULL) {
	if (ignore_case)
	    lower(buf);
	if (sscanf(buf, argv[1], val) == 1)
	    puts(val);
    }
}

lower(p)
    register char *p;
{
    for (; *p != '\0'; p++)
	if (isupper(*p))
	    *p = tolower(*p);
}
