.NH
MANAGING GENERIC MAIL ADDRESSES
.LP
While sending mail to people by specifying a mailbox on a named computer
may fulfill the technical requirements of an electronic mail system, it
may not always be very convenient.  With people having accounts on many
different hosts and often moving between them, it is hard to keep track
of where a person presently will read his or her mail.  For external
senders, remembering strange host names for lots of people is even
worse.  Just knowing that Person A, working in the same group as Person
B, has a mailbox on Computer C does not mean that B also can be reached
on that machine.  It may very well be that Computer C is A's personal
workstation with no other accounts than A's.
.PP
Simply setting up as many forwarding addresses as possible on all sorts
of machines does not solve the problem.  First of all, there might be
reasons for a user to want to actually receive mail on any of these
machines\*-e.g. because this may be the easiest way of copying files
between remote machines.  Also, there is still no visible connection
between the person and his group, which makes it hard to remember his
address.
.PP
Another solution would be to have a special machine for mail forwarding,
preferably with a name corresponding to the local organization.  Since
all mail has to go through this node in order to reach its recipients,
it may prove to be an expensive solution if this means that the extra
load will restrain users from doing other useful work on the machine.
Also, if this node goes down, no mail will be delivered until it comes
up again.
.PP
Our proposed solution to the problem is to extend
.I sendmail 's
notion of aliases to include forwarding of non-local addresses as well
as those specific to the local host.  This way, several hosts may share
the non-local part of a aliases table and any of them can do the
forwarding.  Users may change their preferred mailbox and computers may
be renamed at any time with no change in the way their inbound addresses
look like.  As an option, users'
.DQ From:
line addresses may be rewritten to correspond to the organizational
address by using the same database.  For example, this author's mail
address:
.QQ
lel@ida.liu.se  (\fIaka\fP lel@liuida.\s-1UUCP\s+1)
.LP
is implemented by an entry in the aliases files on set of Sun systems
and a Gould.  All of them will forward messages for that address to my
preferred mailbox on a
.UC DEC system-20.
Any message sent from either the Suns, the Gould, or the
.UC DEC system-20
will have 
.DQ lel@ida.liu.se
as the
.DQ From:
line return address.  The envelope sender, however, will at all times
point to the actual user and host that originated the message.
.PP
This is implemented using an
.I aliases
file with extended syntax, called
.I xaliases .
Entries in this file are marked for either inbound or outbound aliasing.
Inbound is the normal function, and may be used for non-local addresses
as well as local ones.  Outbound aliasing is done on header sender lines
by rewriting them to the LHS value in the
.I xaliases
entry.  The syntax for entries in this file is:
.QQ
alias, alias, \|.\|.\|.\|: prefix address, prefix address, \|.\|.\|.\|
.LP
where the first
.I alias
is the generic address that should be substituted for those in the
header sender lines matching the RHS outbound
.I addresses .
All LHS
.I aliases
are mailboxes that should be forwarded to the RHS
.I addresses
marked inbound.  The
.I prefix
before each RHS
.I address
marks it as either inbound, outbound or both according to the following
table:
.QQ
.TS
l l .
(\fIno mark\fP)	Inbound
<	Outbound
>	Inbound
<>	Both Inbound and Outbound
.TE
.LP
The
.I xaliases
file is then parsed by the
.I xalparse (8)
program, producing a normal
.I aliases (5)
file as output together with a
.I dbm (1)
input file, consisting of the outbound aliases.  An example would
be:
.QQ
Fooey.Barbaz@dept, bar@dept, foo: <> fooey@besthost, < fobar@otherhost
.LP
which means that mails to either
.DQ Fooey.Barbaz@dept,
.DQ bar@dept,
or
.DQ foo@localhost
will be forwarded to
.DQ fooey@besthost
and that mail from either
.DQ fooey@besthost
or
.DQ fobar@otherhost
will have their header sender lines substituted for
.DQ Fooey.Barbaz@dept.
See the supplied
.I xaliases
file for more examples.
.PP
An
.I aliases
file with non-local aliases should be processed by running
.I sendmail
with a configuration file having the
.UC NEWALIASES
identifier defined.  This makes it parse all addresses as local and
return them to the
.UC LOCAL
mailer when building the dbm alias tables.  A delivering
.I sendmail
will then lookup all addresses in the
.I aliases
file and return any found to the
.UC LOCAL
mailer [ruleset 26].  The normal aliasing mechanisms of
.I sendmail
are then used to distribute the messages further.
.PP
The substitution of
.DQ physical
senders with
.DQ generic
addresses, is as previously mentinioned done in the header/sender
specific ruleset 5 by lookup in the
.UC GENERICFROM
database.
.NH
SENDMAIL SOURCE MODIFICATIONS
.LP
.I Sendmail
gives a lot of flexibility to the maintainer and developer of electronic
mail.  Still, it lacks certain functionality for which it was determined
that our project's goals could not be fulfilled without.  Just [sic]
developing a new configuration file was not adequate, but changes to the
source code itself had to be done.  Still, we did this with the
philosophy that it is best to avoid source code modifications whenever
it is possible to obtain the same results by merely changing parameters
in the configuration file.
.LP
The following features have been implemented in our current version of
.I sendmail (5.51++):
.NH 2
Nameserver Default Argument
.LP
Previously, there was no way of knowing whether a nameserver lookup
was successful or not, thus making that feature of limited value.
This version will allow you to add a
.I default
argument to the nameserver lookup function, which will be returned if
the match fails.  A typical usage for this is to determine if a host is
accessible using the
.UC TCP/IP
protocol family.
The extended syntax is as follows:
.QQ
.B $[
hostname
.B $:
default
.B $]
.LP
where the 
.B $: \fIdefault\fP
part is optional.
.NH 2
Direct Access to Dbm(3) Files
.LP
The configuration file syntax has been expanded to include the
declaration and usage of general
.I ndbm (3)
databases.  The option
.SQ K
(for
.I "Keyed database" )
has been added.  It takes two arguments, a one character internal name
for the database and the corresponding
.I dbm (3)
file(s), as in:
.QQ
OKP/usr/lib/mail/pathtable
.LP
which defines the internal database
.SQ P
to be associated with the dbm files /usr/lib/mail/pathtable.dir and
pathtable.pag (or pathtable.map and pathtable.dat if you are using
Maryland's
.I mdbm (3)
package).
.PP
The
.SQ P
database may now be used to lookup arbitrary strings in the RHS of
rewriting rules.  The syntax is as follows:
.QQ
\fB$(\fPx key \fB$@\fP arg \fB$:\fP default \fB$)\fP
.LP
where
.I x
is corresponds to a previously declared database,
.I key
is the string that should be searched for in the database.
The
.I arg
and
.I default
arguments are optional.  The 
.I default
string is returned is if the
.I key
could not be found in the database.  If neither
.I default
string, nor a matching
.I key
is to be found, the whole expression expands to the value of
.I key .
However, if a result is found, it is used as the format string of a
.I sprintf (3)
expression, with the
.I arg
as extra argument.  Thus, database values with
.DQ %s
strings embedded in them can be useful when rewriting expressions.  This
could typically be used in cooperation with the
.I pathalias (1)
program to expand routes without leaving
.I sendmail .
.PP
The
.I aliases (5)
file is automatically available using the
.SQ @
database and should
.B not
be declared with a option
.SQ K
statement.
.NH 2
Batched
.UC SMTP
Support
.LP
.I Sendmail
already speaks
.UC SMTP
over interactive channels, but because it both will drop errors occurring
when acting as server as well as hang indefinitely when talking to a
non-responding channel as client, this is not sufficient to process or
produce
.UC SMTP
batches.
Still, since the
.UC SMTP
code already is there,
it was considered easier to add batching support internally in
.I sendmail
than to write new front-end programs.
.PP
The new code defines a new
.UC MD_BSMTP
mode, which is activated by the
.B \-bb
option or by making a link to 
.I sendmail
named
.I bsmtp .
The normal way of digesting
.UC SMTP
batches is to execute
.I bsmtp
with no arguments.
.PP
To produce
.UC SMTP
scripts, the 
.UC M_BSMTP
(\fBB\fP) mailer flag 
has been added.  It is used as in the following example:
.QQ -1
MUUCP-B, P=/usr/bin/uux, F=BDFMSXhmpu, S=0,  R=15/0,  A=uux \- \-z \-r 
$h!bsmtp
.LP
This defines the
.UC UUCP-B
mailer to send
.UC SMTP
scripts on the standard input to the
.I uux (1)
program.
.NH 2
Separate Envelope/Header Rewriting Rulesets
.LP
Envelope and header addresses does not always look the same.  For
example, it
is often desirable to have envelope return addresses formed using
.UC RFC 822
route syntax, while this format more rarely is understood by users'
front-end mail programs.  Another case is when the envelope recipient
address is expanded to a system route, while the header recipient
should be kept simple.
.PP
With this package, the mail system administrator has the option of
separating rewriting control for envelope/recipient addresses.
Normally, all sender/recipient addresses are passed through rulesets 1
and 2, but if the \fISplitRewriting\fP option
.SQ /
is set, only envelope addresses are handled that way; header addresses
are given to rulesets 5 and 6, which should be properly defined.
.PP
Mailer dependant rewriting may also be controlled in an envelope/header
specific way.  This is accomplished by extending the syntax for the 
.SQ R
and
.SQ S
attributes of the mailer definition statement:
.QQ
R=re/rh, S=se/sh
.LP
with the envelope and header rulesets divided by a slash.  If no slash
is found, it functions as before by using the same ruleset for both
types of rewriting.  A zero or missing ruleset indicates that no
rewriting should be done.  In the previous example of the
.I "Batched \s-1SMTP\s+1 Support" ,
no mailer dependant sender rewriting is done, recipient envelope
addresses are rewritten using ruleset 15, but recipient header addresses
are left untouched.
.NH 2
Separate Local
.UC UUCP
Host Name
.LP
With the extensive, structured world of domains on one side and the
flatspaced, shortnamed
.UC UUCP
world on the other, it may be desirable for a node to have a
.UC UUCP
node name separate from its normal host name.  For this purpose, the
.B $k
macro has been introduced to hold the local node's specific
.UC UUCP
host name.  It defaults to the node's
.DQ normal
host name (as returned by
.I gethostname (3)),
if not explicitly defined in the
configuration file.  It is used when rewriting headers in the
.I "\s-1UUCP\s+1 Relativization Routines"
as well as when producing
.UC UUCP
.DQ From_
lines with the
.UC M_FROMPATH
(\fBp\fP) turned on.
.NH 2
Return Path for
.UC UUCP
Mailers
.LP
The
.UC M_FROMPATH
(\fBp\fP) mailer flag is used by the
.UC SMTP
routines to add the local
host to the envelope sender in the
.UC "MAIL FROM:"
command.  This is a useful option for producing trustworthy routes
back to the sender for receipts and error messages.  This capability
has now been added the the code that produces
.UC UUCP
.DQ From_
lines.  The sender's address is simply prefixed using the local host's
.UC UUCP
name and an exclamation mark\*-the canonical way of constructing
paths in the
.UC UUCP
world.  (For mailers with the
.UC M_UGLYUUCP
flag (\fBU\fP) set, the local host's name is added after the
.DQ "remote from"
string.)
.NH 2
.UC UUCP
Header Address Relativization
.LP
A new
.UC M_RELATIVIZE
(\fBV\fP) mailer flag has been added, which relativizes header lines
with respect to the immediate recipient host.  This means that
.I paths
through the remote host will have the remote node's name removed (local
recipients at the remote host are untouched) and that other addresses
are rewritten to have paths through the local host.
.PP
Specifically,
.DQ \fB$h\fP!\|.\|.\|.\|!user
addresses are stripped down to the
.DQ \|.\|.\|.\|!user
part,
.DQ \fB$h\fP!user
are left untouched, and
.DQ "others"
rewritten into
.DQ \fB$k\fP!others
(the initial value of \fB$w\fP is used if \fB$k\fP is undefined).
.NH 2
Support for Multi-Token Class Matches
.LP
When
.I sendmail
tried to match a LHS \fB$=\fPX class expression, it used to be the case
that it only looked for matches with one token.  If the period is a
delimiter and if
.DQ foo.\s-1EDU\s+1
is a member of the
.SQ X
class, it would not find the string
.DQ foo.\s-1EDU\s+1
in the class since it contained three tokens
.DQ foo "" (
.DQ .
and
.UQ EDU ).
This was considered such a great inconvenience that the expression
matching code was rewritten to allow multi-token class matches on the
expense of being somewhat slower.  With the above example, the current
version will first try to find a match for
.DQ foo
then
.DQ foo.
then
.DQ foo.\s-1EDU\s+1
and so on, each time incorporating the next successive token of the
expression in the class match.
.NH 2
Support for Embedded Subruleset Calls
.LP
Being a
.UC LISP
hacker of heart, the author couldn't refrain from making
.I sendmail
handle embedded ruleset calls.  The previous version had the very
annoying restriction of only allowing one ruleset call per rule and only
allowing the
.B $@
and
.B $:
macros to appear on its left side.  The current version handles both
embedded ruleset calls of the form
.DQ "$>4$>10$>6 $1@.$2"
as well as arbitrarily positioned calls within the RHS expression
(although the latter has not been fully tested).
.NH 2
Elaborate Matching Algorithm for Unknown Local Recipients
.LP
Based on the idea that it always is a bad idea to throw mail back
with a
.DQ "User Unknown"
error message if a human operator might be able to guess the actual
recipients identity, we have added a more elaborate search algorithm
that matches unknown recipients with the personal name field of the
/etc/passwd file.  The previous version of
.I sendmail
offered a similar functionality, but would only find strings that were
exact copies of that field.  This version uses an algorithm that will
return a number corresponding to the degree of similarity between the
two strings.  Strings are considered match best if as many mutual
substrings as possible are found in sequence.  Substrings are delimited
by any non-alphabetic character and completely equal substrings are
better matches than just prefixes.
.PP
The best match of such a search through the /etc/passwd file is returned
as the local recipient, provided that only one such match exists.  If no
best match is found (i.e., if more than one
.I passwd
entry have the same highest matching degree), the search fails and the
mail is returned with an error message.
.NH 2
Support for Maryland's Mdbm Package
.LP
Sites that do not yet have the new
.I ndbm (3)
functions of
.UC BSD
4.3 may still use the
.I "Database Access Functions"
described above using the University of Maryland's public domain
multi-dbm routines, which are available from your nearest
comp.sources.unix archive.  Note that these use different extensions of
their database files (.map and \&.dat instead of \&.dir and \&.pag) as
well as a different internal format than
.I dbm (3),
so it is still recommended to use
.I ndbm (3)
whenever possible.
.NH 2
Improved Test Mode Output
.LP
It is hard to remember what all these
.DQ ^X s
and
.DQ ^V s
stand for when debugging sendmail rewriting rules, using its address
rewriting test mode.  The changes in this version will make macros print
in their symbolic form, i.e.
.DQ "\fB$:\fP"
for
.DQ "^X,"
etc.
.PP
In addition, at least this
.I sendmail.cf
developer often wanted to send addresses directly into a specific
ruleset without having them automatically rewritten by ruleset 3.
Thus, the initial call to ruleset 3 has been 
.B deleted
in this version.  You will have to send your addresses manually through
ruleset 3 henceforth if you adopt this change.
.PP
Finally, the ruleset rewriting output often became too wide to be easily
read due to the excess of quotation marks around the tokens.  These have
now been removed from the test output, leaving just a space between each
token.  The author thinks this is much more convenient and hopes that
you agree.
.NH 2
Better To: and Cc: Headers of Returned Messages
.LP
The original code would produce multiple To: header lines in returned
messages if the message was sent to more than one recipient.  A typical
reason for this to happen was if you used the PostMasterCopy option in
your
.I sendmail.cf
file.  This version will put the PostMasterCopy on a separate Cc: line
and all others together in a comma-separated list on the To: line.
.NH 2
Queue Bug Fixed
.LP
A nasty little queue bug bit us hard several times last year.  It
occurred when, for whatever reason, the queue daemon ended up processing
a locked queue entry as its last.  It immediately discovered that it was
locked and left it alone, but then exited and while doing general
cleanup in
.I finis ,
removed the locked queue file as well.  That way, we frequently started
ending up with broken queue files and lost messages as a consequence.
The fix is to explicitly set the current envelope's id to
.UC NULL
before leaving the current queue pass, since it should not exist
anyway.
.NH 2
Shared Input
.UC SMTP
Bug Tentatively Fixed
.LP
The
.UC SMTP
server routines read delivery requests from stdin.  Each message is
handled by a different process by forking after the
.UC "MAIL FROM:"
command is read.  The parent then sleeps while the child delivers the
message and continues to process more
.UC SMTP
commands thereafter.  Now, both parent and child read from stdin and
share the same file descriptor.  However, they do not share the same
.I _iobuf
that represents the stream, so when the parent starts reading
after the child has died, it reads the very same input that the child
has processed.\**
.FS
Unless stdin is connected to a terminal.
.FE
.PP
There are only two ways out of this.  Either, the parent process don't
fork and delivers all messages itself, or they all read unbuffered.  The
former solution (or a variant thereof) is probably better, but the
latter was easier to implement, so that is what presently have been
done.  Since this causes unnecessary overhead as each character has to
be read with a system call, someone ought to make a better fix for this
eventually.
.NH 2
Optional
.UC BSD
2.9 and 4.2 Compatibility Code
.LP
The Kit includes a set of changes that optionally may be added to make
the 5.51 version of
.I sendmail
run under the Berkeley 4.2 or 2.9 release of
.UX .
The changes neccesary to make it run under 4.2 are very minor and mostly
deal with adding undefined symbols.  The 2.9 changes are fewer than you
would expect, although it still is necessary to drastically trim down
the size of
.I sendmail 's
buffers if you intend to run it on a
.UC PDP -11.
The 2.9 changes are all enclosed under the
.UC BSD 29
define.
.PP
.NH 2
Miscellaneous Changes
.LP
In addition to what already has been mentioned, a set of changes has
been included that only add minor functionality or deal with less
important bugs in the original source.  They are further described in
.I "Appendix A: List of Affected Files" .
.NH
CONCLUSION
.LP
The development of the IDA Sendmail Enhancment Kit has been going on
more or less continuously for over two years.  Many were the interim
versions and many were the nights spent testing the newly configured
system.  Still, it is our feeling that the current version is complete
enough to be considered generally useful, and it is our sincere hope
that you have found your time spent reading this document worthwhile.
.PP
The problems with complex hybrid addresses are parts of the growing
pains of a rapidly expanding world of interconnecting computer networks.
It is this author's opinion that it ultimately will be necessary to
agree on some common way of identifying message originators and
recipients.  In the mean time, we will have to face the world as it is
and try to relieve users' pains as much as possible by letting the MTAs
worry about routing and foreign addressing format issues.
.PP
An excellent source for further reading is John Quarterman's and Hosiah
Hoskins' article
.I "Notable Computer Networks"
\&
.[[
%A John Quarterman
%A Hosiah Hoskins
%T Notable Computer Networks
%J Communications of the ACM
%V 29
%N 10
%D 1986
.]],
which gives a thorough overview of existing major computer networks and
supplied services around the world, with an emphasis on electronic mail.
Their survey has been an invaluable source of information for this
author among others.
.PP
Electronic mail is truly an interesting medium.  It combines the speed
of the telephone with the asychronacity of the written letter.  In
addition, it gives possibilities for developing all sorts of interesting
computerized communication services, such as electronic conferencing
systems and database or expert systems consultation services.  But above
all, it communicates across all boundaries with no respect to operating
systems or computer brands.  It may not always be painless, but that can
be improved.  As long as we communicate, everything can be improved.
.QQ
.ad r
.I
The Mail Connectivity Conspiracy Continues\|.\|.\|.\|\c
.R
\&
.[[
%A Mark Crispin
%T (Private Communication)
%D 1986
.]]
.br
.ad b
.AP A
LIST OF AFFECTED FILES
.LP
This is description of all changes made to the
.I sendmail
source files.
.SH
.UL "Nameserver Default Argument"
.JB daemon.c
Changed to return
.UC TRUE
if
.I gethostbyname (3)
succeeds and
.UC FALSE
if not.
.JB parseaddr.c
Changed to interpret the
.B $:
.I default
argument and to take care of the returned value of
.I maphostname .
.SH
.UL "Direct Access to Dbm(3) Files"
.JB alias.c
Changed to allow access using the
.SQ @
database.
.JB conf.c
Changed to initialize all databases to
.UC DB_NOTYETOPEN .
.JB daemon.c
The lookup function
.I mapkey
goes here.  It takes four arguments:
.I db ,
the character denoting the database,
.I key ,
the lookup string and buffer in which a result is returned,
.I keysiz ,
the maximum size of the key buffer, and
.I arg ,
which either should be a character string or
.UC NULL .
The function returns
.UC TRUE
if a match could be found and
.UC FALSE
otherwise. The debugging flag 60 may be used to trace database lookups.
.JB main.c
Added mappings of
.B $(
and
.B $)
to
.UC KEYBEGIN
and
.UC KEYEND .
.JB parseaddr.c
Added code to interpret \fB$(\fP\|.\|.\|.\|\fB$)\fP
constructs.
.JB readcf.c
Added understanding of the
.SQ K
option.
.JB sendmail.h
Added definitions for the macro characters 
.UC KEYBEGIN
and 
.UC KEYEND .
Added the declaration of the global database file table DbmTab.
.SH
.UL "Batched \s-1SMTP\s+1 Support"
.JB main.c
Added the
.UC MD_BSMTP
option and the usage of
.I bsmtp
as an alternate name of
.I sendmail
that automatically will turn on the
.UC MD_BSMTP
mode.
.JB sendmail.h
Added the
.UC MD_BSMTP
define.
.JB srvrsmtp.c
Added the
.I batched
argument (boolean) to the
.I smtp 
function and changes that will make it mail
back errors is
.I batched
is set.
.JB usersmtp.c
Changed the code to automatically generate internal
.UC SMTPGOODREPLY
(\fB250\fP)
reply codes to all
.UC SMTP
commands if the
.UC M_BSMTP
mailer flag is set.
.SH
.UL "Separate Envelope/Header Rewriting Rulesets"
.JB headers.c
Changed to propagate a flag telling if this is an envelope or header
address for
.I remotename
to rewrite.
.JB main.c
Trace statement changed to display mailers' envelope and header specific
rulesets.
.JB parseaddr.c
Added a boolean
.I headeraddress
argument to
.I remotename
and code to distinguish between envelope and header rewriting.
.JB queue.c
Set both envelope and header rewriting rulesets to -1 in
.I nullmailer .
.JB readcf.c
Made it parse the
.SQ /
option and the extended mailer ruleset specification syntax.
.JB sendmail.h
Extended the mailer declaration to include both envelope and header
specific rulesets.
.SH
.UL "Separate Local \s-1UUCP\s+1 Host Name"
.JB deliver.c
Used when producing
.DQ From_
lines.
.JB main.c
Added the definition of
.B $k
to the initial value of
.B $w .
.JB parseaddr.c
Used when making addresses
.UC UUCP
relative.
.SH
.UL "Return Path for \s-1UUCP\s+1 Mailers"
.JB deliver.c
Changed to look for the mailer flag
.UC M_FROMPATH
when producing the
.UC UUCP
.DQ From_
lines.
.SH
.UL "\s-1UUCP\s+1 Header Address Relativization"
.JB parseaddr.c
Changed to
.I uurelativize
addresses after ruleset 4 has been applied if the
.U M_RELATIVIZE
mailer flag is set.  The actual
.I uurelativize
is here too.
.JB sendmail.h
Defined the
.UC M_RELATIVIZE
flag to be 'V'.
.SH
.UL "Support for Multi-Token Class Matches"
.JB parseaddr.c
Crude code added to enable multi-token class matches.
.SH
.UL "Support for Embedded Subruleset Calls"
.JB parseaddr.c
Wrote a separate
.I callsubr
function to take care of subruleset calls.
.SH
.UL "Elaborate Matching Algorithm for Unknown Local Recipients"
.JB recipient.c
Added the 
.I partialstring
matching routine and code that calls it for unknown local recipients.
.SH
.UL "Support for Maryland's mdbm Package"
.JB alias.c
Changed to be independent on which package is being used.
.JB conf.h
Added the
.UC MDBM
define, to be used if the mdbm routines should be used instead of the
ndbm. 
Note that
.UC NDBM
still should be defined.
.JB mdbm_compat.h
A mdbm compatibility file, used to define macros which map ndbm
functions to their mdbm equivalents.
.JB sendmail.h
Added mdbm compatibility macros and generalized the dbm code in general.
.SH
.UL "Improved Test Mode Output"
.JB main.c
Changed it to export the macros' symbolic names.
.JB parseaddr.c
Changed it to call
.I printcav
instead of
.I printav
when tracing the rewriting rules.
.JB sendmail.h
Included main.c's macro table among the global variables.
.JB util.h
Changed it to print macros using their symbolic names.  Added the
.I printcav
function, which prints argument vectors without enclosing quotation
marks.
.SH
.UL "Better To: and Cc: Headers of Returned Messages"
.JB savemail.c
Changed the code to produce the above result.
.SH
.UL "Queue Bug Fixed"
.JB queue.c
Set the current envelope's id to
.UC NULL
before exiting.
.SH
.UL "Shared Input \s-1SMTP\s+1 Bug Tentatively Fixed"
.JB main.c
Turned off buffering from standard input before the call to
.I smtp .
.SH
.UL "Optional \s-1BSD\s+1\&4.2 Compatibility Code"
.JB conf.h
Added the definition of
.I sigmask
if left undefined by <signal.h>.
Added mock definitions for
.UC LOG_MAIL ,
.UC TRY_AGAIN ,
and
.I h_errno .
.SH
.UL "Optional \s-1BSD\s+1\&2.9 Compatibility Code"
.JB conf.h
Added the definition of 
.UC EPROCLIM
(not really applicable under
.UC BSD
2.9) and the inclusion of ../lib/libndir/dir.h.
.JB conf.c
Changed to include <a.out.h> instead of <nlist.h>, and to search /unix
instead of /vmunix for kernel symbols.
.JB daemon.c
Changed to use
.I gethostname (3)
instead of <whoami.h> to find out its local host name.
.JB deliver.h
Changed not to include <netdb.h>
.JB err.c
Changed not to include <netdb.h>
.SH
.UL "Miscellaneous Changes"
.JB deliver.c
An array of verbose mailer error messages has been added together with
code that prints out the error in text instead of just giving the code
in numeric form.  [Incorporated from
.UC USENET ]
.JB main.c
A new
.B \-Z
command line option has been added, which defines the name of the frozen
configuration file in analogy with
.B \-C .
.JB parseaddr.c
Has been changed to compare aliased users with
.I sameword
instead of
.I strcmp
to make up for differencing case.
.JB sendmail.h
The reference to <sys/syslog.h> has been replaced by <syslog.h> unless
sendmail is compiling on a
.UC VAX .
I'm not sure that this is correct, but neither our Suns, nor the Gould
had syslog.h in that directory.  Also,
.I s_host ,
has been forced undefined if compiling on a Sun.  This is because it is
defined in one of the Sun's include files as well.
.JB srvrsmtp.c
The
.B $s
macro was set to be the name of the remote host, but then cleared before
it could be used.  It is now being set
.I after
the relevant cleanup routines have been run.  An unnecessary additional
rewriting of envelope recipient addresses in the
.UC SMTP
routines has been removed.  It could even be harmful if it was to be
left alone.
.JB ../doc/op.me
Added text to describe our new, wonderful features.
.AP C
CUSTOMIZATION PARAMETERS
.LP
The following is a list of all
.I m4
identifiers used in the configuration file.
All of them are optional.
.JS ALIASES
Name of the aliases file, defaults to sendmail's default.
.JS BSD29
.br
Activates various hacks for usage on
.UC BSD
2.9 systems.
.JS BANGIMPLIESUUCP
.br
If defined, will inhibit domaintable lookups for unqualified nodes first
in
.SQ ! -paths
and always interpreting them to reside in the
.UC UUCP
pseudo-domain.
.JS DECNETNODES
A file containing
.UC DEC net
host names.  Used in combination with
.UC DECNETXTABLE
to determine delivery through the
.UC DEC net
mailer and when to expand flatspaced
.UC DEC net
host names into domains.
.JS DECNETXTABLE
The
.UC DEC net
translation table.  Returns a node's
.UC DEC net
host name if given its domain name. 
.I Dbm "" (
file, see ruleset 24 for more info).
.JS DEFAULT_HOST
Explicit host name, replaces automatic definition of
.B $w .
[Not normally used]
.JS DEFAULT_DOMAIN
The string that (+ 
.SQ "." )
will be attached to
.B $w
to form
.B $j ,
this node's official domain name.  Should only be left undefined when
your hostname (\fB$w\fP) already contains its domain.
.JS DOMAINTABLE
.I Dbm
database used for hostname canonicalization, i.e.  to find the official
domain name for local or otherwise unqualified hosts.
.JS GENERICFROM
A database mapping actual user names to generic user names.  Used
instead of
.UC HIDDENNET
in a heterogeneous environment.
.JS HIDDENNET
Points to a file containing a list of host names, one per line.  Mail
from users on any of these hosts will have their host names substituted
for our host,
.B $w .
.JS LIBDIR	
.br
The directory that will hold most data files, including
sendmail.{hf,st}; defaults to /usr/lib/mail.
.JS PATHTABLE
The heart & soul of this sendmail configuration\*-the pathalias routing
table in
.I dbm (3)
format, as produced by the
.I pathalias (1)
program.  If you want some kind of routing capabilities, you either
define this or rely on
.UC RELAYHOST/RELAYMAILER .
.JS MAILERTABLE
A
.I dbm
table mapping node names to
.DQ "mailer:host"
pairs.  It is used for special cases when the resolving heuristics of
ruleset 26 aren't enough.
.JS NEWALIASES
If defined, will make ruleset 26 return all addresses as local.  This
should be used by the newaliases program only when parsing the aliases
file if you want to handle non-local aliases as well as local.
.JS PSEUDONYMS
Additional names that we are known under (in addition to the nicknames
returned by
.I gethostbyname (3)).
.JS "RELAY_HOST & RELAY_MAILER"
Name of the host and mailer to ship unknown recipient addresses to.  Not
necessary to define if you have a complete
.UC PATHTABLE .
.JS RSH_SERVER
If defined, do local deliveries by 
.I rsh (1)'ing
/bin/mail on the 
.UC RSH_SERVER
host.
.JS SPOOLDIR
Directory for sendmail queue files; defaults to /usr/spool/mqueue.
.JS UUCPNAME
This node's
.UC UUCP
host name, if different from
.B $w .
.JS UUCPNODES
A file containing names of directly connectable 
.UC UUCP
nodes, normally /usr/lib/uucp/L.sys.
.JS UUCPPRECEDENCE
If defined, will change the interpretation of mixed
.SQ ! -
/
.SQ @ -addresses
to use heuristics instead of always preferring
.UC RFC 822
style.\**
.FS
Not fully tested.
.FE
.JS UUCPRELAYS
Name of file containing names of known 
.UC UUCP ) (
relays.  Header addresses containing paths through any of these will be
shortened by having the path to the relay removed.  (It is assumed that
paths to each of these are known to everybody)
.JS UUCPXTABLE
A table mapping domain node names to 
.UC UUCP
node names. Used in envelope addresses sent using  
.UC UUCP /rmail.
.AP D
LIST OF DOMAINS
.LP
The following is a list of all top-level domains officially registered
with the SRI Network Information Center as of May 13, 1987:
.QQ
.SH
Organizational Domains
.LP
.TS
box;
lI lI
lp-1 l .
Domain	Organizations
_
COM	Commercial
EDU	Educational
GOV	Government
MIL	Military
NET	Network Administrations
ORG	Other Organizations
.TE
.SH
National Domains
.LP
.TS
box;
lI lI
lp-1 l .
Domain	Country
_
AU	Australia
DE	Germany
FI	Finland
FR	France
IL	Israel
JP	Japan
KR	Korea
NO	Norway
NL	The Netherlands
NZ	New Zealand
SE	Sweden
UK	The United Kingdom
US	The United States of America
.TE
.SH
Network Domains
.LP
.TS
box;
lI lI
lp-1 l .
Domain	Network
_
ARPA	The Advanced Research Projects Agency Network
.TE
which is the only officially registered network domain, but others more
or less widely recognized are:
.TS
box;
lp-1 l .
BITNET	IBM Network, includes \s-1NETNORTH\s+1 and \s-1EARN\s+1
CSNET	The Computer Science Network
JUNET	The Japanese University Network
MAILNET	A now deceased(?) networking project centered around \s-1MIT-MULTICS\s+1
OZ	The Australian Computer Science Network (ACSnet)
SUNET	The Swedish University Network
UNINETT	The Norwegian University Network
UUCP	The \s-1UNIX\s+1-to-\s-1UNIX\s+1-Copy Network
.TE
.AP F
LIST OF DATA FILES
.LP
The following is a list of all data files used by the
.I sendmail
program in conjunction with the supplied configuration file.  Not all of
them are used in the sample setup.  Not all of them will probably be
needed by your setup either.
.JB aliases
\&.\|.\|.is better described in
.I aliases (5).
.JB domaintable
\&.\|.\|.is domain name table used when finding a node's canonical name.
It is written in
.I dbm (1)
.B parse
format.
.JB generics
\&.\|.\|.is automatically produced by the
.I xalparse (8)
program from the xaliases file.  It contains entries mapping sending
user's real addresses to generic ones.
.JB hiddennet
\&.\|.\|.may contain a list of node (domain) names that should be hidden
by the local host's name on header sender addresses.
.JB mailertable
\&.\|.\|.defines the mapping from node (domain) names to
.I "Special Mailers" .
It is written in
.I dbm (1)
.B parse
format, with each value being a
.DQ mailer:host
tuple.
.JB newaliases.cf
\&.\|.\|.is a configuration file produced by having defined the
.UC NEWALIASES
identifier in the master file.  This should only be used when producing
a new
.I aliases (5)
dbm table, because it returns all addresses to the
.UC LOCAL
mailer in order to accept non-local aliases.
.JB pathtable
\&.\|.\|.is the basis for all explicit routing decisions.  It is written
in
.I pathalias (1)
format and describes how systems connect to each other and where to
forward according to (parent) domains.
.JB xaliases
\&.\|.\|.is the extended aliases file that is used to produce the
.I aliases (5)
file together with the
.I generics
file.  It is further described in the section about
.I "Managing Generic Mail Addresses" .
.JB \\\\\\\\k:\fInetwork\fB/nodes\\\\\\\\h'|\\\\\\\\n:u'\\\\\\\\v'+1'\fInetwork\fB/xtable\fR\\\\\\\\v'-1'
.\".JB \fInetwork\fB/nodes\fR
.\"\&.\|.\|.and.\|.\|.
.\".br
.\".ti -\n(I\n(IRu
.\".B \fInetwork\fB/xtable\fR\t\c
\&.\|.\|.are used when translating node names from one network to
another.  The
.B nodes
file contain all internally known node names for the network and
.B xtable
is a translation table that maps official domain names to the network's
internal node names.
.JB uucp/relays
\&.\|.\|.contains node names of well-known
.UC UUCP
relays.  It is used when compressing header paths in the header
rewriting rulesets.
.AP I
INSTALLATION INSTRUCTIONS
.LP
These instructions will tell you step-by-step how to install and bring
the Kit's
.I sendmail
system up.  The source code modifications are given as context
.I diff (1)'s,
based on the
.UC BSD
4.3 release of
.I sendmail
(version 5.11), ready to be installed using Larry Wall's eminent
.I patch
program.  You will also need Maryland's
.I mdbm
library if you intend to use this instead of
.I ndbm .
Finally, in order to automatically produce routing tables, you will need
Peter Honeyman's
.I pathalias
program.  All of these are available from your nearest
.UC USENET
.B comp.sources.unix
archive.
.PP
Now, assuming that you have read this far and made up your mind to try
it all for yourself, do the following:
.II 1
Unpack the Kit in the
.B sendmail
directory (preferably).  This should give you a new
.B ida
subdirectory with all the Kit's files.
.II
Goto
.B sendmail/ida
and check that you agree with the Makefile's definitions.  If you change
anything, do a
.DQ "make configure"
to propagate those changes to the subdirectories' Makefiles.
.II
Goto
.B sendmail/ida/doc .
Doing
.DQ "make doc"
will print out this paper but since you already are reading it, this
might be unneccesary.  Anyway, do
.DQ "make man"
to print the manual pages.  Do
.DQ "make install"
to install them in your manuals directory.
.II
Goto
.B sendmail/ida/patches
and do
.DQ "make backup."
This will create a backup copy of
.B sendmail/src/*.[hc]
and
.B sendmail/doc/op.me
in
.B Backup.tar .
You can restore them if necessary by performing
.DQ "make restore,"
still in the patches directory.
.II
Do one of
.DQ "make bsd43,"
.DQ "make bsd42,"
or
.DQ "make bsd29"
to patch the
.I sendmail
source to the required compatibility level.  You will need
.I patch (1),
for this or else edit the files by hand.  Look out for rejected patches.
.II
Goto
.B sendmail/src
and recompile
.I sendmail .
See that it still works.  Your old configuration file
.I should
still work unless you depend on some obscure side effects.  Note that a
.UC BSD
4.2 configuration file might not work with
.I sendmail
5.11.
.II
Goto
.B sendmail/ida/aux
and do
.DQ "make"
to compile the auxiliary programs.  Try them out, guided with the newly
printed manual pages.
.II
Do
.DQ "make install"
to install the programs in
.UC BINDIR
(\fB/usr/local/bin\fP by default; but another choice would be
.B /usr/lib/mail
if you only intend to use them with this kit).  It's also about time to
(manually) do a (symbolic) link from
.B /usr/ucb/bsmtp
to
.B /usr/lib/sendmail
if you intend to receive batched
.UC SMTP
mail.
.II
Goto
.B sendmail/ida/cf
and inspect the supplied
.I m4 (1)
configuration definitions.  Send
.B Sendmail.mc
to your line printer and study it.  Do
.DQ "make"
to see how the sample configurations look expanded.
.II
Goto
.B sendmail/ida/lib
and inspect the supplied sample data files.  Try applying the
.I xalparse
program on the
.I xaliases
file if you feel like it.
.II
Determine your site's routing capabilities and create your corresponding
data files in
.UC LIBDIR .
Go back to
.B sendmail/ida/cf
and create your own
.I m4 (1)
configuration file using the samples as templates.  Produce an actual,
personal
.B sendmail.cf
file.
.II
Try out your new
.I sendmail
system.
.br
Good Luck!
.FS [\\n+(II]
Mail problems or comments to lel@ida.liu.se.
.FE
.AP P
LIST OF AUXILIARY PROGRAMS
.LP
All programs but
.I scanf
are further described by their manual pages.  What you find here is only
a short overview of their functionality.
.JB dbm
A general
.I dbm (3)
database management tool.  Clears, loads, and dumps complete databases.
Stores, fetches, and deletes individual keys.  Also includes a special
parser that produces key/value pairs from a compressed but easily
readable format.
.JB mkdomext
Make the extended set of domain names.  This program acts as a filter
that, when supplied with fully qualified domain names on stdin, will
generate all legal abbreviations of these on stdout with respect to the
parent domains given on the command line.  It is used to be able to
recognize unqualified local subdomains and sibling domains from one or
more positions in the domain hierarchy.  See
.UC RFC 822,
section 6.2.2 for a rationale.
.JB rmail
Yet another implementation of the remote mail receiving program.  This
time with raw header line logging together with
.I dbm
lookup of remote node names and a more liberal parsing of
.DQ "From_"
lines.  Needs to run
.DQ "seteuid root"
to be able to use the macro setting options of
.I sendmail .
No new manual supplied, your old one will have to do.  Actually, your
old rmail itself will probably do too.
.JB scanf
Quick hack to scan and extract substrings from input lines using the
.I scanf (3)
function.  No manual page, the source code is self documenting.
.JB xalparse
A program that parses an extended aliases file and produceces an ordinary
aliases file together with a file with generic address translations.
It's all described in the manual page and in the section about
.I "Managing Generic Mail Addresses" .
Quod vide.
.AP R
REFERENCES
.LP
.[
$LIST$
.]
.AP T
TABLE OF CONTENTS
.SH
Sections
.LP
.X1 "\(sc 1" "INTRODUCTION"
.X1 "\(sc 2" "NAMES, ADDRESSES, AND ROUTES"
.X1 "\(sc 3" "MAIL ADDRESS FORMATS"
.X2 "\(sc 3.1" "Relative Addresses"
.X2 "\(sc 3.2" "Absolute Addresses"
.X2 "\(sc 3.3" "Attribute Addresses"
.X2 "\(sc 3.4" "Hybrid Addresses"
.X1 "\(sc 4" "A SHORT ANATOMY OF THE ELECTRONIC MESSAGE"
.X2 "\(sc 4.1" "The Envelope"
.X2 "\(sc 4.2" "The Headers"
.X1 "\(sc 5" "ADDRESS REWRITING STRATEGIES"
.X2 "\(sc 5.1" "Sneak-In Preview"
.X2 "\(sc 5.2" "The Configuration File"
.X2 "\(sc 5.3" "Canonicalizing the Address"
.X2 "\(sc 5.4" "Finding Route and Mailer"
.X2 "\(sc 5.5" "Externalizing the Address"
.X1 "\(sc 6" "MANAGING GENERIC MAIL ADDRESSES"
.X1 "\(sc 7" "SENDMAIL SOURCE MODIFICATIONS"
.X2 "\(sc 7.1" "Nameserver Default Argument"
.X2 "\(sc 7.2" "Direct Access to Dbm(3) Files"
.X2 "\(sc 7.3" "Batched \s-1SMTP\s+1 Support"
.X2 "\(sc 7.4" "Separate Envelope/Header Rewriting Rulesets"
.X2 "\(sc 7.5" "Separate Local \s-1UUCP\s+1 Host Name"
.X2 "\(sc 7.6" "Return Path for \s-1UUCP\s+1 Mailers"
.X2 "\(sc 7.7" "\s-1UUCP\s+1 Header Address Relativization"
.X2 "\(sc 7.8" "Support for Multi-Token Matches"
.X2 "\(sc 7.9" "Support for Embedded Subruleset Calls"
.X2 "\(sc 7.10" "Elaborate Matching Algorithm for Unknown Local Recipients"
.X2 "\(sc 7.11" "Support for Maryland's Mdbm Package"
.X2 "\(sc 7.12" "Improved Test Mode Output"
.X2 "\(sc 7.13" "Better To: and Cc: Headers of Returned Messages"
.X2 "\(sc 7.14" "Queue Bug Fixed"
.X2 "\(sc 7.15" "Shared Input \s-1SMTP\s+1 Bug Tentatively Fixed"
.X2 "\(sc 7.16" "Optional \s-1BSD\s+1 2.9 and 4.2 Compatibility Code"
.X2 "\(sc 7.17" "Miscellaneous Changes"
.X1 "\(sc 8" "CONCLUSION"
.SH
Appendices
.LP
.X1 "Appendix A" "LIST OF AFFECTED FILES" "Appendix M"
.X1 "Appendix C" "CUSTOMIZATION PARAMETERS" "Appendix M"
.X1 "Appendix D" "LIST OF DOMAIN NAMES" "Appendix M"
.X1 "Appendix F" "LIST OF DATA FILES" "Appendix M"
.X1 "Appendix I" "INSTALLATION INSTRUCTIONS" "Appendix M"
.X1 "Appendix P" "LIST OF AUXILIARY PROGRAMS" "Appendix M"
.X1 "Appendix R" "REFERENCES" "Appendix M"
.X1 "Appendix T" "TABLE OF CONTENTS" "Appendix M"
