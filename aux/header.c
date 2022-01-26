/*
**  HEADER -- Header line parser.
**  Copyright (c) 1985 Lennart Lovstrand
**  CIS Dept, Univ of Linkoping, Sweden
**
**  Use it, abuse it, but don't sell it.
**
**  Version of 14-Apr-85.
*/

#include <stdio.h>
#include <strings.h>
#include <ctype.h>
#include "useful.h"

#define H_CC		"cc"
#define H_FROM		"from"
#define H_MESSAGE_ID	"message_id"
#define H_RETURN_PATH	"return-path"
#define H_TO		"to"
#define H_VIA		"via"

#define COMMA	','

#define MAKELC(C)	(isupper(C) ? tolower(C) : C)

/*
 *	iskey: checks if the line is prefixed by
 *	the supplied keyword (immediately followed by
 *	a colon)
 */
iskey(key, line)
char *key, *line;
{
	for (; *key != NULL && *line != NULL; key++, line++)
		if (MAKELC(*key) != MAKELC(*line))
			break;

	return *key == NULL && *line == ':';
}

char *eat(str, ch)
char *str, ch;
{
	for(; *str == ch; str++);
	return str;
}

/*
 *	extract_address:
 *	finds and extracts the machine address part of an address field
 */

char *extract_address(field, address)
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
				field = eat(field, ' ');
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


