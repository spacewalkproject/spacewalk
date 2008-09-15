# $Id: configure.ac,v 1.1.1.1 2002-01-11 00:21:35 apingel Exp $
# Process this file with autoconf to produce a configure script.

PACKAGE=db
AC_INIT
AC_CONFIG_SRCDIR([../db/db.c])
AC_CONFIG_HEADER(db_config.h:config.hin)

# Configure setup.
AC_CANONICAL_HOST
AC_ARG_PROGRAM()

# We cannot build in the top-level directory.
AC_MSG_CHECKING(if building in the top-level directory)
[ test -d db_archive ] && AC_MSG_ERROR([
Berkeley DB cannot be built in the top-level distribution directory.])
AC_MSG_RESULT(no)

# Substitution variables.
AC_SUBST(ADDITIONAL_INCS)
AC_SUBST(ADDITIONAL_LANG)
AC_SUBST(ADDITIONAL_LIBS)
AC_SUBST(ADDITIONAL_OBJS)
AC_SUBST(ADDITIONAL_PROGS)
AC_SUBST(BUILD_TARGET)
AC_SUBST(CFLAGS)
AC_SUBST(CONFIGURATION_ARGS)
AC_SUBST(CONFIGURATION_PATH)
AC_SUBST(CPPFLAGS)
AC_SUBST(CXX)
AC_SUBST(CXXFLAGS)
AC_SUBST(DEFAULT_INSTALL)
AC_SUBST(DEFAULT_LIB)
AC_SUBST(DEFAULT_LIB_CXX)
AC_SUBST(EMBEDIX_ECD_CXX)
AC_SUBST(EMBEDIX_ECD_RPC)
AC_SUBST(EMBEDIX_ROOT)
AC_SUBST(INSTALLER)
AC_SUBST(INSTALL_LIBS)
AC_SUBST(INSTALL_TARGET)
AC_SUBST(JAR)
AC_SUBST(JAVAC)
AC_SUBST(JAVACFLAGS)
AC_SUBST(LDFLAGS)
AC_SUBST(LIBJSO_LIBS)
AC_SUBST(LIBS)
AC_SUBST(LIBSO_LIBS)
AC_SUBST(LIBTOOL)
AC_SUBST(LIBTSO_LIBS)
AC_SUBST(LIBXSO_LIBS)
AC_SUBST(MAKEFILE_CC)
AC_SUBST(MAKEFILE_CCLINK)
AC_SUBST(MAKEFILE_CXX)
AC_SUBST(MAKEFILE_CXXLINK)
AC_SUBST(POSTLINK)
AC_SUBST(RPC_CLIENT_OBJS)
AC_SUBST(RPM_POST_INSTALL)
AC_SUBST(RPM_POST_UNINSTALL)
AC_SUBST(SOFLAGS)
AC_SUBST(SOLINK)
AC_SUBST(SOSUFFIX)
AC_SUBST(TEST_LIBS)
AC_SUBST(db_cv_path_embedix_install)
AC_SUBST(db_cv_path_rpm_archive)
AC_SUBST(o)

# RPM needs the current absolute path.
# RPM needs the list of original arguments, but we don't include the RPM
# option itself.
CONFIGURATION_PATH=${PWD-`pwd`}
CONFIGURATION_ARGS=`echo "$*" |
    sed -e 's/--with-embedix[[^ ]]*//' -e 's/--with-rpm[[^ ]]*//'`

# Set the version.
AM_VERSION_SET

# Set the default installation location.
AC_PREFIX_DEFAULT(/usr/local/BerkeleyDB.@DB_VERSION_MAJOR@.@DB_VERSION_MINOR@)

# Process all options before using them.
AM_OPTIONS_SET

# Set some #defines based on configuration options.
if test "$db_cv_diagnostic" = yes; then
	AC_DEFINE(DIAGNOSTIC)
	AH_TEMPLATE(DIAGNOSTIC, [
	    Define if you want a version with run-time diagnostic checking.])
fi
if test "$db_cv_debug_rop" = yes; then
	AC_DEFINE(DEBUG_ROP)
	AH_TEMPLATE(DEBUG_ROP, [
	    Define if you want a version that logs read operations.])
fi
if test "$db_cv_debug_wop" = yes; then
	AC_DEFINE(DEBUG_WOP)
	AH_TEMPLATE(DEBUG_WOP, [
	    Define if you want a version that logs write operations.])
fi
if test "$db_cv_umrw" = yes; then
	AC_DEFINE(UMRW)
	AH_TEMPLATE(UMRW, [
	    Define to mask harmless unitialized memory read/writes.])

fi
if test "$db_cv_test" = yes; then
	AC_DEFINE(CONFIG_TEST)
	AH_TEMPLATE(CONFIG_TEST, [
	    Define if you are building a version for running the test suite.])
fi

# Check for programs used in building and installation.
AM_PROGRAMS_SET
AC_PROG_INSTALL

# RPM/Embedix support: change the standard make and install targets
if test "$db_cv_rpm" = "yes"; then
	BUILD_TARGET="rpm_build"
	echo "topdir: $CONFIGURATION_PATH" > rpmrc
	if test "$db_cv_embedix" = "yes"; then
		EMBEDIX_ROOT="/usr"
		INSTALL_TARGET="embedix_install"
	else
		INSTALL_TARGET="rpm_install"
	fi
else
	BUILD_TARGET="library_build"
	INSTALL_TARGET="library_install"
fi

# This is where we handle stuff that autoconf can't handle: compiler,
# preprocessor and load flags, libraries that the standard tests don't
# look for.  The default optimization is -O.  We would like to set the
# default optimization for systems using gcc to -O2, but we can't.  By
# the time we know we're using gcc, it's too late to set optimization
# flags.
#
# There are additional libraries we need for some compiler/architecture
# combinations.
#
# Some architectures require DB to be compiled with special flags and/or
# libraries for threaded applications
#
# The makefile CC may be different than the CC used in config testing,
# because the makefile CC may be set to use $(LIBTOOL).
#
# XXX
# Don't override anything if it's already set from the environment.
optimize_def="-O"
case "$host_os" in
aix4.*)	   optimize_def="-O2"
	   CC=${CC-"xlc_r"}
	   CPPFLAGS="-D_THREAD_SAFE $CPPFLAGS"
	   LIBTSO_LIBS="\$(LIBS)";;
bsdi3*)	   CC=${CC-"shlicc2"}
	   optimize_def="-O2"
	   LIBS="-lipc $LIBS";;
bsdi*)	   optimize_def="-O2";;
freebsd*)  optimize_def="-O2"
	   CPPFLAGS="-D_THREAD_SAFE $CPPFLAGS"
           LIBS="-pthread";;
hpux*)	   CPPFLAGS="-D_REENTRANT $CPPFLAGS";;
irix*)	   optimize_def="-O2"
	   CPPFLAGS="-D_SGI_MP_SOURCE $CPPFLAGS";;
linux*)	   optimize_def="-O2"
	   CPPFLAGS="-D_GNU_SOURCE -D_REENTRANT $CPPFLAGS";;
mpeix*)	   CPPFLAGS="-D_POSIX_SOURCE -D_SOCKET_SOURCE $CPPFLAGS"
	   LIBS="-lsocket -lsvipc $LIBS";;
osf*)	   CPPFLAGS="-D_REENTRANT $CPPFLAGS";;
*qnx)	   AC_DEFINE(HAVE_QNX)
	   AH_TEMPLATE(HAVE_QNX, [Define if building on QNX.]);;
sco3.2v4*) CC=${CC-"cc -belf"}
	   LIBS="-lsocket -lnsl_s $LIBS";;
sco*)	   CC=${CC-"cc -belf"}
	   LIBS="-lsocket -lnsl $LIBS";;
solaris*)  CPPFLAGS="-D_REENTRANT $CPPFLAGS";;
esac

# Set CFLAGS/CXXFLAGS.  We MUST set the flags before we call autoconf
# compiler configuration macros, because if we don't, they set CFLAGS
# to no optimization and -g, which isn't what we want.
CFLAGS=${CFLAGS-$optimize_def}
CXXFLAGS=${CXXFLAGS-"$CFLAGS"}

# If the user wants a debugging environment, add -g to the CFLAGS value.
#
# XXX
# Some compilers can't mix optimizing and debug flags.  The only way to
# handle this is to specify CFLAGS in the environment before configuring.
if test "$db_cv_debug" = yes; then
	AC_DEFINE(DEBUG)
	AH_TEMPLATE(DEBUG, [Define if you want a debugging version.])

	CFLAGS="$CFLAGS -g"
	CXXFLAGS="$CXXFLAGS -g"
fi

# The default compiler is cc (NOT gcc), the default CFLAGS is as specified
# above, NOT what is set by AC_PROG_CC, as it won't set optimization flags.
# We still call AC_PROG_CC so that we get the other side-effects.
AC_CHECK_TOOL(CC, cc)
AC_CHECK_TOOL(CC, gcc)
AC_PROG_CC

# Because of shared library building, the ${CC} used for config tests
# may be different than the ${CC} we want to put in the Makefile.
# The latter is known as ${MAKEFILE_CC} in this script.
MAKEFILE_CC=${CC}
MAKEFILE_CCLINK="\$(CC)"
MAKEFILE_CXX="nocxx"
MAKEFILE_CXXLINK="nocxx"

# See if we need the C++ compiler at all.  If so, we'd like to find one that
# interoperates with the C compiler we chose.  Since we prefered cc over gcc,
# we'll also prefer the vendor's compiler over g++/gcc.  If we're wrong, the
# user can set CC and CXX in their environment before running configure.
#
# AC_PROG_CXX sets CXX, but it uses $CXX and $CCC (in that order) as its
# first choices.
if test "$db_cv_cxx" = "yes"; then
	if test "$GCC" != "yes"; then
		case "$host_os" in
		aix*)		AC_CHECK_TOOL(CCC, xlC_r);;
		hpux*)		AC_CHECK_TOOL(CCC, aCC);;
		osf*)		AC_CHECK_TOOL(CCC, cxx);;
		solaris*)	AC_CHECK_TOOL(CCC, CC);;
		esac
	fi
	AC_PROG_CXX
	MAKEFILE_CXX=${CXX}
	MAKEFILE_CXXLINK="\$(CXX)"
fi

# Do some gcc specific configuration.
AC_GCC_CONFIG1
AC_GCC_CONFIG2

# Export our compiler preferences for the libtool configuration.
export CC CCC
CCC=CXX

# Libtool configuration.
AC_PROG_LIBTOOL

LIBTOOL="\$(SHELL) ./libtool"
SOSUFFIX=`sed -e '/^library_names_spec=/!d' -e 's/.*\.\([[a-zA-Z0-9_]]*\).*/\1/' ./libtool`
SOFLAGS="-rpath \$(libdir)"

SAVE_CC="${MAKEFILE_CC}"
SAVE_CXX="${MAKEFILE_CXX}"
MAKEFILE_CC="\$(LIBTOOL) --mode=compile ${SAVE_CC}"
MAKEFILE_CXX="\$(LIBTOOL) --mode=compile ${SAVE_CXX}"
MAKEFILE_CCLINK="\$(LIBTOOL) --mode=link ${SAVE_CC}"
MAKEFILE_CXXLINK="\$(LIBTOOL) --mode=link ${SAVE_CXX}"

SOLINK="\$(LIBTOOL) --mode=link ${SAVE_CC} -avoid-version"
INSTALLER="\$(LIBTOOL) --mode=install cp"

# Configure for shared libraries, static libraries, or both.  If both are
# configured, build the utilities and example programs with shared versions.
#
# $o is set to ".o" or ".lo", and is the file suffix used in the Makefile
# instead of .o
if test "$enable_shared" = "no"; then
	DEFAULT_LIB="\$(libdb)"
	DEFAULT_LIB_CXX="\$(libcxx)"
	DEFAULT_INSTALL="install_static"
	POSTLINK="@true"
	o=".o"
fi
if test "$enable_shared" = "yes"; then
	DEFAULT_LIB="\$(libso_target)"
	DEFAULT_LIB_CXX="\$(libxso_target)"
	DEFAULT_INSTALL="${DEFAULT_INSTALL} install_shared"
	POSTLINK="\$(LIBTOOL) --mode=execute true"
	o=".lo"
fi

# Optional C++ API.
if test "$db_cv_cxx" = "yes"; then
	if test "$enable_shared" = "no"; then
		DEFAULT_INSTALL="${DEFAULT_INSTALL} install_static_cxx"
	fi
	if test "$enable_shared" = "yes"; then
		ADDITIONAL_LIBS="$ADDITIONAL_LIBS \$(libxso_target)"
		DEFAULT_INSTALL="${DEFAULT_INSTALL} install_shared_cxx"
	fi

	# Fill in C++ library for Embedix.
	EMBEDIX_ECD_CXX='<OPTION db-extra>\
	TYPE=bool\
	DEFAULT_VALUE=1\
	PROMPT=Include BerkeleyDB C++ library?\
	<KEEPLIST>\
		/usr/include/db_cxx.h\
		/usr/lib/libdb_cxx-@DB_VERSION_MAJOR@.@DB_VERSION_MINOR@.so\
	</KEEPLIST>\
	<PROVIDES>\
		libdb_cxx-@DB_VERSION_MAJOR@.@DB_VERSION_MINOR@.so\
	</PROVIDES>\
	<REQUIRES>\
		ld-linux.so.2\
		libc.so.6\
	</REQUIRES>\
	STATIC_SIZE=0\
	STORAGE_SIZE=523612\
	STARTUP_TIME=0\
	</OPTION>'
fi

# Optional Java API.
if test "$db_cv_java" = "yes"; then
	# Java requires shared libraries.
	if test "$enable_shared" = "no"; then
		AC_MSG_ERROR([Java requires shared libraries])
	fi

	AC_CHECK_TOOL(JAVAC, javac, nojavac)
	if test "$JAVAC" = "nojavac"; then
		AC_MSG_ERROR([no javac compiler in PATH])
	fi
	AC_CHECK_TOOL(JAR, jar, nojar)
	if test "$JAR" = "nojar"; then
		AC_MSG_ERROR([no jar utility in PATH])
	fi
	AC_PATH_PROG(JAVACABS, javac, nojavac)
	ADDITIONAL_LIBS="$ADDITIONAL_LIBS \$(libjso_target)"
	ADDITIONAL_LANG="$ADDITIONAL_LANG java"
	DEFAULT_INSTALL="${DEFAULT_INSTALL} install_java"

# find the include directory relative to the javac executable
	while ls -ld "$JAVACABS" 2>/dev/null | grep " -> " >/dev/null; do
		AC_MSG_CHECKING(symlink for $JAVACABS)
		JAVACLINK=`ls -ld $JAVACABS | sed 's/.* -> //'`
		case "$JAVACLINK" in
		/*) JAVACABS="$JAVACLINK";;
# 'X' avoids triggering unwanted echo options.
		*) JAVACABS=`echo "X$JAVACABS" | sed -e 's/^X//' -e 's:[[^/]]*$::'`"$JAVACLINK";;
		esac
		AC_MSG_RESULT($JAVACABS)
	done
	JTOPDIR=`echo "$JAVACABS" | sed -e 's://*:/:g' -e 's:/[[^/]]*$::'`
	case "$host_os" in
		darwin*)	JTOPDIR=`echo "$JTOPDIR" | sed -e s:/[[^/]]*$::'`
				JNIHEADERDIR="$JTOPDIR/Headers";;
		*)		JNIHEADERDIR="$JTOPDIR/include";;
	esac
	if test -f "$JNIHEADERDIR/jni.h"; then
		CPPFLAGS="$CPPFLAGSS -I$JNIHEADERDIR"
	else
		JTOPDIR=`echo "$JTOPDIR" | sed -e 's:/[[^/]]*$::'`
		if test -f "$JTOPDIR/include/jni.h"; then
			CPPFLAGS="$CPPFLAGS -I$JTOPDIR/include"
		else
			AC_MSG_ERROR([cannot find java include files])
		fi
	fi

# get the likely subdirectories for system specific java includes
	case "$host_os" in
	solaris*)	JINCSUBDIRS="solaris";;
	linux*)		JINCSUBDIRS="linux genunix";;
	*)		JINCSUBDIRS="genunix";;
	esac

	for JINCSUBDIR in $JINCSUBDIRS
	do
		if test -d "$JTOPDIR/include/$JINCSUBDIR"; then
			CPPFLAGS="$CPPFLAGS -I$JTOPDIR/include/$JINCSUBDIR"
		fi
	done
else
	JAVAC=nojavac
fi

# Optional RPC client/server.
if test "$db_cv_rpc" = "yes"; then
	AC_DEFINE(HAVE_RPC)
	AH_TEMPLATE(HAVE_RPC, [Define if building RPC client/server.])

	RPC_CLIENT_OBJS="\$(RPC_CLIENT_OBJS)"
	ADDITIONAL_PROGS="berkeley_db_svc $ADDITIONAL_PROGS"

	EMBEDIX_ECD_RPC="/usr/bin/berkeley_db_svc"

	case "$host_os" in
	hpux*)
		AC_CHECK_FUNC(svc_run,,
		    AC_CHECK_LIB(nsl, svc_run,
		    LIBS="-lnsl $LIBS"; LIBTSO_LIBS="-lnsl $LIBTSO_LIBS"));;
	solaris*)
		AC_CHECK_FUNC(svc_run,, AC_CHECK_LIB(nsl, svc_run));;
	esac
fi

AM_TCL_LOAD

# Optional DB 1.85 compatibility API.
if test "$db_cv_compat185" = "yes"; then
	ADDITIONAL_INCS="db_185.h $ADDITIONAL_INCS"
	ADDITIONAL_OBJS="db185${o} $ADDITIONAL_OBJS"
fi

# Optional utilities.
if test "$db_cv_dump185" = "yes"; then
	ADDITIONAL_PROGS="db_dump185 $ADDITIONAL_PROGS"
fi

# test servers, example programs.
# Include -lpthread if the library exists.
AC_CHECK_LIB(rt, sched_yield, TEST_LIBS="-lrt $TEST_LIBS")
AC_CHECK_LIB(pthread, pthread_create, TEST_LIBS="-lpthread $TEST_LIBS")

# Checks for system/compiler characteristics.
AC_C_BIGENDIAN
AC_C_CONST

# Checks for include files, structures.
AC_HEADER_STAT
AC_HEADER_TIME
AC_HEADER_DIRENT
AC_CHECK_HEADERS(sys/select.h)
AC_CHECK_HEADERS(sys/time.h)
AC_CHECK_MEMBERS([struct stat.st_blksize])

# Check for C types.
AM_TYPES

# Check for ANSI C exit success/failure values.
AC_EGREP_CPP(yes, [
    #include <stdlib.h>
    #ifdef EXIT_SUCCESS
    yes
    #endif], [
    AC_DEFINE(HAVE_EXIT_SUCCESS)
    AH_TEMPLATE(HAVE_EXIT_SUCCESS, [
        Define if you have EXIT_SUCCESS/EXIT_FAILURE #defines.])])

# Check for mutexes.  We do this here because it changes $LIBS.
AM_DEFINE_MUTEXES

# Checks for system functions for which we have replacements.
#
# XXX
# The only portable getcwd call is getcwd(char *, size_t), where the
# buffer is non-NULL -- Solaris can't handle a NULL buffer, and they
# deleted getwd().
AC_REPLACE_FUNCS(getcwd getopt memcmp memcpy memmove)
AC_REPLACE_FUNCS(raise snprintf strcasecmp strerror vsnprintf)

# XXX
# Nasty hack.  AC_REPLACE_FUNCS added entries of the form xxx.o to the
# LIBOBJS variable.  They have to be xxx.lo if we are building shared
# libraries.  Use sed, configure already requires it.
tmp="`echo \"$LIBOBJS\" | sed \"s/\.o/${o}/g\"`"
LIBOBJS="$tmp"

# Check for system functions we optionally use.
AC_CHECK_FUNCS(_fstati64 getuid pstat_getdynamic sched_yield select strtoul)
AC_CHECK_FUNCS(sysconf yield)

# Pread/pwrite.
#
# HP-UX has pread/pwrite, but it doesn't work with bigfile support.
case "$host_os" in
hpux*)
	AC_MSG_WARN([pread/pwrite interfaces ignored on $host_os.]);;
*)	AC_CHECK_FUNCS(pread pwrite)
esac

# Check for fcntl(2) to deny child process access to file descriptors.
AC_CACHE_CHECK([for fcntl/F_SETFD], db_cv_fcntl_f_setfd, [
AC_TRY_RUN([
#include <sys/types.h>
#include <fcntl.h>
main(){exit(fcntl(1, F_SETFD, 1) == -1);}],
	[db_cv_fcntl_f_setfd=yes], [db_cv_fcntl_f_setfd=no])])
if test "$db_cv_fcntl_f_setfd" = yes; then
	AC_DEFINE(HAVE_FCNTL_F_SETFD)
	AH_TEMPLATE(HAVE_FCNTL_F_SETFD, [
	    Define if fcntl/F_SETFD denies child access to file descriptors.])
fi

# A/UX has a broken getopt(3).
case "$host_os" in
aux*)	ADDITIONAL_OBJS="getopt${o} $ADDITIONAL_OBJS";;
esac

# Checks for system functions for which we don't have replacements.
# We require qsort(3).
AC_CHECK_FUNCS(qsort, , AC_MSG_ERROR([No qsort library function.]))

# Some versions of sprintf return a pointer to the first argument instead
# of a character count.  We assume that the return value of snprintf and
# vsprintf etc. will be the same as sprintf, and check the easy one.
AC_CACHE_CHECK([for int type sprintf return value], db_cv_sprintf_count, [
AC_TRY_RUN([main(){char buf[20]; exit(sprintf(buf, "XXX") != 3);}],
	[db_cv_sprintf_count=yes], [db_cv_sprintf_count=no])])
if test "$db_cv_sprintf_count" = no; then
	AC_DEFINE(SPRINTF_RET_CHARPNT)
	AH_TEMPLATE(SPRINTF_RET_CHARPNT,
	    [Define if your sprintf returns a pointer, not a length.])
fi

# You can't build C++ with big-file support on HP-UX, the include files
# are wrong.  On Solaris 8, the <fcntl.h> included with big-file support
# is not compatible with C++.
largefile_ok=yes
case "$host_os" in
solaris2.8|hpux*)
	if test "$db_cv_cxx" = "yes"; then
AC_MSG_WARN([Large file and C++ API support are incompatible on HP-UX])
AC_MSG_WARN([and Solaris 8; large file support has been turned off.])
		largefile_ok=no
	fi;;
esac
if test "$largefile_ok" = yes; then
	AC_SYS_LARGEFILE
fi

# Figure out how to create shared regions.
#
# First, we look for mmap.
#
# BSD/OS has mlock(2), but it doesn't work until the 4.1 release.
#
# Nextstep (version 3.3) apparently supports mmap(2) (the mmap symbol
# is defined in the C library) but does not support munmap(2).  Don't
# try to use mmap if we can't find munmap.
#
# Ultrix has mmap(2), but it doesn't work.
mmap_ok=no
case "$host_os" in
bsdi3*|bsdi4.0)
	AC_MSG_WARN([mlock(2) interface ignored on BSD/OS 3.X and 4.0.])
	mmap_ok=yes
	AC_CHECK_FUNCS(mmap munmap, , mmap_ok=no);;
ultrix*)
	AC_MSG_WARN([mmap(2) interface ignored on Ultrix.]);;
*)
	mmap_ok=yes
	AC_CHECK_FUNCS(mlock munlock)
	AC_CHECK_FUNCS(mmap munmap, , mmap_ok=no);;
esac

# Second, we look for shmget.
#
# SunOS has the shmget(2) interfaces, but there appears to be a missing
# #include <debug/debug.h> file, so we ignore them.
shmget_ok=no
case "$host_os" in
sunos*)
	AC_MSG_WARN([shmget(2) interface ignored on SunOS.]);;
*)
	shmget_ok=yes
	AC_CHECK_FUNCS(shmget, , shmget_ok=no);;
esac

# We require either mmap/munmap(2) or shmget(2).
if test "$mmap_ok" = no -a "$shmget_ok" = no; then
	AC_MSG_WARN([Neither mmap/munmap(2) or shmget(2) library functions.])
fi

# Initial output file list.
CREATE_LIST="Makefile
    include.tcl:$srcdir/../test/include.tcl
    db_int.h:$srcdir/../include/db_int.in"

# Create the db.h file -- append the global function prototypes to the
# file.  If the user has requested unique names, use the file that does
# DB_VERSION_UNIQUE_NAME substitution.
if test "$db_cv_uniquename" = "yes"; then
    CREATE_LIST="${CREATE_LIST}
    db.h:$srcdir/../include/db.in:$srcdir/../include_auto/rpc_defs.in:$srcdir/../include_auto/global_uext.in"
else
    CREATE_LIST="${CREATE_LIST}
    db.h:$srcdir/../include/db.in:$srcdir/../include_auto/rpc_defs.in:$srcdir/../include_auto/global_ext.in"
fi

# Create the function prototype include files.  If the user has requested
# unique names, use the files that do DB_VERSION_UNIQUE_NAME substitution.
if test "$db_cv_uniquename" = "yes"; then
    CREATE_LIST="${CREATE_LIST}
    db_ext.h:$srcdir/../include_auto/db_ext.in
    btree_ext.h:$srcdir/../include_auto/btree_ext.in
    clib_ext.h:$srcdir/../include_auto/clib_ext.in
    common_ext.h:$srcdir/../include_auto/common_ext.in
    db_server.h:$srcdir/../include_auto/db_server.in
    env_ext.h:$srcdir/../include_auto/env_ext.in
    hash_ext.h:$srcdir/../include_auto/hash_ext.in
    lock_ext.h:$srcdir/../include_auto/lock_ext.in
    log_ext.h:$srcdir/../include_auto/log_ext.in
    mp_ext.h:$srcdir/../include_auto/mp_ext.in
    mutex_ext.h:$srcdir/../include_auto/mutex_ext.in
    os_ext.h:$srcdir/../include_auto/os_ext.in
    qam_ext.h:$srcdir/../include_auto/qam_ext.in
    rpc_client_ext.h:$srcdir/../include_auto/rpc_client_ext.in
    rpc_server_ext.h:$srcdir/../include_auto/rpc_server_ext.in
    tcl_ext.h:$srcdir/../include_auto/tcl_ext.in
    txn_ext.h:$srcdir/../include_auto/txn_ext.in
    xa_ext.h:$srcdir/../include_auto/xa_ext.in"
fi
if test "$db_cv_compat185" = "yes"; then
	if test "$db_cv_uniquename" = "yes"; then
		CREATE_LIST="${CREATE_LIST}
db_185.h:$srcdir/../include/db_185.in:$srcdir/../include_auto/db185_uext.in
db185_int.h:$srcdir/../db185/db185_int.in:$srcdir/../include_auto/db185_uext.in"
	else
		CREATE_LIST="${CREATE_LIST}
db_185.h:$srcdir/../include/db_185.in:$srcdir/../include_auto/db185_ext.in
db185_int.h:$srcdir/../db185/db185_int.in:$srcdir/../include_auto/db185_ext.in"
	fi
fi
if test "$db_cv_embedix" = "yes"; then
	CREATE_LIST="${CREATE_LIST} db.ecd:../dist/db.ecd.in"
fi
if test "$db_cv_rpm" = "yes"; then
	CREATE_LIST="${CREATE_LIST} db.spec:../dist/db.spec.in"
fi

AC_CONFIG_FILES(${CREATE_LIST})
AC_OUTPUT
