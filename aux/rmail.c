/*
**  RMAIL -- Receive remote mail requests.
**  Copyright (c) 1987 Lennart Lovstrand
**  CIS Dept, Univ of Linkoping, Sweden
**
**  Use it, abuse it, but don't sell it.
**
**  Version 2.6 of 5-May-87.
**
**  This time logging selected header lines + more liberal parsing of
**  the initial from-line but not yet with accounting & like; 14-Apr-85.
**  Dbm lookup of UUCP domain names added 5-May-87.
**
**  The following definitions below are optional:
**	LOGFILE -- If defined, should be the name of a file in which to
**		log the raw addresses of each message.
**	DEFAULT_HOST -- If no host is found in the envelope recipients,
**		this host is assumed [defaults to your local host].
**	DEFAULT_DOMAIN -- If the sending host is unqualifed, add this
**		domain to the host for use in the Received: line.
**	DOMAINTABLE -- If defined, should point to your local domain
**		lookup database.  It is used for the same purpose as
**		the DEFAULT_DOMAIN.
*/

#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>
#include <sys/time.h>
#include <strings.h>
#ifdef MDBM
# include "mdbm_compat.h"
#else MDBM
# include <ndbm.h>
# define DBMFILE DBM
#endif MDBM
#include "useful.h"

#define STRSIZ		1024
#define COMMA		','
/* #define LOGFILE		"/usr/lib/uucp/rmail.log" */
#define SENDMAIL	"/usr/lib/sendmail"
#define NETCHRS		"%@!:"
/* #define DEFAULT_HOST	"liuida" */
#define DEFAULT_DOMAIN	"UUCP"
/* #define DOMAINTABLE	"/usr/lib/mail/domaintable" */

#define H_CC		"cc"
#define H_FROM		"from"
#define H_MESSAGE_ID	"message_id"
#define H_RETURN_PATH	"return-path"
#define H_TO		"to"
#define H_VIA		"via"

#define MAKELC(C)	(isupper(C) ? tolower(C) : C)
#define EATSPACE(P)	while (*P == ' ') P++

FILE *popen();
char *Progname;
int Debug = FALSE;
DBMFILE	*Dbm;

main(argc, argv)
    int argc;
    char **argv;
{
    char from_[STRSIZ], cmd[STRSIZ], s_mac[STRSIZ], f_opt[STRSIZ], s[STRSIZ];
    char *v_opt = "";
    char *p, *user, *host, *domain = "";
    char *acctsys = (char *) getenv("ACCTSYS");
    FILE *outf;
#ifdef LOGFILE
    FILE *logf = NULL;
#endif LOGFILE
#ifdef DOMAINTABLE
    datum key, val;
#endif DOMAINTABLE
    int insideheader, printedlast = FALSE;
    int c, errflg = FALSE;
    
    extern int optind;
    extern char *optarg;

#ifdef DEFAULT_DOMAIN
    domain = DEFAULT_DOMAIN;
#endif DEFAULT_DOMAIN

    Progname = argv[0];
    while ((c = getopt(argc, argv, "D:dv")) != EOF) {
	switch (c) {
	  case 'D':
	    domain = optarg;
	    break;
	  case 'd':
	    Debug++;
	    break;
	  case 'v':
	    v_opt = " -v";
	    break;
	  default:
	    errflg = TRUE;
	    break;
	}
    }
    if (errflg || optind >= argc) {
	(void) fprintf(stderr, "usage: %s [-Ddomain] user ...\n", Progname);
	exit(2);
    }

    /*
     * set our real uid to root as well as our effective uid so
     * make sendmail accept the -oM options
     */
    (void) setreuid(0, 0);

#ifdef DOMAINTABLE
    Dbm = dbm_open(DOMAINTABLE, O_RDONLY);
    if (Dbm == NULL)
	perror(DOMAINTABLE);
#endif DOMAINTABLE

#ifdef LOGFILE
    if ((logf = fopen(Debug ? "/dev/tty" : LOGFILE, "a")) != NULL) {
	struct timeval t;
	int a;

	(void) gettimeofday(&t, (struct timezone *) NULL);
	(void) fprintf(logf, "\n[%.12s] ", ctime(&t.tv_sec) + 4);
	for (a = 0; a < argc; a++)
	    (void) fprintf(logf, " '%s'", argv[a]);
	(void) putc('\n', logf);
    } else
	(void) fprintf(stderr, "%s: couldn't open log file \"%s\"\n",
		       Progname, LOGFILE);
#endif LOGFILE

    user = NULL;
    host = NULL;
    (void) gets(from_);

#ifdef LOGFILE
    if (logf != NULL)
	(void) fprintf(logf, "%s\n", from_);
#endif LOGFILE

    if (strncmp(from_, "From ", 5) == 0 || strncmp(from_, ">From ", 6) == 0) {
	user = index(from_, ' ') + 1;
	EATSPACE(user);
	if ((p = index(user, ' ')) != NULL) {
	    *p = '\0';
	    while ((p = index(p + 1, 'r')) != NULL) {
		if (strncmp(p, "remote from ", 12) == 0) {
		    host = p + 12;
		    EATSPACE(host);
		    if ((p = index(host, '\n')) != NULL)
			*p = '\0';
		    if (strcmp(host, "somewhere") == 0)
			host = NULL;
		    break;
		}
	    }
	}
    }

    if (acctsys == NULL)
	acctsys = host;

    if (host)
	(void) sprintf(f_opt, " -f%s!%s", host, user);
    else if (user)
	(void) sprintf(f_opt, " -f%s", user);
    else
	*f_opt = '\0';

    if (acctsys) {
#ifdef DOMAINTABLE
	if (Dbm != NULL) {
	    key.dptr = acctsys;
	    key.dsize = strlen(acctsys) + 1;
	    val = dbm_fetch(Dbm, key);
	    if (val.dptr != NULL)
		acctsys = val.dptr;
	}
#endif DOMAINTABLE
	if (index(acctsys, '.') == NULL && *domain != '\0')
	    (void) sprintf(s_mac, " -oMs%s.%s", acctsys, domain);
	else
	    (void) sprintf(s_mac, " -oMs%s", acctsys);
    } else
	*s_mac = '\0';

    (void) sprintf(cmd, "exec %s -ee -i -oMrUUCP%s%s%s",
		   SENDMAIL, s_mac, f_opt, v_opt);

    for (; optind < argc; optind++) {
	(void) strcat(cmd, " '");
#ifdef DEFAULT_HOST
	if (anyin(argv[optind], NETCHRS) == NULL) {
	    (void) strcat(cmd, DEFAULT_HOST);
	    (void) strcat(cmd, "!");
	}
#endif DEFAULT_HOST
	if (*argv[optind] == '(')
	    (void) strncat(cmd, &argv[optind][1], strlen(argv[optind])-2);
	else
	    (void) strcat(cmd, argv[optind]);
	(void) strcat(cmd, "'");
    }

#ifdef LOGFILE
    if (logf != NULL)
	(void) fprintf(logf, "%s\n", cmd);
#endif LOGFILE
    if (Debug)
	outf = stdout;
    else {
	outf = popen(cmd, "w");
	if (outf == NULL) {
	    (void) fprintf(stderr, "%s: could not open pipe thru %s\n",
			   Progname, cmd);
	    exit(1);
	}
    }

    insideheader = TRUE;
    while (gets(s)) {
	if (*s == NULL)
	    insideheader = FALSE;

#ifdef LOGFILE
	if (logf != NULL && insideheader &&
	    ((printedlast && isspace(*s)) ||
	     iskey(H_FROM, s) || iskey(H_TO, s) || iskey(H_CC, s) ||
	     iskey(H_RETURN_PATH, s) || iskey(H_MESSAGE_ID, s))) {
		 (void) fprintf(logf, "\t%s\n", s);
		 printedlast = TRUE;
	     } else
		 printedlast = FALSE;
#endif LOGFILE
	(void) fprintf(outf, "%s\n", s);
    }

#ifdef LOGFILE
    if (logf != NULL)
	(void) fclose(logf);
#endif LOGFILE

    if (!Debug)
	exit((pclose(outf) >> 8) & 0377);
}

/*
**	ANYIN -- Does the target string contain chars from the pattern string?
*/
anyin(t, p)
    char *t;
    register char *p;
{
    for (; *p != '\0'; p++)
	if (index(t, *p) != NULL)
	    return TRUE;
    return FALSE;
}

/*
**	ISKEY -- Checks if the line is prefixed by the supplied keyword
**	(immediately followed by a colon)
*/
iskey(key, line)
    char *key, *line;
{
    for (; *key != NULL && *line != NULL; key++, line++)
	if (MAKELC(*key) != MAKELC(*line))
	    break;

    return *key == NULL && *line == ':';
}

/*
**	EXTRACT_ADDRESS -- Finds and extracts the machine address part
**	of an address field.
*/

char *
extract_address(field, address)
    char *field, *address;
{
    char *address_start = address;

    while(*field && *field != COMMA && *field != '>')
	switch (*field) {
	  case '<':
	    return extract_address(field, address_start);
	  case '(':
	    while (*field && *field != ')');
	    field++;
	    break;
	  case '"':
	    do
		*address++ = *field++;
	    while (*field && *field != '"');
	    if (*field)
		*address++ = *field++;
	    break;
	  case ' ':
	    *address++ = *field++;
	    EATSPACE(field);
	    break;
	  case '\\':
	    *address++ = *field++;
	    /* fall through */
	  default:
	    *address++ = *field++;
	}
    *address = NULL;
    if (*field)
	return index(field, COMMA)+1;
    else
	return field;
}


