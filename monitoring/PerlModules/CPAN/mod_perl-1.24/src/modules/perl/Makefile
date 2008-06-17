# ====================================================================
# Copyright (c) 1995-1997 The Apache Group.  All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
#
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in
#    the documentation and/or other materials provided with the
#    distribution.
#
# 3. All advertising materials mentioning features or use of this
#    software must display the following acknowledgment:
#    "This product includes software developed by the Apache Group
#    for use in the Apache HTTP server project (http://www.apache.org/)."
#
# 4. The names "Apache Server" and "Apache Group" must not be used to
#    endorse or promote products derived from this software without
#    prior written permission.
#
# 5. Redistributions of any form whatsoever must retain the following
#    acknowledgment:
#    "This product includes software developed by the Apache Group
#    for use in the Apache HTTP server project (http://www.apache.org/)."
#
# THIS SOFTWARE IS PROVIDED BY THE APACHE GROUP ``AS IS'' AND ANY
# EXPRESSED OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE APACHE GROUP OR
# ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
# ====================================================================
#
# This software consists of voluntary contributions made by many
# individuals on behalf of the Apache Group and was originally based
# on public domain software written at the National Center for
# Supercomputing Applications, University of Illinois, Urbana-Champaign.
# For more information on the Apache Group and the Apache HTTP server
# project, please see <http://www.apache.org/>.
# 
# Makefile for the Apache mod_perl library
# 
# $Id: Makefile,v 1.1.1.1 2000-10-27 16:42:51 kboomsli Exp $
#

#__ORIGINAL__


INCLUDES=$(INCLUDES1) $(INCLUDES0) $(INCLUDES_DEPTH2) $(EXTRA_INCLUDES)

SHELL = /bin/sh

LIB=libperl.a

#on/off switches for Perl API hooks
#comment out to enable callbacks at a certain stage in the request
PERL_DISPATCH = -DNO_PERL_DISPATCH
PERL_CHILD_INIT = -DNO_PERL_CHILD_INIT
PERL_CHILD_EXIT = -DNO_PERL_CHILD_EXIT
PERL_RESTART = -DNO_PERL_RESTART
PERL_POST_READ_REQUEST = -DNO_PERL_POST_READ_REQUEST
PERL_TRANS   = -DNO_PERL_TRANS
PERL_HEADER_PARSER = -DNO_PERL_HEADER_PARSER
PERL_ACCESS  = -DNO_PERL_ACCESS
PERL_AUTHEN  = -DNO_PERL_AUTHEN
PERL_AUTHZ   = -DNO_PERL_AUTHZ
PERL_TYPE    = -DNO_PERL_TYPE 
PERL_FIXUP   = -DNO_PERL_FIXUP 
PERL_LOG     = -DNO_PERL_LOG 
PERL_INIT    = -DNO_PERL_INIT
PERL_CLEANUP = -DNO_PERL_CLEANUP

PERL_STACKED_HANDLERS = -DNO_PERL_STACKED_HANDLERS
PERL_SECTIONS         = -DNO_PERL_SECTIONS
PERL_METHOD_HANDLERS  = -DNO_PERL_METHOD_HANDLERS
PERL_DIRECTIVE_HANDLERS  = -DNO_PERL_DIRECTIVE_HANDLERS
PERL_SSI = -DNO_PERL_SSI

PERL_HOOKS =   $(PERL_DISPATCH) $(PERL_CHILD_INIT) $(PERL_CHILD_EXIT) \
 $(PERL_POST_READ_REQUEST) $(PERL_TRANS) $(PERL_HEADER_PARSER) \
 $(PERL_ACCESS) $(PERL_AUTHEN) $(PERL_AUTHZ) \
 $(PERL_TYPE) $(PERL_FIXUP) $(PERL_LOG) \
 $(PERL_INIT) $(PERL_CLEANUP) $(PERL_RESTART) \
 $(PERL_STACKED_HANDLERS) $(PERL_SECTIONS) $(PERL_METHOD_HANDLERS) \
 $(PERL_SSI) $(PERL_DIRECTIVE_HANDLERS)

#STATIC_SRC = Apache.c Constants.c
#STATIC_EXTS = Apache Apache::Constants

#TRACE = -DPERL_TRACE
#SSL_COMMON_INC = -I../../../ssl/include -I/usr/local/ssl/include
#APACHE_SSL = 
PERL=/usr/bin/perl
PERL_STATIC_EXTS =
PERL5LIB=`$(PERL) -MConfig -e 'print $$Config{privlibexp}'`
EXTUTILS_EMBED = $(PERL) -MExtUtils::Embed
PERL_CCFLAGS = `$(EXTUTILS_EMBED) -e ccopts` $(PERL_HOOKS) $(TRACE)

.SUFFIXES: .xs .c .o

XS_INIT = `$(EXTUTILS_EMBED) -e xsinit -- -std $(PERL_STATIC_EXTS) $(STATIC_EXTS)`

CC=`$(PERL) -MConfig -e 'print $$Config{cc}'`

# AUX_CFLAGS comes from higher level Makefile
CFLAGS=-I. -I$(INCDIR) -I$(INCDIR)/regex -I$(INCDIR)/../$(OSDIR) $(AUX_CFLAGS) \
	$(APACHE_SSL) $(PERL_CCFLAGS) \
	-DMOD_PERL_VERSION=\"$(MOD_PERL_VERSION)\" \
	$(INCLUDES)

all:	$(LIB)

perlxsi.c:
	$(XS_INIT) 

.xs.c:
	$(PERL) $(PERL5LIB)/ExtUtils/xsubpp -typemap $(PERL5LIB)/ExtUtils/typemap $*.xs > $@

PERLSRC=mod_perl_opmask.c mod_perl.c perlxsi.c perl_config.c perl_util.c perlio.c $(STATIC_SRC)

OBJS=$(PERLSRC:.c=.o)

.c.a:
	$(MAKE) $(CFLAGS) $<

$(LIB):	$(OBJS)
	rm -f $@
	ar crv $@ $(OBJS)
	$(RANLIB) $@

# dependencies
$(OBJS): mod_perl.h $(INCDIR)/httpd.h $(INCDIR)/http_config.h 
mod_perl.o: $(PERLSRC)

# various forms of cleanup
tidy:
	rm -f *.out

clean:	tidy
	rm -f *.o $(LIB) perlxsi.c Apache.c Constants.c









