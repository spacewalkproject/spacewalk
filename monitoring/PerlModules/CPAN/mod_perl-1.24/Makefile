# This Makefile is for the mod_perl extension to perl.
#
# It was generated automatically by MakeMaker version
# 5.4302 (Revision: 1.222) from the contents of
# Makefile.PL. Don't edit this file, edit Makefile.PL instead.
#
#	ANY CHANGES MADE HERE WILL BE LOST!
#
#   MakeMaker ARGV: ()
#
#   MakeMaker Parameters:

#	DEFINE => undef
#	NAME => q[mod_perl]
#	VERSION => q[1.24]
#	clean => { FILES=>q[t/docs/.htaccess t/docs/hooks.txt src/Configuration lib/Apache/MyConfig.pm Apache/Apache.xs Constants/Constants.xs t/modules/ssi.t t/logs/error_log t/conf/srm.conf t/logs/httpd.pid src/modules/perl/mod_perl_version.h t/net/perl/cgi.pl t/report t/httpd apaci/find_source apaci/apxs_cflags apaci/mod_perl.config] }
#	dist => { CI=>q[ci -u -m\"See Changes file\"], COMPRESS=>q[gzip -9f], SUFFIX=>q[gz] }
#	macro => { CVSROOT=>q[perl.apache.org:/home/cvs], PERL=>q[/usr/bin/perl], HTTPD=>q[httpd], PORT=>q[8529], APACHE_ROOT=>q[../apache_1.3.12], SHRPENV=>q[], OPCODE_FILE=>q[src/opcodes.txt], APACHE_SRC=>q[../apache_1.3.12/src], PWD=>q[/home/kboomsli/src/BUILD/mod_perl-1.24], ARCHNAME=>q[i386-linux] }

# --- MakeMaker post_initialize section:


# --- MakeMaker const_config section:

# These definitions are from config.sh (via /usr/lib/perl5/5.00503/i386-linux/Config.pm)

# They may have been overridden via Makefile.PL or on the command line
AR = ar
CC = cc
CCCDLFLAGS = -fpic
CCDLFLAGS = -rdynamic
DLEXT = so
DLSRC = dl_dlopen.xs
LD = cc
LDDLFLAGS = -shared -L/usr/local/lib
LDFLAGS =  -L/usr/local/lib
LIBC = 
LIB_EXT = .a
OBJ_EXT = .o
OSNAME = linux
OSVERS = 2.2.5-22smp
RANLIB = :
SO = so
EXE_EXT = 


# --- MakeMaker constants section:
AR_STATIC_ARGS = cr
NAME = mod_perl
DISTNAME = mod_perl
NAME_SYM = mod_perl
VERSION = 1.24
VERSION_SYM = 1_24
XS_VERSION = 1.24
INST_BIN = blib/bin
INST_EXE = blib/script
INST_LIB = blib/lib
INST_ARCHLIB = blib/arch
INST_SCRIPT = blib/script
PREFIX = /usr
INSTALLDIRS = site
INSTALLPRIVLIB = $(PREFIX)/lib/perl5/5.00503
INSTALLARCHLIB = $(PREFIX)/lib/perl5/5.00503/i386-linux
INSTALLSITELIB = $(PREFIX)/lib/perl5/site_perl/5.005
INSTALLSITEARCH = $(PREFIX)/lib/perl5/site_perl/5.005/i386-linux
INSTALLBIN = $(PREFIX)/bin
INSTALLSCRIPT = $(PREFIX)/bin
PERL_LIB = /usr/lib/perl5/5.00503
PERL_ARCHLIB = /usr/lib/perl5/5.00503/i386-linux
SITELIBEXP = /usr/lib/perl5/site_perl/5.005
SITEARCHEXP = /usr/lib/perl5/site_perl/5.005/i386-linux
LIBPERL_A = libperl.a
FIRST_MAKEFILE = Makefile
MAKE_APERL_FILE = Makefile.aperl
PERLMAINCC = $(CC)
PERL_INC = /usr/lib/perl5/5.00503/i386-linux/CORE
PERL = /usr/bin/perl
FULLPERL = /usr/bin/perl

VERSION_MACRO = VERSION
DEFINE_VERSION = -D$(VERSION_MACRO)=\"$(VERSION)\"
XS_VERSION_MACRO = XS_VERSION
XS_DEFINE_VERSION = -D$(XS_VERSION_MACRO)=\"$(XS_VERSION)\"

MAKEMAKER = /usr/lib/perl5/5.00503/ExtUtils/MakeMaker.pm
MM_VERSION = 5.4302

# FULLEXT = Pathname for extension directory (eg Foo/Bar/Oracle).
# BASEEXT = Basename part of FULLEXT. May be just equal FULLEXT. (eg Oracle)
# ROOTEXT = Directory part of FULLEXT with leading slash (eg /DBD)  !!! Deprecated from MM 5.32  !!!
# PARENT_NAME = NAME without BASEEXT and no trailing :: (eg Foo::Bar)
# DLBASE  = Basename part of dynamic library. May be just equal BASEEXT.
FULLEXT = mod_perl
BASEEXT = mod_perl
DLBASE = $(BASEEXT)
OBJECT = 
LDFROM = $(OBJECT)
LINKTYPE = dynamic

# Handy lists of source code files:
XS_FILES= 
C_FILES = 
O_FILES = 
H_FILES = 
MAN1PODS = 
MAN3PODS = cgi_to_mod_perl.pod \
	lib/Apache/Debug.pm \
	lib/Apache/ExtUtils.pm \
	lib/Apache/FakeRequest.pm \
	lib/Apache/Include.pm \
	lib/Apache/Options.pm \
	lib/Apache/PerlRun.pm \
	lib/Apache/PerlSections.pm \
	lib/Apache/RedirectLogFix.pm \
	lib/Apache/Registry.pm \
	lib/Apache/RegistryLoader.pm \
	lib/Apache/Resource.pm \
	lib/Apache/SIG.pm \
	lib/Apache/SizeLimit.pm \
	lib/Apache/StatINC.pm \
	lib/Apache/Status.pm \
	lib/Apache/Symdump.pm \
	lib/Apache/httpd_conf.pm \
	lib/Apache/src.pm \
	lib/Bundle/Apache.pm \
	mod_perl.pod \
	mod_perl_cvs.pod \
	mod_perl_method_handlers.pod \
	mod_perl_traps.pod \
	mod_perl_tuning.pod
INST_MAN1DIR = blib/man1
INSTALLMAN1DIR = $(PREFIX)/man/man1
MAN1EXT = 1
INST_MAN3DIR = blib/man3
INSTALLMAN3DIR = $(PREFIX)/lib/perl5/man/man3
MAN3EXT = 3
PERM_RW = 644
PERM_RWX = 755

# work around a famous dec-osf make(1) feature(?):
makemakerdflt: all

.SUFFIXES: .xs .c .C .cpp .cxx .cc $(OBJ_EXT)

# Nick wanted to get rid of .PRECIOUS. I don't remember why. I seem to recall, that
# some make implementations will delete the Makefile when we rebuild it. Because
# we call false(1) when we rebuild it. So make(1) is not completely wrong when it
# does so. Our milage may vary.
# .PRECIOUS: Makefile    # seems to be not necessary anymore

.PHONY: all config static dynamic test linkext manifest

# Where is the Config information that we are using/depend on
CONFIGDEP = $(PERL_ARCHLIB)/Config.pm $(PERL_INC)/config.h

# Where to put things:
INST_LIBDIR      = $(INST_LIB)
INST_ARCHLIBDIR  = $(INST_ARCHLIB)

INST_AUTODIR     = $(INST_LIB)/auto/$(FULLEXT)
INST_ARCHAUTODIR = $(INST_ARCHLIB)/auto/$(FULLEXT)

INST_STATIC  =
INST_DYNAMIC =
INST_BOOT    =

EXPORT_LIST = 

PERL_ARCHIVE = 

TO_INST_PM = ../apache_1.3.12/src/include/alloc.h \
	../apache_1.3.12/src/include/ap.h \
	../apache_1.3.12/src/include/ap_compat.h \
	../apache_1.3.12/src/include/ap_config.h \
	../apache_1.3.12/src/include/ap_config_auto.h \
	../apache_1.3.12/src/include/ap_ctype.h \
	../apache_1.3.12/src/include/ap_md5.h \
	../apache_1.3.12/src/include/ap_mmn.h \
	../apache_1.3.12/src/include/ap_sha1.h \
	../apache_1.3.12/src/include/buff.h \
	../apache_1.3.12/src/include/compat.h \
	../apache_1.3.12/src/include/conf.h \
	../apache_1.3.12/src/include/explain.h \
	../apache_1.3.12/src/include/fnmatch.h \
	../apache_1.3.12/src/include/hsregex.h \
	../apache_1.3.12/src/include/http_conf_globals.h \
	../apache_1.3.12/src/include/http_config.h \
	../apache_1.3.12/src/include/http_core.h \
	../apache_1.3.12/src/include/http_log.h \
	../apache_1.3.12/src/include/http_main.h \
	../apache_1.3.12/src/include/http_protocol.h \
	../apache_1.3.12/src/include/http_request.h \
	../apache_1.3.12/src/include/http_vhost.h \
	../apache_1.3.12/src/include/httpd.h \
	../apache_1.3.12/src/include/multithread.h \
	../apache_1.3.12/src/include/rfc1413.h \
	../apache_1.3.12/src/include/scoreboard.h \
	../apache_1.3.12/src/include/util_date.h \
	../apache_1.3.12/src/include/util_md5.h \
	../apache_1.3.12/src/include/util_script.h \
	../apache_1.3.12/src/include/util_uri.h \
	../apache_1.3.12/src/lib/expat-lite/asciitab.h \
	../apache_1.3.12/src/lib/expat-lite/hashtable.h \
	../apache_1.3.12/src/lib/expat-lite/iasciitab.h \
	../apache_1.3.12/src/lib/expat-lite/latin1tab.h \
	../apache_1.3.12/src/lib/expat-lite/nametab.h \
	../apache_1.3.12/src/lib/expat-lite/utf8tab.h \
	../apache_1.3.12/src/lib/expat-lite/xmldef.h \
	../apache_1.3.12/src/lib/expat-lite/xmlparse.h \
	../apache_1.3.12/src/lib/expat-lite/xmlrole.h \
	../apache_1.3.12/src/lib/expat-lite/xmltok.h \
	../apache_1.3.12/src/lib/expat-lite/xmltok_impl.h \
	../apache_1.3.12/src/modules/perl/apache_inc.h \
	../apache_1.3.12/src/modules/perl/mod_perl.h \
	../apache_1.3.12/src/modules/perl/mod_perl_version.h \
	../apache_1.3.12/src/modules/perl/mod_perl_xs.h \
	../apache_1.3.12/src/modules/perl/perl_PL.h \
	../apache_1.3.12/src/modules/proxy/mod_proxy.h \
	../apache_1.3.12/src/modules/standard/mod_rewrite.h \
	../apache_1.3.12/src/os/bs2000/ebcdic.h \
	../apache_1.3.12/src/os/bs2000/os-inline.c \
	../apache_1.3.12/src/os/bs2000/os.h \
	../apache_1.3.12/src/os/mpeix/os-inline.c \
	../apache_1.3.12/src/os/mpeix/os.h \
	../apache_1.3.12/src/os/netware/getopt.h \
	../apache_1.3.12/src/os/netware/os.h \
	../apache_1.3.12/src/os/netware/precomp.h \
	../apache_1.3.12/src/os/netware/test_char.h \
	../apache_1.3.12/src/os/netware/uri_delims.h \
	../apache_1.3.12/src/os/os2/os-inline.c \
	../apache_1.3.12/src/os/os2/os.h \
	../apache_1.3.12/src/os/os390/ebcdic.h \
	../apache_1.3.12/src/os/os390/os-inline.c \
	../apache_1.3.12/src/os/os390/os.h \
	../apache_1.3.12/src/os/tpf/ebcdic.h \
	../apache_1.3.12/src/os/tpf/os-inline.c \
	../apache_1.3.12/src/os/tpf/os.h \
	../apache_1.3.12/src/os/unix/os-inline.c \
	../apache_1.3.12/src/os/unix/os.h \
	../apache_1.3.12/src/os/win32/getopt.h \
	../apache_1.3.12/src/os/win32/installer/installdll/test/resource.h \
	../apache_1.3.12/src/os/win32/installer/installdll/test/test.h \
	../apache_1.3.12/src/os/win32/os.h \
	../apache_1.3.12/src/os/win32/passwd.h \
	../apache_1.3.12/src/os/win32/readdir.h \
	../apache_1.3.12/src/os/win32/registry.h \
	../apache_1.3.12/src/os/win32/resource.h \
	../apache_1.3.12/src/os/win32/service.h \
	../apache_1.3.12/src/regex/cclass.h \
	../apache_1.3.12/src/regex/cname.h \
	../apache_1.3.12/src/regex/regex2.h \
	../apache_1.3.12/src/regex/utils.h \
	../apache_1.3.12/src/support/suexec.h \
	Apache/typemap \
	apaci/mod_perl.exp \
	cgi_to_mod_perl.pod \
	lib/Apache/Constants/Exports.pm \
	lib/Apache/Debug.pm \
	lib/Apache/ExtUtils.pm \
	lib/Apache/FakeRequest.pm \
	lib/Apache/Include.pm \
	lib/Apache/MyConfig.pm \
	lib/Apache/Opcode.pm \
	lib/Apache/Options.pm \
	lib/Apache/PerlRun.pm \
	lib/Apache/PerlSections.pm \
	lib/Apache/RedirectLogFix.pm \
	lib/Apache/Registry.pm \
	lib/Apache/RegistryBB.pm \
	lib/Apache/RegistryLoader.pm \
	lib/Apache/RegistryNG.pm \
	lib/Apache/Resource.pm \
	lib/Apache/SIG.pm \
	lib/Apache/SizeLimit.pm \
	lib/Apache/StatINC.pm \
	lib/Apache/Status.pm \
	lib/Apache/Symdump.pm \
	lib/Apache/httpd_conf.pm \
	lib/Apache/src.pm \
	lib/Apache/test.pm \
	lib/Bundle/Apache.pm \
	lib/mod_perl.pm \
	lib/mod_perl_hooks.pm \
	lib/mod_perl_hooks.pm.PL \
	mod_perl.pod \
	mod_perl_cvs.pod \
	mod_perl_method_handlers.pod \
	mod_perl_traps.pod \
	mod_perl_tuning.pod

PM_TO_BLIB = ../apache_1.3.12/src/include/multithread.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/multithread.h \
	../apache_1.3.12/src/include/buff.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/buff.h \
	../apache_1.3.12/src/include/httpd.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/httpd.h \
	../apache_1.3.12/src/os/netware/os.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/netware/os.h \
	mod_perl.pod \
	$(INST_LIBDIR)/mod_perl.pod \
	../apache_1.3.12/src/support/suexec.h \
	$(INST_ARCHLIB)/auto/Apache/include/support/suexec.h \
	../apache_1.3.12/src/include/ap_config.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/ap_config.h \
	../apache_1.3.12/src/regex/utils.h \
	$(INST_ARCHLIB)/auto/Apache/include/regex/utils.h \
	../apache_1.3.12/src/lib/expat-lite/iasciitab.h \
	$(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/iasciitab.h \
	../apache_1.3.12/src/modules/perl/mod_perl.h \
	$(INST_ARCHLIB)/auto/Apache/include/modules/perl/mod_perl.h \
	../apache_1.3.12/src/include/alloc.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/alloc.h \
	../apache_1.3.12/src/os/bs2000/os-inline.c \
	$(INST_ARCHLIB)/auto/Apache/include/os/bs2000/os-inline.c \
	../apache_1.3.12/src/os/win32/service.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/win32/service.h \
	../apache_1.3.12/src/os/tpf/ebcdic.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/tpf/ebcdic.h \
	../apache_1.3.12/src/include/ap.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/ap.h \
	../apache_1.3.12/src/os/win32/getopt.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/win32/getopt.h \
	../apache_1.3.12/src/os/unix/os.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/unix/os.h \
	../apache_1.3.12/src/include/ap_md5.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/ap_md5.h \
	../apache_1.3.12/src/os/win32/registry.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/win32/registry.h \
	../apache_1.3.12/src/os/tpf/os.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/tpf/os.h \
	lib/Bundle/Apache.pm \
	$(INST_LIB)/Bundle/Apache.pm \
	../apache_1.3.12/src/lib/expat-lite/xmldef.h \
	$(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/xmldef.h \
	../apache_1.3.12/src/lib/expat-lite/latin1tab.h \
	$(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/latin1tab.h \
	../apache_1.3.12/src/include/util_md5.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/util_md5.h \
	../apache_1.3.12/src/include/rfc1413.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/rfc1413.h \
	lib/Apache/test.pm \
	$(INST_LIB)/Apache/test.pm \
	../apache_1.3.12/src/include/conf.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/conf.h \
	../apache_1.3.12/src/os/win32/resource.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/win32/resource.h \
	lib/mod_perl_hooks.pm \
	$(INST_LIB)/mod_perl_hooks.pm \
	../apache_1.3.12/src/lib/expat-lite/xmlparse.h \
	$(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/xmlparse.h \
	lib/Apache/Debug.pm \
	$(INST_LIB)/Apache/Debug.pm \
	lib/Apache/src.pm \
	$(INST_LIB)/Apache/src.pm \
	lib/Apache/Resource.pm \
	$(INST_LIB)/Apache/Resource.pm \
	../apache_1.3.12/src/include/util_uri.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/util_uri.h \
	lib/Apache/httpd_conf.pm \
	$(INST_LIB)/Apache/httpd_conf.pm \
	../apache_1.3.12/src/modules/perl/mod_perl_version.h \
	$(INST_ARCHLIB)/auto/Apache/include/modules/perl/mod_perl_version.h \
	../apache_1.3.12/src/include/explain.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/explain.h \
	lib/mod_perl_hooks.pm.PL \
	$(INST_LIB)/mod_perl_hooks.pm.PL \
	Apache/typemap \
	$(INST_ARCHLIB)/auto/Apache/typemap \
	lib/Apache/Symdump.pm \
	$(INST_LIB)/Apache/Symdump.pm \
	../apache_1.3.12/src/os/os390/os-inline.c \
	$(INST_ARCHLIB)/auto/Apache/include/os/os390/os-inline.c \
	../apache_1.3.12/src/include/ap_compat.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/ap_compat.h \
	lib/Apache/RegistryLoader.pm \
	$(INST_LIB)/Apache/RegistryLoader.pm \
	../apache_1.3.12/src/include/http_config.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/http_config.h \
	../apache_1.3.12/src/os/netware/getopt.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/netware/getopt.h \
	../apache_1.3.12/src/os/mpeix/os-inline.c \
	$(INST_ARCHLIB)/auto/Apache/include/os/mpeix/os-inline.c \
	mod_perl_tuning.pod \
	$(INST_LIBDIR)/mod_perl_tuning.pod \
	../apache_1.3.12/src/os/unix/os-inline.c \
	$(INST_ARCHLIB)/auto/Apache/include/os/unix/os-inline.c \
	../apache_1.3.12/src/include/ap_sha1.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/ap_sha1.h \
	lib/Apache/Registry.pm \
	$(INST_LIB)/Apache/Registry.pm \
	../apache_1.3.12/src/os/bs2000/ebcdic.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/bs2000/ebcdic.h \
	../apache_1.3.12/src/lib/expat-lite/xmltok.h \
	$(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/xmltok.h \
	lib/Apache/SizeLimit.pm \
	$(INST_LIB)/Apache/SizeLimit.pm \
	lib/Apache/RedirectLogFix.pm \
	$(INST_LIB)/Apache/RedirectLogFix.pm \
	../apache_1.3.12/src/os/netware/test_char.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/netware/test_char.h \
	lib/Apache/MyConfig.pm \
	$(INST_LIB)/Apache/MyConfig.pm \
	../apache_1.3.12/src/lib/expat-lite/xmlrole.h \
	$(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/xmlrole.h \
	../apache_1.3.12/src/os/os2/os.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/os2/os.h \
	../apache_1.3.12/src/include/compat.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/compat.h \
	../apache_1.3.12/src/include/scoreboard.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/scoreboard.h \
	../apache_1.3.12/src/os/os390/ebcdic.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/os390/ebcdic.h \
	../apache_1.3.12/src/modules/perl/perl_PL.h \
	$(INST_ARCHLIB)/auto/Apache/include/modules/perl/perl_PL.h \
	lib/Apache/Constants/Exports.pm \
	$(INST_LIB)/Apache/Constants/Exports.pm \
	../apache_1.3.12/src/os/bs2000/os.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/bs2000/os.h \
	../apache_1.3.12/src/modules/proxy/mod_proxy.h \
	$(INST_ARCHLIB)/auto/Apache/include/modules/proxy/mod_proxy.h \
	lib/Apache/SIG.pm \
	$(INST_LIB)/Apache/SIG.pm \
	../apache_1.3.12/src/include/http_core.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/http_core.h \
	../apache_1.3.12/src/include/http_request.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/http_request.h \
	../apache_1.3.12/src/lib/expat-lite/hashtable.h \
	$(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/hashtable.h \
	../apache_1.3.12/src/os/os390/os.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/os390/os.h \
	../apache_1.3.12/src/os/win32/installer/installdll/test/test.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/win32/installer/installdll/test/test.h \
	../apache_1.3.12/src/os/netware/uri_delims.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/netware/uri_delims.h \
	mod_perl_cvs.pod \
	$(INST_LIBDIR)/mod_perl_cvs.pod \
	../apache_1.3.12/src/include/http_protocol.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/http_protocol.h \
	mod_perl_method_handlers.pod \
	$(INST_LIBDIR)/mod_perl_method_handlers.pod \
	../apache_1.3.12/src/modules/standard/mod_rewrite.h \
	$(INST_ARCHLIB)/auto/Apache/include/modules/standard/mod_rewrite.h \
	../apache_1.3.12/src/lib/expat-lite/nametab.h \
	$(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/nametab.h \
	../apache_1.3.12/src/os/netware/precomp.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/netware/precomp.h \
	lib/Apache/StatINC.pm \
	$(INST_LIB)/Apache/StatINC.pm \
	../apache_1.3.12/src/include/util_date.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/util_date.h \
	lib/Apache/Opcode.pm \
	$(INST_LIB)/Apache/Opcode.pm \
	lib/Apache/PerlSections.pm \
	$(INST_LIB)/Apache/PerlSections.pm \
	../apache_1.3.12/src/os/win32/os.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/win32/os.h \
	../apache_1.3.12/src/regex/regex2.h \
	$(INST_ARCHLIB)/auto/Apache/include/regex/regex2.h \
	lib/Apache/FakeRequest.pm \
	$(INST_LIB)/Apache/FakeRequest.pm \
	../apache_1.3.12/src/include/http_main.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/http_main.h \
	lib/mod_perl.pm \
	$(INST_LIB)/mod_perl.pm \
	lib/Apache/ExtUtils.pm \
	$(INST_LIB)/Apache/ExtUtils.pm \
	lib/Apache/Status.pm \
	$(INST_LIB)/Apache/Status.pm \
	lib/Apache/Include.pm \
	$(INST_LIB)/Apache/Include.pm \
	../apache_1.3.12/src/include/http_conf_globals.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/http_conf_globals.h \
	../apache_1.3.12/src/os/os2/os-inline.c \
	$(INST_ARCHLIB)/auto/Apache/include/os/os2/os-inline.c \
	lib/Apache/PerlRun.pm \
	$(INST_LIB)/Apache/PerlRun.pm \
	mod_perl_traps.pod \
	$(INST_LIBDIR)/mod_perl_traps.pod \
	../apache_1.3.12/src/lib/expat-lite/xmltok_impl.h \
	$(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/xmltok_impl.h \
	../apache_1.3.12/src/regex/cclass.h \
	$(INST_ARCHLIB)/auto/Apache/include/regex/cclass.h \
	lib/Apache/Options.pm \
	$(INST_LIB)/Apache/Options.pm \
	../apache_1.3.12/src/os/win32/passwd.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/win32/passwd.h \
	../apache_1.3.12/src/os/mpeix/os.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/mpeix/os.h \
	../apache_1.3.12/src/modules/perl/apache_inc.h \
	$(INST_ARCHLIB)/auto/Apache/include/modules/perl/apache_inc.h \
	lib/Apache/RegistryNG.pm \
	$(INST_LIB)/Apache/RegistryNG.pm \
	../apache_1.3.12/src/include/util_script.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/util_script.h \
	../apache_1.3.12/src/modules/perl/mod_perl_xs.h \
	$(INST_ARCHLIB)/auto/Apache/include/modules/perl/mod_perl_xs.h \
	../apache_1.3.12/src/include/http_vhost.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/http_vhost.h \
	../apache_1.3.12/src/include/ap_ctype.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/ap_ctype.h \
	../apache_1.3.12/src/os/win32/installer/installdll/test/resource.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/win32/installer/installdll/test/resource.h \
	../apache_1.3.12/src/include/hsregex.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/hsregex.h \
	../apache_1.3.12/src/include/ap_mmn.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/ap_mmn.h \
	cgi_to_mod_perl.pod \
	$(INST_LIBDIR)/cgi_to_mod_perl.pod \
	../apache_1.3.12/src/regex/cname.h \
	$(INST_ARCHLIB)/auto/Apache/include/regex/cname.h \
	../apache_1.3.12/src/os/win32/readdir.h \
	$(INST_ARCHLIB)/auto/Apache/include/os/win32/readdir.h \
	apaci/mod_perl.exp \
	$(INST_ARCHLIB)/auto/Apache/mod_perl.exp \
	../apache_1.3.12/src/lib/expat-lite/utf8tab.h \
	$(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/utf8tab.h \
	../apache_1.3.12/src/include/ap_config_auto.h \
	$(INST_ARCHLIB)/auto/Apache/include/ap_config_auto.h \
	../apache_1.3.12/src/lib/expat-lite/asciitab.h \
	$(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/asciitab.h \
	../apache_1.3.12/src/os/tpf/os-inline.c \
	$(INST_ARCHLIB)/auto/Apache/include/os/tpf/os-inline.c \
	lib/Apache/RegistryBB.pm \
	$(INST_LIB)/Apache/RegistryBB.pm \
	../apache_1.3.12/src/include/fnmatch.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/fnmatch.h \
	../apache_1.3.12/src/include/http_log.h \
	$(INST_ARCHLIB)/auto/Apache/include/include/http_log.h


# --- MakeMaker tool_autosplit section:

# Usage: $(AUTOSPLITFILE) FileToSplit AutoDirToSplitInto
AUTOSPLITFILE = $(PERL) "-I$(PERL_ARCHLIB)" "-I$(PERL_LIB)" -e 'use AutoSplit;autosplit($$ARGV[0], $$ARGV[1], 0, 1, 1) ;'


# --- MakeMaker tool_xsubpp section:

XSUBPPDIR = /usr/lib/perl5/5.00503/ExtUtils
XSUBPP = $(XSUBPPDIR)/xsubpp
XSPROTOARG = 
XSUBPPDEPS = $(XSUBPPDIR)/typemap
XSUBPPARGS = -typemap $(XSUBPPDIR)/typemap


# --- MakeMaker tools_other section:

SHELL = /bin/sh
CHMOD = chmod
CP = cp
LD = cc
MV = mv
NOOP = $(SHELL) -c true
RM_F = rm -f
RM_RF = rm -rf
TEST_F = test -f
TOUCH = touch
UMASK_NULL = umask 0
DEV_NULL = > /dev/null 2>&1

# The following is a portable way to say mkdir -p
# To see which directories are created, change the if 0 to if 1
MKPATH = $(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) -MExtUtils::Command -e mkpath

# This helps us to minimize the effect of the .exists files A yet
# better solution would be to have a stable file in the perl
# distribution with a timestamp of zero. But this solution doesn't
# need any changes to the core distribution and works with older perls
EQUALIZE_TIMESTAMP = $(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) -MExtUtils::Command -e eqtime

# Here we warn users that an old packlist file was found somewhere,
# and that they should call some uninstall routine
WARN_IF_OLD_PACKLIST = $(PERL) -we 'exit unless -f $$ARGV[0];' \
-e 'print "WARNING: I have found an old package in\n";' \
-e 'print "\t$$ARGV[0].\n";' \
-e 'print "Please make sure the two installations are not conflicting\n";'

UNINST=0
VERBINST=1

MOD_INSTALL = $(PERL) -I$(INST_LIB) -I$(PERL_LIB) -MExtUtils::Install \
-e "install({@ARGV},'$(VERBINST)',0,'$(UNINST)');"

DOC_INSTALL = $(PERL) -e '$$\="\n\n";' \
-e 'print "=head2 ", scalar(localtime), ": C<", shift, ">", " L<", shift, ">";' \
-e 'print "=over 4";' \
-e 'while (defined($$key = shift) and defined($$val = shift)){print "=item *";print "C<$$key: $$val>";}' \
-e 'print "=back";'

UNINSTALL =   $(PERL) -MExtUtils::Install \
-e 'uninstall($$ARGV[0],1,1); print "\nUninstall is deprecated. Please check the";' \
-e 'print " packlist above carefully.\n  There may be errors. Remove the";' \
-e 'print " appropriate files manually.\n  Sorry for the inconveniences.\n"'


# --- MakeMaker dist section:

DISTVNAME = $(DISTNAME)-$(VERSION)
TAR  = tar
TARFLAGS = cvf
ZIP  = zip
ZIPFLAGS = -r
COMPRESS = gzip -9f
SUFFIX = gz
SHAR = shar
PREOP = @$(NOOP)
POSTOP = @$(NOOP)
TO_UNIX = @$(NOOP)
CI = ci -u -m\"See Changes file\"
RCS_LABEL = rcs -Nv$(VERSION_SYM): -q
DIST_CP = best
DIST_DEFAULT = tardist


# --- MakeMaker macro section:
CVSROOT = perl.apache.org:/home/cvs
PERL = /usr/bin/perl
HTTPD = httpd
PORT = 8529
APACHE_ROOT = ../apache_1.3.12
SHRPENV = 
OPCODE_FILE = src/opcodes.txt
APACHE_SRC = ../apache_1.3.12/src
PWD = /home/kboomsli/src/BUILD/mod_perl-1.24
ARCHNAME = i386-linux


# --- MakeMaker depend section:


# --- MakeMaker cflags section:

CCFLAGS = -Dbool=char -DHAS_BOOL -I/usr/local/include
OPTIMIZE = -O2 -m486 -fno-strength-reduce
PERLTYPE = 
LARGE = 
SPLIT = 


# --- MakeMaker const_loadlibs section:

# mod_perl might depend on some other libraries:
# See ExtUtils::Liblist for details
#
LD_RUN_PATH = 


# --- MakeMaker const_cccmd section:
CCCMD = $(CC) -c $(INC) $(CCFLAGS) $(OPTIMIZE) \
	$(PERLTYPE) $(LARGE) $(SPLIT) $(DEFINE_VERSION) \
	$(XS_DEFINE_VERSION)

# --- MakeMaker post_constants section:


# --- MakeMaker pasthru section:

PASTHRU = LIB="$(LIB)"\
	LIBPERL_A="$(LIBPERL_A)"\
	LINKTYPE="$(LINKTYPE)"\
	PREFIX="$(PREFIX)"\
	OPTIMIZE="$(OPTIMIZE)"\
	APACHE_SRC="$(APACHE_SRC)"\
	DEFINE="$(DEFINE)"


# --- MakeMaker c_o section:

.c$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $*.c

.C$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $*.C

.cpp$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $*.cpp

.cxx$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $*.cxx

.cc$(OBJ_EXT):
	$(CCCMD) $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $*.cc


# --- MakeMaker xs_c section:

.xs.c:
	$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) $(XSUBPP) $(XSPROTOARG) $(XSUBPPARGS) $*.xs >xstmp.c && $(MV) xstmp.c $*.c


# --- MakeMaker xs_o section:

.xs$(OBJ_EXT):
	$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) $(XSUBPP) $(XSPROTOARG) $(XSUBPPARGS) $*.xs >xstmp.c && $(MV) xstmp.c $*.c
	$(CCCMD) $(CCCDLFLAGS) -I$(PERL_INC) $(DEFINE) $*.c


# --- MakeMaker top_targets section:

#all ::	config $(INST_PM) subdirs linkext manifypods

all :: pure_all manifypods
	@$(NOOP)

pure_all :: config pm_to_blib subdirs linkext
	@$(NOOP)

subdirs :: $(MYEXTLIB)
	@$(NOOP)

config :: Makefile $(INST_LIBDIR)/.exists
	@$(NOOP)

config :: $(INST_ARCHAUTODIR)/.exists
	@$(NOOP)

config :: $(INST_AUTODIR)/.exists
	@$(NOOP)

config :: Version_check
	@$(NOOP)


$(INST_AUTODIR)/.exists :: /usr/lib/perl5/5.00503/i386-linux/CORE/perl.h
	@$(MKPATH) $(INST_AUTODIR)
	@$(EQUALIZE_TIMESTAMP) /usr/lib/perl5/5.00503/i386-linux/CORE/perl.h $(INST_AUTODIR)/.exists

	-@$(CHMOD) $(PERM_RWX) $(INST_AUTODIR)

$(INST_LIBDIR)/.exists :: /usr/lib/perl5/5.00503/i386-linux/CORE/perl.h
	@$(MKPATH) $(INST_LIBDIR)
	@$(EQUALIZE_TIMESTAMP) /usr/lib/perl5/5.00503/i386-linux/CORE/perl.h $(INST_LIBDIR)/.exists

	-@$(CHMOD) $(PERM_RWX) $(INST_LIBDIR)

$(INST_ARCHAUTODIR)/.exists :: /usr/lib/perl5/5.00503/i386-linux/CORE/perl.h
	@$(MKPATH) $(INST_ARCHAUTODIR)
	@$(EQUALIZE_TIMESTAMP) /usr/lib/perl5/5.00503/i386-linux/CORE/perl.h $(INST_ARCHAUTODIR)/.exists

	-@$(CHMOD) $(PERM_RWX) $(INST_ARCHAUTODIR)

config :: $(INST_MAN3DIR)/.exists
	@$(NOOP)


$(INST_MAN3DIR)/.exists :: /usr/lib/perl5/5.00503/i386-linux/CORE/perl.h
	@$(MKPATH) $(INST_MAN3DIR)
	@$(EQUALIZE_TIMESTAMP) /usr/lib/perl5/5.00503/i386-linux/CORE/perl.h $(INST_MAN3DIR)/.exists

	-@$(CHMOD) $(PERM_RWX) $(INST_MAN3DIR)

help:
	perldoc ExtUtils::MakeMaker

Version_check:
	@$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) \
		-MExtUtils::MakeMaker=Version_check \
		-e "Version_check('$(MM_VERSION)')"

gen_exports:
	$(PERL) -I./lib -MExtUtils::testlib -MApache::Constants::Exports \
	-e 'Apache::Constants::Exports->gen_ctags' > Exports.c

gen_op_mask:
	$(PERL) -MExtUtils::testlib -MApache::Opcode \
	-e 'Apache::Opcode->gen_op_mask' -- $(OPCODE_FILE) > op_mask.c

update_op_mask: gen_op_mask
	@$(RM_F) $(APACHE_SRC)/modules/perl/mod_perl_opmask.o
	$(CP) op_mask.c $(APACHE_SRC)/modules/perl/op_mask.c

apxs_distclean:
	(cd ./apaci && $(MAKE) distclean)

apxs_libperl:
	(cd ./apaci && $(MAKE))

apxs_install: apxs_libperl
	(cd ./apaci && $(MAKE) install;)

apache_httpd: $(APACHE_SRC)/Makefile.tmpl
	(cd $(APACHE_SRC) && $(SHRPENV) $(MAKE) CC="$(CC)";)

apaci_httpd: 
	(cd $(APACHE_ROOT) && $(MAKE))

apaci_install: 
	(cd $(APACHE_ROOT) && $(MAKE) install)

tar_Apache:
	(cd $(INSTALLSITELIB); \
	     $(TAR) -cf $(PWD)/Apache.tar mod_perl.pm Apache.pm Apache $(ARCHNAME)/auto/Apache; )

offsite-tar:
	$(CP) MANIFEST MANIFEST.orig
	$(PERL) -e 'for (<$(APACHE_SRC)/*.h>) {' \
	-e 'system "$(CP) $$_ src/";' \
	-e 's,^$(APACHE_SRC),,;' \
	-e 'system "echo src$$_ >> MANIFEST";' \
	-e '}' 
	$(MAKE) dist
	$(RM_F) src/*.h
	$(MV) MANIFEST.orig MANIFEST



# --- MakeMaker linkext section:

linkext :: $(LINKTYPE)
	@$(NOOP)


# --- MakeMaker dlsyms section:


# --- MakeMaker dynamic section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make dynamic"
#dynamic :: Makefile $(INST_DYNAMIC) $(INST_BOOT) $(INST_PM)
dynamic :: Makefile $(INST_DYNAMIC) $(INST_BOOT)
	@$(NOOP)


# --- MakeMaker dynamic_bs section:

BOOTSTRAP =


# --- MakeMaker dynamic_lib section:


# --- MakeMaker static section:

## $(INST_PM) has been moved to the all: target.
## It remains here for awhile to allow for old usage: "make static"
#static :: Makefile $(INST_STATIC) $(INST_PM)
static :: Makefile $(INST_STATIC)
	@$(NOOP)


# --- MakeMaker static_lib section:


# --- MakeMaker manifypods section:
POD2MAN_EXE = /usr/bin/pod2man --release mod_perl-1.24
POD2MAN = $(PERL) -we '%m=@ARGV;for (keys %m){' \
-e 'next if -e $$m{$$_} && -M $$m{$$_} < -M $$_ && -M $$m{$$_} < -M "Makefile";' \
-e 'print "Manifying $$m{$$_}\n";' \
-e 'system(qq[$$^X ].q["-I$(PERL_ARCHLIB)" "-I$(PERL_LIB)" $(POD2MAN_EXE) ].qq[$$_>$$m{$$_}])==0 or warn "Couldn\047t install $$m{$$_}\n";' \
-e 'chmod(oct($(PERM_RW))), $$m{$$_} or warn "chmod $(PERM_RW) $$m{$$_}: $$!\n";}'

manifypods : pure_all lib/Apache/FakeRequest.pm \
	mod_perl.pod \
	lib/Apache/ExtUtils.pm \
	lib/Apache/SIG.pm \
	lib/Apache/Include.pm \
	lib/Apache/Status.pm \
	lib/Apache/Debug.pm \
	lib/Apache/Resource.pm \
	lib/Apache/src.pm \
	lib/Apache/PerlRun.pm \
	lib/Apache/httpd_conf.pm \
	mod_perl_traps.pod \
	lib/Apache/Options.pm \
	mod_perl_cvs.pod \
	lib/Apache/Symdump.pm \
	lib/Apache/RegistryLoader.pm \
	mod_perl_method_handlers.pod \
	mod_perl_tuning.pod \
	cgi_to_mod_perl.pod \
	lib/Apache/StatINC.pm \
	lib/Apache/Registry.pm \
	lib/Apache/SizeLimit.pm \
	lib/Bundle/Apache.pm \
	lib/Apache/RedirectLogFix.pm \
	lib/Apache/PerlSections.pm
	@$(POD2MAN) \
	lib/Apache/FakeRequest.pm \
	$(INST_MAN3DIR)/Apache::FakeRequest.$(MAN3EXT) \
	mod_perl.pod \
	$(INST_MAN3DIR)/mod_perl.$(MAN3EXT) \
	lib/Apache/ExtUtils.pm \
	$(INST_MAN3DIR)/Apache::ExtUtils.$(MAN3EXT) \
	lib/Apache/SIG.pm \
	$(INST_MAN3DIR)/Apache::SIG.$(MAN3EXT) \
	lib/Apache/Include.pm \
	$(INST_MAN3DIR)/Apache::Include.$(MAN3EXT) \
	lib/Apache/Status.pm \
	$(INST_MAN3DIR)/Apache::Status.$(MAN3EXT) \
	lib/Apache/Debug.pm \
	$(INST_MAN3DIR)/Apache::Debug.$(MAN3EXT) \
	lib/Apache/Resource.pm \
	$(INST_MAN3DIR)/Apache::Resource.$(MAN3EXT) \
	lib/Apache/src.pm \
	$(INST_MAN3DIR)/Apache::src.$(MAN3EXT) \
	lib/Apache/PerlRun.pm \
	$(INST_MAN3DIR)/Apache::PerlRun.$(MAN3EXT) \
	lib/Apache/httpd_conf.pm \
	$(INST_MAN3DIR)/Apache::httpd_conf.$(MAN3EXT) \
	mod_perl_traps.pod \
	$(INST_MAN3DIR)/mod_perl_traps.$(MAN3EXT) \
	lib/Apache/Options.pm \
	$(INST_MAN3DIR)/Apache::Options.$(MAN3EXT) \
	mod_perl_cvs.pod \
	$(INST_MAN3DIR)/mod_perl_cvs.$(MAN3EXT) \
	lib/Apache/Symdump.pm \
	$(INST_MAN3DIR)/Apache::Symdump.$(MAN3EXT) \
	lib/Apache/RegistryLoader.pm \
	$(INST_MAN3DIR)/Apache::RegistryLoader.$(MAN3EXT) \
	mod_perl_method_handlers.pod \
	$(INST_MAN3DIR)/mod_perl_method_handlers.$(MAN3EXT) \
	mod_perl_tuning.pod \
	$(INST_MAN3DIR)/mod_perl_tuning.$(MAN3EXT) \
	cgi_to_mod_perl.pod \
	$(INST_MAN3DIR)/cgi_to_mod_perl.$(MAN3EXT) \
	lib/Apache/StatINC.pm \
	$(INST_MAN3DIR)/Apache::StatINC.$(MAN3EXT) \
	lib/Apache/Registry.pm \
	$(INST_MAN3DIR)/Apache::Registry.$(MAN3EXT) \
	lib/Apache/SizeLimit.pm \
	$(INST_MAN3DIR)/Apache::SizeLimit.$(MAN3EXT) \
	lib/Bundle/Apache.pm \
	$(INST_MAN3DIR)/Bundle::Apache.$(MAN3EXT) \
	lib/Apache/RedirectLogFix.pm \
	$(INST_MAN3DIR)/Apache::RedirectLogFix.$(MAN3EXT) \
	lib/Apache/PerlSections.pm \
	$(INST_MAN3DIR)/Apache::PerlSections.$(MAN3EXT)

# --- MakeMaker processPL section:


# --- MakeMaker installbin section:


# --- MakeMaker subdirs section:

# The default clean, realclean and test targets in this Makefile
# have automatically been given entries for each subdir.



subdirs ::
	@cd Apache && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd Connection && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd Constants && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd File && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd Leak && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd Log && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd ModuleConfig && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd PerlRunXS && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd Server && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd Symbol && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd Table && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd URI && $(MAKE) all $(PASTHRU)



subdirs ::
	@cd Util && $(MAKE) all $(PASTHRU)



# --- MakeMaker clean section:

# Delete temporary files but do not touch installed files. We don't delete
# the Makefile here so a later make realclean still has a makefile to use.

clean ::
	-cd Apache && $(TEST_F) Makefile && $(MAKE) clean
	-cd Connection && $(TEST_F) Makefile && $(MAKE) clean
	-cd Constants && $(TEST_F) Makefile && $(MAKE) clean
	-cd File && $(TEST_F) Makefile && $(MAKE) clean
	-cd Leak && $(TEST_F) Makefile && $(MAKE) clean
	-cd Log && $(TEST_F) Makefile && $(MAKE) clean
	-cd ModuleConfig && $(TEST_F) Makefile && $(MAKE) clean
	-cd PerlRunXS && $(TEST_F) Makefile && $(MAKE) clean
	-cd Server && $(TEST_F) Makefile && $(MAKE) clean
	-cd Symbol && $(TEST_F) Makefile && $(MAKE) clean
	-cd Table && $(TEST_F) Makefile && $(MAKE) clean
	-cd URI && $(TEST_F) Makefile && $(MAKE) clean
	-cd Util && $(TEST_F) Makefile && $(MAKE) clean
	-rm -rf t/docs/.htaccess t/docs/hooks.txt src/Configuration lib/Apache/MyConfig.pm Apache/Apache.xs Constants/Constants.xs t/modules/ssi.t t/logs/error_log t/conf/srm.conf t/logs/httpd.pid src/modules/perl/mod_perl_version.h t/net/perl/cgi.pl t/report t/httpd apaci/find_source apaci/apxs_cflags apaci/mod_perl.config ./blib $(MAKE_APERL_FILE) $(INST_ARCHAUTODIR)/extralibs.all perlmain.c mon.out core so_locations pm_to_blib *~ */*~ */*/*~ *$(OBJ_EXT) *$(LIB_EXT) perl.exe $(BOOTSTRAP) $(BASEEXT).bso $(BASEEXT).def $(BASEEXT).exp
	-mv Makefile Makefile.old $(DEV_NULL)


# --- MakeMaker realclean section:

# Delete temporary files (via clean) and also delete installed files
realclean purge ::  clean
	-cd Apache && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd Apache && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd Connection && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd Connection && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd Constants && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd Constants && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd File && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd File && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd Leak && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd Leak && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd Log && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd Log && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd ModuleConfig && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd ModuleConfig && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd PerlRunXS && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd PerlRunXS && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd Server && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd Server && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd Symbol && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd Symbol && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd Table && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd Table && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd URI && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd URI && $(TEST_F) Makefile && $(MAKE)  realclean
	-cd Util && $(TEST_F) Makefile.old && $(MAKE) -f Makefile.old realclean
	-cd Util && $(TEST_F) Makefile && $(MAKE)  realclean
	rm -rf $(INST_AUTODIR) $(INST_ARCHAUTODIR)
	rm -f $(INST_ARCHLIB)/auto/Apache/include/include/multithread.h $(INST_ARCHLIB)/auto/Apache/include/include/buff.h $(INST_ARCHLIB)/auto/Apache/include/include/httpd.h $(INST_ARCHLIB)/auto/Apache/include/os/netware/os.h $(INST_LIBDIR)/mod_perl.pod $(INST_ARCHLIB)/auto/Apache/include/support/suexec.h $(INST_ARCHLIB)/auto/Apache/include/include/ap_config.h $(INST_ARCHLIB)/auto/Apache/include/regex/utils.h $(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/iasciitab.h $(INST_ARCHLIB)/auto/Apache/include/modules/perl/mod_perl.h $(INST_ARCHLIB)/auto/Apache/include/include/alloc.h $(INST_ARCHLIB)/auto/Apache/include/os/bs2000/os-inline.c $(INST_ARCHLIB)/auto/Apache/include/os/win32/service.h $(INST_ARCHLIB)/auto/Apache/include/os/tpf/ebcdic.h $(INST_ARCHLIB)/auto/Apache/include/include/ap.h $(INST_ARCHLIB)/auto/Apache/include/os/win32/getopt.h $(INST_ARCHLIB)/auto/Apache/include/os/unix/os.h $(INST_ARCHLIB)/auto/Apache/include/include/ap_md5.h $(INST_ARCHLIB)/auto/Apache/include/os/win32/registry.h $(INST_ARCHLIB)/auto/Apache/include/os/tpf/os.h $(INST_LIB)/Bundle/Apache.pm $(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/xmldef.h $(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/latin1tab.h $(INST_ARCHLIB)/auto/Apache/include/include/util_md5.h $(INST_ARCHLIB)/auto/Apache/include/include/rfc1413.h $(INST_LIB)/Apache/test.pm $(INST_ARCHLIB)/auto/Apache/include/include/conf.h $(INST_ARCHLIB)/auto/Apache/include/os/win32/resource.h $(INST_LIB)/mod_perl_hooks.pm $(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/xmlparse.h $(INST_LIB)/Apache/Debug.pm $(INST_LIB)/Apache/src.pm $(INST_LIB)/Apache/Resource.pm $(INST_ARCHLIB)/auto/Apache/include/include/util_uri.h $(INST_LIB)/Apache/httpd_conf.pm $(INST_ARCHLIB)/auto/Apache/include/modules/perl/mod_perl_version.h $(INST_ARCHLIB)/auto/Apache/include/include/explain.h $(INST_LIB)/mod_perl_hooks.pm.PL $(INST_ARCHLIB)/auto/Apache/typemap $(INST_LIB)/Apache/Symdump.pm $(INST_ARCHLIB)/auto/Apache/include/os/os390/os-inline.c $(INST_ARCHLIB)/auto/Apache/include/include/ap_compat.h $(INST_LIB)/Apache/RegistryLoader.pm $(INST_ARCHLIB)/auto/Apache/include/include/http_config.h $(INST_ARCHLIB)/auto/Apache/include/os/netware/getopt.h $(INST_ARCHLIB)/auto/Apache/include/os/mpeix/os-inline.c $(INST_LIBDIR)/mod_perl_tuning.pod $(INST_ARCHLIB)/auto/Apache/include/os/unix/os-inline.c $(INST_ARCHLIB)/auto/Apache/include/include/ap_sha1.h $(INST_LIB)/Apache/Registry.pm $(INST_ARCHLIB)/auto/Apache/include/os/bs2000/ebcdic.h $(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/xmltok.h $(INST_LIB)/Apache/SizeLimit.pm $(INST_LIB)/Apache/RedirectLogFix.pm $(INST_ARCHLIB)/auto/Apache/include/os/netware/test_char.h $(INST_LIB)/Apache/MyConfig.pm $(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/xmlrole.h $(INST_ARCHLIB)/auto/Apache/include/os/os2/os.h $(INST_ARCHLIB)/auto/Apache/include/include/compat.h $(INST_ARCHLIB)/auto/Apache/include/include/scoreboard.h $(INST_ARCHLIB)/auto/Apache/include/os/os390/ebcdic.h $(INST_ARCHLIB)/auto/Apache/include/modules/perl/perl_PL.h $(INST_LIB)/Apache/Constants/Exports.pm $(INST_ARCHLIB)/auto/Apache/include/os/bs2000/os.h $(INST_ARCHLIB)/auto/Apache/include/modules/proxy/mod_proxy.h $(INST_LIB)/Apache/SIG.pm $(INST_ARCHLIB)/auto/Apache/include/include/http_core.h $(INST_ARCHLIB)/auto/Apache/include/include/http_request.h $(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/hashtable.h $(INST_ARCHLIB)/auto/Apache/include/os/os390/os.h $(INST_ARCHLIB)/auto/Apache/include/os/win32/installer/installdll/test/test.h $(INST_ARCHLIB)/auto/Apache/include/os/netware/uri_delims.h $(INST_LIBDIR)/mod_perl_cvs.pod $(INST_ARCHLIB)/auto/Apache/include/include/http_protocol.h $(INST_LIBDIR)/mod_perl_method_handlers.pod $(INST_ARCHLIB)/auto/Apache/include/modules/standard/mod_rewrite.h $(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/nametab.h $(INST_ARCHLIB)/auto/Apache/include/os/netware/precomp.h $(INST_LIB)/Apache/StatINC.pm $(INST_ARCHLIB)/auto/Apache/include/include/util_date.h $(INST_LIB)/Apache/Opcode.pm $(INST_LIB)/Apache/PerlSections.pm $(INST_ARCHLIB)/auto/Apache/include/os/win32/os.h $(INST_ARCHLIB)/auto/Apache/include/regex/regex2.h $(INST_LIB)/Apache/FakeRequest.pm $(INST_ARCHLIB)/auto/Apache/include/include/http_main.h $(INST_LIB)/mod_perl.pm $(INST_LIB)/Apache/ExtUtils.pm $(INST_LIB)/Apache/Status.pm $(INST_LIB)/Apache/Include.pm $(INST_ARCHLIB)/auto/Apache/include/include/http_conf_globals.h $(INST_ARCHLIB)/auto/Apache/include/os/os2/os-inline.c $(INST_LIB)/Apache/PerlRun.pm $(INST_LIBDIR)/mod_perl_traps.pod $(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/xmltok_impl.h $(INST_ARCHLIB)/auto/Apache/include/regex/cclass.h $(INST_LIB)/Apache/Options.pm $(INST_ARCHLIB)/auto/Apache/include/os/win32/passwd.h $(INST_ARCHLIB)/auto/Apache/include/os/mpeix/os.h $(INST_ARCHLIB)/auto/Apache/include/modules/perl/apache_inc.h $(INST_LIB)/Apache/RegistryNG.pm $(INST_ARCHLIB)/auto/Apache/include/include/util_script.h $(INST_ARCHLIB)/auto/Apache/include/modules/perl/mod_perl_xs.h $(INST_ARCHLIB)/auto/Apache/include/include/http_vhost.h $(INST_ARCHLIB)/auto/Apache/include/include/ap_ctype.h $(INST_ARCHLIB)/auto/Apache/include/os/win32/installer/installdll/test/resource.h $(INST_ARCHLIB)/auto/Apache/include/include/hsregex.h $(INST_ARCHLIB)/auto/Apache/include/include/ap_mmn.h $(INST_LIBDIR)/cgi_to_mod_perl.pod $(INST_ARCHLIB)/auto/Apache/include/regex/cname.h $(INST_ARCHLIB)/auto/Apache/include/os/win32/readdir.h $(INST_ARCHLIB)/auto/Apache/mod_perl.exp $(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/utf8tab.h $(INST_ARCHLIB)/auto/Apache/include/ap_config_auto.h $(INST_ARCHLIB)/auto/Apache/include/lib/expat-lite/asciitab.h $(INST_ARCHLIB)/auto/Apache/include/os/tpf/os-inline.c $(INST_LIB)/Apache/RegistryBB.pm $(INST_ARCHLIB)/auto/Apache/include/include/fnmatch.h $(INST_ARCHLIB)/auto/Apache/include/include/http_log.h
	rm -rf Makefile Makefile.old


# --- MakeMaker dist_basics section:

distclean :: realclean distcheck

distcheck :
	$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) -MExtUtils::Manifest=fullcheck \
		-e fullcheck

skipcheck :
	$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) -MExtUtils::Manifest=skipcheck \
		-e skipcheck

manifest :
	$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) -MExtUtils::Manifest=mkmanifest \
		-e mkmanifest


# --- MakeMaker dist_core section:

dist : $(DIST_DEFAULT)
	@$(PERL) -le 'print "Warning: Makefile possibly out of date with $$vf" if ' \
	    -e '-e ($$vf="$(VERSION_FROM)") and -M $$vf < -M "Makefile";'

tardist : $(DISTVNAME).tar$(SUFFIX)

zipdist : $(DISTVNAME).zip

$(DISTVNAME).tar$(SUFFIX) : distdir
	$(PREOP)
	$(TO_UNIX)
	$(TAR) $(TARFLAGS) $(DISTVNAME).tar $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(COMPRESS) $(DISTVNAME).tar
	$(POSTOP)

$(DISTVNAME).zip : distdir
	$(PREOP)
	$(ZIP) $(ZIPFLAGS) $(DISTVNAME).zip $(DISTVNAME)
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)

uutardist : $(DISTVNAME).tar$(SUFFIX)
	uuencode $(DISTVNAME).tar$(SUFFIX) \
		$(DISTVNAME).tar$(SUFFIX) > \
		$(DISTVNAME).tar$(SUFFIX)_uu

shdist : distdir
	$(PREOP)
	$(SHAR) $(DISTVNAME) > $(DISTVNAME).shar
	$(RM_RF) $(DISTVNAME)
	$(POSTOP)


# --- MakeMaker dist_dir section:

distdir :
	$(RM_RF) $(DISTVNAME)
	$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) -MExtUtils::Manifest=manicopy,maniread \
		-e "manicopy(maniread(),'$(DISTVNAME)', '$(DIST_CP)');"


# --- MakeMaker dist_test section:

disttest : distdir
	cd $(DISTVNAME) && $(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) Makefile.PL
	cd $(DISTVNAME) && $(MAKE)
	cd $(DISTVNAME) && $(MAKE) test


# --- MakeMaker dist_ci section:

ci :
	$(PERL) -I$(PERL_ARCHLIB) -I$(PERL_LIB) -MExtUtils::Manifest=maniread \
		-e "@all = keys %{ maniread() };" \
		-e 'print("Executing $(CI) @all\n"); system("$(CI) @all");' \
		-e 'print("Executing $(RCS_LABEL) ...\n"); system("$(RCS_LABEL) @all");'


# --- MakeMaker install section:

install :: all pure_install doc_install

install_perl :: all pure_perl_install doc_perl_install

install_site :: all pure_site_install doc_site_install

install_ :: install_site
	@echo INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_install :: pure_$(INSTALLDIRS)_install

doc_install :: doc_$(INSTALLDIRS)_install
	@echo Appending installation info to $(INSTALLARCHLIB)/perllocal.pod

pure__install : pure_site_install
	@echo INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

doc__install : doc_site_install
	@echo INSTALLDIRS not defined, defaulting to INSTALLDIRS=site

pure_perl_install ::
	@$(MOD_INSTALL) \
		read $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist \
		write $(INSTALLARCHLIB)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(INSTALLPRIVLIB) \
		$(INST_ARCHLIB) $(INSTALLARCHLIB) \
		$(INST_BIN) $(INSTALLBIN) \
		$(INST_SCRIPT) $(INSTALLSCRIPT) \
		$(INST_MAN1DIR) $(INSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(INSTALLMAN3DIR)
	@$(WARN_IF_OLD_PACKLIST) \
		$(SITEARCHEXP)/auto/$(FULLEXT)


pure_site_install ::
	@$(MOD_INSTALL) \
		read $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist \
		write $(INSTALLSITEARCH)/auto/$(FULLEXT)/.packlist \
		$(INST_LIB) $(INSTALLSITELIB) \
		$(INST_ARCHLIB) $(INSTALLSITEARCH) \
		$(INST_BIN) $(INSTALLBIN) \
		$(INST_SCRIPT) $(INSTALLSCRIPT) \
		$(INST_MAN1DIR) $(INSTALLMAN1DIR) \
		$(INST_MAN3DIR) $(INSTALLMAN3DIR)
	@$(WARN_IF_OLD_PACKLIST) \
		$(PERL_ARCHLIB)/auto/$(FULLEXT)

doc_perl_install ::
	-@$(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLPRIVLIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(INSTALLARCHLIB)/perllocal.pod

doc_site_install ::
	-@$(DOC_INSTALL) \
		"Module" "$(NAME)" \
		"installed into" "$(INSTALLSITELIB)" \
		LINKTYPE "$(LINKTYPE)" \
		VERSION "$(VERSION)" \
		EXE_FILES "$(EXE_FILES)" \
		>> $(INSTALLARCHLIB)/perllocal.pod


uninstall :: uninstall_from_$(INSTALLDIRS)dirs

uninstall_from_perldirs ::
	@$(UNINSTALL) $(PERL_ARCHLIB)/auto/$(FULLEXT)/.packlist

uninstall_from_sitedirs ::
	@$(UNINSTALL) $(SITEARCHEXP)/auto/$(FULLEXT)/.packlist


# --- MakeMaker force section:
# Phony target to force checking subdirectories.
FORCE:
	@$(NOOP)


# --- MakeMaker perldepend section:


# --- MakeMaker makefile section:

# We take a very conservative approach here, but it\'s worth it.
# We move Makefile to Makefile.old here to avoid gnu make looping.
Makefile : Makefile.PL $(CONFIGDEP)
	@echo "Makefile out-of-date with respect to $?"
	@echo "Cleaning current config before rebuilding Makefile..."
	-@$(RM_F) Makefile.old
	-@$(MV) Makefile Makefile.old
	-$(MAKE) -f Makefile.old clean $(DEV_NULL) || $(NOOP)
	$(PERL) "-I$(PERL_ARCHLIB)" "-I$(PERL_LIB)" Makefile.PL 
	@echo "==> Your Makefile has been rebuilt. <=="
	@echo "==> Please rerun the make command.  <=="
	false

# To change behavior to :: would be nice, but would break Tk b9.02
# so you find such a warning below the dist target.
#Makefile :: $(VERSION_FROM)
#	@echo "Warning: Makefile possibly out of date with $(VERSION_FROM)"


# --- MakeMaker staticmake section:

# --- MakeMaker makeaperl section ---
MAP_TARGET    = perl
FULLPERL      = /usr/bin/perl

$(MAP_TARGET) :: static $(MAKE_APERL_FILE)
	$(MAKE) -f $(MAKE_APERL_FILE) $@

$(MAKE_APERL_FILE) : $(FIRST_MAKEFILE)
	@echo Writing \"$(MAKE_APERL_FILE)\" for this $(MAP_TARGET)
	@$(PERL) -I$(INST_ARCHLIB) -I$(INST_LIB) -I$(PERL_ARCHLIB) -I$(PERL_LIB) \
		Makefile.PL DIR=Apache:Connection:Constants:File:Leak:Log:ModuleConfig:PerlRunXS:Server:Symbol:Table:URI:Util \
		MAKEFILE=$(MAKE_APERL_FILE) LINKTYPE=static \
		MAKEAPERL=1 NORECURS=1 CCCDLFLAGS=


# --- MakeMaker test section:

test_pre_init:
	$(CP) t/conf/mod_perl_srm.conf t/conf/srm.conf

MP_TEST_SCRIPT=t/TEST

TEST_VERBOSE=0

kill_httpd:
	kill `cat t/logs/httpd.pid`
	@$(RM_F) t/conf/srm.conf
	@$(RM_F) t/logs/mod_perl.lock*
	$(RM_F) t/logs/httpd.pid
	$(RM_F) t/logs/error_log

start_httpd: test_pre_init
	@(cd t/conf; test -f httpd.conf || cp httpd.conf-dist httpd.conf)
	@(cd t/net; test -f config.pl || cp config.pl.dist config.pl)
	@$(TOUCH) t/conf/srm.conf
	$(APACHE_SRC)/$(HTTPD) -f `pwd`/t/conf/httpd.conf -X -d `pwd`/t &
	@echo httpd listening on port $(PORT)
	@echo will write error_log to: t/logs/error_log
	@echo "letting apache warm up...\c"
	@sleep 2
	@echo done

start_httpd_fork:
	$(APACHE_SRC)/$(HTTPD) -f `pwd`/t/conf/httpd.conf -d `pwd`/t

rehttpd:   kill_httpd start_httpd

run_tests:
	$(FULLPERL) $(MP_TEST_SCRIPT) $(TEST_VERBOSE)



test:	pure_all start_httpd run_tests kill_httpd



test_report:
	$(MAKE) test | t/report


# --- MakeMaker ppd section:
# Creates a PPD (Perl Package Description) for a binary distribution.
ppd:
	@$(PERL) -e "print qq{<SOFTPKG NAME=\"mod_perl\" VERSION=\"1,24,0,0\">\n}. qq{\t<TITLE>mod_perl</TITLE>\n}. qq{\t<ABSTRACT></ABSTRACT>\n}. qq{\t<AUTHOR></AUTHOR>\n}. qq{\t<IMPLEMENTATION>\n}. qq{\t\t<OS NAME=\"$(OSNAME)\" />\n}. qq{\t\t<ARCHITECTURE NAME=\"i386-linux\" />\n}. qq{\t\t<CODEBASE HREF=\"\" />\n}. qq{\t</IMPLEMENTATION>\n}. qq{</SOFTPKG>\n}" > mod_perl.ppd

# --- MakeMaker pm_to_blib section:

pm_to_blib: $(TO_INST_PM)
	@$(PERL) "-I$(INST_ARCHLIB)" "-I$(INST_LIB)" \
	"-I$(PERL_ARCHLIB)" "-I$(PERL_LIB)" -MExtUtils::Install \
        -e "pm_to_blib({qw{$(PM_TO_BLIB)}},'$(INST_LIB)/auto')"
	@$(TOUCH) $@


# --- MakeMaker selfdocument section:


# --- MakeMaker postamble section:
cvs_export :
	cvs -d $(CVSROOT) export -rv$(VERSION_SYM) -d$(DISTVNAME) .

cvs_tag :
	cvs -d $(CVSROOT) tag v$(VERSION_SYM) modperl
	@echo update mod_perl.pm VERSION now



# End.
