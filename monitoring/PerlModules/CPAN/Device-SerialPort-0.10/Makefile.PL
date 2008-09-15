package SerialJunk;
use ExtUtils::MakeMaker;
use POSIX qw(uname);

$|=1;

# Test for our ioctl methods right off the bat... (from SerialPort.pm)
print "Finding ioctl methods ...\n";

# Needed on some misbehaving Solaris machines... (h2ph's fault...) -Kees
($sysname, $nodename, $release, $version, $machine) = POSIX::uname();
if ($sysname eq "SunOS" && $machine =~ /^sun/) {
        eval "sub __sparc () {1;}";
}

$VERBOSE=1;
# Need to determine location (Linux, Solaris, AIX, BSD known & working)
@LOCATIONS=(    
                'termios.ph',     # Linux
                'asm/termios.ph', # Linux
		'sys/termiox.ph', # AIX
                'sys/termios.ph', # OpenBSD
		'sys/ttycom.ph'   # OpenBSD
);
foreach $loc (@LOCATIONS) {
   print "trying '$loc'... " if ($VERBOSE);
   eval {
        # silence .ph warnings
        local $SIG{'__WARN__'}=sub { };

        require "$loc";
   };
   if ($@) {
      print "nope\n" if ($VERBOSE);
      print "\tDevice::Serial error: $@\n" if ($DEBUG);
      next;
   }

   $benefit=0;

   # do we have everything we need yet?
   if (!defined($got{'hardflow'}) &&
        (defined(&SerialJunk::CRTSCTS) || defined(&SerialJunk::CTSXON))) {
        $got{'hardflow'}=1;
        if (defined(&SerialJunk::CRTSCTS)) {
                print "(CRTSCTS) " if ($VERBOSE);
        } else {
                print "(CTSXON) " if ($VERBOSE);
        }
        $benefit=1;
   }
   if (!defined($got{'TIOCMBIS'}) && defined(&SerialJunk::TIOCMBIS)) {
	$got{'TIOCMBIS'}=1;
	print "(TIOCMBIS) " if ($VERBOSE);
	$benefit=1;
   } 
   if (!defined($got{'TIOCMBIC'}) && defined(&SerialJunk::TIOCMBIC)) {
	$got{'TIOCMBIC'}=1;
	print "(TIOCMBIC) " if ($VERBOSE);
	$benefit=1;
   } 
   if (!defined($got{'TIOCMGET'}) && defined(&SerialJunk::TIOCMGET)) {
	$got{'TIOCMGET'}=1;
	print "(TIOCMGET) " if ($VERBOSE);
	$benefit=1;
   } 
   if (!defined($got{'dtr'}) && 
        (defined(&SerialJunk::TIOCSDTR) || defined(&SerialJunk::TIOCM_DTR))) {
	$got{'dtr'}=1;
	if (defined(&SerialJunk::TIOCSDTR)) {
		print "(TIOCSDTR) " if ($VERBOSE);
	} else {
		print "(TIOCM_DTR) " if ($VERBOSE);
	}
	$benefit=1;
   } 
   if ($benefit == 1) {
   	push(@using, $loc);
	print "useful\n" if ($VERBOSE);
   }
   else {
	print "not useful\n" if ($VERBOSE);
   }
   if ($got{'dtr'} && $got{'hardflow'} && $got{'TIOCMBIS'} &&
	$got{'TIOCMBIC'} && $got{'TIOCMGET'}) {
                $ioctl_ok = 1;
                print "\nNeeded '".
                        join("', '",@using)."'\n" if ($VERBOSE);
                last;
   }
}
if ($ioctl_ok == 0) {
   warn "Device::Serial could not find ioctl definitions!\n";
   die "Perl did not find any .ph files to get at least the following ioctls:
	TIOCMBIS
	TIOCMBIC
	TIOCMGET
	CRTSCTS
Please check your Perl installation, or read 'man h2ph'.  As root, you may
need to run:
        cd /usr/include; h2ph -r -l .
before the Perl *.ph files will work.\n";
}


# First, we need to figure out a default serial port to use for
# testing.
my @SERIALS=( "/dev/ttyS0", "/dev/cua00", "/dev/term/a", "/dev/tty0" );
if (@ARGV) {
    @SERIALS=@ARGV;
}

print "Trying to find a serial port for testing...\n";

my $file=undef;
my $test;
foreach $test (@SERIALS) {
    print "\tchecking '$test' ... ";
    lstat($test);
    if (-e $test) {
        if (-l $test) {
	    my $sunserial=readlink($test);
	    if (-c $sunserial) {
	        print "character device\n";
	        if ($sunserial =~ m#/devices/#) {
	            # this is a sun serial device, check the type
	            my @paths=split('/',$sunserial);
		    foreach $part (@paths) {
	                if ($part =~ /^(zs|se)\@/) {
		            $serialtype=$1;
			    last;
                        }
                    }
		    if ($serialtype =~ /^zs/) {
		        &CheckEtcSystem("zs:default_dtrlow");
		    }
		    elsif ($serialtype =~ /^se/) {
		        warn "\nMake sure you have patch 105924-09 or better ".
		             "to handle your 'se' serial port.\n";
		        &CheckEtcSystem("se:se_default_dtrlow");
		    }
		    else {
		        warn "\nFound what seems to be a Sun serial device.\n".
		             "Its path is '$sunserial',\n".
		   	     "but is not a 'zs' or 'se' style serial device.\n".
			     "continuing anyway...\n";
		    }
		    $file=$test;
		    last;
	        }
	    }
	}
	# if we get here, it's either not a link, or not a link to a sun dev
	stat($test);
	if (-c $test) {
	    print "character device\n";
	    $file=$test;
	    last;
	}
    }
    print "nope\n";
}

if (!defined($file)) {
    die "Could not find a serial port to use for testing.\n".
        "Please specify one on the 'perl Makefile.PL' command line, like so:\n".
	"\tperl Makefile.PL /dev/ttyS0\n";
}

my $dfile = "t/DefaultPort.pm";
open (DEFAULT, "> $dfile") or die "Can't create $dfile: $!\n";
print DEFAULT <<EOF;
package SerialJunk;
# Created by Makefile.PL

\$Makefile_Test_Port = "$file";
EOF

close DEFAULT;


# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'	=> 'Device::SerialPort',
    'VERSION_FROM' => 'SerialPort.pm', # finds $VERSION
    'AUTHOR' => 'Kees Cook <cook@cpoint.net>',
    'ABSTRACT_FROM' => 'SerialPort.pm',
    'SKIP'	=> [qw(tool_autosplit)],
    'clean' => { FILES => 't/DefaultPort.pm *.cfg t/*.cfg' },
    'dist' => { COMPRESS => 'gzip -9f', SUFFIX => '.tar.gz', }
);

sub CheckEtcSystem {
    my $setting=shift;

    if (! -f "/etc/system") {
	warn "Hey, where is your '/etc/system' file?  We need to check\n".
	     "and make sure your '$settings' settings are correct\n".
	     "since it looks like you have a Sun serial port\n";
	return;
    }

    open(SYSTEM,"</etc/system") || die "Ack!  Can't read '/etc/system': $!\n";
    my @lines=<SYSTEM>;
    close(SYSTEM);

    my $found=0;
    foreach $line (@lines) {
	chomp($line);
	next if ($line !~ /^set/);
	next if ($line !~ /$setting/);

	my @parts=split(/\s*=\s*/,$line,2);
	my $value=@parts[1];
	$value=~s/\s*$//;
	if ($value != 0) {
	    warn "\nYour '$setting' in '/etc/system' is not '0'.  This will\n".
		 "break several of the Device::SerialPort tests, and cause\n".
		 "longer delays when working with the DTR functions.\n";
	}
	else {
	    $found=1;
	}
    }
    if ($found != 1) {
	warn "\nYou don't have a '$setting' line in '/etc/system'.\n".
	     "you might need to add:\n".
	     "\tset $setting = 0\n".
             "to '/etc/system', or else Device::SerialPort's DTR functions\n".
	     "will not work properly.\n";
    }
    else {
        print "\tOh good, your '/etc/system' contains '$setting = 0'!\n";
    }
}
