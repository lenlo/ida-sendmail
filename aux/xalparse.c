/*
**  XALPARSE -- Xaliases file parser.
**  Copyright (c) 1987 Lennart Lovstrand
**  CIS Dept, Univ of Linkoping, Sweden
**
**  Use it, abuse it, but don't sell it.
*/

#include "useful.h"
#include <stdio.h>
#include <ctype.h>

#ifndef lint
static char	SccsId[] = "@(#)xalparse.c 1.1 (lel@ida.liu.se) 4/12/87";
#endif !lint

struct alias {
  bool a_in, a_out;
  char *a_name;
};

#define ANULL	(struct alias *) NULL

/*
**  XPARSE -- Parse an xaliases file, producing aliases + generics files.
**
**	This program parses a file in ``xaliases'' format, producing
**	a standard aliases file + a generics file.  The xaliases input
**	file has entry of the following format:
**		generic_list: mbox_list
**	where elements in both lists are separated by commas.  In
**	addition, each element in the mbox_list may be prefixed with
**	either or both of the ``redirection characters,'' "<" and ">".

**	In its simplest form, the generic_list has just one member and
**	the mbox_list uses no redirection characters.  This
**	corresponds exactly to the standard aliases format and
**	function.

**	The first extention is made by allowing more than one entry on
**	the left hand side, thus making "a, b: c" as shorthand for the
**	two entries "a: c" and "b: c".

**	The second extension is made by adding the previously
**	mentioned redirection characters to the addresses on the right
**	hand side.  These control in what direction the aliases should
**	be used.
**
**	etc.
*/

int iflag = FALSE, Iflag = FALSE, Oflag = FALSE;

main(argc, argv)
     int argc;
     char **argv;
{
  extern int optind;
  extern char *optarg;
  char c;
  FILE *xaliases, *aliases, *generics;


  if (argc != 4) {
    fprintf(stderr, "usage: %s xaliases aliases generics\n", argv[0]);
    exit(1);
  }

  if (strcmp(argv[1], "-") == 0)
    xaliases = stdin;
  else {
    xaliases = fopen(argv[1], "r");
    if (xaliases == NULL)
      perror(argv[1]), exit(2);
  }
  aliases = fopen(argv[2], "w");
  if (aliases == NULL)
    perror(argv[2]), exit(2);
  generics = fopen(argv[3], "w");
  if (generics == NULL)
    perror(argv[3]), exit(2);
  
  parsefile(xaliases, aliases, generics);
  exit(0);
}

parsefile(xaliases, aliases, generics)
     FILE *xaliases, *aliases, *generics;
{
  extern char *index();
  char line[BUFSIZ];
  struct alias *rhs[BUFSIZ], *lhs[BUFSIZ];
  struct alias **a, **r, **first;

  while (readline(line, sizeof(line), xaliases) >= 0) {
    parseline(line, lhs, rhs);

    for (first = rhs; *first != ANULL; first++)
      if ((*first)->a_in)
	break;
    if (*first != ANULL)
      for (a = lhs; *a != ANULL; a++) {
	fprintf(aliases, "%s:%s", (*a)->a_name, (*first)->a_name);
	for (r = first+1; *r != ANULL; r++)
	  if ((*r)->a_in)
	    fprintf(aliases, ",%s", (*r)->a_name);
	fprintf(aliases, "\n");
      }

    for (first = rhs; *first != ANULL; first++)
      if ((*first)->a_out)
	break;
    if (*first != ANULL) {
      fprintf(generics, "%s\t%s", lhs[0]->a_name, (*first)->a_name);
      for (r = first+1; *r != ANULL; r++)
	if ((*r)->a_out)
	  fprintf(generics, " %s", (*r)->a_name);
      fprintf(generics, "\n");
    }

    freebufs(lhs, rhs);
  }
}

/**
 **	PEEKC -- Return the next char to be read.
 **/

peekc(stream)
     FILE *stream;
{
  int c;

  c = getc(stream);
  if (c != EOF)
    ungetc(c, stream);
  return c;
}

/**
 **	READLINE -- Read a (logical) line and return the # of chars read
 **/

readline(buf, bufsiz, stream)
     char *buf;
     int bufsiz;
     FILE *stream;
{
  int len;
  char *sharp;

  if (fgets(buf, bufsiz, stream) == NULL)
    return -1;
  buf[strlen(buf)-1] = '\0';

  /*
  if ((sharp = index(buf, '#')) != NULL)
    *sharp = '\0';
  */
  if (buf[0] == '#')
    buf[0] = '\0';

  len = strlen(buf);
  if (isspace(peekc(stream)))
    return len + readline(&buf[len], bufsiz-len, stream);
  else
    return len;
}

/**
 **	PARSETHING
 **/


#define LHS	1
#define RHS	2

char *
parsething(line, thing, side)
     char *line;
     struct alias **thing;
     int side;
{
  register char *s, *d;
  register bool
    insideroute = FALSE,
    insidestring = FALSE,
    quotedchar = FALSE;
  bool i_mark, o_mark;
  char buf[BUFSIZ];
  extern char *malloc();

  s = line;
  d = buf;

  while (*s != '\0' && isspace(*s)) s++;
  if (side == RHS) {
    if (o_mark = (*s == '<')) s++;
    if (i_mark = (*s == '>')) s++;
    i_mark = i_mark || !o_mark;			/* default to '>' */
    while (*s != '\0' && isspace(*s)) s++;
  }

  for (;*s != '\0'; s++) {
    /* exit if non-quoted comma (or colon & LHS) */
    if (!insidestring && !quotedchar && !insideroute &&
	*s == ',' || ((side == LHS) && *s == ':'))
      break;

    /* copy if not unquoted whitespace */
    if (insidestring || quotedchar || !isspace(*s))
      *d++ = *s;

    /* special quote character handling */
    if (quotedchar)
      quotedchar = FALSE;
    else {
      quotedchar = (*s == '\\');
      if (!insidestring)
	if (*s == '<')
	  insideroute = TRUE;
	else if (*s == '>')
	  insideroute = FALSE;
      if (*s == '"')
	insidestring = !insidestring;
    }
  }
  while (d > buf && isspace(d[-1])) d--;
  *d = '\0';

  if (d == buf && *s == '\0') {
    *thing = ANULL;
    return NULL;
  } else {
    *thing = (struct alias *) malloc(sizeof(struct alias));
    (*thing)->a_in = i_mark;
    (*thing)->a_out = o_mark;
    (*thing)->a_name = malloc(strlen(buf) + 1);
    strcpy((*thing)->a_name, buf);
    return s;
  }
}

/**
 **	PARSELINE
 **/

parseline(line, lhs, rhs)
     char *line;
     struct alias **lhs, **rhs;
{
  line--;

  while ((line = parsething(line+1, lhs++, LHS)) != NULL)
    if (*line == ':')
      break;
  *lhs = NULL;

  if (line != NULL)
    while ((line = parsething(line+1, rhs++, RHS)) != NULL);
  *rhs = ANULL;
}

/**
 **	FREEBUFS
 **/

freebufs(lhs, rhs)
     struct alias **lhs, **rhs;
{
  while (*lhs != ANULL) {
    free((*lhs)->a_name);
    free(*lhs);
    lhs++;
  }
  while (*rhs != ANULL) {
    free((*rhs)->a_name);
    free(*rhs);
    rhs++;
  }
}

/**
 **	COMPRESSLINE -- Remove all heading & trailing whitespace around items.
 **/

compressline(line)
     char *line;
{
  register char *d, *s, *b, *e;

  for (d = s = line; *s != '\0'; s++) {
		/* eat initial whitespace */
    while (*s != '\0' && isspace(*s)) s++;
    if (*s == '\0')
      break;
		/* remember beginning of "word" and find end */
    b = s;
    while (*s != '\0' && *s != ',' && *s != ':') s++;
    e = s - 1;
		/* backspace end thru whitespace */
    while (e >= b && isspace(*e)) e--;
		/* copy "word" w/o whitespace */
    while (b <= e) *d++ = *b++;
		/* copy separator */
    *d++ = *s;
    if (*s == '\0')
      return;
  }
  *d = '\0';
}
