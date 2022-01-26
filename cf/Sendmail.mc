##########################################################################
###	The IDA Sendmail Master Configuration File	##################
##########################################################################
###	Lennart_Lovstrand.EuroPARC@Xerox.COM			       ###
###	Rank Xerox EuroPARC, 61 Regent St, Cambridge, England	       ###
###	Copyright (c) 1984-88 -- Use it, abuse it, but don't sell it   ###
##########################################################################
# Current version
DVIDA-1.2.5
changequote({,})

####### INTRODUCTION #####################################################
#
#	This is The IDA Sendmail Master Configuration File--a completely
#	independent development having nothing to do with the version
#	distributed by Berkeley.  In order to work properly, it requires
#	a set of new functions implemented by the IDA Sendmail Enhancement
#	Kit, available from your nearest comp.sources.unix archive.
#
#	Get it today, tomorrow they might have a disk crash!

#	IDA is an abbreviation of "Institutionen for Datavetenskap",
#	which is Swedish for "The Department of Computer and Information
#	Science".  Under no circumstance should it be confused with the
#	IDA that stands for the Institute for Defense Analysis, with
#	which the author has no relationship to nor wish to become
#	associated with.


####### REWRITING STRATEGIES #############################################
#
#	Ruleset 3 completely canonicalizes addresses to an internal
#	format which looks like "user@.domain", including the dot
#	after the atsign.  The "user" part may end up containing a
#	route in either standard RFC822 format or using the %-kludge.
#	The "domain" will be mapped to its full, official domain name
#	using the TCP/IP name server and a dbm domaintable.  !- and
#	::-style paths are rewritten into RFC822 routes internally.
#	Resonable mixtures of !-, %-, and RFC822 routes are resolved,
#	either using straight domain preference, or using heuristics.
#	Some effort is made to repair malformed addresses.
#
#	This format is used in all internal rulesets until finally
#	rewritten by the mailer dependant rules, where they are fully
#	transformed into the mailer's preferred address syntax.  Three
#	kinds of mailers currently exist:
#
#	[1]  Domain based mailers, for which the official domain names
#	     are used and routes are given in the %-format for header
#	     addresses and envelope recipient addresses, while
#	     envelope return paths are kept in RFC822 route syntax.
#	     Typical examples of this type are the TCP/IP and LOCAL
#	     mailers.
#
#	[2]  Domain based mailers with flat node name mappings.  These
#	     use full domain names in header addresses but translate
#	     envelope domains to names relative the actual network's
#	     name space.  Two mailers fit into this category: The DECnet
#	     mailer, which map domain names to DECnet names, and the
#	     UUCP-A/B mailers, which map domains to UUCP node names.
#	     Both the DECnet and the UUCP worlds use flat namespaces.
#	     The DECnet and the UUCP-B mailers essentially uses type I
#	     routes while the UUCP-A mailer uses type III routes (ie,
#	     !-paths).
#
#	[3]  UUCP !-path based mailers.  This mailer type rewrites all
#	     addresses into !-paths, both header and envelope addresses.
#	     Header addresses are made relative the remote node by
#	     removing "remote!" from them or prefixing "localhost!" to
#	     them. UUCP nodes with domain names are translated to their
#	     UUCP equivlanents.


####### SENDMAIL CONFIGURATION EXTENSIONS ################################
#
#	This is a short table describing extensions to the configuration
#	language.  See the reference guide for a detailed definition.
#
#	Option "/" will turn on general envelope/header specific
#	rewriting.  Mailer specific e/h rulesets are given as in
#	"R=14/15", where ruleset 14 is used for envelope recipient
#	addresses and ruleset 15 for header recipients.
#
#	The M_FROMPATH (p) flag will work for mailers that use "From_"
#	line envelopes as well as SMTP mailers.
#
#	The M_RELATIVIZE (V) flag has been added, which make all header
#	lines relative the recipient host by removing "remote!" or
#	adding "localhost!".
#
#	TCP/IP nameserver lookups are extended with a default argument,
#	as in "$[ hostname $: default $]".  The "default" string will be
#	returned if the host isn't known to gethostname(3).
#
#	General dbm database functions have been added.  The option "K"
#	will declare a dbm database and associate it with a letter,
#	which later on is used in constructs like:
#		"$(x key $@ arg $: default $)"
#	The "x" is the one-letter name of the database, the "key" is the
#	lookup string; the optional "arg" is then sprintf(3)'ed through
#	the result, if found.  The whole expression evaluates to
#	"default", or "key" if "$: default" is not present, if the "key"
#	can't be found in the database.  The "@" database is
#	automatically connected to the aliases(5) file.


####### M4 IDENTIFIERS ###################################################
#
#	NOTE: Be aware that this is an m4 source where curly braces are
#	used as quote characters.  You will lose heavily if you care-
#	lessly mention reserved m4 words or use curly braces where you
#	shouldn't.
#
#	The following is a list of all m4 identifiers used in this file.
#	All of them are optional.
#
#	ALIASES
#		Name of the aliases file, defaults to sendmail's default.
#	BANGIMPLIESUUCP
#		If defined, will assume that all !-paths with leading,
#		unqualified nodes resides in the UUCP pseudo-domain.
#		Will otherwise try to qualify node using the name server
#		and domaintable, retreating to .UUCP if unknown by them.
#	DECNETNODES
#		A file containing DECnet host names.  Used in combination
#		with DECNETXTABLE to determine delivery through the DECnet
#		mailer and when to expand flatspaced DECnet host names into
#		domains.
#	DECNETXTABLE
#		The DECnet translation table.  Returns a node's DECnet
#		host name if given its domain name.  (Dbm file, see
#		ruleset 24 for more info).
#	DEFAULT_HOST
#		Explicit host name, replaces automatic definition of $w.
#	DEFAULT_DOMAIN
#		The string that (+ ".") will be attached to $w to
#		form $j, this node's official domain name.  Only define
#		this if $w doesn't already include your full domain
#		(ie, as returned by gethostbyname(<yourhost>)).
#	DOMAINTABLE
#		Dbm database used for hostname canonicalization, ie.
#		to find the official domain name for local or otherwise
#		unqualified hosts.
#	GENERICFROM
#		A database mapping actual user names to generic user
#		names.  Used instead of HIDDENNET in a heterogenous
#		environment.
#	HIDDENNET
#		Points to a file containing a list of host names, one
#		per line.  Mail from users on any of these hosts will
#		have the host name substituted for our host, $w.
#	LIBDIR	
#		The directory that will hold most data files, including
#		sendmail.{hf,st}; defaults to /usr/lib/mail.
#	LIUIDA
#		Site specific parts for the CIS Dept, U of Linkoping.
#	PATHTABLE
#		The heart & soul of this sendmail configuration--the
#		pathalias routing table in dbm format, as produced by
#		the pathalias program.  Either you define this or rel(a)y
#		on RELAY_HOST/RELAY_MAILER.
#	MAILERTABLE
#		A dbm table mapping node names to "mailer:host" pairs.
#		It is used for special cases when the resolving heuristics
#		of ruleset 26 aren't enough.
#	NEWALIASES
#		If defined, will make ruleset 26 return all addresses
#		as local.  This should be used by the newaliases program
#		only when parsing the aliases file if you want to be
#		able to handle non-local aliases (ie aliases of type
#		"user@host: whatever").  Note that you can't let
#		sendmail rebuild the database automatically if this is
#		the case or else those aliases will be thrown away.
#	PSEUDODOMAINS
#		A list of well-known top level pseudo domains such as
#		BITNET, CSNET, UUCP, etc.  Addresses ending with a top
#		level domain in this class won't be canonicalized using
#		the resolver to reduce load on the root name servers.
#		Note that this variable is independent of the T class
#		below.  Any "well-known" top level domain that is not
#		part of NIC's registered domains may be put here.
#	PSEUDONYMS
#		Additional names that we are known under (in addition
#		to those returned by gethostbyname()).
#	RELAY_HOST & RELAY_MAILER
#		Name of the host and mailer to ship unknown recipient
#		addresses to.
#	RSH_SERVER
#		If defined, do local deliveries by rsh'ing /bin/mail
#		on the RSH_SERVER host.  Make sure that root is allowed
#		to remotely login to the server.
#	SPOOLDIR
#		Directory for sendmail queue files; defaults to
#		/usr/spool/mqueue.
#	STRICTLY822
#		This flag will guide the interpretation of mixed (hybrid)
#		!/@ addresses.  If left undefined, we will look at the
#		protocol used to receive the message and interpret
#		accordingly (! takes precedence for UUCP; @ for others).
#		If you define STRICTLY822, all mixed addresses will be
#		interpreted as path@host.
#	TCPMAILER
#		The default TCP mailer to use for SMTP/TCP deliveries.
#		Defaults to TCP (as opposed to TCP-D or TCP-U, qv).
#	UUCPMAILER
#		The default UUCP mailer to use for UUCP deliveries.
#		Defaults to UUCP (as opposed to UUCP-A or UUCP-B, qv).
#	UUCPNAME
#		This node's UUCP host name, if different from $k.
#	UUCPNODES
#		A file containing names of directly connectable UUCP nodes.
#	UUCPPRECEDENCE
#		This option has been obsoleted by checking the receiving
#		protocol when resolving mixed !/@ addresses.  Define
#		STRICTLY822 to disable this.
#	UUCPRELAYS
#		Name of file containing names of known (UUCP) relays.
#		Header addresses containing paths through any of these
#		will be shortened by having the path to the relay removed.
#		(It is assumed that paths to each of these are known to
#		everybody)
#	UUCPXTABLE
#		A table mapping domain node names to UUCP node names.
#		Used in envelope addresses sent using UUCP/rmail.
#
#  The following are still experimental:
#	XEROXGV & XEROXNS
#		Default gateways for unspecified Xerox Grapevine and XNS
#		addresses.
#	XNSDOMAIN
#		The name of the XNS Gateway domain {from the XNS side}.
#	XNSMAIL
#		The name of your XNS Mail Gateway program.


####### CLASSES, DEFINITIONS, and DATABASES ##############################
#
#	The following classes, macro definitions and keyed databases are
#	being used:
#
#	CA	An atsign (@), used in class membership negations
#	CD	Known DECnet host names (see DECNETNODES above)
#	CH	Node names that should be hidden by $w (see HIDDENNET above)
#	CP	Known top level pseudo domains (see PSEUDODOMAINS above)
#	CR	Removeable relays from header addresses (see UUCPRELAYS above)
#	CT	Known top level domains (global + local)
#	CU	Directly connectable UUCP nodes
#	CX	A set of chars that delimit the LHS of a domain (@ %)
#	CY	A set of chars that delimit the RHS of a domain (, : % @)
#	CZ	RFC822 Source Route punctuation chars (, :)
#
#	DV	Configuration version number
#
#	OK@	The aliases database (automatically defined; see ALIASES above)
#	OKD	DECnet domain translation table (see DECNETXTABLE above)
#	OKG	Generic usernames (see GENERICFROM above)
#	OKM	Special domain => mailer:host table (see MAILERTABLE above)
#	OKN	Official name lookup table (see DOMAINTABLE above)
#	OKP	Pathalias routing database (see PATHTABLE above)
#	OKU	UUCP domain translation table (see UUCPXTABLE above)


##########################################################################
## Default Definitions ###################################################
##########################################################################
ifdef({LIBDIR},,{define(LIBDIR, /usr/lib/mail)})
ifdef({SPOOLDIR},,{define(SPOOLDIR, /usr/spool/mqueue)})
ifdef({TCPMAILER},,{define(TCPMAILER, TCP)})
ifdef({UUCPMAILER},,{define(UUCPMAILER, UUCP)})
ifdef({UUCPPRECEDENCE},
	{errprint({Note: UUCPPRECEDENCE is obsolete, please see Sendmail.mc})})

#
##########################################################################
## Domain Definitions ####################################################
##########################################################################

##########################################################################
#	Universally known top-level domains

#					Organizational domains
CTcom edu gov org mil net
#					National domains
CTau ar at be ca cdn ch cl de dk es fi fr ie il irl is it jp kr
CTmy nl no nz pg se uk us
#					Network based domains
CTarpa bitnet csnet junet mailnet uucp

##########################################################################
#	Well-known pseudo domains
#	(that the resolver shouldn't be bothered with)

ifdef({PSEUDODOMAINS},{
{CP}PSEUDODOMAINS
})

##########################################################################
## Misc Definitions ######################################################
##########################################################################

ifdef({DEFAULT_HOST},
# This node's local host name
{Dw}DEFAULT_HOST)

# This node's official domain name
ifdef({DEFAULT_DOMAIN},
{Dj$w.}DEFAULT_DOMAIN,
Dj$w)

ifdef({PSEUDONYMS},
# Other names for this node
{Cw}PSEUDONYMS)
Cw$k

# my name
DnMAILER-DAEMON

# UNIX header format
DlFrom $g $d

# delimiter (operator) characters
Do".:;%@!=/[]?#^,<>"

# Characters that mark the left (X) & right (Y) hand side of a domain
CX@ %
CY, : % @

# Pure RFC822 route punctuation characters
CZ, :

# The atsign-in-a-class
CA@

# Format of a total name: Personal Name <user@domain>
Dq$?x$!x <$g>$|$g$.

# SMTP login message
DeWelcome to IDA Sendmail $v/$V running on $j


##########################################################################
#	Options

#				set default alias file
ifdef({ALIASES},{OA}ALIASES)
#				time to look for "@:@" in alias file
Oa15
#				substitution for blank character
OB.
#				don't connect to "expensive" mailers
Oc
#				delivery mode
Odb
#				rebuild alias database as needed
# OD
#				set error processing mode
# Oe
#				temporary file mode
OF0600
#				save Unix-style From lines on front
# Of
#				default gid
Og1
#				help file
{OH}LIBDIR/sendmail.hf
#				ignore dot lines in message
# Oi
#				database files
ifdef({DECNETXTABLE},{OKD}DECNETXTABLE)
ifdef({GENERICFROM},{OKG}GENERICFROM)
ifdef({MAILERTABLE},{OKM}MAILERTABLE)
ifdef({DOMAINTABLE},{OKN}DOMAINTABLE)
ifdef({PATHTABLE},{OKP}PATHTABLE)
ifdef({UUCPXTABLE},{OKU}UUCPXTABLE)
#				log level
OL9
#				define macro
# OM
#				send to me too
Om
#				local network name
ifdef({DEFAULT_DOMAIN},{ON}DEFAULT_DOMAIN)
#				assume old style headers
Oo
#				postmaster copy of returned messages
OPPostmaster
#				queue directory
{OQ}SPOOLDIR
#				read timeout -- violates protocols
Or30m
#				status file
{OS}LIBDIR/sendmail.st
#				be super safe, even if expensive
Os
#				queue timeout
OT4d
#				time zone name
# OtMET,MET DST
#				set default uid
Ou1
#				run in verbose mode
# Ov
#				wizard's password
OW*
#				load avg at which to auto-queue msgs
Ox3
#				load avg to auto-reject connections
OX8
#				fork when running the queue
# OY
#				use separate envelope/header rewriting rulesets
O/

##########################################################################
#	Message precedences

Pfirst-class=0
Pspecial-delivery=100
Pjunk=-100

##########################################################################
#	Trusted users

Troot
Tdaemon
Tuucp

##########################################################################
#	Header Formats

#HReceived: $?sfrom $s $.by $j; $b
HReceived: $?sfrom $s $.by $j$?r with $r$.
	($v/$V) id $i; $b
H?P?Return-Path: <$g>
H?D?Date: $a
H?F?From: $q
H?x?Full-Name: $x
H?M?Message-ID: <$t.$i@$j>


#
##########################################################################
## Mailer Specifications #################################################
##########################################################################

##########################################################################
#
#	Local & Prog mailer definitions

# List of nodes that should be hidden by our name (header senders)
ifdef({HIDDENNET},{FH}HIDDENNET)

ifdef({RSH_SERVER}, {
Mlocal,	P=/usr/ucb/rsh, F=DFMlmns,	A=RSH_SERVER /bin/mail -d $u
}, {
Mlocal,	P=/bin/mail, F=DFMSlmnrs,	A=mail -d $u
})
Mprog,	P=/bin/csh,  F=DFMhlsu,		A=csh -fc $u


##########################################################################
#
#	TCP/IP mailer specification
#
#	The TCP mailer is the normal choice for SMTP/TCP delivery, but a
#	couple of variations exist for compatibility with mailers that
#	need special address formatting for indirect UUCP and DECnet
#	addresses.  Both has to be explicitly mentioned in the mailertable
#	to be chosen as all normal mail will use the standard TCP mailer.
#
#	TCP-D -- will flatten envelope recipient DECnet domains for
#	messages destinated to our DECnet gateway.   Unfortunately, our
#	(Linkoping) DECnet gateway is too dumb to do this itself.
#
#	TCP-U -- is available for hosts which require hybrid addresses
#	for deliveries to UUCP destinations.  Eg. "bar!foo@desthost" will
#	be translated to "foo%bar@desthost", then to "bar!foo@desthost"
#	[as opposed to just "foo@bar" which is what the standard TCP
#	mailer would have produced].
#
#	Both of the above only touch envelope addresses; header
#	addresses are still kept in our preferred format.  Change the
#	R/S settings below if you don't like that.

MTCP,   P=[IPC], F=CDFMXhnmpu, E=\r\n, A=IPC $h
MTCP-D, P=[IPC], F=CDFMXhnmpu, E=\r\n, R=24/0, A=IPC $h
MTCP-U, P=[IPC], F=CDFMXhnmpu, E=\r\n, R=13/0, S=13/0, A=IPC $h

# Produce hybrid (brr) addresses for unqualified or .UUCP hosts
S13
R$+@.$-			$:$>19 $1@.$2			bangify unqualified
R$+@.$-.UUCP		$:$>19 $1@.$2.UUCP		bangify .UUCP
R$+@.$+			$@ $1@.$2			let normal domains pass
R$+			$@ $1@.$[$&h$]			add rcpt host for paths


##########################################################################
#
#	(Pseudo)DECnet mailer specification
#
#	Send all envelope recipients thru DECnet domain name flattener.

# List of DECnet nodes
ifdef({DECNETNODES},{FD}DECNETNODES)

ifdef({LIUIDA},{
# Since we don't have any Unix boxes with DECnet yet, we cheat...
MDECnet,  P=[IPC], F=CDFMXhnmpu, R=24/0, E=\r\n, A=IPC lisbet.liu.se
})


##########################################################################
#
#	UUCP mailer definitions

# Our UUCP name, if other than $w
ifdef({UUCPNAME},{Dk}UUCPNAME)

# List of known UUCP nodes
ifdef({UUCPNODES},{FU}UUCPNODES)
CU$k

# List of UUCP relays that are to be removed from sender paths
ifdef({UUCPRELAYS},{FR}UUCPRELAYS)

MUUCP,   P=/usr/bin/uux, F=DFMUVShpu, S=19, R=19,    A=uux - -z -r $h!rmail ($u)
MUUCP-A, P=/usr/bin/uux, F=DFMShmpu, S=19/0, R=15/0, A=uux - -z -r $h!rmail ($u)
MUUCP-B, P=/usr/bin/uux, F=BDFMSXhmpu, S=0,  R=15/0, A=uux - -z -r $h!bsmtp

# Canonicalize envelope recipient addresses before UUCP-ifying them.
S14
R$+			$@ $>19$>3 $1

# UUCP-ify address, then move domain back if not UUCP destination
S15
R$+			$: $>19 $1		UUCP-ify
R$+!$+			$: $1?$2		mark first bang
R$+.$=T?$+		$@ $3@.$1.$2		restore if real domain
R$+?$+			$@ $1!$2		just put bang back otherwise

##########################################################################
#
#	XNS Mailer -- this is still experimental.
#

MXNS,  {P=}XNSMAIL, F=CDFMXhnmprsu, R=16/0, S=16/0, A=xnsmail -q -O $u

# Convert address to XNS Object Name.
S16
R$+			$: $>4 $1		first externalize
R{$+@}XEROXNS		$@ $1			this is already an XNS addrs
R$+			$@ {$1:}XNSDOMAIN	add XNS domain for others


#
##########################################################################
## Standard Rewriting Rules ##############################################
##########################################################################

#########################################################################
#									#
#	Rule Set #0:	Mailer Resolving Ruleset			#
#									#
#	This is rather straightforward.  The code should say it all.	#
#									#
#########################################################################
S0

# Digest routes through ourselves
R$+@.$+			$:$>29 $1@.$2			remove routed self

# Try immediate delivery
R$+@.$+			$:$>26 $1@.$2			try to find mailer
R$#$+			$# $1				found one, return it

# Unknown domain, try to find a pathalias route
R$+@.$+			$:$>22 $1@.$2			go get route
R$+@.$+			$:$>29 $1@.$2			remove routed self
R$+@.$+			$:$>26 $1@.$2			now look for mailer
R$#$+			$# $1				success, return it

ifdef({RELAY_HOST}, {
# If we have a RELAY_HOST/RELAY_MAILER, use it
R$+@.$+			${#}RELAY_MAILER $@RELAY_HOST $:$1@.$2
})

# Try TCP/IP otherwise, there might be an MX record for it
# (there should be a way of checking for this)
R$+@.$+		{$#}TCPMAILER $@$2 $:$1@.$2

# Undeliverable recipients--complain loudly & return to sender
R$+@.$-		$#ERROR $:Host $2 not known--please specify domain
R$+@.$-.$*$=T	$#ERROR $:Host $2 not known within the $3$4 domain
R$+@.$+.$-	$#ERROR $:Domain $3 not known--please try to route manually
R@$+		$#ERROR $:"Incomplete Source Route--use <...> format"
R$*		$#ERROR $:Could not parse $1


#########################################################################
#									#
#	Rule Set #1:	[Envelope] Sender Specific Rewriting		#
#									#
#	[Currently nothing.]						#
#									#
#########################################################################
S1


#########################################################################
#									#
#	Rule Set #2:	[Envelope] Receiver Specific Rewriting		#
#									#
#	Turn RFC822 Source Routes into a %-paths since most MTAs	#
#	don't know about how to handle the former format.		#
#									#
#########################################################################
S2

R$+@.$+			$:$>25 $1@.$2		Src Routes => %-routes


#########################################################################
#									#
#	Rule Set #3:	Address Canonicalization			#
#									#
#	Turns the address into the (internally) canonical format	#
#	mailbox@.domain.  The `domain' is what you think it is, but	#
#	the `mailbox' may be either a "real" mailbox in which case	#
#	no further meaning is associated to it, or a route in either	#
#	the Source Route format as specified by RFC822 or the (un-	#
#	documented) Good Ole ARPAnet %-Kludge Format.			#
#									#
#	Input formats include the standard "mailbox@domain" format,	#
#	RFC822 Source Routes, RFC822 Group Names, ARPAnet %-Kludges,	#
#	UUCP !-Paths, the Berknet "host:user" format, the VAX/VMS	#
#	"host::user" format and resonable mixtures of the above.	#
#									#
#	The code even tries to clean up after various mistakes that	#
#	other nodes has done when reformatting the addresses, such	#
#	as mangled Xerox distribution lists or malformatted RFC822	#
#	Group Specifications.						#
#									#
#########################################################################
S3

###
###	First attempt to repair malformed addresses
###

R$*<$+>$*		$2			turn to essentials
R$*<>$*			Postmaster		default user

# These are not for us
R:{include}:$*@$*	$@:{include}:$1@.$2	indirect address
R:{include}:$*		$@:{include}:$1@.$w	indirect address
R$*/$*@$*		$@$1/$2@.$3		file name
R$*/$*			$@$1/$2@.$w		file name

# Fix group names and return them
R$+:;@$+		$:$1:;			remove host info
R$+:			$:$1:;			missing semicolon
R$+!;			$:$1:;			UUCP-style mangled group
R$+!$+:;		$2:;			remove UUCP host info
R$+:;			$@$1:;			Finally return group

# Miscellaneous cleanup (sigh)
R$+!.$+			$1^.$2			fix mangled Xerox dList
R$+::$+			$1!$2			VAX/VMS relative address
R$+!:$+@$+		$1!$3!$2		scrambled source route
R$+!:$+			$1!$2			mangled VAX/VMS address
ifdef({XEROXNS},,{
R$-:$-			$1!$2			Berknet style address
})
R$+:@$+			$1,@$2			slightly malformed src route
R$*$~Z@$+@$+		$1$2%$3@$4		fix user@host@relay
ifdef({LIUIDA},{
Renea!$+!!$+,!$+	enea!$1!!$2,@$3		brutally beaten src route
Renea!$+!!$+:$+!$+	$: enea!$1!$2!$4!$3	seriously smashed src route
Renea!$+!!$+		$: enea!@$2@$1		maddenly messy src route
})
R$+@$+.$=T.UUCP		$1@$2.$3		strip UUCP off foo@bar.EDU.UUCP

# Fix %-kludgified RFC822 source routes (double sigh)
R$+!%$+:$+%$+		$1!%$2:$3@$4		change all %'s into @'s
R$+!%$+,%$+		$1!%$2,@$3
R$+!%$+			$1!@$2

###
###	The address should be in a reasonable format now.
###	Time to resolve mixed !/@ hybrid addresses and !-paths.
###

R$+!$+			$:$>18 $1!$2		resolve UUCP address

###
###	Address should be close to canonical now, give or take
###	the @domain part.  Make it really internal by adding a
###	dot before the [direct] domain (if any).  Also qualify
###	known domain names.
###

# Add dot and put direct host on back for RFC822 Source Routes
R$+			$: $1@			make sure address has atsign
R$+@$+@			$: $1@$2		remove again if already there
R$*@$+			$: $1@.$2		add dot after [direct] domain
R@.$+$=Z$+		$: $3@.$1		tack direct domain on end
R$+@..$+		$: $1@.$2		one dot is enough! (intern fix)

# Routed address (good ol' ARPA version)
R$+%$+@			$:$1@.$2		replace '%' with '@.'
R$+@.$+%$+		$1%$2@.$3		move gaze right

# Sometimes users try to send to RFC822 Source Routes without angle
# brackets.  This will cause the mailer to split the comma-separated
# domain path into separate phony addresses, which all look like
# "@domain".  There's not much to do about it here though.
R@.$+@			$@ @$1			incomplete Source Route

# Automatically route Grapevine and XNS addresses via resp gateways.
# Note that this assumes that there won't be any local users with dots
# or colons in their names; nor any such names in aliases.
ifdef({XEROXGV},{
R$-.$*@			$: {$1.$2@.}XEROXGV	GW for Grapvine User.registry
})
ifdef({XEROXNS},{
R$+:$*@			$: {$1:$2@.}XEROXNS	XNS User:Domain:Organization
})

# No domain, attach default
# (tip: passing it through the domaintable allows us to hide local hosts)
ifdef({DOMAINTABLE},{
R$+@			$: $1@.$(N $w $)	no host/domain, attach default
},{
R$+@			$: $1@.$w		no host/domain, attach default
})

# Try to find official name for domain
R$+@.$*$~P		$: $1@.$[ $2$3 $]	officialize using resolver
ifdef({DOMAINTABLE},{
R$+@.$+			$: $1@.$(N $2 $)	officialize using domaintable
})


#########################################################################
#									#
#	Rule Set #4:	Address PrettyPrinter				#
#									#
#	Does the final prettyprinting before the address is included	#
#	in the message.  (This is essentially a trivial reformatting	#
#	from internal to external format)				#
#									#
#########################################################################
S4

# Remove dot and return RFC822 Source Routes
R@$+@.$+		$@ @$2,@$1
R$+@$+@.$+		$@ @$3:$1@$2

# Remove dot for normal domain addresses
R$+@.$+			$@ $1@$2


#########################################################################
#									#
#	Rule Set #5:	[Header] Sender Specific Rewriting		#
#									#
#	Rewrite RFC822 source routes into %-routes, since most mailer	#
#	UAs can't handle them.  Compact obvious routes, mostly for	#
#	aesthetical reasons.  Possibly hide local nodes behind ourself.	#
#	Substitute generic names for physical senders.			#
#									#
#########################################################################
S5

R$+@.$+			$:$>23 $1@.$2			unsourcify & prettify

# Hide these nodes using our own name
R$+@.$=H		$: $1@.$j

ifdef({GENERICFROM}, {
# Use (canonicalized) generic names for local users
# (Assumes that it never will find a $+@.$+ address in the db, ie. with dot)
R$+@.$+			$: $1@.$2 ? $1@.$2		duplicate
R$+?$+@.$+.$-		$1 ? $(G $2@$3.$4 $: $2@.$3 $)	search db foreach dom
R$+?$+@.$-		$: $1 ? $(G $2@$3 $: $2@.   $)	search for last dom
R$+@.$=w?$+@.		$: $1@.$2 ? $(G $3 $: $3@.  $)	search for locals
R$+@.$+?$+@.$*		$@ $1@.$2			not found
R$+?$+			$@ $>3 $2			found, canonicalize
})


#########################################################################
#									#
#	Rule Set #6:	[Header] Receiver Specific Rewriting		#
#									#
#	Rewrite RFC822 source routes into %-routes, since most mailer	#
#	UAs can't handle them.  Compact obvious routes, mostly for	#
#	aesthetical reasons.						#
#									#
#########################################################################
S6

R$+@.$+			$:$>23 $1@.$2			unsourcify & prettify


#
##########################################################################
## General Rewriting Rule Subroutines ####################################
##########################################################################

#########################################################################
#									#
#	Rule Set #18:	Resolve mixed (hybrid) !/@ addresses		#
#									#
#	Given an address like a!b@c, resolve it into either a->c->b	#
#	(UUCP style !-precedence) or c->a->b (others, @-precedence).	#
#	Pure UUCP !-paths (ie without domain part) are also handled.	#
#	Used by ruleset 3 *before* the address has been put into	#
#	into internal canonical format (ie. no dot after atsign).	#
#									#
#########################################################################
S18

# Case 0: !-prefixed RFC822 source route--extend to complete source route
R$+!$+!@$+		$1,@$2!@$3		!-path to ,@-route
R$+!@$+			$: @$1,@$2		including first & last !-host

ifdef({STRICTLY822},,{
# Case 1: Let ! take precedence if protocol is UUCP
R$~A$*!$+@$+		$: $1$2!$3@$4?$&r	attach protocol
R$~A$*!$+@$+?UUCP	$@$>21 $1$2!$3%$4@	UUCP: ! takes precedence
R$~A$*!$+@$+?$*		$: $1$2!$3@$4		remove protocol
})

# Case 2: Let @ take precedence for others
#     (2a -- !-path on top of %-route on top of @-domain (ugh!))
R$~A$*!$+%$+@$+		$: $1$2?$3%$4@$5	mark first bang
R$+?$+!$+%$+		$1!$2?$3%$4		find rightmost
R$+?$+%$+%$+@$+		$3!$1?$2%$4@$5		move %hosts around
R$+?$+%$+@$+		$@$>21 $4!$3!$1!$2@	now send it thru unbanger
#     (2b -- Domain address without %-route)
R$~A$*!$+@$+		$@$>21 $4!$1$2!$3@	@ takes precedence

# Case 3: Pure UUCP-path
R$~A$*!$+		$@$>21 $1$2!$3@		pure UUCP style


#########################################################################
#									#
#	Rule Set #19:	Translate domain addresses to UUCP !-paths	#
#									#
#	Takes an domain style address as input and transforms this	#
#	into a !-path.  There will be no atsign left in the address	#
#	after this, but there may(?) still be a percent sign.		#
#	Routes are specially processed, trying to qualify all non-	#
#	qualified nodes in the path.  This is to make sure local nodes	#
#	will have their proper domains properly attached before the	#
#	messages leavs us.  I'm not sure if this is a good thing or	#
#	not, since they may not be local at all.  UUCP nodes with	#
#	domain style names are qualified, anyway.			#
#									#
#########################################################################
S19

# Don't touch groups!
R$+:;			$@ $1:;			return groups

# Translate RFC822 Source Routes FULLY into !-path format
R$+@$+@.$+		$:$>4 $1@$2@.$3		first externalize
R@$+			$: ?@$1			mark first node
R$*?@$+$=Z$+		$1$2!?$4		change prefix path to !
R$+?$~A$*@$+		$: $1$4!$2$3		turn last pair into ! format 2
R$*?$*			$: $1$2			remove possible trailing mark

# Translate normal domain addresses
ifdef({UUCPXTABLE},{
R$+%$-@.$+		$: $1%$2@.$3 ? $(U $3 $: $)	UUCP node as domain?
R$+%$-@.$+?$+		$:$>20 $1%$2@.$3	yes, !-ify
R$+%$-@.$+?		$: $1%$2@.$3		no, remove mark
})
R$+%$-@.$+.UUCP		$:$>20 $1%$2@.$3.UUCP	!-ify "obvious" UUCP routes
R$+%$-@.$+.$-		$: $3.$4!$1%$2		don't know about other domains
R$+@.$+			$:$>20 $1@.$2		all the rest to the !-ifyer

###
### Address should be in !-path format now.
###

ifdef({DOMAINTABLE},{
# Qualify all nodes that we know of
# THIS IS DANGEROUS AND WRONG!  But still needed since some nodes out there
# do heavy path optimizations and our DECnet nodes may lose due to that.
R$*			$: ?$1			mark start
R$*?$+!$+		$1$(N $2 $)!?$3		qualify node
R$*?$*			$: $1$2			remove mark
})

# Unqualify all UUCP nodes
ifdef({UUCPXTABLE},{
R$*			$: ?$1			mark start
R$*?$+!$+		$1$(U $2 $)!?$3		unqualify node
R$*?$*			$: $1$2			remove mark
})
R$-.UUCP!$+		$: $1!$2		remove first .UUCP
R$+!$-.UUCP!$+		$1!$2!$3		remove other .UUCP's


#########################################################################
#									#
#	Rule Set #20:	%-Route to !-Path Translator			#
#									#
#	Translates Good Ol' ARPA %-Routes to UUCP style !-paths.	#
#	This is done up to, but not beyond, the first non-UUCP		#
#	domain found in the path.					#
#	   This ruleset is used strictly for heuristical reasons.	#
#	Nodes with Real Domain Names are assumed in general not to	#
#	understand !-paths, but rather prefer %-routes.  This wouldn't	#
#	have been necessary to do here if all gateways had fully	#
#	converted all addresses.					#
#	Eg.	mbox%a%b%c@.domain	=> domain!c!b!a!mbox		#
#		mbox%a.b%c%d@.domain	=> domain!d!c!mbox%a.b		#
#									#
#########################################################################
S20

ifdef({UUCPXTABLE},{
R$+@.$+			$: $(U $2 $)?$1		move translated domain to front
},{
R$+@.$+			$: $2?$1		move domain to front
})
R$+?$+%$-		$1!$3?$2		prefix host route
ifdef({UUCPXTABLE},{
R$+?$+%$+		$: $1?$2%$(U $3 $)	translate UUCP domains to hosts
R$+?$+%$-		$@$>20 $1?$2%$3		recurse if host found
})
R$+?$+%$-.UUCP		$@$>20 $1?$2%$3		recurse if ending in host.UUCP
R$+?$+			$: $1!$2		get rid of temp !-subst


#########################################################################
#									#
#	Rule Set #21:	Prehost to Posthost Converter			#
#									#
#	Changes !-paths into RFC822 Source Routes.			#
#	Eg. a!b!c!d	=> a,@b,@c,@d	=> @a,@b:d@c			#
#	    a!b!c%d	=> a,@b,@c%d	=> @a:c%d@b			#
#	    a!b!c@d	=> a,@b,@c@d	=> @a,@b:c@d)			#
#									#
#########################################################################
S21

# Initial canonicalization (get rid of possible '@' as in path!u@h)
R$+@			$: $1			remove optional trailing '@'
R$+!$+			$: $1?$2		find the rightmost '!'
R$+?$+!$+		$1!$2?$3		..and change it into a '?'
R$+?$+@$+		$: $1!$3!$2		change last u@h to h!u if any
R$+?$+			$: $1!$2		just remove '?' otherwise

# The address is now formatted as a!b!..!h!u -- transform it into a,@b,@..?h?u
R$+!$+			$: ?$1?$2		find last h!u-pair
R$*?$+?$+!$+		$1,@$2?$3?$4		change all '!'s before to ',@'
R?$+?$+			$: $2@$1		h!u => u@h
R,$+?$+?$+		$: $1:$3@$2		,path..h!u => path:u@h



# Infer .UUCP domain on first host if it is unqualified and either:
# (BANGIMPLIESUUCP is defined) OR (DOMAINTABLE is undefined and the host
# isn't known by the name server) OR (the host isn't known by the domaintable)

ifdef({BANGIMPLIESUUCP},{
# (BANGIMPLIESUUCP is defined)
R@$-$=Z$+		$@ @$1.UUCP$2$3			route: add .UUCP
R$+@$-			$@ $1@$2.UUCP			host: add .UUCP
},{ifdef({DOMAINTABLE},{
# (DOMAINTABLE is defined)
R@$-$=Z$+		$: @$[ $1 $: $1 $]$2$3		route: try name server
R@$-$=Z$+		$@ @$(N $1 $: $1.UUCP $)$2$3	route: try domain table
R@$+			$@ @$1				already has domain
R$+@$-			$: $1@$[ $2 $: $2 $]		host: try name server
R$+@$-			$@ $1@$(N $2 $: $2.UUCP $)	host: try domain table
},{
# (neither BANGIMPLIESUUCP nor DOMAINTABLE is defined)
R@$-$=Z$+		$@ @$[ $1 $: $1.UUCP $]$2$3	route: try name server
R$+@$-			$@ $1@$[ $2 $: $2.UUCP $]	host: try name server
})})

#########################################################################
#									#
#	Rule Set #22:	General Pathalias Router			#
#									#
#	Tries to find a route for an address using the pathalias	#
#	database.  It will return the complete (canonicalized)		#
#	route if found, or the same address otherwise.			#
#									#
#########################################################################
S22

ifdef({PATHTABLE},{
# Change RFC822 Source Routes into %-path to get rid of multiple atsigns
R$+@$+@.$+	$:$>25 $1@$2@.$3			Src Route to %-path

# Search pathalias database
R$+@.$-.UUCP	$: $(P  $2 $@$1        $:$1@.$2.UUCP $)	0th: UUCP host w/o .UUCP
R$+@.$+		$: $(P  $2 $@$1          $:$1@?$2 $)	1st: try full domain
R$+@$*?$-.$+	$(P .$3.$4 $@$1%$2.$3.$4 $:$1@$2.$3?$4 $)	2nd: subdomains
R$+@.$+?$-	$: $(P .$3 $@$1%$2.$3    $:$1@?$2.$3 $)	3rd: try top domain

# Found a route?
R$+@?$+		$@ $1@.$2				failure: return
R$+%.$+		$1%$2					success: remove '.'

# Yes, canonicalize result
R$+@$+		$@$>3 $1@$2				canonicalize domains
R$+!$+		$@$>3 $1!$2				canonicalize !-paths
R$+%$+		$@$>3 $1%$2				canonicalize %-paths
R$+		$@ $1@.$w				canonicalize users
})

#########################################################################
#									#
#	Rule Set #23:	Route prettyprinter & compressor.		#
#									#
#	This code rewrities RFC822 Source Routes into %-routes, which	#
#	most users and mail FEs understand better.  It also comresses	#
#	"obvious" routes whenever considered necessary -- mostly just	#
#	for aesthetical reasons, though.  If you don't like this, feel	#
#	free to disable it.  Sendmail shouldn't break, anyway.  (But	#
#	there will probably be others...)
#									#
#########################################################################
S23

# Turn RFC822 Source Route into %-path
R$+@$+@.$+		$:$>25 $1@$2@.$3

# Remove route to well-known domain
R$+%$+.$=T$=Y$+		$:$>3 $1%$2.$3		known top domain

# Strip routes through well-known UUCP relays
R$+%$-@.$=R		$:$>3 $2!$1		known UUCP relay

ifdef({LIUIDA},{ifdef({DOMAINTABLE},{
# LOCAL FIX: Strip header %-routes that paranoid instances of MM produce
R$+%aida%$+@.majestix.liu.se	$@ $1@.$(N aida $)	AIDA's MM does this
R$+%carmen%$+@.majestix.liu.se	$@ $1@.$(N carmen $)	CARMEN's too
})})


#########################################################################
#									#
#	Rule Set #24:	Unqualify domains for DECnet nodes		#
#									#
#	This is needed since DECnet has a flat namespace.  All DECnet	#
#	nodes that are [externally] known to have a certain domain	#
#	name are unqualified to their corresponding DECnet host name.	#
#									#
#########################################################################
S24

ifdef({DECNETXTABLE}, {
R$+			$: ?$1			mark beginning of addrs
R$*?$*$=X$+$=Y$*	$1$2$3$(D $4 $)?$5$6	scan & lookup domains
R$*?$*@.$+		$1$2@.$(D $3 $)		lookup direct domain
})
ifdef({LIUIDA},{
# LOCAL FIX: The SUNET.SE domain only consists of DECnet nodes.
R$*$=X$-.SUNET.SE$=Y$*	$1$2$3$4$5		*.SUNET.SE are on DECnet
R$+@.$-.SUNET.SE	$1@.$2			dito
})


#########################################################################
#									#
#	Rule Set #25:	Translate RFC822 Source Routes into %-Paths	#
#									#
#	This ruleset takes a (perhaps internalized) RFC822 Source	#
#	Route and translates it into it's %-kludgified equivalent.	#
#	Non-RFC822 Source Routes should pass through unharmed.		#
#									#
#	Eg: [u@h@.a	=>] @a:u@h	=> u%h@a			#
#	    [@b:u@h@.a	=>] @a,@b:u@h	=> u%h%b@a			#
#	  [@c,@b:u@h@.a	=>] @a,@b,@c:u@h => u%h%b%a%c@d			#
#									#
#########################################################################
S25

# Take care of internal mbox@.domain format
R@$+:$+@$+@.$+	$: @$4,@$1:$2@$3		move @.domain to front
R$+@$+@.$+	$: @$3:$1@$2			dito

# Address is now real RFC822 Source Route--make sure user isn't !-path
# (an address like <@a,@b:x!y!z@c> would otherwise be rewritten as
# <x!y!z%c%b@a>, which is highly ambiguous--rewrite to <z%y%x%c%b@a> instead)
R@$+:$+!$+@$+	$: @$1:$>4$>3 $2!$3@$4.DUMMY	rewrite last user@host
R$+.DUMMY$+	$: $1$2				remove host canon inhibitor
R@$+:$+:$+@$+	$: @$1,$2:$3@$4			merge possible double Src Route

# Finally, the actual translation
R@$+:$+@$+	$: @$1:$2%$3?			path:u@.h => path:u%h + mark
R@$+:$+@	$: @$1:$2?			path:u@ => path:u + mark
R@$+$=Z$+?$*	$3?%$1$4			rotate & concat
R$+%$+?$*	$1@.$2$3			instantiate '%' & remove mark
R$+@.$+%$+	$1%$2@.$3			move gaze right


#########################################################################
#									#
#	Rule Set #26:	Determine Mailer for Address			#
#									#
#	Takes an address in canonical format as input and returns	#
#	a complete mailer specification if a mailer is known for	#
#	the supplied domain.  Just returns the address otherwise.	#
#									#
#########################################################################
S26

ifdef({NEWALIASES}, {
# Updating aliases database -- return all addresses as local
R$+@.$w			$#LOCAL  $@$w $:$1		default host
R$+@.$+			$#LOCAL  $@$2 $:$1@.$2		specified host
})

# Search for possible global alias
R$+@.$+			$: $1@.$2 ? $>4$>10$>2 $1@.$2	externalize
R$+?$+			$: $1 ? $(@ $2 $:$)		search aliases
R$+@.$+?$+		$#LOCAL  $@$2 $:$1@.$2		found it!
R$+?			$: $1				not found, remove mark

# Deliver to locals right away
R$+@.$=w		$#LOCAL  $@$2 $:$1

ifdef({MAILERTABLE},{
###
###	Determine delivery over specific media
###
R$+@.$+			$: $1@.$2 ? $(M $2 $: $)	search mailer table
R$+@.$+?$+:$+		$#$3     $@$4 $:$>28 $1@.$2	relativize & return
R$+@.$+?$*		$: $1@.$2			no match, remove mark
})

###
###	Determine delivery over TCP/IP
###
R$+@.$*$~P		$: $1@.$2$3 ? $[ $2$3 $: $]	ask nameserver
R$+@.$+?$+		{$#}TCPMAILER $@$3 $:$>28 $1@.$2	relativize & return
R$+@.$+?$*		$: $1@.$2			no match, remove mark

###
###	Determine delivery over XNS
###
ifdef({XNSDOMAIN},
{R$+@.}XEROXNS		{$#XNS $@xnsmail $:$1@.}XEROXNS
)

###
###	Determine delivery over DECnet
###	(Kludge: Should relativize too if we had a real DECnet connection)
###
ifdef({DECNETXTABLE},{
R$+@.$+			$: $1@.$2 ? $(D $2 $: $)	check DECnet table
R$+@.$+?$=D		$#DECnet $@$3 $:$1@.$2		only return real ones
R$+@.$+?$*		$: $1@.$2			not found, remove mark
})

###
###	Determine delivery over UUCP
###	(Can't use ruleset 28 since we need to relativize immediate users)
###
ifdef({UUCPXTABLE},{
R$+@.$+			$: $1@.$2 ? $(U $2 $: $)	check UUCP table
R$+@.$+?$=U		$: $1@.$3			replace if found real
R$+@.$+?$*		$: $1@.$2			not found, remove mark
})
R$+@.$=U.UUCP		$: $1@.$2			remove pseudo domain
R$+%$+@.$=U		{$#}UUCPMAILER $@$3 $:$>3 $1%$2	(canonicalize routes)
R$+@$+@.$=U		{$#}UUCPMAILER $@$3 $:$>3 $1@$2	(canonicalize routes)
R$+@.$=U		{$#}UUCPMAILER $@$2 $:$1	(immediate delivery)


#########################################################################
#									#
#	Rule Set #27:	Simple %-Path to !-Paths Translator		#
#									#
#	Subroutine of other address translators.  Will change a		#
#	"a!b!c%d%e" path into "e!d!a!b!c".  Typically used when		#
#	a message have travelled from UUCP-land into Domain land	#
#	(and back again).						#
#									#
#########################################################################
S27

R$+%$+			$: $1?$2		mark first %
R$+?$+%$+		$1%$2?$3		find last %
R$+?$+!$+		$@ $1%$2!$3		this is weird--don't change it
R$+?$+			$: $2!$>27 $1		put on front and recurse


#########################################################################
#									#
#	Rule Set #28:	One-level route stripper			#
#									#
#	Remove immediate host for routed addresses.  Typically used	#
#	in ruleset 26 to produce a recipient relative to the immediate	#
#	host.  Only to be used for routed full domains.			#
#									#
#########################################################################
S28

R$+@$+@.$+		$@$>3 $1@$2		relativize & return src route
R$+%$+@.$+		$@$>3 $1@$2		relativize & return %-path


#########################################################################
#									#
#	Rule Set #29:	Multi-level self route stripper			#
#									#
#	Remove immediate host for routed addresses if it is self.	#
#	Typically used in ruleset 0 to remove superfluous routing	#
#	info and produce a path relative to this host.			#
#									#
#########################################################################
S29

R$+@$+@.$=w		$@$>29$>3 $1@$2			RFC822 Src Route
R$+%$+@.$=w		$@$>29$>3 $1%$2			%-Path
