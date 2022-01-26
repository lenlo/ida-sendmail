/*
**  DBM -- General dbm management tool.
**  Copyright (c) 1987 Lennart Lovstrand
**  CIS Dept, Univ of Linkoping, Sweden
**
**  Use it, abuse it, but don't sell it.
*/

#include "useful.h"
#include <stdio.h>
#include <ctype.h>
#include <sys/file.h>
#ifdef MDBM
# include "mdbm_compat.h"
#else MDBM
# include <ndbm.h>
# define DBMFILE DBM
# define DB_DIREXT	".dir"
# define DB_PAGEXT	".pag"
#endif MDBM

#ifndef lint
static char	SccsId[] = "@(#)dbm.c 2.1 (lel@ida.liu.se) 8/15/88";
#endif !lint

#define	SAMECASE	0
#define LOWERCASE	1
#define UPPERCASE	2

#define COMMENTCHAR	'#'
#define SENTENIEL	"@@@"

#define streq(s, t)	(strcmp(s, t) == 0)
#define MAKEDATUM(d, s)	{(d).dptr = s; (d).dsize = strlen(s) + 1;}

void do_clear(), do_delete(), do_dump(), do_fetch(), do_load(), do_make(),
    do_parse(), do_store();

struct comtab {
    char *c_name;
    void (*c_func)();
} CommandTable[] = {
    {"clear",	do_clear},
    {"delete",	do_delete},
    {"dump",	do_dump},
    {"fetch",	do_fetch},
    {"load",	do_load},
    {"make",	do_make},
    {"parse",	do_parse},
    {"store",	do_store}
};
    
/* global arguments */
int	Argc;
char	**Argv;

/* options */
int	Appending = FALSE;
int	Casing = SAMECASE;
bool	Debug = FALSE;
char	*Outfile = NULL;
int	Mode = 0644;
char	*Progname;
char	*Senteniel = NULL;
int	Storeflag = DBM_INSERT;
bool	Storewarn = TRUE;

/* Dbm globals */
DBMFILE	*Dbm;
char	*Dbmfile = NULL;
int	Dbmaccess;
datum	key, val;

main(argc, argv)
     int argc;
     char **argv;
{
    extern int optind;
    extern char *optarg;
    char *scantoken();
    struct comtab *cmd;
    int c;

    Argc = argc;
    Argv = argv;

    Progname = Argv[0];

    while ((c = getopt(Argc, Argv, "ADILRSUd:m:o:s:")) != EOF)
	switch (c) {
	  case 'A':
	    Appending = TRUE;
	    break;
	  case 'D':
	    Debug = TRUE;
	    break;
	  case 'I':
	    Storeflag = DBM_INSERT;
	    Storewarn = FALSE;
	    break;
	  case 'L':
	    Casing = LOWERCASE;
	    break;
	  case 'R':
	    Storeflag = DBM_REPLACE;
	    break;
	  case 'S':
	    if (Senteniel == NULL)
		Senteniel = SENTENIEL;
	    break;
	  case 'U':
	    Casing = UPPERCASE;
	    break;
	  case 'd':
	    Dbmfile = optarg;
	    break;
	  case 'm':
	    if (optarg[0] == '0')
		(void) sscanf(optarg, "%o", &Mode);
	    else {
		(void) sscanf(optarg, "%d", &Mode);
		if (Mode == 0) {
		    (void) fprintf(stderr, "%s: non-numeric mode: %s\n",
				   Progname, optarg);
		    exit(1);
		}
	    }
	    break;
	  case 'o':
	    Outfile = optarg;
	    break;
	  case 's':
	    Senteniel = optarg;
	    break;
	  default:
	    (void) fprintf(stderr,
			   "usage: %s [-ADILNRSU] [-d dbm_file] [-m mode] %s", 
			   Progname, "[-o output_file] command [args]\n");
	    exit(1);
	}

    Argc -= optind;
    Argv += optind;

    if (Argc > 0) {
	for (cmd = CommandTable; cmd < &CommandTable[sizeof(CommandTable) /
						     sizeof(*CommandTable)];
	     cmd++)
	    if (streq(*Argv, cmd->c_name)) {
		(*cmd->c_func)();
		exit(0);
	    }
	(void) fprintf(stderr, "%s: unknown dbm command %s", Progname, *Argv);
    } else
	(void) fprintf(stderr, "%s: missing dbm command", Progname);
    (void) fprintf(stderr, ", use one of the following:\n");
    for (cmd = CommandTable; cmd < &CommandTable[sizeof(CommandTable) /
						 sizeof(*CommandTable)]; cmd++)
	(void) fprintf(stderr, "%s%s", cmd == CommandTable ? "" : "\t",
		       cmd->c_name);
    (void) fprintf(stderr, "\n");
    exit(3);
}

opendbm(access)
     int access;
{
    if (Dbmfile == NULL) {
	if (Argc > 1) {
	    /* use last argument */
	    Dbmfile = Argv[Argc-1];
	    Argc--;
	} else {
	    (void) fprintf(stderr, "%s: dbm file not specified\n", Progname);
	    exit(3);
	}
    }
    Dbm = dbm_open(Dbmfile, access, Mode);
    if (Dbm == NULL) {
	char *filename = (char *) malloc(strlen(Dbmfile) + 20);
	sprintf(filename, "%s{%s,%s}", Dbmfile, DB_DIREXT, DB_PAGEXT);
	perror(filename);
	exit(4);
    }
    (void) flock(dbm_dirfno(Dbm), LOCK_EX);
    Dbmaccess = access;
}

closedbm()
{
    if ((Dbmaccess & O_RDONLY) == 0 && Senteniel != NULL) {
	MAKEDATUM(key, Senteniel);
	if (dbm_store(Dbm, key, key, DBM_REPLACE) != NULL) {
	    (void) fprintf(stderr, "%s: could not store senteniel \"%s\"\n",
			   Progname, Senteniel);
	    perror(Progname);
	    exit(5);
	}
    }
	
    (void) flock(dbm_dirfno(Dbm), LOCK_UN);
    dbm_close(Dbm);
}

FILE *
openfile(filename, access)
     char *filename;
     char *access;
{
    FILE *f;

    if (streq(filename, "-"))
	if (streq(access, "r"))
	    return stdin;
	else
	    return stdout;
    else {
	f = fopen(filename, access);
	if (f == NULL) {
	    perror(filename);
	    exit(4);
	}
	return f;
    }
}

void
closefile(f)
     FILE *f;
{
    if (f != stdin && f != stdout)
	(void) fclose(f);
}
/*
**	DO_CLEAR -- Clear out database leaving it emtpy.
*/

void
do_clear()
{
    if (Dbmfile != NULL) {
	opendbm(O_RDWR | O_CREAT | O_TRUNC);
	closedbm();
    }
    while (Argc > 1) {
	opendbm(O_RDWR | O_CREAT | O_TRUNC);
	closedbm();
    }
}

   
/*
**	DO_DELETE -- Delete individual entries from the database.
*/

void
do_delete()
{
    opendbm(O_RDWR | O_CREAT);

    for (Argc--, Argv++; Argc > 0; Argc--, Argv++) {
	casify(*Argv, Casing);
	MAKEDATUM(key, *Argv);
	if (dbm_delete(Dbm, key) != NULL) {
	    perror(*Argv);
	    exit(5);
	}
    }

    closedbm();
}

/*
**	DO_DUMP -- List all entries in the database.
*/
 
void
do_dump()
{
    FILE *output;
    
    opendbm(O_RDONLY);

    if (Outfile == NULL)
	output = stdout;
    else
	output = openfile(Outfile, "w");

#ifdef MDBM
    for (key = dbm_firstkey(Dbm); key.dptr != NULL; key = dbm_nextkey(Dbm, key)) {
#else MDBM
    for (key = dbm_firstkey(Dbm); key.dptr != NULL; key = dbm_nextkey(Dbm)) {
#endif MDBM
	val = dbm_fetch(Dbm, key);
	if (val.dptr == NULL)
	    perror(key.dptr);
	else
	    (void) fprintf(output, "%s\t%s\n", key.dptr, val.dptr);
    }
}
/*
**	DO_FETCH -- Lookup individual keys in the database.
*/
 
void
do_fetch()
{
    opendbm(O_RDONLY);

    for (Argc--, Argv++; Argc > 0; Argc--, Argv++) {
	casify(*Argv, Casing);
	MAKEDATUM(key, *Argv);
	val = dbm_fetch(Dbm, key);
	if (val.dptr == NULL)
	    (void) printf("%s\t[NOT FOUND]\n", *Argv);
	else
	    (void) printf("%s\t%s\n", *Argv, val.dptr);
    }

    closedbm();
}

/*
**	DO_STORE -- Insert individual entries into the database.
*/

void
do_store()
{
    /* barf if # of args - 1 is even and no dbm file has been specified */
    if (Argc & 1 == 1 && Dbmfile == NULL) {
	(void) fprintf(stderr, "%s: no dbm file specified\n", Progname);
	exit(3);
    }

    opendbm(O_RDWR | O_CREAT);

    for (Argc--, Argv++; Argc > 1; Argc -= 2, Argv += 2) {
	casify(Argv[0], Casing);
	MAKEDATUM(key, Argv[0]);
	MAKEDATUM(val, Argv[1]);
	if (dbm_store(Dbm, key, val, Storeflag) != NULL) {
	    extern int errno;

	    if (errno != 0) {
		perror(Argv[0]);
		exit(5);
	    } else if (Storewarn)
		(void) fprintf(stderr,
			       "%s: duplicate key \"%s\" => \"%s\" ignored\n",
			       Progname, Argv[0], Argv[1]);
	}
    }
    if (Argc > 0)
	(void) fprintf(stderr, "%s: no value for last key \"%s\"--ignored\n",
		       Progname, Argv[0]);

    closedbm();
}

/*
**	DO_PARSE -- Parse a textual database file and produce key-value
**		pairs separated by a tab (suitable for input to the ``load''
**		function).
*/

void
do_parse()
{
    FILE *input, *output;
    
    if (Outfile == NULL)
	output = stdout;
    else
	output = openfile(Outfile, "w");

    if (Argc == 1)
	parsefile(stdin, output);
    else
	for (Argc--, Argv++; Argc > 0; Argc--, Argv++) {
	    input = openfile(*Argv, "r");
	    parsefile(input, output);
	    closefile(input);
	}
}

/*
**	DO_MAKE -- Parse the textual input and load the result into
**		the database.
*/

void
do_make()
{
    FILE *input, *pipin, *pipout;
    int pipes[2];

    opendbm(O_RDWR | O_CREAT | (Appending ? 0 : O_TRUNC));

    if (pipe(pipes) != NULL) {
	perror("pipe");
	exit(9);
    }
    pipin = fdopen(pipes[0], "r");
    pipout = fdopen(pipes[1], "w");

    if (fork() == 0) {
	/* child process */
	(void) fclose(pipout);

	loadfile(pipin);
    } else {
	/* parent process */
	(void) fclose(pipin);

	if (Argc == 1)
	    parsefile(stdin, pipout);
	else
	    for (Argc--, Argv++; Argc > 0; Argc--, Argv++) {
		input = openfile(*Argv, "r");
		parsefile(input, pipout);
		closefile(input);
	    }
    }
    closedbm();
}

/*
**	DO_LOAD -- Load the dbm database from a text file.  The input should
**		be key-value pairs separated by a tab, each on a single line.
*/

void
do_load()
{
    FILE *input;

    opendbm(O_RDWR | O_CREAT | (Appending ? 0 : O_TRUNC));

    if (Argc == 1)
	loadfile(stdin);
    else
	for (Argc--, Argv++; Argc > 0; Argc--, Argv++) {
	    input = openfile(*Argv, "r");
	    loadfile(input);
	    closefile(input);
	}
    closedbm();
}    

/*
**	PARSEFILE, LOADFILE
*/ 

parsefile(input, output)
     FILE *input, *output;
{
    extern char *index();
    char buf[BUFSIZ], *key, *val = NULL;
    register char *p;

    while (fgets(buf, sizeof(buf), input) != NULL) {
	if (buf[0] == COMMENTCHAR || buf[0] == '\n' || buf[0] == '\0')
	    continue;
	if (!isspace(buf[0])) {
	    /* extract value */
	    p = scantoken(buf);
	    if (val != NULL)
		free(val);
	    val = (char *) malloc(p - buf + 1);
	    (void) strncpy(val, buf, p - buf);
	    val[p - buf] = '\0';
	}
	casify(buf, Casing);
	for (p = buf; *p != '\0';) {
	    while (*p != '\0' && isspace(*p)) p++;
	    if (*p == '\0' || *p == COMMENTCHAR)
		break;
	    key = p;
	    p = scantoken(p);
	    if (*p == COMMENTCHAR)
		*p = '\0';
	    else if (*p != '\0')
		*p++ = '\0';
	    (void) fprintf(output, "%s\t%s\n", key, val);
	}
    }
}

loadfile(input)
     FILE *input;
{
    char buf[BUFSIZ];
    register char *tab, *nl;
    extern char *index();

    while (fgets(buf, sizeof(buf), input) != NULL) {
	nl = index(buf, '\n');
	if (nl != NULL)
	    *nl = '\0';

	tab = index(buf, '\t');
	if (tab == NULL) {
	    (void) fprintf(stderr, "%s: missing tab in \"%s\"--ignored\n",
			   Progname, buf);
	    continue;
	}
	*tab++ = '\0';
	casify(buf, Casing);
	MAKEDATUM(key, buf);
	MAKEDATUM(val, tab);
	if (dbm_store(Dbm, key, val, Storeflag) != NULL && Storewarn) {
	    extern int errno;

	    if (errno != 0) {
		perror(buf);
		exit(5);
	    } else if (Storewarn)
		(void) fprintf(stderr,
			       "%s: duplicate key \"%s\" => \"%s\" ignored\n",
			       Progname, buf, tab);
	}
    }
}

char *
scantoken(p)
     register char *p;
{
  register bool quotedchar = FALSE, insidestring = FALSE, insideroute = FALSE;

  /* hidious address scanner */
  while (*p != '\0' && (quotedchar || insidestring || insideroute || 
			(*p != COMMENTCHAR && !isspace(*p)))) {
    /* special quote character handling */
    if (quotedchar)
      quotedchar = FALSE;
    else {
      quotedchar = (*p == '\\');
      if (!insidestring)
	if (*p == '<')
	  insideroute = TRUE;
	else if (*p == '>')
	  insideroute = FALSE;
      if (*p == '"')
	insidestring = !insidestring;
    }
    p++;
  }

  return p;
}

casify(p, c)
     register char *p;
     int c;
{
    switch (c) {
      case LOWERCASE:
	for (; *p != '\0'; p++)
	    if (isupper(*p))
		*p = tolower(*p);
	break;
      case UPPERCASE:
	for (; *p != '\0'; p++)
	    if (islower(*p))
		*p = toupper(*p);
	break;
    }
}
