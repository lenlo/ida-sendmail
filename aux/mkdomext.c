/*
**  MKDOMEXT -- Extend domain names
**  Copyright (c) 1987 Lennart Lovstrand
**  CIS Dept, Univ of Linkoping, Sweden
**
**  Use it, abuse it, but don't sell it.
*/

#include "useful.h"
#include <stdio.h>
#include <ctype.h>

#ifndef lint
static char	SccsId[] = "@(#)mkdomext.c 1.5 (lel@ida.liu.se) 4/24/87";
#endif !lint

void printf(), fprintf();

char *Progname;

main(argc, argv)
     int argc;
     char **argv;
{
    char buf[BUFSIZ];
    char domains[BUFSIZ];
    char *tab, *p, *index();

    Progname = argv[0];

    if (argc == 1) {
	fprintf(stderr, "%s: no domains?\n", Progname);
	exit(1);
    }

    /* collect the argument domain names */
    domains[0] = '\0';
    for (argc--, argv++; argc > 0; argc--, argv++) {
	if (strlen(*argv) + 3 > sizeof(domains)) {
	    fprintf(stderr, "%s: too many domain arguments--\n %s %s %s\n",
		    Progname,
		    "chain two instances of", Progname,
		    "together or recompile with larger ``domains'' array");
	    exit(1);
	}
	(void) strcat(domains, " .");
	(void) strcat(domains, *argv);
    }

    while (gets(buf) != NULL) {
	tab = index(buf, '\t');
	if (tab != NULL)
	    *tab = '\0';

	for (p = index(buf, '.'); p != NULL; p = index(p + 1, '.')) {
	    if (instring(domains, p)) {
		for (; p != NULL; p = index(p + 1, '.')) {
		    *p = '\0';
		    if (tab != NULL)
			printf("%s\t%s\n", buf, tab + 1);
		    else
			printf("%s\n", buf);
		    *p = '.';
		}
		break;
	    }
	}
	if (tab != NULL)
	    *tab = '\t';
	puts(buf);
    }
}

/*
**	INSTRING -- Returns TRUE if the source string ``s'' can be found
**		as a substring in target string ``t''.
*/

instring(t, s)
     char *t, *s;
{
    extern char *index();
    register char *p;
    register int len = strlen(s);

    for (p = index(t, *s); p != NULL; p = index(p + 1, *s))
	if (ispart(p, s, len))
	    return TRUE;
    return FALSE;
}

/*
**	ISPART -- Compare at most the first n chars of two strings
**		without respect to upper/lower case.
*/

ispart(s, t, n)
     register char *s, *t;
     register int n;
{
    for (; n > 0 && *s != '\0' && *t != '\0'; s++, t++, n--)
	if ((isupper(*s) ? tolower(*s) : *s) !=
	    (isupper(*t) ? tolower(*t) : *t))
	    break;
    return (n == 0 || *s == *t); /* really *s == 0 && *t == 0 */
}
