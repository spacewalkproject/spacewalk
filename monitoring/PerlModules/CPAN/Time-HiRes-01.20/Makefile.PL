
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
#

require 5.002;

use Config;
use ExtUtils::MakeMaker;

# comment the following if xsubpp complains about bad usage.
$XSOPT = '-nolinenumbers'; 

# if you have 5.004_03 (and some slightly older versions?), xsubpp
# tries to generate line numbers in the C code generated from the .xs.
# unfortunately, it is a little buggy around #ifdef'd code.
# my choice is leave it in and have people with old perls complain 
# about the "Usage" bug, or leave it out and be unable to compile myself
# without changing it, and then I'd always forget to change it before a 
# release. Sorry, Edward :)

sub TMPDIR {
    my $TMPDIR =
	(grep(defined $_ && -d $_ && -w _,
	      ((defined $ENV{'TMPDIR'} ? $ENV{'TMPDIR'} : undef),
	       qw(/var/tmp /usr/tmp /tmp))))[0]
		   unless defined $TMPDIR;
    $TMPDIR || die "Cannot find writable temporary directory.\n";
}

sub try_compile_and_link {
    my ($c, $cccmd) = @_;

    my ($ok) = 0;
    my ($tmp) = ($^O eq 'VMS') ? "tmp$$" : TMPDIR . '/' . "tmp$$";
    local(*TMPC);

    my $obj_ext = $Config{obj_ext} || ".o";
    unlink("$tmp.c", "$tmp$obj_ext");

    if (open(TMPC, ">$tmp.c")) {
	print TMPC $c;
	close(TMPC);
	my $COREincdir = $Config{'archlibexp'} . '/' . 'CORE';
	my $ccflags = $Config{'ccflags'} . ' ' . "-I$COREincdir";
	if ($^O eq 'VMS') {
            my $perl_core = $Config{'installarchlib'};
            $perl_core =~ s/\]$/.CORE]/;
            $cccmd = "$Config{'cc'} /include=(perl_root:[000000],$perl_core) $tmp.c"; 
        }
	$cccmd = "$Config{'cc'} -o $tmp $ccflags $tmp.c @$LIBS"
	 unless (defined $cccmd);
	system($cccmd);
	if ($^O eq 'VMS') {
	    $ok = -s "$tmp$obj_ext" && -x _;
	    unlink("$tmp.c", "$tmp$obj_ext");
        }
        else
        {
	    $ok = -s $tmp && -x _;
	    unlink("$tmp.c", $tmp);
        }
    }
    
    $ok;
}

sub has_gettimeofday {
    # confusing but true (if condition true ==> -DHAS_GETTIMEOFDAY already)
    return 0 if $Config{'d_gettimeod'} eq 'define';
    return 1 if try_compile_and_link(<<EOM); 
#include "EXTERN.h" 
#include "perl.h" 
#include "XSUB.h" 
#ifdef I_SYS_TYPES 
#   include <sys/types.h>
#endif

#ifdef I_SYS_TIME
#   include <sys/time.h>
#endif

#ifdef I_SYS_SELECT
#   include <sys/select.h>	/* struct timeval might be hidden in here */
#endif
static int foo()
{
    struct timeval tv;
    gettimeofday(&tv, 0);
}
int main _((int argc, char** argv, char** env))
{
    foo();
}
EOM
    return 0;
}

sub has_x {
    my ($x) = @_; 

    return 1 if
    try_compile_and_link(<<EOM);
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#ifdef I_UNISTD
#   include <unistd.h>
#endif

#ifdef I_SYS_TYPES
#   include <sys/types.h>
#endif

#ifdef I_SYS_TIME
#   include <sys/time.h>
#endif

int main _((int argc, char** argv, char** env))
{
	$x;
}
EOM
    return 0;
}

sub unixinit {
    $DEFINE = '';

    $LIBS = [''];

    # this might break the link, try it if it can't find some things you 
    # honestly think should be in there...
    # $LIBS = ['-lucb -lbsd'];

    # ... but ucb is poison for Solaris, and probably Linux. honest.
    $LIBS = [''] if $Config{'osname'} eq 'solaris';
    $LIBS = [''] if $Config{'osname'} eq 'linux';
    $LIBS = ['-lm'] if $Config{'osname'} =~ /sco/i;

    if ($Config{'d_gettimeod'} eq 'define') {
	# do nothing special, everything should be fine
    } elsif (has_gettimeofday) {
	$DEFINE .= ' -DHAS_GETTIMEOFDAY';
    } else {
	die <<EOD
Your operating system does not seem to have the gettimeofday() function.
(or, at least, I cannot find it)

There is no way Time::HiRes is going to work.

I am awfully sorry but I cannot go further.

Aborting configuration

EOD
    }

    print "Looking for usleep()...\n";
    if (has_x ("usleep (0)")) {
	$DEFINE .= ' -DHAS_USLEEP';
	print "You have usleep()\n\n";
    } else {
	print "Whoops! No usleep()! Let's see if you have select().\n";
        if ($Config{'d_select'} eq 'define') {
	    print "You have select(); we can make a Time::HiRes::usleep()\n\n";
	} else {
	    print "No select(); you won't have a Time::HiRes::usleep()\n\n";
	}
    }

    print "Looking for ualarm()...\n";
    if (has_x ("ualarm (0, 0)")) {
	$DEFINE .= ' -DHAS_UALARM';
	print "You have ualarm()\n\n";
    } else {
	print "Whoops! No ualarm()!\n";
	if (has_x("setitimer(ITIMER_REAL, 0, 0)")) {
	    print "You have setitimer(); we can make a Time::HiRes::ualarm()\n\n";
	    $DEFINE .= ' -DHAS_SETITIMER';
	} else {
	     print "We'll manage.\n\n";
	}
    }
    $DEFINE =~ s/^\s+//;
}

sub doMakefile {
    print <<EOM if ($$LIBS[0] ne '');
Looking for libraries...
Note: it is ok if none of the libraries '@$LIBS' is found.

EOM

    @makefileopts = ();

    if ($] >= 5.005) {
	push (@makefileopts,
	    'AUTHOR'    => 'Doug Wegscheid (wegscd@whirlpool.com)',
	    'ABSTRACT_FROM' => 'HiRes.pm',
	);
	$DEFINE .= " -DATLEASTFIVEOHOHFIVE";
    }

    push (@makefileopts,
	'NAME'	=> 'Time::HiRes',
	'VERSION_FROM' => 'HiRes.pm', # finds $VERSION
	'LIBS'	=> $LIBS,   # e.g., '-lm' 
	'DEFINE'	=> $DEFINE,     # e.g., '-DHAS_SOMETHING' 
	'XSOPT'	=> $XSOPT,
    # do not even think about 'INC' => '-I/usr/ucbinclude', Solaris will avenge.
	'INC'	=> '',     # e.g., '-I/usr/include/other' 
	'dist'      => {
	    'CI'=>'ci -l',
	    'COMPRESS'=>'gzip -9f', 
	    'SUFFIX' => 'gz',
	},
    );

    WriteMakefile(@makefileopts);
}

sub main {
    print <<EOM;

Configuring...

EOM

    if ($^O =~ /Win32/i) {
      $DEFINE = '-DSELECT_IS_BROKEN';
      $LIBS = [''];
    } else {
      unixinit();
    }
    configure;
    doMakefile;
    my $make = $Config{'make'} || "make";
print  <<EOM;

Done configuring

Now you may issue '$make'. Do not forget also '$make test'.

EOM
}

&main;

# EOF
