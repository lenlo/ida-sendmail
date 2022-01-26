.\" refer -e -l,2 -s paper.ms | tbl | pstroff -ms		-*- nroff -*-
.AM
.RP
.ds < \v'0.2m'\s-3
.ds > \s0\v'-0.2m'
.de DQ			\" Double quoted string
\\&\\$3\\*Q\\$1\\*U\\$2
..
.de SQ			\" Single quoted string
\\&\\$3`\\$1'\\$2
..
.de UC			\" Uppercase string (in a smaller font)
\\&\\$3\\s-1\\$1\\s+1\&\\$2
..
.de UQ			\" Uppercase quoted string (in a smaller font)
\\&\\$3\\*Q\\s-1\\$1\\s+1\\*U\\$2
..
.de QQ			\" Quoted paragraph (possibly in a sized font)
.QP
.if !'\\$1'' .ps \\$1
..
.de II			\" Indented, auto numbered paragraph
.if !'\\$1'' .nr II \\$1-1 1
.IP [\\n+(II]
..
.de JB			\" Indented paragraph, bold label, extended width
.IP "\fB\\$1\fR" 15
..
.de JS			\" Indented paragraph, small label
.IP "\s-1\\$1\s+1"
..
.de AP			\" Appendix
.if \\n(1T .bp
.RT
.if \\n(1T .sp
.if !\\n(1T .BG
.RT
.ft 3
.if n .ul 100
APPENDIX \\$1:
..
.de DO				\" Domain table entry, see Appendix D
.br
.UC \\$1
\t\\$2
..
.de X1				\" Generate 1st level index entry
.br
.ie '\\$3'' .ta \\n(LLu-\\w"\\$1"u \\n(LLuR
.el .ta \\n(LLu-\\w'\\$3'u-1u \\n(LLu-\\w'\\$3'u
\\$2\a\t\\$1
..
.de X2				\" Generate 2nd level index entry
.in 3n
.nr LL \\n(LL-3n
.X1 "\\$1" "\\$2"
.nr LL \\n(LL+3n
.in 0
..
.\" ***** HERE BEGINS THE ACTUAL CODE (ie TEXT)
.ND May 27, 1987
.ie n .ds LH Electronic Mail Addressing
.el .ds LH Electronic Mail Addressing with The IDA Sendmail Enhancement Kit
.ds CH
.ds RH Lennart Lo\\*:vstrand \\(co 1987
.ds LF
.ds CF \*- % \*-
.ds RF
.TL
Electronic Mail Addressing in Theory and Practice
.SM
.br
with The IDA Sendmail Enhancement Kit
.if t \{\
.SM
.br
(or The Postmaster's Last Will and Testament)
.\}
.AU
Lennart Lo\*:vstrand*
.FS
* New address from July 1987: Xerox EuroPARC, 61 Regent Street,
Cambridge CB2 1AB, U.K.
.FE
<lel@ida.liu.se>
.AI
Department of Computer and Information Science
University of Linko\*:ping
S-581 83 Linko\*:ping
SWEDEN
.AB
This paper discusses theoretical and practical aspects of handling
electronic mail addresses in a heterogeneous environment.  It argues for
more intelligent Mail Transport Agents that are able to fully format
addresses according to different formats and that does not unnecessarily
complicate header addresses.  Also described is a set of enhancements to
the
.UX
.I sendmail
program and accompanying rewriting rules used to fulfill our two main
goals: (1) To provide a canonical format for handling all electronic
mail addresses in which
.DQ replying
regularly will work and where local users do not have to depend on the
recipient's explicit route or addressing syntax when submitting a
message.  (2) To design and implement a method for managing mail to and
from local users in a machine independent way, allowing them to change
their preferred actual mailboxes while maintaining the same visible
surface addresses at all times.
.FS
.ps +1
.sp
Report no. LiTH-IDA-Ex-8715
.FE
.AE
.NH
INTRODUCTION
.QQ
.I
While some computer-based mail addressing systems are actually easier to
deal with than the paper-based model, they are the exception\*-and not
the rule.
.br
.ti +\n(QIu
Why, you might ask, has electronic mail service become so very complex?
Most of the problems are simply inherent in reaching beyond a local
system to connect with another.
.br
.R
.ad r
\&
.[[
%A David Crocker
%T Networking Considered Harmful
%J Unix Review
%V 5
%N 3
%D 1987
.]]
.br
.ad b
.LP
Sending electronic mail is not always as easy as it ought to be.  Too
many incompatible mail addressing formats exist, forcing the presumptive
user sending a message to know a great deal more than can be thought
reasonable about the recipient mail system's idiosyncrasies.  This is a
widely recognized problem, which can be seen as a consequence of the
ever increasing interconnectivity between different computer systems,
each subscribing to a different addressing standard.  There are gateways
that do address transformation on messages passing from one network to
another, but it is normally done in a too insufficient manner to get rid
of the unintelligible hybrid addresses that often infest us.  Even worse
are the many systems that assault these mixed format addresses by
rewriting them to malformed or incomplete ones.  A hybrid address
passing several network boundaries is often transformed in such a way
that it no longer is possible to use it as a
.DQ reply
or error return address; not even for a human being, much less for a
machine.
.PP
These problems are especially frequent in the
.UX 
world.  Networks like the
.UC ARPANET
and
.UC CSNET
have the advantage of being more internally coherent; both
follow the Internet mail syntax specifications, described in
.UC RFC 822
\&
.[[
%A David Crocker
%T Standard for the Format of \s-1ARPA\s+1 Internet Text Messages
%S \s-1RFC\s+1\&822
%D 1982
.]].
The
.UX 
world used to practice the
.SQ ! -path 
addressing syntax in which all addresses are relative routes, but has
recently been moving over to the domain address standard of the
Internet.  The present problems concern nodes that has not yet done the
transition and those that
.I cannot
change, because their standard mailer software is unable to handle these
new format addresses.  A typical example of the latter are the System V
systems.  Berkeley systems have the freedom of
.I sendmail (8),
which unfortunately not always turns out as a blessing.  In a way, it is
too easy to rewrite addresses using
.I sendmail ,
but too hard to control the transformations.  This often leads to strange and
incompatible formats that don't belong in either standard.
.PP
This paper discusses the most common formats and functions electronic
mail addresses have.  It argues for more intelligent Mail Transport
Agents that are able to fully format addresses according to different
formats and that does not unnecessarily complicate header addresses.  In
the end, it moves over to describe the
.I
IDA Sendmail Enhancement Kit
.R
and the work and rationale that lies behind it.  The Kit is made up of
two parts: First, the configuration file setup and the rewriting rules
contained in it.  These implement a rewriting strategy based on always
.I completely
resolving addresses instead of being content by looking at the immediate
host.  The addresses are then fully transformed again according to the
respective mailer's and expected ultimate recipient's format.  Second,
we describe a set of modifications to the
.I sendmail
source, giving it an extended functionality that in the opinion of this
author should have been implemented long ago.  Typical additions are:
Direct Access to Dbm(3) Files, Separate Envelope/Header Rewritings, and
Multi-Token Class Matches.  The configuration file is heavily dependent
of these modifications and will not function without them.
.PP
We have also developed a way of handling mail to or from local users in
a machine independent way by hiding their actual sender and recipient
addresses behind generic organization oriented addresses.  This way, one
may have a fixed visible address which is dynamically associated with
one or more physical mailboxes.  Mails sent from any of a person's
.DQ "well known"
accounts will appear to come from his generic address.  Similarly, mail
to any of his generic address will be forwarded to his preferred
mailbox(es).  Note that the generic addresses as a group have no
connection to any particular machine.  Instead, they are merely database
entries on one or more nodes.
.NH
NAMES, ADDRESSES, AND ROUTES
.LP
Larry Kluger and John Shoch has in an excellent article
.[ [
%A Larry Kluger
%A John Shoch
%T Names, Addresses, and Routes
%J Unix Review
%V 4
%N 1
%D 1986
.]]
described the distinction between
.I names ,
.I addresses ,
and
.I routes ,
in short:
.QQ
.I
The name of a resource refers to what we seek, an address indicates
where the resource is, and a route tells us how to get there.
.LP
When dealing with electronic mail,
.I names
are typically used in identifying three kinds of entities: (1) The
mailbox associated with the sender (originator) and recipient of a
message, (2) The name space (domain) in which the sender/recipient is
known, and (3) The computer system that houses a Mail Transfer Agent
(MTA) able of delivering or forwarding messages.  Often, the two latter
coincide by associating the domain of a set of mailboxes with the actual
machine that implements them.  Furthermore, an
.I address
would be the data structure used in directly connecting to another MTA
over a computer network, such as a four-byte Internet number + TCP port
number, or an ordinary telephone number.  It may well happen that many
names map to the same address, or that the same name have more than one
address.  Lastly, a
.I route
consists of an ordered sequence of two or more MTA names or addresses,
forming an explicit path that the message should take to reach its
recipient.  Routes can be further divided into
.I "system routes,"
where the MTA itself is the responsible of constructing a useful path
and
.I "source routes,"
where that responsibility lies on the person sending the message.
.PP
The mapping from
.I names
to
.I addresses
is essentially beyond the scope of this paper, and will only briefly be
mentioned in the following sections.
Thus, we have taken the liberty of using the general meaning of the word
.I address
to it denote both mailbox/domain name pairs as well as complete routes.
Also, we are using the words
.I system ,
.I host ,
and
.I node
to all denote MTAs somewhere in a network.  It is our hope that the
reader should not be confused because of this.
.NH
MAIL ADDRESS FORMATS
.LP
The absolute majority of today's mailing systems use addresses,\**
.FS
That is, routes or mailbox/domain name pairs.
.FE
represented by a simple string of characters.  Some of these characters
implement operators that are used to divide the address into
mailbox/domain/route parts when parsed by an MTA.  Different
operators have different directions of associativity, making it
increasingly difficult to unambiguously parse addresses produced by
combining incompatible operators of different mail address syntaxes.  It
is hoped that at least some of these problems will be solved with the
emergence of the structured attribute list addresses of
.UC X .400.
In the mean time, we have a variety of different formats in use, each
subscribing to a different set of delimiting operators.  It is not uncommon to
see addresses like:
.QQ
mcvax!enea!liuida!obelix!p_e%seismo.css.gov@relay.cs.net
.LP
or even
.QQ
enea!seismo.\s-1CSS.GOV\s+1!!\s-1OZ.AI.MIT.EDU\s+1,!\s-1MC.LCS.MIT.EDU\s+1:ebg!\s-1REAGAN.AI.MIT.EDU\s+1
.LP
turn up in message envelopes and headers.  The last example comes from
the envelope sender address found on a message in which the
.UC RFC 822
route was incompletely translated into
.UUCP
.SQ ! -path
syntax.  Now, before delving into a discussion about how these may be
resolved or preferably avoided, let's take a look at what kind of
addressing formats currently exist.
.NH 2
Relative Addresses
.LP
These types of addresses are by necessity all implemented as
.I routes .
In purely relative addresses, all node names are relative to each other,
making path optimization or system routing difficult, if not impossible.
For the sender of a message, this means that addresses will look
different depending on his location in the network, forcing him to
recompute all addresses each time he changes his location.  Even worse,
in a rapidly growing network, it might even happen that an address
becomes invalid overnight because some link far away has been
disconnected or replaced by another.  All this makes it difficult for a
presumptive user to continuously keep his addresses correct and up to
date.
.PP
Relative addresses have since long been in use within the
.UX 
community, but a great deal of work has been done by an organization
called
.I "The \s-1UUCP\s+1 Mapping Project"
in eliminating duplicate host names, thus making it possible to use
absolute addresses\**
.FS
See the following section.
.FE
in a flat name space.  It is presently moving towards utilizing full
domain names but is delayed by the fact that some systems, notably
.I "System V"
systems, cannot handle anything but
.UC UUCP
source routes with standard mailer software.  The addressing syntax for
.UX
.UC UUCP
.SQ ! -paths
is as follows:
.QQ
node!\|.\|.\|.\|!node!user
.LP
The route sequence is read from the left to the right, with the ultimate
recipient on the rightmost end.  Other systems that have similar
addressing formats are the Berknet and
.UC VAX/VMS
mail systems, which use:
.QQ
node:\|.\|.\|.\|:node:user
.LP
and
.QQ
node::\|.\|.\|.\|::node::user
.LP
respectively.
.UC RFC 822
also specifies a way of constructing explicit paths using the somewhat
complicated syntax:
.QQ
<@node,@node,\|.\|.\|.\|:user@node>
.LP
Here, the message should be passed through each successive node from
left to right, ending up in the last user@node's mailbox.  Note that the
less than and greater than brackets are included in the syntax.  Another
widely used but undocumented format is
.I
Ye Olde
.UC ARPANET
.SQ % -Kludge:
.R
.QQ
user%node%\|.\|.\|.\|%node@node
.LP
which is interpreted from the right to the left by delivering the
message to the node after the atsign and then instantiating the
rightmost percent sign into a new atsign, etc.
.NH 2
Absolute Addresses
.QQ
.nf
.I
The Tao that can be told of is not the Absolute Tao;
The Names that can be given are not Absolute Names.\k:

The Nameless is the origin of Heaven and Earth;
The Named is it the Mother of all Things.
.br
.R
\h'|\n:u-\w'[LaotseBC]'u'
.[[
%A Laotse
%T Tao Te Ching
%S Book 1, Verse 1
%D ca 500 BC
.]]
.br
.ad b
.LP
Absolute addresses have the advantage of being universally unique and
thus applicable by any MTA\**
.FS
At least in theory\*-not all MTAs necessarily know about how to deliver
to all addresses.
.FE
independently of where it is located.  Since the names should be
uniquely identified, some way of distributing them within their name
space needs to be accomplished.  The simplest way of doing this is by
registering plain node names with some central name directory on a
first-come-you-get-it service.  The
.I "\s-1UUCP\s+1 Project"
tried this to avoid duplicate
.UC UUCP
node names.  However, maintaining such a directory and propagating its
changes easily becomes too heavy a burden to handle.  Another strategy
was first adopted by the
.UC ARPA 
Internet community, the hierarchical domain naming system described by
.UC RFC 882
\&
.[[
%A Paul Mockapetris
%T Domain Names\*-Concepts and Facilities
%S \s-1RFC\s+1\&882
%D 1983
.]],
.UC RFC 920
\&
.[[
%A Jon Postel
%A Joyce Reynolds
%T Domain Requirements
%S \s-1RFC\s+1\&920
%D 1984
.]]
and others.
.PP
In this system, a labelled tree is built with each node in the tree
denoting a specific domain.  Some nodes correspond to actual hosts,
typically the leaves in the tree, while others simply map to some
organizational entity, like a group, department, or institution.  The
purpose of the domain naming system is to distribute the naming
authority throughout the tree.  Letting each domain have the
responsibility of naming the domains immediately beneath it guarantees
the uniqueness of all simple domain names relative to their parents.
The full, qualified domain names are constructed by concatenating each
level's simple domain name with a dot in between.  For example, there
might exist a certain mail computer named
.UQ MC
within the Laboratory of Computer Science of the Massachusetts Institute
of Technology, an Educational organization.  A possible domain name for
this computer would be:
.QQ -1
MC.LCS.MIT.EDU
.LP
There might be many hosts named
.UQ MC,
but only one within the
.UQ LCS.MIT.EDU
domain.  The same goes for the
.UQ LCS
domain within the
.UQ MIT.EDU
domain.  The global uniqueness of each fully qualified domain is thus
guaranteed by its parentage.
.PP
The domain system is currently in use within the
.UC ARPA
Internet,
.UC CSNET,
and is in progress within the
.UC UUCP
world.  Under its anonymous root domain, it presently has six
three-letter organizational domains registered and a continuously
increasing number of national two-letter domains.  The organizational
domains are mainly used within the U.S., and the national domains in
Europe and Asia.  There are also a set of
.I "de facto"
network based domains in use, although not officially registered.  These
are really mock domains used to incorporate hosts on physical networks
that cannot or do not want to handle domain addresses.  Examples of
these are
.UC BITNET
and still most of the
.UC UUCP
world.  Appendix D lists all domains currently registered with the SRI
Network Information Center together with a set of otherwise frequently
recognized network based domains.
.NH 2
Attribute Addresses
.LP
With the
.UC CCITT \**
.FS
.I
Comite\*' Consultatif International Te\*'le\*'phonique et
Te\*'le\*'graphique,
.R
i.e. the International Telegraph and Telephone Consultive Committee
.FE
.UC X .400
\&
.[[
%A Malaga-Torremolinos
%T Message Handling Systems: System Model\\*-Service Elements
%S \s-1X\s+1.400
%D 1984
.]]
series standard for electronic mail in emergence, a new kind of
addressing system is being proposed.  In this format, recipients are
uniquely identified using a list of attribute-value pairs.  Some of
these, like the Organization and Country attributes, are obligatory
while others may be supplied only if known by the sender.  The idea is
that the base attributes should be able to guide the message to a
relevant directory server, while the others then are used to select the
actual recipient.  Attribute sets that select no or more than one
recipient will probably be considered erroneous, but could be used in
selecting multiple recipients.
.PP
It will yet take several years before the attribute addressing scheme
has come to widespread use.  It will, however, surely come\*-if nothing
else, then because it has the force of the united PTTs behind it.
Already, there exists guidelines for mapping between
.UC RFC 822
based addresses and
.UC X .400,
such as
.UC RFC 987
\&
.[[
%A Steven Kille
%S \s-1RFC\s+1\&987
%T Mapping Between \s-1X\s+1.400 and \s-1RFC\s+1\&822
%D 1986
.]].
.NH 2
Hybrid Addresses
.LP
With all this in mind, let's take a look at how different formats
sometimes are combined and how we can resolve them.  The three major
addressing formats for routing messages are:
.TS
l lw(2i) l.
[1]	T{
The
.UC UUCP
.SQ ! -path
T}	<\fInode\*<1\*>\fP!\fInode\*<2\*>\fP!\fInode\*<3\*>\fP!\fIuser\fP>
[2]	T{
Ye Olde
.UC ARPANET
.SQ % -Kludge
T}	<\fIuser\fP%\fInode\*<3\*>\fP%\fInode\*<2\*>\fP@\fInode\*<1\*>\fP>
[3]	T{
The
.UC RFC 822
route syntax
T}	<@\fInode\*<1\*>\fP,@\fInode\*<2\*>\fP:\fIuser\fP@\fInode\*<3\*>\fP>
.TE
.LP
where the latter mostly is used for envelope senders.
.PP
Combinations of the above usually appear in messages crossing one or
more network boundaries with different addressing formats.  Since each
of these formats were independently developed, it may not be obvious how
they should be interpreted when combined.  Still, by reasoning a little,
much can be inferred from how they incrementally are constructed.
.PP
Starting with the Domainist's approach to the matter, we have to give
.SQ @
precedence over
.SQ !
since this is implied by
.UC RFC 822.
This means that addresses like:
.QQ
node\*<2\*>!node\*<1\*>!user@domain
.LP
will be interpreted as:
.QQ
domain \(-> node\*<2\*> \(-> node\*<1\*> \(-> user
.LP
Now, since
.SQ %
is often the 
.I "de facto"
standard routing operator on top of
.SQ @ ,
an address like:
.QQ
host!user@domain
.LP
that is autorouted through 
.I relay
will probably end up looking as:
.QQ
host!user%domain@relay
.LP
meaning:
.QQ
relay \(-> domain \(-> host \(-> user
.LP
This forces us to give
.SQ %
priority over
.SQ ! .
However, a
.SQ ! -path
address ending with a 
.DQ user%node,
cannot be a domain address (no
.SQ @ )
and should therefore be interpreted using
.UC UUCP
semantics by prioritizing
.SQ !
over
.SQ % .
Thus,
.QQ
node\*<1\*>!node\*<2\*>!user%domain
.LP
should be read as:
.QQ
node\*<1\*> \(-> node\*<2\*> \(-> domain \(-> user
.LP
Mixtures with
.UC RFC 822
routes may look hard to read, but are actually easy to parse.  A fairly complicated address like:
.QQ
node\*<1\*>!node\*<2\*>!@domain\*<1\*>,@domain\*<2\*>:host!user%relay@domain\*<3\*>
.LP
has to be interpreted as:
.QQ
node\*<1\*> \(-> node\*<2\*> \(-> domain\*<1\*> \(-> domain\*<2\*> \(-> domain\*<3\*> \(-> relay \(-> host \(-> user
.LP
since
.UC RFC 822
like
.SQ ! -paths
associate left-to-right, and since the last
.DQ localpart@domain
can be unambiguously found after the colon.
.PP
Now, not all of us are Domainists.  Many nodes can and will only be able
to interpret
.UC UUCP
.SQ !  -paths,
which leads to complications with mixed
.SQ ! -
and
.SQ @  -style
addresses.  The only workable solution to this is to try and avoid such
mixtures altogether.  The easiest way of doing this is to write them as
.SQ ! -
and
.SQ % -style
combinations, but even better would be to wrap them wholly around to the
.SQ ! -path
format.  They should then turned back into
.SQ %
and
.SQ @
combinations when breaking the Domain Land boundary.
.NH
A SHORT ANATOMY OF THE ELECTRONIC MESSAGE
.LP
In analogy to the written letter, there are two major parts of a
message: The envelope and the contents.  The envelope is there
specifically for the MTAs to handle and contains the sender address
together with the message's actual recipients.  The contents are usually
further subdivided into the header lines and the actual body, where only
the latter is under the sender's full control.  The headers are used by
the MTAs and MUAs\**
.FS
Mail User Agent, the program that the user directly interacts with when 
reading or composing messages.
.FE
to store various information of interest to the recipient, such as
sender, all official recipients, posting date, etc.  Although the body
usually is left uninterpreted, some mail systems put constraints by
limiting the length of each line or the whole message, or by only
allowing printable
.UC ASCII
characters.
.NH 2
The Envelope
.LP
The envelope contains the physical message's actual recipients, which
very well may be different from those in the headers.  Typically, a
message sent to more than one recipient will be split into
.I n
copies, one for each network.  These messages will have the original's
all recipients listed in their header lines, but each copy's envelope
should only have those being delivered over the network in question.
There is usually also the option of
.I "Blank Carbon Copy"
recipients, which per definition never shall show up in the headers.
.PP
The envelope will also contain the explicit path back to the sender for
error messages and tracing purposes.  This path should formed by having
each node that forwards the message incrementally add its name to the
route, thus avoiding routing problems that otherwise may appear.  The
result of each rewriting should be a full route in a suitable format
leading from the current node back to the originator.
.PP
If the envelope recipient(s) are routes, they are handled in an
analogous manner to the senders by removing the local node's name from
each address before propagating it further.  Optionally, the address can
be made fully relative to the immediate receiving node by removing its
name from the route as well.  This should be determined on a mailer
dependent basis.  The MTA has the full freedom of at any point turning a
simple envelope recipient address into a route if it sees reason to do
so.  This could be done on the grounds that the immediate recipient node
cannot perform automatic routing.  It should, however, be avoided if
possible since it is hard to keep routing tables fully updated with
topological changes in distant parts of the network.  Turning envelope
routes into simple addresses should also be avoided since there usually
exists a good reason for a route to be there.
.NH 2
The Headers
.LP
Header addresses are not normally used by the MTA.  Exceptions may be
when headers such as
.DQ "Return-Receipt-To:"
exists and the MTA is doing the final delivery or when the delivery of a
message fails and there exists a
.DQ Errors-To:
header.\**
.FS
These are
.I sendmail
specific; other MTAs may have other exceptions.
.FE
The MTA is also allowed to rewrite, or
.DQ munge,
header addresses when a message is forwarded from one network to
another.  This is done by first removing the addressing idiosyncrasies
of the transmitting network to obtain some internal canonical format and
then applying the receiving network's idiosyncrasies to produce a
conforming address
.[ [
%A Marshall Rose
%T Proposed Standard for Message Header Munging
%S \s-1RFC\s+1\&886
%D 1983
.]].
Of course, this should be done to both envelope and header addresses.
.PP
Even within one world, like the
.UC UUCP
pseudo-network, it may be necessary to
.DQ munge
addresses for them to be understandable by the recipient system.  For
instance, many mail systems does not recognize all domains or perhaps
cannot even handle anything but pure and fully routed
.UC UUCP
.SQ ! -paths.
If the transmitting MTA does not take this into consideration, the user
sending the message has to submit full source routes with each receiving
network's addressing syntax embedded.  Except in the most simple cases,
this task requires great knowledge\**
.FS
That is, a case for a
.I guru !
.FE
about how networks are interconnected, much more than can be considered 
reasonable by any casual or even experienced user.
.PP
.I
In our opinion, this is currently the greatest obstacle in making
electronic mail usable.
.R
On from bad to worse, these user supplied source routes that are fully
contained in the headers often get rewritten into further complicated
routes.  When such a message is received by its recipient, its header
addresses may very well be too unintelligible to be understandable by a
human being, much less by a machine.  In the best case, they will just
have routes with incorrect points of reference, forcing
.DQ reply
messages to the other recipients to first be (automatically) routed to
the first node of the path before it can start on the actual route.
Then often in the opposite direction, leading half way back again.
.NH
ADDRESS REWRITING STRATEGIES
.LP
Now, given the freedom and flexibility of
.I sendmail ,
our project's task has been to construct a configuration file that, with
the necessary enhancements to the
.I sendmail
source, will completely resolve and canonicalize all envelope and header
addresses to an internal format.  All unqualified addresses are then
officialized using the
.UC TCP/IP
name server function and a local
.I dbm (3)
based domain name table, and a route is found using a direct interface
to a
.I pathalias (1)
routing file.
Finally, using a static
.I dbm (3)
mailer table together again with the
.UC TCP/IP
name server function, the message is dispatched to the appripriate
mailer which fully rewrites the addresses according to its own
idiosyncrasies.
.NH 2
Sneak-In Preview
.LP
To give a taste of how the complete system performs with a realistic
case, consider at the following only partly imaginary example:
.QQ
.nf
.ne 2.1
.B Envelope:
	Sender: enea!seismo!relay.cs.net!cate%busch%pany.com
	Recipient: obelix!p_e
.ne 2.1
.B Headers:
	From: enea!relay.cs.net!cate%busch%pany.com
	To: mcvax!enea!liuida!obelix!p_e%seismo.css.gov@relay.cs.net
	cc: ree.pete%fidelio.uu.se%seismo.css.gov@relay.cs.net
.fi
.LP
A user
.I cate
on the Company Inc's local host
.I busch
has sent a message to two Swedish recipients:
.I p_e
on the 
.UC UUCP
host
.I obelix
in Linko\*:ping and to
.I ree.pete
on the Uppsala node
.I fidelio.uu.se.
If the headers would be left untouched, a reply from
.I p_e
to both
.I cate
and
.I ree.pete
would force 
.I ree.pete 's
copy to go all the way back to
.I relay.cs.net
before it could return to Sweden and Uppsala.  Clearly, this is a waste of
both resources and time when there might (and does) exist a much shorter
path within the country.  With The Kit's rewriting heuristics, the same
header lines will look like the following when leaving the local node:
.QQ
.nf
.ne 2.1
.B Envelope:
	Sender: @majestix.liu.se,@enea.se,@seismo:cate%busch%pany.com@relay.cs.net
	Recipient: p_e%obelix.liu.se@asterix.liu.se
.ne 2.1
.B Headers:
	From: cate%busch@pany.com
	To: p_e@obelix.\s-1UUCP\s+1
	cc: ree.pete@fidelio.uu.se
.fi
.LP
Here, our local node's name has been added to the envelope sender path,
which also has been transformed into a 
.UC RFC 822
route\**.
.FS
Save for the
.SQ <
and
.SQ >
brackets.
.FE
Other options would be to have it as a
.SQ ! -path
or
.SQ % -path.
The envelope recipient has been routed via
.I asterix.liu.se,
and changed into a
.SQ % -path,
on the basis that the message is forwarded over a
.UC TCP/IP
connection and this is the preferred route format for most such systems.
.PP
Also, the route has been removed from the header
.DQ From:
line, leaving the first universally qualified node there together with a
.SQ % -path
from that point to the recipient.  The 
.DQ To:
line has undergone even more drastic changes.  First, the route to
.I seismo.css.gov
was removed since this is the first universally qualified node.  Then
a table of well-known
.UC UUCP
relays was consulted to further compress the path.
.I Mcvax ,
.I enea ,
and
.I liuida
were all members of that list.  This gave
.DQ obelix!p_e
as a result, which then was turned into the domain form
.DQ p_e@obelix.\s-1UUCP\s+1.
In the last line,
.DQ ree.pete@fidelio.uu.se
simply had its path removed since
.UC \fISE\fP
is a registered top domain.
.NH 2
The Configuration File
.LP
The IDA Sendmail Master Configuration File should be sent through the
.I m4 (1)
macro processor to produce an actual configuration file.
Several
.I m4
identifiers are used to customize the file; each of them is described in
.I "Appendix C: Customization Parameters" .
Unlike the Berkeley version, it was not designed as a set of
.I m4
fragments that
.DQ sources
each other to form a full configuration, but rather as a single master
configuration file which holds a
.I bank
of all possible mailers and corresponding rewriting rulesets.  The
instance's actually available mailers are enabled by giving values to
their corresponding
.I m4
identifiers.  The current version include mailer definitions for a
.UC TCP/IP
mailer, three kinds of
.UC UUCP
mailers depending on the remote node's address handling capabilities, a
mock
.UC DEC net
mailer, as well as the
.UC LOCAL
and
.UC PROG
mailers.  Their design has been kept as clean as possible to make the
construction of e.g.
.UC BITNET
or
.UC CSNET
mailers using these as templates straight-forward.
.PP
The rewriting rules of the Kit's configuration file are
explicitly oriented towards the domain naming syntax.  They will resolve
all input addresses to an internal domain based format and then rewrite
them according to the selected mailer's preferences.  Internally,
all addresses have the same
.QQ
user@.domain
.LP
format.  Note the dot after the atsign; it is there to make it easier
to rewrite the address.  Also note
that this differs substantially from the Berkeley 
.DQ "whatever<@host>whatever"
format.  For historical reasons, both the
.UC RFC 822
route syntax and
.I
Ye Olde
.UC ARPANET
.SQ % -Kludge
.R
are used internally to represent routes when only one of them should be
sufficient.
.NH 2
Canonicalizing the Address
.LP
Ruleset 3 canonicalizes all addresses, making them conform to our
internal format.  After the canonicalization, the
.DQ user
part may end up containing a route in either standard
.UC RFC 822
format or using the
.SQ % -path
format.
.SQ ! -,
.SQ : -,
and
.SQ :: -style
paths are rewritten into
.UC RFC 822
routes.  Reasonable mixtures of route formats are resolved
using the strategies described in the section about
.I "Hybrid Addresses" .
As an option, the (untested)
.UC UUCPPRECEDENCE
switch may be turned on in the configuration master file.  This will
enable some simple heuristics that will decide between domain style and
.UC UUCP
.SQ ! -path
prioritized unpacking depending on whether the 
.I domain
is qualified or not.  In any case, ruleset 3 will make sure that the
.I domain
part of all
.DQ user@.domain
addresses are mapped to their full, official domain names whenever
possible using both the
.UC TCP/IP
name server and a dbm domaintable.  It also goes through some effort to
repair malformed addresses, but much of this is probably too site
specific to be generally useful.
.PP
Since
.SQ ! -paths
are internally represented as
.UC RFC 822
routes, you should not be surprised when you see an address like:
.QQ
foo!bar!baz!user
.LP
first be transformed into:
.QQ
@foo.\s-1UUCP\s+1,@bar:user@baz
.LP
and then to:
.QQ
bar:user@baz@.foo.\s-1UUCP\s+1
.LP
The
.UC UUCP
domain of
.I foo
has been inferred from the 
.SQ ! -style
syntax.  If
.I foo
had been known by the domaintable to have specific domain name, that had
been used instead.  Nothing can be inferred about the nodes
.I bar
and
.I baz ,
since we they may be local to
.I foo .
Now, since the pure
.UC RFC 822
route doesn't conform to our internal format, i.e. it does not have a
.DQ user
part followed by an atsign-dot and a
.DQ domain,
we had to rearrange it a little.  The closest node of the route was thus
extracted and added the right side of the rest of the route together
with the atsign-dot.  It may not be very pretty to look at, but it is
easier to handle this way.
.PP
Note that there is a risk of confusing
.UC UUCP
node names with local hosts using the domaintable lookup.  For example,
if you had a local node
.I linus
with a full domain name of
.I linus.liu.se
and received an address like
.DQ linus!user,
this would be interpreted as the local
.I linus
and rewritten into
.DQ user@linus.liu.se.
This is probably right for envelope recipients, but not so surely in
header lines.  You can define
.UC BANGIMPLIESUUCP
if you want to disable the domaintable qualification.
.NH 2
Finding Route and Mailer
.QQ
.I
.in +\n(QIu
.ti -\n(QIu
\*QWould you tell me, please, which way I ought to go from here?\*U
.br
.ti -\n(QIu
\*QThat depends a good deal on where you want to get to,\*U said the Cat.
.br
.in -\n(QIu
.R
.ad r
\&
.[[
%A Lewis Carrol
%T Alice in Wonderland
%D 1896
.]]
.br
.ad b
.LP
Before ruleset 0 tries to find an applicable mailer, it digests all
routes through the local host by stripping off its own name and sending
the address through ruleset 3 again.  It then has four strategies of
finding a suitable mailer for the address:
.II 1
Try to find a mailer that will connect to the immediate host in the
address.
.II
Try to find a route to the address' domain using a
.I dbm (3)
routing table and a mailer that will connect to the route's closest
node.
.II
Use the firm-wired
.UC RELAY_MAILER
and
.UC RELAY_HOST
pairs to automatically forward the message.
.II
Give up; send the address to the
.UC ERROR
mailer.
.LP
The code that determines if a mailer directly can deliver to a certain
domain is found in ruleset 26.\**
.FS
Yes, I too wish that named rulesets would be available in
.I sendmail .
Perhaps somebody should convert this configuration file into
.I ease .
.FE
It does this on a per mailer bases with the following order of priority:
.IP \s-1LOCAL\s+1 10
If the supplied domain is any of local host's names (member of the
.B $w
class), or if the complete address is found in the
.I aliases (5)
file, the message is delivered locally.  The latter type of local
delivery will cause the address to be expanded to the RHS of the alias
entry and the complete process to recurse.
.IP \\\\k:\\fISpecial\\fP\\\\h'|\\\\n:u'\\\\v'+1'\\fIMailers\\fP\\\\v'-1'
In order to override the standard mailer selection, a
special dbm
.I mailertable
may be used to force addresses to be delivered using specific mailers.
If the address' domain is found in the
.I mailertable ,
the associated mailer will be used.  The mailer table should map
official domain names to
.DQ mailer:host
pairs, with a colon between the mailer and the host.
.IP \s-1TCP/IP\s+1
With the new
.I default
argument of the
.UC TCP/IP
nameserver lookup function, it is possible to determine if an address
can be delivered using this protocol family without relying on static
host tables.  If the address' domain is known to the
.UC TCP/IP
nameserver, it is returned together with its canonicalized host name.
.IP \s-1DEC\s+1net
The
.UC DEC net
mailer does not share the network based nameserver facilities of the
.UC TCP/IP
mailer, and thus has to rely on a host table.  This is done with a
two-phase operation\*-first the domain is mapped to a
.UC DEC net
name, if known, then
the the
.UC DEC net
host name is checked in the list of connectable
.UC DEC net
hosts before it is returned.  This is because some
.UC DEC net
nodes cannot talk across area boundaries, forcing recipient addresses to
be explicitly routed over an intermediary host.
.I Note:
The supplied
.UC DEC net
mailer uses a
.UC TCP/IP
connection to a
.UC DEC system-20
acting as gateway.  A real implementation should remove the immediate
node from routes before returning them, but we cannot do this.
.IP \s-1UUCP\s+1
The
.UC UUCP
mailer is also determined with a two-phase operation\*-first the domains
is mapped through the
.UC UUCP
translation table, returning the
.UC UUCP
node name, if known.  The
.UC UUCP
mailer will then be selected only if the
.UC UUCP
name is known to be directly connectable by us (normally determined
using the /usr/lib/uucp/L.sys file).  All nodes found this way will be
sent to through the
.DQ dumb
.UC UUCP
mailer.  Delivery using either the
.UC UUCP-A
or the
.UC UUCP-B
mailer has to be determined using the special mailertable previously
mentioned.
.LP
If an address needs to be routed, i.e. if the first pass through ruleset
26 fails, it is given to ruleset 22 where its domain is looked up in a
.I pathalias (1)
type routing table.  Routes to explicit domain/host names are preferred
over general (parent) domain routes.  Before the new address is
returned, it is sent through the canonicalization routines of ruleset 3.
This makes specific
.I pathalias
route syntax effectively ineffective.  The normal way would be not to
specify any special routing syntax at all to
.I pathalias ,
but to invariably let it produce
.SQ ! -paths.
.NH 2
Externalizing the Address
.LP
After a mailer has been chosen, addresses are rewritten using rulesets 1
and 2 for envelope senders/recipients and rulesets 5 and 6 for header
senders/recipients.  Envelope senders are left untouched by this
process, but envelope recipients will have
.UC RFC 822
routes turned into
.SQ % -paths.
Header
.UC RFC 822
routes will also be turned into
.SQ % -paths
and then gently compressed by having paths to fully qualified domains
and
.UC UUCP
relay-to-relay paths removed.
Header senders will furthermore have their host names hidden by
.UC HIDDENNAME,
if defined, and their addresses filtered through the
.UC GENERICFROM
table, if available.
.PP
When this is done, the mailer specific rewriting phase starts.  The
.UC LOCAL
and
.UC PROG
mailers does not do any further rewriting as supplied, but could be
convinced to produce
.SQ ! -paths
for
.UC UUCP
routes if preferred [using ruleset 15 or a variant thereof].
.PP
The
.UC TCP/IP
and
.UC DEC net
mailers will add a call to ruleset 24 for all envelope recipients.  This
will turn domains corresponding to
.UC DEC net
nodes into flatspaced
.UC DEC net
host names, since domains are not supported there.  This should really
not be done in the
.UC TCP/IP
mailer, but all our
.UC DEC net
traffic is presently routed over a
.UC TCP/IP
link.  Since no special rewriting is done for envelope senders, this
means that they normally will appear in
.UC RFC 822
route format using these as well as any of the previous mailers.
.PP
There are three variants of the
.UC UUCP
mailer depending on the remote node's address handling capabilities.
The
.DQ dumb
version, simply called
.UC UUCP ,
corresponds closely to the class 1 mailer of
.UC RFC 976
\&
.[[
%A Mark Horton
%T \s-1UUCP\s+1 Mail Interchange Format Standard
%S \s-1RFC\s+1\&976
%D 1986
.]].
It will rewrite all addresses into
.SQ ! -format,
and makes all header addresses
.SQ ! -relative
the recipient node, routed through the transmitting node if
necessary.\**
.FS
See the new
.UC M_RELATIVIZE
mailer flag in the following section.
.FE
The
.UC UUCP-A
is closer to the
.UC RFC 976
classes 2 and 3 mailers in that it will let all header addresses stay in
.SQ @ -format,
but change envelope addresses to
.SQ ! -paths
whenever applicable.  The
.UC UUCP-B
mailer, finally, functions as the
.UC UUCP-A
mailer but will in addition supply envelope senders in
.UC RFC 822
route format and transmit the message to a
.I bsmtp
program on the remote node.
.PP
Ruleset 4 will as usual make the address truly external.  In our case,
this means by removing the dot after the atsign and by moving the
immediate domain to the head of
.UC RFC 822
routes.
