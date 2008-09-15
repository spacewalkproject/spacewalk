# Note: This is a POSIX version of the Win32::Serialport module
#       ported by Joe Doss, Kees Cook 
#       for use with the MisterHouse and Sendpage programs

# Prototypes for ioctl constants do not match POSIX constants
# so put them into implausible namespace and call them there
#
# It appears this is a long standing issue. In Changes5.002,
# NETaa14422, Larry Wall comments, "It's almost like you want an
# AUTOPROTO to go with your AUTOLOAD." POSIX.pm was his example.

package SerialJunk;
use POSIX qw(uname);

$VERBOSE=0; # turn on for verbose ph hunting...
$DEBUG=0; # turn this on to debug the *.ph hunting...

# Auto-ioctl settings are now hunted down and verified.
#  - Kees Cook, Sep 2000

use vars qw($ioctl_ok);
$ioctl_ok = 0;

# Needed on some misbehaving Solaris machines... (h2ph's fault...) -Kees
($sysname, $nodename, $release, $version, $machine) = POSIX::uname();
if ($sysname eq "SunOS" && $machine =~ /^sun/) {
	eval "sub __sparc () {1;}";
}

# Need to determine location (Linux, Solaris, AIX, BSD known & working)
@LOCATIONS=(	
                'termios.ph',     # Linux
                'asm/termios.ph', # Linux
		'sys/termiox.ph', # AIX
                'sys/termios.ph', # AIX, OpenBSD
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
}

package Device::SerialPort;

use POSIX qw(:termios_h);
use IO::Handle;

use vars qw($bitset $bitclear $rtsout $dtrout $getstat $incount $outcount
	    $txdone $dtrset $dtrclear $termioxflow $tcgetx $tcsetx);
if ($SerialJunk::ioctl_ok) {
  eval {
    # silence .ph warnings
    local $SIG{'__WARN__'}=sub { };

    $bitset = &SerialJunk::TIOCMBIS;
    $bitclear = &SerialJunk::TIOCMBIC;
    $getstat = &SerialJunk::TIOCMGET;
    $incount = defined(&SerialJunk::TIOCINQ) ? &SerialJunk::TIOCINQ : 0;
    $outcount = defined(&SerialJunk::TIOCOUTQ) ? &SerialJunk::TIOCOUTQ : 0;
    $txdone = defined(&SerialJunk::TIOCSERGETLSR)?&SerialJunk::TIOCSERGETLSR:0;
    $dtrset = defined(&SerialJunk::TIOCSDTR) ? &SerialJunk::TIOCSDTR : 0;
    $dtrclear=defined(&SerialJunk::TIOCCDTR) ? &SerialJunk::TIOCCDTR : 0;
    $rtsout = pack('L', &SerialJunk::TIOCM_RTS);
    $dtrout = pack('L', &SerialJunk::TIOCM_DTR);
    $termioxflow = defined(&SerialJunk::CTSXON) ? 
	(&SerialJunk::CTSXON | &SerialJunk::RTSXOFF) : 0;
    $tcgetx = defined(&SerialJunk::TCGETX) ? &SerialJunk::TCGETX : 0;
    $tcsetx = defined(&SerialJunk::TCGETX) ? &SerialJunk::TCGETX : 0;
  };
}
else {
    $bitset = 0;
    $bitclear = 0;
    $statget = 0;
    $incount = 0;
    $outcount = 0;
    $txdone = 0;
    $dtrset = 0;
    $dtrclear = 0;
    $rtsout = pack('L', 0);
    $dtrout = pack('L', 0);
    $termioxflow = 0;
    $tcgetx = 0;
    $tcsetx = 0;
}

    # non-POSIX constants commonly defined in termios.ph
sub CRTSCTS {
    return 0 unless (defined &SerialJunk::CRTSCTS);
    return &SerialJunk::CRTSCTS;
}

sub OCRNL {
    return 0 unless (defined &SerialJunk::OCRNL);
    return &SerialJunk::OCRNL;
}

sub ONLCR {
    return 0 unless (defined &SerialJunk::ONLCR);
    return &SerialJunk::ONLCR;
}

sub ECHOKE {
    return 0 unless (defined &SerialJunk::ECHOKE);
    return &SerialJunk::ECHOKE;
}

sub ECHOCTL {
    return 0 unless (defined &SerialJunk::ECHOCTL);
    return &SerialJunk::ECHOCTL;
}

sub TIOCM_LE {
    if (defined &SerialJunk::TIOCSER_TEMT) { return &SerialJunk::TIOCSER_TEMT; }
    if (defined &SerialJunk::TIOCM_LE) { return &SerialJunk::TIOCM_LE; }
    0;
}

## Next 4 use Win32 names for compatibility

sub MS_RLSD_ON {
    if (defined &SerialJunk::TIOCM_CAR) { return &SerialJunk::TIOCM_CAR; }
    if (defined &SerialJunk::TIOCM_CD) { return &SerialJunk::TIOCM_CD; }
    0;
}

sub MS_RING_ON {
    if (defined &SerialJunk::TIOCM_RNG) { return &SerialJunk::TIOCM_RNG; }
    if (defined &SerialJunk::TIOCM_RI) { return &SerialJunk::TIOCM_RI; }
    0;
}

sub MS_CTS_ON {
    return 0 unless (defined &SerialJunk::TIOCM_CTS);
    return &SerialJunk::TIOCM_CTS;
}

sub MS_DSR_ON {
    return 0 unless (defined &SerialJunk::TIOCM_DSR);
    return &SerialJunk::TIOCM_DSR;
}

use Carp;
use strict;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = '0.10';

require Exporter;

@ISA = qw(Exporter);
@EXPORT= qw();
@EXPORT_OK= qw();
%EXPORT_TAGS = (STAT	=> [qw( MS_CTS_ON	MS_DSR_ON
				MS_RING_ON	MS_RLSD_ON
				ST_BLOCK	ST_INPUT
				ST_OUTPUT	ST_ERROR )],

		PARAM	=> [qw( LONGsize	SHORTsize	OS_Error
				nocarp		yes_true )]);

Exporter::export_ok_tags('STAT', 'PARAM');

$EXPORT_TAGS{ALL} = \@EXPORT_OK;

#### Package variable declarations ####

sub ST_BLOCK	{0}	# status offsets for caller
sub ST_INPUT	{1}
sub ST_OUTPUT	{2}
sub ST_ERROR	{3}	# latched

# parameters that must be included in a "save" and "checking subs"

my %validate =	(
		ALIAS		=> "alias",
		E_MSG		=> "error_msg",
		RCONST		=> "read_const_time",
		RTOT		=> "read_char_time",
		U_MSG		=> "user_msg",
		DVTYPE		=> "devicetype",
		HNAME		=> "hostname",
		HADDR		=> "hostaddr",
		DATYPE		=> "datatype",
		CFG_1		=> "cfg_param_1",
		CFG_2		=> "cfg_param_2",
		CFG_3		=> "cfg_param_3",
		);

# Linux-specific Baud-Rates
sub B57600  { 0010001 }
sub B115200 { 0010002 }
sub B230400 { 0010003 }
sub B460800 { 0010004 }

my @termios_fields = (
		     "C_CFLAG",
		     "C_IFLAG",
		     "C_ISPEED",
		     "C_LFLAG",
		     "C_OFLAG",
		     "C_OSPEED"
		     );

my %c_cc_fields = (
		   VEOF     => &POSIX::VEOF,
		   VEOL     => &POSIX::VEOL,
		   VERASE   => &POSIX::VERASE,
		   VINTR    => &POSIX::VINTR,
		   VKILL    => &POSIX::VKILL,
		   VQUIT    => &POSIX::VQUIT,
		   VSUSP    => &POSIX::VSUSP,
		   VSTART   => &POSIX::VSTART,
		   VSTOP    => &POSIX::VSTOP,
		   VMIN     => &POSIX::VMIN,
		   VTIME    => &POSIX::VTIME,
		   );

my %bauds = (
	     0        => B0,
	     50       => B50,
	     75       => B75,
	     110      => B110,
	     134      => B134,
	     150      => B150,
	     200      => B200,
	     300      => B300,
	     600      => B600,
	     1200     => B1200,
	     1800     => B1800,
	     2400     => B2400,
	     4800     => B4800,
	     9600     => B9600,
	     19200    => B19200,
	     38400    => B38400,
	     # These are Linux-specific
	     57600    => B57600,
	     115200   => B115200,
	     230400   => B230400,
	     460800   => B460800,
	     );

my $Babble = 0;
my $testactive = 0;	# test mode active

my @Yes_resp = (
		"YES", "Y",
		"ON",
		"TRUE", "T",
		"1"
		);

my @binary_opt = ( 0, 1 );
my @byte_opt = (0, 255);

my $cfg_file_sig="Device::SerialPort_Configuration_File -- DO NOT EDIT --\n";

## my $null=[];
my $null=0;
my $zero=0;

# Preloaded methods go here.

sub get_tick_count {
	# clone of Win32::GetTickCount - perhaps same 49 day problem
    my ($real2, $user2, $system2, $cuser2, $csystem2) = POSIX::times();
    $real2 *= 10.0;
    ## printf "real2 = %8.0f\n", $real2;
    return int $real2;
}

sub SHORTsize { 0xffff; }	# mostly for AltPort test
sub LONGsize { 0xffffffff; }	# mostly for AltPort test

sub OS_Error { print "Device::SerialPort OS_Error\n"; }

    # test*.pl only - suppresses default messages
sub set_test_mode_active {
    return unless (@_ == 2);
    $testactive = $_[1];     # allow "off"
    my @fields = @termios_fields;
    my $item;
    foreach $item (keys %c_cc_fields) {
	push @fields, "C_$item";
    }
    foreach $item (keys %validate) {
	push @fields, "$item";
    }
    return @fields;
}

sub nocarp { return $testactive }

sub yes_true {
    my $choice = uc shift;
    my $ans = 0;
    foreach (@Yes_resp) { $ans = 1 if ( $choice eq $_ ) }
    return $ans;
}

sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = {};
    my $ok    = 0;		# API return value

    my $item = 0;


    $self->{NAME}     = shift;

                                # bbw change: 03/10/99
                                #  - Add quiet option so we can do a 'test'
                                #    new (print no error if fail)
                                # 
    my $quiet = shift;

    unless ($quiet or ($bitset && $bitclear && $rtsout &&
	    (($dtrset && $dtrclear) || $dtrout)) ) {
       nocarp or warn "disabling ioctl methods - constants not found\n";
    }

    my $lockfile = shift;
    if ($lockfile) {
        $self->{LOCK} = $lockfile;
	my $lockf = POSIX::open($self->{LOCK}, 
				    &POSIX::O_WRONLY |
				    &POSIX::O_CREAT |
				    &POSIX::O_NOCTTY |
				    &POSIX::O_EXCL);
	unless (defined $lockf) {
            unless ($quiet) {
                nocarp or carp "can't open lockfile: $self->{LOCK}\n"; 
            }
            return 0 if ($quiet);
	    return;
	}
	my $pid = "$$\n";
	$ok = POSIX::write($lockf, $pid, length $pid);
	my $ok2 = POSIX::close($lockf);
	return unless ($ok && (defined $ok2));
	sleep 2;	# wild guess for Version 0.05
    }
    else {
        $self->{LOCK} = "";
    }

    $self->{FD}= POSIX::open($self->{NAME}, 
				    &POSIX::O_RDWR |
				    &POSIX::O_NOCTTY |
				    &POSIX::O_NONBLOCK);

    unless (defined $self->{FD}) { $self->{FD} = -1; }
    unless ($self->{FD} >= 1) {
        unless ($quiet) {
            nocarp or carp "can't open device: $self->{NAME}\n"; 
        }
        $self->{FD} = -1;
        if ($self->{LOCK}) {
	    $ok = unlink $self->{LOCK};
	    unless ($ok or $quiet) {
                nocarp or carp "can't remove lockfile: $self->{LOCK}\n"; 
    	    }
            $self->{LOCK} = "";
        }
        return 0 if ($quiet);
	return undef;
    }

    $self->{TERMIOS} = POSIX::Termios->new();

    # a handle object for ioctls: read-only ok
    $self->{HANDLE} = new_from_fd IO::Handle ($self->{FD}, "r");
    
    # get the current attributes
    $ok = $self->{TERMIOS}->getattr($self->{FD});

    unless ( $ok ) {
        carp "can't getattr";
        undef $self;
        return undef;
    }

    # save the original values
    $self->{"_CFLAG"} = $self->{TERMIOS}->getcflag();
    $self->{"_IFLAG"} = $self->{TERMIOS}->getiflag();
    $self->{"_ISPEED"} = $self->{TERMIOS}->getispeed();
    $self->{"_LFLAG"} = $self->{TERMIOS}->getlflag();
    $self->{"_OFLAG"} = $self->{TERMIOS}->getoflag();
    $self->{"_OSPEED"} = $self->{TERMIOS}->getospeed();

    # build termiox flag anyway
    $self->{'TERMIOX'} = 0;

    foreach $item (keys %c_cc_fields) {
	$self->{"_$item"} = $self->{TERMIOS}->getcc($c_cc_fields{$item});
    }

    # copy the original values into "current" values
    foreach $item (keys %c_cc_fields) {
	$self->{"C_$item"} = $self->{"_$item"};
    }

    $self->{"C_CFLAG"} = $self->{"_CFLAG"};
    $self->{"C_IFLAG"} = $self->{"_IFLAG"};
    $self->{"C_ISPEED"} = $self->{"_ISPEED"};
    $self->{"C_LFLAG"} = $self->{"_LFLAG"};
    $self->{"C_OFLAG"} = $self->{"_OFLAG"};
    $self->{"C_OSPEED"} = $self->{"_OSPEED"};

    # Finally, default to "raw" mode for this package
    $self->{"C_IFLAG"} &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL|IXON);
    $self->{"C_OFLAG"} &= ~OPOST;
    $self->{"C_LFLAG"} &= ~(ECHO|ECHONL|ICANON|ISIG|IEXTEN);
    $self->{"C_CFLAG"} &= ~(CSIZE|PARENB);
    $self->{"C_CFLAG"} |= (CS8|CLOCAL);
    &write_settings($self);

    $self->{ALIAS} = $self->{NAME};	# so "\\.\+++" can be changed
##    print "opening $self->{NAME}\n"; ## DEBUG ##

    # "private" data
    $self->{"_DEBUG"}    	= 0;
    $self->{U_MSG}     		= 0;
    $self->{E_MSG}     		= 0;
    $self->{RCONST}   		= 0;
    $self->{RTOT}   		= 0;
    $self->{"_T_INPUT"}		= "";
    $self->{"_LOOK"}		= "";
    $self->{"_LASTLOOK"}	= "";
    $self->{"_LASTLINE"}	= "";
    $self->{"_CLASTLINE"}	= "";
    $self->{"_SIZE"}		= 1;
    $self->{OFS}		= "";
    $self->{ORS}		= "";
    $self->{"_LMATCH"}		= "";
    $self->{"_LPATT"}		= "";
    $self->{"_PROMPT"}		= "";
    $self->{"_MATCH"}		= [];
    $self->{"_CMATCH"}		= [];
    @{ $self->{"_MATCH"} }	= "\n";
    @{ $self->{"_CMATCH"} }	= "\n";
    $self->{DVTYPE}		= "none";
    $self->{HNAME}		= "localhost";
    $self->{HADDR}		= 0;
    $self->{DATYPE}		= "raw";
    $self->{CFG_1}		= "none";
    $self->{CFG_2}		= "none";
    $self->{CFG_3}		= "none";

    bless ($self, $class);
    return $self;
}

sub write_settings {
    my $self = shift;
    my $item;

    # put current values into Termios structure
    $self->{TERMIOS}->setcflag($self->{"C_CFLAG"});
    $self->{TERMIOS}->setiflag($self->{"C_IFLAG"});
    $self->{TERMIOS}->setispeed($self->{"C_ISPEED"});
    $self->{TERMIOS}->setlflag($self->{"C_LFLAG"});
    $self->{TERMIOS}->setoflag($self->{"C_OFLAG"});
    $self->{TERMIOS}->setospeed($self->{"C_OSPEED"});

    foreach $item (keys %c_cc_fields) {
	$self->{TERMIOS}->setcc($c_cc_fields{$item}, $self->{"C_$item"});
    }

    $self->{TERMIOS}->setattr($self->{FD}, &POSIX::TCSANOW);

    if ($Babble) {
        print "writing settings to $self->{ALIAS}\n";
    }
    1;
}

sub save {
    my $self = shift;
    my $item;
    my $getsub;
    my $value;

    return unless (@_);

    my $filename = shift;
    unless ( open CF, ">$filename" ) {
        carp "can't open file: $filename"; 
        return;
    }
    print CF "$cfg_file_sig";
    print CF "$self->{NAME}\n";
	# used to "reopen" so must be DEVICE=NAME
    print CF "$self->{LOCK}\n";
	# use lock to "open" if established

        # put current values from Termios structure FIRST
    foreach $item (@termios_fields) {
	printf CF "$item,%d\n", $self->{"$item"};
    }
    foreach $item (keys %c_cc_fields) {
	printf CF "C_$item,%d\n", $self->{"C_$item"};
    }
    
    no strict 'refs';		# for $gosub
    while (($item, $getsub) = each %validate) {
        chomp $getsub;
	$value = scalar &$getsub($self);
        print CF "$item,$value\n";
    }
    use strict 'refs';
    close CF;
    if ($Babble) {
        print "wrote file $filename for $self->{ALIAS}\n";
    }
    1;
}

# parse values for start/restart
sub get_start_values {
    return unless (@_ == 2);
    my $self = shift;
    my $filename = shift;

    unless ( open CF, "<$filename" ) {
        carp "can't open file: $filename"; 
        return;
    }
    my ($signature, $name, $lockfile, @values) = <CF>;
    close CF;
    
    unless ( $cfg_file_sig eq $signature ) {
        carp "Invalid signature in $filename: $signature"; 
        return;
    }
    chomp $name;
    unless ( $self->{NAME} eq $name ) {
        carp "Invalid Port DEVICE=$self->{NAME} in $filename: $name"; 
        return;
    }
    chomp $lockfile;
    if ($Babble or not $self) {
        print "signature = $signature";
        print "name = $name\n";
        if ($Babble) {
            print "values:\n";
            foreach (@values) { print "    $_"; }
        }
    }
    my $item;
    my @fields = @termios_fields;
    foreach $item (keys %c_cc_fields) {
	push @fields, "C_$item";
    }
    my %termios;
    foreach $item (@fields) {
	$termios{$item} = 1;
    }
    my $key;
    my $value;
    my $gosub;
    my $fault = 0;
    no strict 'refs';		# for $gosub
    foreach $item (@values) {
        chomp $item;
        ($key, $value) = split (/,/, $item);
        if ($value eq "") { $fault++ }
	elsif (defined $termios{$key}) {
	    $self->{"$key"} = $value;
	}
        else {
            $gosub = $validate{$key};
            unless (defined &$gosub ($self, $value)) {
    	        carp "Invalid parameter for $key=$value   "; 
    	        return;
	    }
        }
    }
    use strict 'refs';
    if ($fault) {
        carp "Invalid value in $filename"; 
        undef $self;
        return;
    }
    1;
}

sub restart {
    return unless (@_ == 2);
    my $self = shift;
    my $filename = shift;
    get_start_values($self, $filename);
    write_settings($self);
}

sub start {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    return unless (@_);
    my $filename = shift;

    unless ( open CF, "<$filename" ) {
        carp "can't open file: $filename"; 
        return;
    }
    my ($signature, $name, $lockfile, @values) = <CF>;
    close CF;
    
    unless ( $cfg_file_sig eq $signature ) {
        carp "Invalid signature in $filename: $signature"; 
        return;
    }
    chomp $name;
    chomp $lockfile;
    my $self  = new ($class, $name, 1, $lockfile); # quiet for lock
    return 0 if ($lockfile and not $self);
    if ($Babble or not $self) {
        print "signature = $signature";
        print "class = $class\n";
        print "name = $name\n";
        print "lockfile = $lockfile\n";
        if ($Babble) {
            print "values:\n";
            foreach (@values) { print "    $_"; }
        }
    }
    if ($self) {
        if ( get_start_values($self, $filename) ) {
            write_settings ($self);
	}
        else {
            carp "Invalid value in $filename"; 
            undef $self;
            return;
        }
    }
    return $self;
}

# true/false capabilities (read only)
# currently just constants in the POSIX case

sub can_baud			{ return 1; }
sub can_databits		{ return 1; }
sub can_stopbits		{ return 1; }
sub can_dtrdsr			{ return 1; }
sub can_handshake		{ return 1; }
sub can_parity_check		{ return 1; }
sub can_parity_config		{ return 1; }
sub can_parity_enable		{ return 1; }
sub can_rlsd			{ return 0; } # currently
sub can_16bitmode		{ return 0; } # Win32-specific
sub is_rs232			{ return 1; }
sub is_modem			{ return 0; } # Win32-specific
sub can_rtscts			{ return 1; } # this is a flow option
sub can_xonxoff			{ return 1; } # this is a flow option
sub can_xon_char		{ return 1; } # use stty
sub can_spec_char		{ return 0; } # use stty
sub can_interval_timeout	{ return 0; } # currently
sub can_total_timeout		{ return 1; } # currently
sub binary			{ return 1; }
  
sub reset_error			{ return 0; } # for compatibility

sub can_ioctl {
    return 0 unless ($bitset && $bitclear && $rtsout && 
	    (($dtrset && $dtrclear) || $dtrout));
    return 1;
}

sub can_status {
    return 0 unless ($incount && $outcount);
    return 1;
}

sub can_write_done {
    return 0 unless ($txdone && TIOCM_LE && $outcount);
    return 1;
}

# can we control the rts line?
sub can_rts {
    return 0 unless($bitset && $bitclear && $rtsout && !($dtrset && $dtrclear));
    return 1;
}

sub termiox {
    my $self = shift;
    return unless ($termioxflow);
    my $on = shift;
    my $rc;

    $self->{'TERMIOX'}=$on ? $termioxflow : 0;

    my $flags=pack('SSSS',0,0,0,0);
    if (!($rc=ioctl($self->{HANDLE}, $tcgetx, $flags))) {
	warn "TCGETX ioctl: $!\n";
    }

    my @vals=unpack('SSSS',$flags);
    $vals[0]= $on ? $termioxflow : 0;
    $flags=pack('SSSS',@vals);

    if (!($rc=ioctl($self->{HANDLE}, $tcsetx, $flags))) {
	warn "TCSETX($on) ioctl: $!\n";
    }
    return $rc;
}
  
sub handshake {
    my $self = shift;
    
    if (@_) {
	if ( $_[0] eq "none" ) {
	    $self->{"C_IFLAG"} &= ~(IXON | IXOFF);
	    $self->termiox(0) if ($termioxflow);
	    $self->{"C_CFLAG"} &= ~CRTSCTS;
	}
	elsif ( $_[0] eq "xoff" ) {
	    $self->{"C_IFLAG"} |= (IXON | IXOFF);
	    $self->termiox(0) if ($termioxflow);
	    $self->{"C_CFLAG"} &= ~CRTSCTS;
	}
	elsif ( $_[0] eq "rts" ) {
	    $self->{"C_IFLAG"} &= ~(IXON | IXOFF);
	    $self->termiox(1) if ($termioxflow);
	    $self->{"C_CFLAG"} |= CRTSCTS;
	}
        else {
            if ($self->{U_MSG} or $Babble) {
                carp "Can't set handshake on $self->{ALIAS}";
            }
	    return;
        }
	write_settings($self);
    }
    if (wantarray) { return ("none", "xoff", "rts"); }
    my $mask = (IXON|IXOFF);
    return "xoff" if ($mask == ($self->{"C_IFLAG"} & $mask));
    if ($termioxflow) {
	return "rts" if ($self->{'TERMIOX'} & $termioxflow);
    } else {
    	return "rts" if ($self->{"C_CFLAG"} & CRTSCTS);
    }
    return "none";
}

sub baudrate {
    my $self = shift;
    my $item = 0;

    if (@_) {
        if (defined $bauds{$_[0]}) {
            $self->{"C_OSPEED"} = $bauds{$_[0]};
            $self->{"C_ISPEED"} = $bauds{$_[0]};
            write_settings($self);
        }
        else {
            if ($self->{U_MSG} or $Babble) {
                carp "Can't set baudrate on $self->{ALIAS}";
            }
	    return undef;
        }
    }
    if (wantarray) { return (keys %bauds); }
    foreach $item (keys %bauds) {
	return $item if ($bauds{$item} == $self->{"C_OSPEED"});
    }
    return undef;
}

sub parity {
    my $self = shift;
    if (@_) {
	if ( $_[0] eq "none" ) {
	    $self->{"C_IFLAG"} &= ~INPCK;
	    $self->{"C_CFLAG"} &= ~PARENB;
	}
	elsif ( $_[0] eq "odd" ) {
	    $self->{"C_IFLAG"} |= INPCK;
	    $self->{"C_CFLAG"} |= (PARENB|PARODD);
	}
	elsif ( $_[0] eq "even" ) {
	    $self->{"C_IFLAG"} |= INPCK;
	    $self->{"C_CFLAG"} |= PARENB;
	    $self->{"C_CFLAG"} &= ~PARODD;
	}
        else {
            if ($self->{U_MSG} or $Babble) {
                carp "Can't set parity on $self->{ALIAS}";
            }
	    return;
        }
	write_settings($self);
    }
    if (wantarray) { return ("none", "odd", "even"); }
    return "none" unless ($self->{"C_IFLAG"} & INPCK);
    my $mask = (PARENB|PARODD);
    return "odd"  if ($mask == ($self->{"C_CFLAG"} & $mask));
    $mask = (PARENB);
    return "even" if ($mask == ($self->{"C_CFLAG"} & $mask));
    return "none";
}

sub databits {
    my $self = shift;
    if (@_) {
	if ( $_[0] == 8 ) {
	    $self->{"C_CFLAG"} &= ~CSIZE;
	    $self->{"C_CFLAG"} |= CS8;
	}
	elsif ( $_[0] == 7 ) {
	    $self->{"C_CFLAG"} &= ~CSIZE;
	    $self->{"C_CFLAG"} |= CS7;
	}
	elsif ( $_[0] == 6 ) {
	    $self->{"C_CFLAG"} &= ~CSIZE;
	    $self->{"C_CFLAG"} |= CS6;
	}
	elsif ( $_[0] == 5 ) {
	    $self->{"C_CFLAG"} &= ~CSIZE;
	    $self->{"C_CFLAG"} |= CS5;
	}
        else {
            if ($self->{U_MSG} or $Babble) {
                carp "Can't set databits on $self->{ALIAS}";
            }
	    return;
        }
	write_settings($self);
    }
    if (wantarray) { return (5, 6, 7, 8); }
    my $mask = ($self->{"C_CFLAG"} & CSIZE);
    return 8 if ($mask == CS8);
    return 7 if ($mask == CS7);
    return 6 if ($mask == CS6);
    return 5;
}

sub stopbits {
    my $self = shift;
    if (@_) {
	if ( $_[0] == 2 ) {
	    $self->{"C_CFLAG"} |= CSTOPB;
	}
	elsif ( $_[0] == 1 ) {
	    $self->{"C_CFLAG"} &= ~CSTOPB;
	}
        else {
            if ($self->{U_MSG} or $Babble) {
                carp "Can't set stopbits on $self->{ALIAS}";
            }
	    return;
        }
	write_settings($self);
    }
    if (wantarray) { return (1, 2); }
    return 2 if ($self->{"C_CFLAG"} & CSTOPB);
    return 1;
}

sub is_xon_char {
    my $self = shift;
    if (@_) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
	$self->{"C_VSTART"} = $v;
	write_settings($self);
    }
    return $self->{"C_VSTART"};
}

sub is_xoff_char {
    my $self = shift;
    if (@_) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
	$self->{"C_VSTOP"} = $v;
	write_settings($self);
    }
    return $self->{"C_VSTOP"};
}

sub is_stty_intr {
    my $self = shift;
    if (@_) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
	$self->{"C_VINTR"} = $v;
	write_settings($self);
    }
    return $self->{"C_VINTR"};
}

sub is_stty_quit {
    my $self = shift;
    if (@_) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
	$self->{"C_VQUIT"} = $v;
	write_settings($self);
    }
    return $self->{"C_VQUIT"};
}

sub is_stty_eof {
    my $self = shift;
    if (@_) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
	$self->{"C_VEOF"} = $v;
	write_settings($self);
    }
    return $self->{"C_VEOF"};
}

sub is_stty_eol {
    my $self = shift;
    if (@_) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
	$self->{"C_VEOL"} = $v;
	write_settings($self);
    }
    return $self->{"C_VEOL"};
}

sub is_stty_erase {
    my $self = shift;
    if (@_) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
	$self->{"C_VERASE"} = $v;
	write_settings($self);
    }
    return $self->{"C_VERASE"};
}

sub is_stty_kill {
    my $self = shift;
    if (@_) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
	$self->{"C_VKILL"} = $v;
	write_settings($self);
    }
    return $self->{"C_VKILL"};
}

sub is_stty_susp {
    my $self = shift;
    if (@_) {
	my $v = int shift;
	return if (($v < 0) or ($v > 255));
	$self->{"C_VSUSP"} = $v;
	write_settings($self);
    }
    return $self->{"C_VSUSP"};
}

sub stty_echo {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_LFLAG"} |= ECHO;
        } else {
	    $self->{"C_LFLAG"} &= ~ECHO;
	}
	write_settings($self);
    }
    return ($self->{"C_LFLAG"} & ECHO) ? 1 : 0;
}

sub stty_echoe {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_LFLAG"} |= ECHOE;
        } else {
	    $self->{"C_LFLAG"} &= ~ECHOE;
	}
	write_settings($self);
    }
    return ($self->{"C_LFLAG"} & ECHOE) ? 1 : 0;
}

sub stty_echok {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_LFLAG"} |= ECHOK;
        } else {
	    $self->{"C_LFLAG"} &= ~ECHOK;
	}
	write_settings($self);
    }
    return ($self->{"C_LFLAG"} & ECHOK) ? 1 : 0;
}

sub stty_echonl {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_LFLAG"} |= ECHONL;
        } else {
	    $self->{"C_LFLAG"} &= ~ECHONL;
	}
	write_settings($self);
    }
    return ($self->{"C_LFLAG"} & ECHONL) ? 1 : 0;
}

	# non-POSIX
sub stty_echoke {
    my $self = shift;
    return unless ECHOKE;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_LFLAG"} |= ECHOKE;
        } else {
	    $self->{"C_LFLAG"} &= ~ECHOKE;
	}
	write_settings($self);
    }
    return ($self->{"C_LFLAG"} & ECHOKE) ? 1 : 0;
}

	# non-POSIX
sub stty_echoctl {
    my $self = shift;
    return unless ECHOCTL;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_LFLAG"} |= ECHOCTL;
        } else {
	    $self->{"C_LFLAG"} &= ~ECHOCTL;
	}
	write_settings($self);
    }
    return ($self->{"C_LFLAG"} & ECHOCTL) ? 1 : 0;
}

sub stty_istrip {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_IFLAG"} |= ISTRIP;
        } else {
	    $self->{"C_IFLAG"} &= ~ISTRIP;
	}
	write_settings($self);
    }
    return ($self->{"C_IFLAG"} & ISTRIP) ? 1 : 0;
}

sub stty_icrnl {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_IFLAG"} |= ICRNL;
        } else {
	    $self->{"C_IFLAG"} &= ~ICRNL;
	}
	write_settings($self);
    }
    return ($self->{"C_IFLAG"} & ICRNL) ? 1 : 0;
}

sub stty_igncr {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_IFLAG"} |= IGNCR;
        } else {
	    $self->{"C_IFLAG"} &= ~IGNCR;
	}
	write_settings($self);
    }
    return ($self->{"C_IFLAG"} & IGNCR) ? 1 : 0;
}

sub stty_inlcr {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_IFLAG"} |= INLCR;
        } else {
	    $self->{"C_IFLAG"} &= ~INLCR;
	}
	write_settings($self);
    }
    return ($self->{"C_IFLAG"} & INLCR) ? 1 : 0;
}

	# non-POSIX
sub stty_ocrnl {
    my $self = shift;
    return unless OCRNL;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_OFLAG"} |= OCRNL;
        } else {
	    $self->{"C_OFLAG"} &= ~OCRNL;
	}
	write_settings($self);
    }
    return ($self->{"C_OFLAG"} & OCRNL) ? 1 : 0;
}

	# non-POSIX
sub stty_onlcr {
    my $self = shift;
    return unless ONLCR;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_OFLAG"} |= ONLCR;
        } else {
	    $self->{"C_OFLAG"} &= ~ONLCR;
	}
	write_settings($self);
    }
    return ($self->{"C_OFLAG"} & ONLCR) ? 1 : 0;
}

sub stty_opost {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_OFLAG"} |= OPOST;
        } else {
	    $self->{"C_OFLAG"} &= ~OPOST;
	}
	write_settings($self);
    }
    return ($self->{"C_OFLAG"} & OPOST) ? 1 : 0;
}

sub stty_isig {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_LFLAG"} |= ISIG;
        } else {
	    $self->{"C_LFLAG"} &= ~ISIG;
	}
	write_settings($self);
    }
    return ($self->{"C_LFLAG"} & ISIG) ? 1 : 0;
}

sub stty_icanon {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_LFLAG"} |= ICANON;
        } else {
	    $self->{"C_LFLAG"} &= ~ICANON;
	}
	write_settings($self);
    }
    return ($self->{"C_LFLAG"} & ICANON) ? 1 : 0;
}

sub alias {
    my $self = shift;
    if (@_) { $self->{ALIAS} = shift; }	# should return true for legal names
    return $self->{ALIAS};
}

sub devicetype {
    my $self = shift;
    if (@_) { $self->{DVTYPE} = shift; } # return true for legal names
    return $self->{DVTYPE};
}

sub hostname {
    my $self = shift;
    if (@_) { $self->{HNAME} = shift; }	# return true for legal names
    return $self->{HNAME};
}

sub hostaddr {
    my $self = shift;
    if (@_) { $self->{HADDR} = shift; }	# return true for assigned port
    return $self->{HADDR};
}

sub datatype {
    my $self = shift;
    if (@_) { $self->{DATYPE} = shift; } # return true for legal types
    return $self->{DATYPE};
}

sub cfg_param_1 {
    my $self = shift;
    if (@_) { $self->{CFG_1} = shift; }	# return true for legal param
    return $self->{CFG_1};
}

sub cfg_param_2 {
    my $self = shift;
    if (@_) { $self->{CFG_2} = shift; }	# return true for legal param
    return $self->{CFG_2};
}

sub cfg_param_3 {
    my $self = shift;
    if (@_) { $self->{CFG_3} = shift; }	# return true for legal param
    return $self->{CFG_3};
}

sub buffers {
    my $self = shift;
    if (@_) { return unless (@_ == 2); }
    return wantarray ?  (4096, 4096) : 1;
}

sub read_const_time {
    my $self = shift;
    if (@_) {
	$self->{RCONST} = (shift)/1000; # milliseconds -> select_time
    }
    return $self->{RCONST}*1000;
}

sub read_char_time {
    my $self = shift;
    if (@_) {
	$self->{RTOT} = (shift)/1000; # milliseconds -> select_time
    }
    return $self->{RTOT}*1000;
}

sub read {
    return undef unless (@_ == 2);
    my $self = shift;
    my $wanted = shift;
    my $result = "";
    my $ok     = 0;
    return unless ($wanted > 0);

    my $done = 0;
    my $count_in = 0;
    my $string_in = "";
    my $in2 = "";
    my $bufsize = 255;	# VMIN max (declared as char)

    while ($done < $wanted) {
	my $size = $wanted - $done;
        if ($size > $bufsize) { $size = $bufsize; }
	($count_in, $string_in) = $self->read_vmin($size);
	if ($count_in) {
            $in2 .= $string_in;
	    $done += $count_in;
	}
	elsif ($done) {
	    last;
	}
        else {
            return if (!defined $count_in);
	    last;
        }
    }
    return ($done, $in2);
}

sub read_vmin {
    return undef unless (@_ == 2);
    my $self = shift;
    my $wanted = shift;
    my $result = "";
    my $ok     = 0;
    return unless ($wanted > 0);

    if ($self->{"C_VMIN"} != $wanted) {
	$self->{"C_VMIN"} = $wanted;
        write_settings($self);
    }
    my $rin = "";
    vec($rin, $self->{FD}, 1) = 1;
    my $ein = $rin;
    my $tin = $self->{RCONST} + ($wanted * $self->{RTOT});
    my $rout;
    my $wout;
    my $eout;
    my $tout;
    my $ready = select($rout=$rin, $wout=undef, $eout=$ein, $tout=$tin);

    my $got = POSIX::read ($self->{FD}, $result, $wanted);

    unless (defined $got) {
##	$got = -1;	## DEBUG
	return (0,"") if (&POSIX::EAGAIN == ($ok = POSIX::errno()));
	return (0,"") if (!$ready and (0 == $ok));
		# at least Solaris acts like eof() in this case
	carp "Error #$ok in Device::SerialPort::read";
	return;
    }

    print "read_vmin=$got, ready=$ready, result=..$result..\n" if ($Babble);
    return ($got, $result);
}

sub are_match {
    my $self = shift;
    my $pat;
    my $patno = 0;
    my $reno = 0;
    my $re_next = 0;
    if (@_) {
	@{ $self->{"_MATCH"} } = @_;
	if ($] >= 5.005) {
	    @{ $self->{"_CMATCH"} } = ();
	    while ($pat = shift) {
	        if ($re_next) {
		    $re_next = 0;
	            eval 'push (@{ $self->{"_CMATCH"} }, qr/$pat/)';
		} else {
	            push (@{ $self->{"_CMATCH"} }, $pat);
		}
	        if ($pat eq "-re") {
		    $re_next++;
	        }
	    }
	} else {
	    @{ $self->{"_CMATCH"} } = @_;
	}
    }
    return @{ $self->{"_MATCH"} };
}

sub lookclear {
    my $self = shift;
    if (nocarp && (@_ == 1)) {
        $self->{"_T_INPUT"} = shift;
    } 
    $self->{"_LOOK"}	 = "";
    $self->{"_LASTLOOK"} = "";
    $self->{"_LMATCH"}	 = "";
    $self->{"_LPATT"}	 = "";
    return if (@_);
    1;
}

sub linesize {
    my $self = shift;
    if (@_) {
	my $val = int shift;
	return if ($val < 0);
        $self->{"_SIZE"} = $val;
    }
    return $self->{"_SIZE"};
}

sub lastline {
    my $self = shift;
    if (@_) {
        $self->{"_LASTLINE"} = shift;
	if ($] >= 5.005) {
	    eval '$self->{"_CLASTLINE"} = qr/$self->{"_LASTLINE"}/';
	} else {
            $self->{"_CLASTLINE"} = $self->{"_LASTLINE"};
	}
    }
    return $self->{"_LASTLINE"};
}

sub matchclear {
    my $self = shift;
    my $found = $self->{"_LMATCH"};
    $self->{"_LMATCH"}	 = "";
    return if (@_);
    return $found;
}

sub lastlook {
    my $self = shift;
    return if (@_);
    return ( $self->{"_LMATCH"}, $self->{"_LASTLOOK"},
	     $self->{"_LPATT"}, $self->{"_LOOK"} );
}

sub lookfor {
    my $self = shift;
    my $size = 0;
    if (@_) { $size = shift; }
    my $loc = "";
    my $count_in = 0;
    my $string_in = "";
    $self->{"_LMATCH"}	 = "";
    $self->{"_LPATT"}	 = "";

    if ( ! $self->{"_LOOK"} ) {
        $loc = $self->{"_LASTLOOK"};
    }

    if ($size) {
####    my ($bbb, $iii, $ooo, $eee) = status($self);
####	if ($iii > $size) { $size = $iii; }
	($count_in, $string_in) = $self->read($size);
	return unless ($count_in);
        $loc .= $string_in;
    }
    else {
	$loc .= $self->input;
    }

    if ($loc ne "") {
####	if ($self->{icrnl}) { $loc =~ tr/\r/\n/; }
	my $n_char;
	my $mpos;
####	my $erase_is_bsdel = 0;
####	my $nl_after_kill = "";
####	my $clear_after_kill = 0;
####	my $echo_ctl = 0;
	my $lookbuf;
	my $re_next = 0;
	my $got_match = 0;
	my $pat;
####	my $lf_erase = "";
####	my $lf_kill = "";
####	my $lf_eof = "";
####	my $lf_quit = "";
####	my $lf_intr = "";
####	my $nl_2_crnl = 0;
####	my $cr_2_nl = 0;

####	if ($self->{opost}) {
####	    $nl_2_crnl = $self->{onlcr};
####	    $cr_2_nl = $self->{ocrnl};
####	}

####	if ($self->{echo}) {
####	    $erase_is_bsdel = $self->{echoe};
####	    if ($self->{echok}) {
####	        $nl_after_kill = $self->{onlcr} ? "\r\n" : "\n";
####	    }
####	    $clear_after_kill = $self->{echoke};
####	    $echo_ctl = $self->{echoctl};
####	}

####	if ($self->{icanon}) {
####	    $lf_erase = $self->{erase};
####	    $lf_kill = $self->{s_kill};
####	    $lf_eof = $self->{s_eof};
####	}

####	if ($self->{isig}) {
####	    $lf_quit = $self->{quit};
####	    $lf_intr = $self->{intr};
####	}
	
	my @loc_char = split (//, $loc);
	while (defined ($n_char = shift @loc_char)) {
##	    printf STDERR "0x%x ", ord($n_char);
####	    if ($n_char eq $lf_erase) {
####	        if ($erase_is_bsdel && (length $self->{"_LOOK"}) ) {
####		    $mpos = chop $self->{"_LOOK"};
####	            $self->write($self->{bsdel});
####	            if ($echo_ctl && (($mpos lt "@")|($mpos eq chr(127)))) {
####	                $self->write($self->{bsdel});
####		    }
####		} 
####	    }
####	    elsif ($n_char eq $lf_kill) {
####		$self->{"_LOOK"} = "";
####	        $self->write($self->{clear}) if ($clear_after_kill);
####	        $self->write($nl_after_kill);
####	        $self->write($self->{"_PROMPT"});
####	    }
####	    elsif ($n_char eq $lf_intr) {
####		$self->{"_LOOK"}     = "";
####		$self->{"_LASTLOOK"} = "";
####		return;
####	    }
####	    elsif ($n_char eq $lf_quit) {
####		exit;
####	    }
####	    else {
		$mpos = ord $n_char;
####		if ($self->{istrip}) {
####		    if ($mpos > 127) { $n_char = chr($mpos - 128); }
####		}
                $self->{"_LOOK"} .= $n_char;
##	        print $n_char;
####	        if ($cr_2_nl) { $n_char =~ s/\r/\n/os; }
####	        if ($nl_2_crnl) { $n_char =~ s/\n/\r\n/os; }
####	        if (($mpos < 32)  && $echo_ctl &&
####			($mpos != is_stty_eol($self))) {
####		    $n_char = chr($mpos + 64);
####	            $self->write("^$n_char");
####		}
####		elsif (($mpos == 127) && $echo_ctl) {
####	            $self->write("^.");
####		}
####		elsif ($self->{echonl} && ($n_char =~ "\n")) {
####		    # also writes "\r\n" for onlcr
####	            $self->write($n_char);
####		}
####		elsif ($self->{echo}) {
####		    # also writes "\r\n" for onlcr
####	            $self->write($n_char);
####		}
		$lookbuf = $self->{"_LOOK"};
####		if (($lf_eof ne "") and ($lookbuf =~ /$lf_eof$/)) {
####		    $self->{"_LOOK"}     = "";
####		    $self->{"_LASTLOOK"} = "";
####		    return $lookbuf;
####		}
		$count_in = 0;
		foreach $pat ( @{ $self->{"_CMATCH"} } ) {
		    if ($pat eq "-re") {
			$re_next++;
		        $count_in++;
			next;
		    }
		    if ($re_next) {
			$re_next = 0;
			# always at $lookbuf end when processing single char
		        if ( $lookbuf =~ s/$pat//s ) {
		            $self->{"_LMATCH"} = $&;
			    $got_match++;
			}
		    }
		    elsif (($mpos = index($lookbuf, $pat)) > -1) {
			$got_match++;
			$lookbuf = substr ($lookbuf, 0, $mpos);
		        $self->{"_LMATCH"} = $pat;
		    }
		    if ($got_match) {
		        $self->{"_LPATT"} = $self->{"_MATCH"}[$count_in];
		        if (scalar @loc_char) {
		            $self->{"_LASTLOOK"} = join("", @loc_char);
##		            print ".$self->{\"_LASTLOOK\"}.";
                        }
		        else {
		            $self->{"_LASTLOOK"} = "";
		        }
		        $self->{"_LOOK"}     = "";
		        return $lookbuf;
                    }
		    $count_in++;
		}
####	    }
	}
    }
    return "";
}

sub streamline {
    my $self = shift;
    my $size = 0;
    if (@_) { $size = shift; }
    my $loc = "";
    my $mpos;
    my $count_in = 0;
    my $string_in = "";
    my $re_next = 0;
    my $got_match = 0;
    my $best_pos = 0;
    my $pat;
    my $match = "";
    my $before = "";
    my $after = "";
    my $best_match = "";
    my $best_before = "";
    my $best_after = "";
    my $best_pat = "";
    $self->{"_LMATCH"}	 = "";
    $self->{"_LPATT"}	 = "";

    if ( ! $self->{"_LOOK"} ) {
        $loc = $self->{"_LASTLOOK"};
    }

    if ($size) {
####    my ($bbb, $iii, $ooo, $eee) = status($self);
####	if ($iii > $size) { $size = $iii; }
	($count_in, $string_in) = $self->read($size);
	return unless ($count_in);
        $loc .= $string_in;
    }
    else {
	$loc .= $self->input;
    }

    if ($loc ne "") {
        $self->{"_LOOK"} .= $loc;
	$count_in = 0;
	foreach $pat ( @{ $self->{"_CMATCH"} } ) {
	    if ($pat eq "-re") {
		$re_next++;
		$count_in++;
		next;
	    }
	    if ($re_next) {
		$re_next = 0;
	        if ( $self->{"_LOOK"} =~ /$pat/s ) {
		    ( $match, $before, $after ) = ( $&, $`, $' );
		    $got_match++;
        	    $mpos = length($before);
        	    if ($mpos) {
        	        next if ($best_pos && ($mpos > $best_pos));
			$best_pos = $mpos;
			$best_pat = $self->{"_MATCH"}[$count_in];
			$best_match = $match;
			$best_before = $before;
			$best_after = $after;
	    	    } else {
		        $self->{"_LPATT"} = $self->{"_MATCH"}[$count_in];
		        $self->{"_LMATCH"} = $match;
	                $self->{"_LASTLOOK"} = $after;
		        $self->{"_LOOK"}     = "";
		        return $before;
		        # pattern at start will be best
		    }
		}
	    }
	    elsif (($mpos = index($self->{"_LOOK"}, $pat)) > -1) {
		$got_match++;
		$before = substr ($self->{"_LOOK"}, 0, $mpos);
        	if ($mpos) {
        	    next if ($best_pos && ($mpos > $best_pos));
		    $best_pos = $mpos;
		    $best_pat = $pat;
		    $best_match = $pat;
		    $best_before = $before;
		    $mpos += length($pat);
		    $best_after = substr ($self->{"_LOOK"}, $mpos);
	    	} else {
	            $self->{"_LPATT"} = $pat;
		    $self->{"_LMATCH"} = $pat;
		    $before = substr ($self->{"_LOOK"}, 0, $mpos);
		    $mpos += length($pat);
	            $self->{"_LASTLOOK"} = substr ($self->{"_LOOK"}, $mpos);
		    $self->{"_LOOK"}     = "";
		    return $before;
		    # match at start will be best
		}
	    }
	    $count_in++;
	}
	if ($got_match) {
	    $self->{"_LPATT"} = $best_pat;
	    $self->{"_LMATCH"} = $best_match;
            $self->{"_LASTLOOK"} = $best_after;
	    $self->{"_LOOK"}     = "";
	    return $best_before;
        }
    }
    return "";
}

sub input {
    return undef unless (@_ == 1);
    my $self = shift;
    my $ok     = 0;
    my $result = "";
    my $wanted = 255;

    if (nocarp && $self->{"_T_INPUT"}) {
	$result = $self->{"_T_INPUT"};
	$self->{"_T_INPUT"} = "";
	return $result;
    }

    if ( $self->{"C_VMIN"} ) {
	$self->{"C_VMIN"} = 0;
	write_settings($self);
    }

    my $got = POSIX::read ($self->{FD}, $result, $wanted);

    unless (defined $got) { $got = -1; }
    if ($got == -1) {
	return "" if (&POSIX::EAGAIN == ($ok = POSIX::errno()));
	return "" if (0 == $ok);	# at least Solaris acts like eof()
	carp "Error #$ok in Device::SerialPort::input"
    }
    return $result;
}

sub write {
    return undef unless (@_ == 2);
    my $self = shift;
    my $wbuf = shift;
    my $ok;

    return 0 if ($wbuf eq "");
    my $lbuf = length ($wbuf);

    my $written = POSIX::write ($self->{FD}, $wbuf, $lbuf);

    return $written;
}

sub write_drain {
    my $self = shift;
    return if (@_);
    return 1 if (defined POSIX::tcdrain($self->{FD}));
    return;
}

sub purge_all {
    my $self = shift;
    return if (@_);
    return 1 if (defined POSIX::tcflush($self->{FD}, TCIOFLUSH));
    return;
}

sub purge_rx {
    my $self = shift;
    return if (@_);
    return 1 if (defined POSIX::tcflush($self->{FD}, TCIFLUSH));
    return;
}

sub purge_tx {
    my $self = shift;
    return if (@_);
    return 1 if (defined POSIX::tcflush($self->{FD}, TCOFLUSH));
    return;
}

sub buffer_max {
    my $self = shift;
    if (@_) {return undef; }
    return (4096, 4096);
}

  # true/false parameters

sub user_msg {
    my $self = shift;
    if (@_) { $self->{U_MSG} = yes_true ( shift ) }
    return wantarray ? @binary_opt : $self->{U_MSG};
}

sub error_msg {
    my $self = shift;
    if (@_) { $self->{E_MSG} = yes_true ( shift ) }
    return wantarray ? @binary_opt : $self->{E_MSG};
}

sub parity_enable {
    my $self = shift;
    if (@_) {
	if ( yes_true( shift ) ) {
	    $self->{"C_IFLAG"} |= PARMRK;
	    $self->{"C_CFLAG"} |= PARENB;
        } else {
	    $self->{"C_IFLAG"} &= ~PARMRK;
	    $self->{"C_CFLAG"} &= ~PARENB;
	}
	write_settings($self);
    }
    return wantarray ? @binary_opt : ($self->{"C_CFLAG"} & PARENB);
}

sub write_done {
    return unless (@_ == 2);
    return unless ($txdone && TIOCM_LE && $outcount);
    my $self = shift;
    my $wait = yes_true ( shift );
    $self->write_drain if ($wait);
    my $mstat = " ";
    my $result;
    for (;;) {
        ioctl($self->{HANDLE}, $outcount, $mstat) || return;
        $result = unpack('L', $mstat);
	return (0, 0) if ($result);	# characters pending
	ioctl($self->{HANDLE}, $txdone, $mstat) || return;
	$result = (unpack('L', $mstat) & TIOCM_LE);
	last unless ($wait);
	last if ($result);		# shift register empty
	select (undef, undef, undef, 0.02);
    }
    return $result ? (1, 0) : (0, 0);
}

sub modemlines {
    return undef unless (@_ == 1);
    return undef unless ($getstat);
    my $self = shift;
    my $mstat = pack('L',0);
    if (!ioctl($self->{HANDLE}, $getstat, $mstat)) {
	warn "modemlines ioctl failed: $!\n";
	return undef;
    }
    my $result = unpack('L', $mstat);
    if ($Babble) {
        printf "result = %x\n", $result;
        print "CTS is ON\n"		if ($result & MS_CTS_ON);
        print "DSR is ON\n"		if ($result & MS_DSR_ON);
        print "RING is ON\n"		if ($result & MS_RING_ON);
        print "RLSD is ON\n"		if ($result & MS_RLSD_ON);
    }
    return $result;
}

sub status {
    my $self = shift;
####    if (@_ and $testactive) {
####        $self->{"_LATCH"} |= shift;
####    }
    return if (@_);
    return unless ($incount && $outcount);
    my @stat = (0, 0, 0, 0);
    my $mstat = " ";

    ioctl($self->{HANDLE}, $incount, $mstat) || return;
    $stat[ST_INPUT] = unpack('L', $mstat);
    ioctl($self->{HANDLE}, $outcount, $mstat) || return;
    $stat[ST_OUTPUT] = unpack('L', $mstat);

    if ( $Babble or $self->{"_DEBUG"} ) {
        printf "Blocking Bits= %d\n", $stat[ST_BLOCK];
        printf "Input Queue= %d\n", $stat[ST_INPUT];
        printf "Output Queue= %d\n", $stat[ST_OUTPUT];
        printf "Latched Errors= %d\n", $stat[ST_ERROR];
    }
    return @stat;
}

sub dtr_active {
    return unless (@_ == 2);
    my $self = shift;
    return unless $self->can_ioctl();
    my $on = shift;
    my $rc;

    # if we have set DTR and clear DTR, we should use it (OpenBSD)
    if ($dtrset && $dtrclear) {
#        warn "SDTR/CDTR\n";
	$rc=ioctl($self->{HANDLE}, $on ? $dtrset : $dtrclear, 0);
    }
    else {
#        warn "BIS/BIC\n";
        $rc=ioctl($self->{HANDLE}, $on ? $bitset : $bitclear, $dtrout);
    }
    warn "dtr_active($on) ioctl: $!\n"    if (!$rc);
    return $rc;
}

sub rts_active {
    return unless (@_ == 2);
    my $self = shift;
    return unless ($self->can_rts());
    my $on = shift;
    # returns ioctl result
    my $rc=ioctl($self->{HANDLE}, $on ? $bitset : $bitclear, $rtsout);
    warn "rts_active($on) ioctl: $!\n" if (!$rc);
    return $rc; 
}

sub pulse_break_on {
    return unless (@_ == 2);
    my $self = shift;
    my $delay = (shift)/1000;
    my $length = 0;
    my $ok = POSIX::tcsendbreak($self->{FD}, $length);
    warn "could not pulse break on: $!\n" unless ($ok);
    select (undef, undef, undef, $delay);
    return $ok;
}

sub pulse_rts_on {
    return unless (@_ == 2);
    my $self = shift;
    return unless ($self->can_rts());
    my $delay = (shift)/1000;
    $self->rts_active(1) or warn "could not pulse rts on\n";
##    print "rts on\n"; ## DEBUG
    select (undef, undef, undef, $delay);
    $self->rts_active(0) or warn "could not restore from rts on\n";
##    print "rts_off\n"; ## DEBUG
    select (undef, undef, undef, $delay);
    1;
}

sub pulse_dtr_on {
    return unless (@_ == 2);
    my $self = shift;
    return unless $self->can_ioctl();
    my $delay = (shift)/1000;
    $self->dtr_active(1) or warn "could not pulse dtr on\n";
##    print "dtr on\n"; ## DEBUG
    select (undef, undef, undef, $delay);
    $self->dtr_active(0) or warn "could not restore from dtr on\n";
##    print "dtr_off\n"; ## DEBUG
    select (undef, undef, undef, $delay);
    1;
}

sub pulse_rts_off {
    return unless (@_ == 2);
    my $self = shift;
    return unless ($self->can_rts());
    my $delay = (shift)/1000;
    $self->rts_active(0) or warn "could not pulse rts off\n";
##    print "rts off\n"; ## DEBUG
    select (undef, undef, undef, $delay);
    $self->rts_active(1) or warn "could not restore from rts off\n";
##    print "rts on\n"; ## DEBUG
    select (undef, undef, undef, $delay);
    1;
}

sub pulse_dtr_off {
    return unless (@_ == 2);
    my $self = shift;
    return unless $self->can_ioctl();
    my $delay = (shift)/1000;
    $self->dtr_active(0) or warn "could not pulse dtr off\n";
##    print "dtr off\n"; ## DEBUG
    select (undef, undef, undef, $delay);
    $self->dtr_active(1) or warn "could not restore from dtr off\n";
##    print "dtr on\n"; ## DEBUG
    select (undef, undef, undef, $delay);
    1;
}

sub debug {
    my $self = shift;
    if (ref($self))  {
        if (@_) { $self->{"_DEBUG"} = yes_true ( shift ); }
        if (wantarray) { return @binary_opt; }
        else {
	    my $tmp = $self->{"_DEBUG"};
            nocarp || carp "Debug level: $self->{ALIAS} = $tmp";
            return $self->{"_DEBUG"};
        }
    } else {
        if (@_) { $Babble = yes_true ( shift ); }
        if (wantarray) { return @binary_opt; }
        else {
            nocarp || carp "Debug Class = $Babble";
            return $Babble;
        }
    }
}

sub close {
    my $self = shift;
    my $ok = undef;
    my $item;

    return unless (defined $self->{NAME});

    if ($Babble) {
        carp "Closing $self " . $self->{ALIAS};
    }
    if ($self->{FD}) {
        purge_all ($self);

	# copy the original values into "current" values
	foreach $item (keys %c_cc_fields) {
	    $self->{"C_$item"} = $self->{"_$item"};
	}

	$self->{"C_CFLAG"} = $self->{"_CFLAG"};
	$self->{"C_IFLAG"} = $self->{"_IFLAG"};
	$self->{"C_ISPEED"} = $self->{"_ISPEED"};
	$self->{"C_LFLAG"} = $self->{"_LFLAG"};
	$self->{"C_OFLAG"} = $self->{"_OFLAG"};
	$self->{"C_OSPEED"} = $self->{"_OSPEED"};
	
	write_settings($self);

        $ok = POSIX::close($self->{FD});
	# also closes $self->{HANDLE}

	$self->{FD} = undef;
    }
    if ($self->{LOCK}) {
	unless ( unlink $self->{LOCK} ) {
            nocarp or carp "can't remove lockfile: $self->{LOCK}\n"; 
	}
        $self->{LOCK} = "";
    }
    $self->{NAME} = undef;
    $self->{ALIAS} = undef;
    return unless ($ok);
    1;
}

##### tied FileHandle support
 
# DESTROY this
#      As with the other types of ties, this method will be called when the
#      tied handle is about to be destroyed. This is useful for debugging and
#      possibly cleaning up.

sub DESTROY {
    my $self = shift;
    return unless (defined $self->{NAME});
    if ($self->{"_DEBUG"}) {
        carp "Destroying $self->{NAME}";
    }
    $self->close;
}
 
sub TIEHANDLE {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    return unless (@_);

##    my $self = new($class, shift);
    my $self = start($class, shift);
    return $self;
}
 
# WRITE this, LIST
#      This method will be called when the handle is written to via the
#      syswrite function.

sub WRITE {
    return if (@_ < 3);
    my $self = shift;
    my $buf = shift;
    my $len = shift;
    my $offset = 0;
    if (@_) { $offset = shift; }
    my $out2 = substr($buf, $offset, $len);
    return unless ($self->post_print($out2));
    return length($out2);
}

# PRINT this, LIST
#      This method will be triggered every time the tied handle is printed to
#      with the print() function. Beyond its self reference it also expects
#      the list that was passed to the print function.
 
sub PRINT {
    my $self = shift;
    return unless (@_);
    my $ofs = $, ? $, : "";
    if ($self->{OFS}) { $ofs = $self->{OFS}; }
    my $ors = $\ ? $\ : "";
    if ($self->{ORS}) { $ors = $self->{ORS}; }
    my $output = join($ofs,@_);
    $output .= $ors;
    return $self->post_print($output);
}

sub output_field_separator {
    my $self = shift;
    my $prev = $self->{OFS};
    if (@_) { $self->{OFS} = shift; }
    return $prev;
}

sub output_record_separator {
    my $self = shift;
    my $prev = $self->{ORS};
    if (@_) { $self->{ORS} = shift; }
    return $prev;
}

sub post_print {
    my $self = shift;
    return unless (@_);
    my $output = shift;
##    if ($self->stty_opost) {
##	if ($self->stty_ocrnl) { $output =~ s/\r/\n/osg; }
##	if ($self->stty_onlcr) { $output =~ s/\n/\r\n/osg; }
##    }
    my $to_do = length($output);
    my $done = 0;
    my $written = 0;
    while ($done < $to_do) {
        my $out2 = substr($output, $done);
        $written = $self->write($out2);
	if (! defined $written) {
            return;
        }
	return 0 unless ($written);
	$done += $written;
    }
    1;
}
 
# PRINTF this, LIST
#      This method will be triggered every time the tied handle is printed to
#      with the printf() function. Beyond its self reference it also expects
#      the format and list that was passed to the printf function.
 
sub PRINTF {
    my $self = shift;
    my $fmt = shift;
    return unless ($fmt);
    return unless (@_);
    my $output = sprintf($fmt, @_);
    $self->PRINT($output);
}
 
# READ this, LIST
#      This method will be called when the handle is read from via the read
#      or sysread functions.

sub READ {
    return if (@_ < 3);
    my $buf = \$_[1];
    my ($self, $junk, $size, $offset) = @_;
    unless (defined $offset) { $offset = 0; }
    my $count_in = 0;
    my $string_in = "";

    ($count_in, $string_in) = $self->read($size);

    my $tail = substr($$buf, $offset + $count_in);
    my $head = substr($$buf, 0, $offset);
    $$buf = $head.$string_in.$tail;
    return $count_in;
}

# READLINE this
#      This method will be called when the handle is read from via <HANDLE>.
#      The method should return undef when there is no more data.
 
sub READLINE {
    my $self = shift;
    return if (@_);
    my $count_in = 0;
    my $string_in = "";
    my $match = "";
    my $was;

    if (wantarray) {
	my @lines;
        for (;;) {
            last if ($was = $self->reset_error);	# dummy, currently
	    if ($self->stty_icanon) {
	        ($count_in, $string_in) = $self->read_vmin(255);
                last if (! defined $count_in);
	    }
	    else {
                $string_in = $self->streamline($self->{"_SIZE"});
                last if (! defined $string_in);
	        $match = $self->matchclear;
                if ( ($string_in ne "") || ($match ne "") ) {
		    $string_in .= $match;
                }
	    }
            push (@lines, $string_in);
	    last if ($string_in =~ /$self->{"_CLASTLINE"}/s);
        }
	return @lines if (@lines);
        return;
    }
    else {
	my $last_icanon = $self->stty_icanon;
        $self->stty_icanon(1);
        for (;;) {
            last if ($was = $self->reset_error);	# dummy, currently
            $string_in = $self->lookfor($self->{"_SIZE"});
            last if (! defined $string_in);
	    $match = $self->matchclear;
            if ( ($string_in ne "") || ($match ne "") ) {
		$string_in .= $match; # traditional <HANDLE> behavior
	        $self->stty_icanon(0);
	        return $string_in;
	    }
        }
	$self->stty_icanon($last_icanon);
        return;
    }
}
 
# GETC this
#      This method will be called when the getc function is called.
 
sub GETC {
    my $self = shift;
    my ($count, $in) = $self->read(1);
    if ($count == 1) {
        return $in;
    }
    return;
}
 
# CLOSE this
#      This method will be called when the handle is closed via the close
#      function.
 
sub CLOSE {
    my $self = shift;
    $self->write_drain;
    my $success = $self->close;
    if ($Babble) { printf "CLOSE result:%d\n", $success; }
    return $success;
}
 
1;  # so the require or use succeeds

# Autoload methods go after =cut, and are processed by the autosplit program.

__END__

=pod

=head1 NAME

Device::SerialPort - Linux/POSIX emulation of Win32::SerialPort functions.

=head1 SYNOPSIS

  use Device::SerialPort qw( :PARAM :STAT 0.07 );

=head2 Constructors

       # $quiet and $lockfile are optional
  $PortObj = new Device::SerialPort ($PortName, $quiet, $lockfile)
       || die "Can't open $PortName: $!\n";

  $PortObj = start Device::SerialPort ($Configuration_File_Name)
       || die "Can't start $Configuration_File_Name: $!\n";

  $PortObj = tie (*FH, 'Device::SerialPort', $Configuration_File_Name)
       || die "Can't tie using $Configuration_File_Name: $!\n";

=head2 Configuration Utility Methods

  $PortObj->alias("MODEM1");

  $PortObj->save($Configuration_File_Name)
       || warn "Can't save $Configuration_File_Name: $!\n";

       # currently optional after new, POSIX version expected to succeed
  $PortObj->write_settings;

       # rereads file to either return open port to a known state
       # or switch to a different configuration on the same port
  $PortObj->restart($Configuration_File_Name)
       || warn "Can't reread $Configuration_File_Name: $!\n";

       # "app. variables" saved in $Configuration_File, not used internally
  $PortObj->devicetype('none');     # CM11, CM17, 'weeder', 'modem'
  $PortObj->hostname('localhost');  # for socket-based implementations
  $PortObj->hostaddr(0);            # false unless specified
  $PortObj->datatype('raw');        # in case an application needs_to_know
  $PortObj->cfg_param_1('none');    # null string '' hard to save/restore
  $PortObj->cfg_param_2('none');    # 3 spares should be enough for now
  $PortObj->cfg_param_3('none');    # one may end up as a log file path

      # test suite use only
  @necessary_param = Device::SerialPort->set_test_mode_active(1);

      # exported by :PARAM
  nocarp || carp "Something fishy";
  $a = SHORTsize;			# 0xffff
  $a = LONGsize;			# 0xffffffff
  $answer = yes_true("choice");		# 1 or 0
  OS_Error unless ($API_Call_OK);	# prints error

=head2 Configuration Parameter Methods

     # most methods can be called two ways:
  $PortObj->handshake("xoff");           # set parameter
  $flowcontrol = $PortObj->handshake;    # current value (scalar)

     # The only "list context" method calls from Win32::SerialPort
     # currently supported are those for baudrate, parity, databits,
     # stopbits, and handshake (which only accept specific input values).
  @handshake_opts = $PortObj->handshake; # permitted choices (list)

     # similar
  $PortObj->baudrate(9600);
  $PortObj->parity("odd");
  $PortObj->databits(8);
  $PortObj->stopbits(1);	# POSIX does not support 1.5 stopbits

     # these are essentially dummies in POSIX implementation
     # the calls exist to support compatibility
  $PortObj->buffers(4096, 4096);	# returns (4096, 4096)
  @max_values = $PortObj->buffer_max;	# returns (4096, 4096)
  $PortObj->reset_error;		# returns 0

     # true/false parameters (return scalar context only)
     # parameters exist, but message processing not yet fully implemented
  $PortObj->user_msg(ON);	# built-in instead of warn/die above
  $PortObj->error_msg(ON);	# translate error bitmasks and carp

  $PortObj->parity_enable(F);	# faults during input
  $PortObj->debug(0);

     # true/false capabilities (read only)
     # most are just constants in the POSIX case
  $PortObj->can_baud;			# 1
  $PortObj->can_databits;		# 1
  $PortObj->can_stopbits;		# 1
  $PortObj->can_dtrdsr;			# 1
  $PortObj->can_handshake;		# 1
  $PortObj->can_parity_check;		# 1
  $PortObj->can_parity_config;		# 1
  $PortObj->can_parity_enable;		# 1
  $PortObj->can_rlsd;    		# 0 currently
  $PortObj->can_16bitmode;		# 0 Win32-specific
  $PortObj->is_rs232;			# 1
  $PortObj->is_modem;			# 0 Win32-specific
  $PortObj->can_rtscts;			# 1
  $PortObj->can_xonxoff;		# 1
  $PortObj->can_xon_char;		# 1 use stty
  $PortObj->can_spec_char;		# 0 use stty
  $PortObj->can_interval_timeout;	# 0 currently
  $PortObj->can_total_timeout;		# 1 currently
  $PortObj->can_ioctl;			# automatically detected by eval
  $PortObj->can_status;			# automatically detected by eval
  $PortObj->can_write_done;		# automatically detected by eval

=head2 Operating Methods

  ($count_in, $string_in) = $PortObj->read($InBytes);
  warn "read unsuccessful\n" unless ($count_in == $InBytes);

  $count_out = $PortObj->write($output_string);
  warn "write failed\n"		unless ($count_out);
  warn "write incomplete\n"	if ( $count_out != length($output_string) );

  if ($string_in = $PortObj->input) { PortObj->write($string_in); }
     # simple echo with no control character processing

  $ModemStatus = $PortObj->modemlines;
  if ($ModemStatus & $PortObj->MS_RLSD_ON) { print "carrier detected"; }

  ($BlockingFlags, $InBytes, $OutBytes, $ErrorFlags) = $PortObj->status;
      # same format for compatibility. Only $InBytes and $OutBytes are
      # currently returned (on linux). Others are 0.
      # Check return value of "can_status" to see if this call is valid.

  ($done, $count_out) = $PortObj->write_done(0);
     # POSIX defaults to background write. Currently $count_out always 0.
     # $done set when hardware finished transmitting and shared line can
     # be released for other use. Ioctl may not work on all OSs.
     # Check return value of "can_write_done" to see if this call is valid.

  $PortObj->write_drain;  # POSIX alternative to Win32 write_done(1)
                          # set when software is finished transmitting
  $PortObj->purge_all;
  $PortObj->purge_rx;
  $PortObj->purge_tx;

      # controlling outputs from the port
  $PortObj->dtr_active(T);		# sends outputs direct to hardware
  $PortObj->rts_active(Yes);		# return status of ioctl call
					# return undef on failure

  $PortObj->pulse_break_on($milliseconds); # off version is implausible
  $PortObj->pulse_rts_on($milliseconds);
  $PortObj->pulse_rts_off($milliseconds);
  $PortObj->pulse_dtr_on($milliseconds);
  $PortObj->pulse_dtr_off($milliseconds);
      # sets_bit, delays, resets_bit, delays
      # returns undef if unsuccessful or ioctls not implemented

  $PortObj->read_const_time(100);	# const time for read (milliseconds)
  $PortObj->read_char_time(5);		# avg time between read char

  $milliseconds = $PortObj->get_tick_count;

=head2 Methods used with Tied FileHandles

  $PortObj = tie (*FH, 'Device::SerialPort', $Configuration_File_Name)
       || die "Can't tie: $!\n";             ## TIEHANDLE ##

  print FH "text";                           ## PRINT     ##
  $char = getc FH;                           ## GETC      ##
  syswrite FH, $out, length($out), 0;        ## WRITE     ##
  $line = <FH>;                              ## READLINE  ##
  @lines = <FH>;                             ## READLINE  ##
  printf FH "received: %s", $line;           ## PRINTF    ##
  read (FH, $in, 5, 0) or die "$!";          ## READ      ##
  sysread (FH, $in, 5, 0) or die "$!";       ## READ      ##
  close FH || warn "close failed";           ## CLOSE     ##
  undef $PortObj;
  untie *FH;                                 ## DESTROY   ##

  $PortObj->linesize(10);		     # with READLINE
  $PortObj->lastline("_GOT_ME_");	     # with READLINE, list only

      ## with PRINT and PRINTF, return previous value of separator
  $old_ors = $PortObj->output_record_separator("RECORD");
  $old_ofs = $PortObj->output_field_separator("COMMA");

=head2 Destructors

  $PortObj->close || warn "close failed";
      # release port to OS - needed to reopen
      # close will not usually DESTROY the object
      # also called as: close FH || warn "close failed";

  undef $PortObj;
      # preferred unless reopen expected since it triggers DESTROY
      # calls $PortObj->close but does not confirm success
      # MUST precede untie - do all three IN THIS SEQUENCE before re-tie.

  untie *FH;

=head2 Methods for I/O Processing

  $PortObj->are_match("text", "\n");	# possible end strings
  $PortObj->lookclear;			# empty buffers
  $PortObj->write("Feed Me:");		# initial prompt
  $PortObj->is_prompt("More Food:");	# not implemented

  my $gotit = "";
  until ("" ne $gotit) {
      $gotit = $PortObj->lookfor;	# poll until data ready
      die "Aborted without match\n" unless (defined $gotit);
      sleep 1;				# polling sample time
  }

  printf "gotit = %s\n", $gotit;		# input BEFORE the match
  my ($match, $after, $pattern, $instead) = $PortObj->lastlook;
      # input that MATCHED, input AFTER the match, PATTERN that matched
      # input received INSTEAD when timeout without match
  printf "lastlook-match = %s  -after = %s  -pattern = %s\n",
                           $match,      $after,        $pattern;

  $gotit = $PortObj->lookfor($count);	# block until $count chars received

  $PortObj->are_match("-re", "pattern", "text");
      # possible match strings: "pattern" is a regular expression,
      #                         "text" is a literal string

=head1 DESCRIPTION

This module provides an object-based user interface essentially
identical to the one provided by the Win32::SerialPort module.

=head2 Initialization

The primary constructor is B<new> with a F<PortName> specified. This
will open the port and create the object. The port is not yet ready
for read/write access. First, the desired I<parameter settings> must
be established. Since these are tuning constants for an underlying
hardware driver in the Operating System, they are all checked for
validity by the methods that set them. The B<write_settings> method
updates the port (and will return True under POSIX). Ports are opened
for binary transfers. A separate C<binmode> is not needed.

  $PortObj = new Device::SerialPort ($PortName, $quiet, $lockfile)
       || die "Can't open $PortName: $!\n";

There are two optional parameters for B<new>. Failure to open a port
prints an error message to STDOUT by default. Since other applications
can use the port, one source of failure is "port in use". There was
originally no way to check this without getting a "fail message".
Setting C<$quiet> disables this built-in message. It also returns 0
instead of C<undef> if the port is unavailable (still FALSE, used for
testing this condition - other faults may still return C<undef>).
Use of C<$quiet> only applies to B<new>.

The C<$lockfile> parameter has a related purpose. It will attempt to
create a file (containing just the current process id) at the location
specified. This file will be automatically deleted when the C<$PortObj>
is no longer used (by DESTROY). You would usually request C<$lockfile>
with C<$quiet> true to disable messages while attempting to obtain
exclusive ownership of the port via the lock. Lockfiles are experimental
in Version 0.07. They are intended for use with other applications. No
attempt is made to resolve port aliases (/dev/modem == /dev/ttySx) or
to deal with login processes such as getty and uugetty.

The second constructor, B<start> is intended to simplify scripts which
need a constant setup. It executes all the steps from B<new> to
B<write_settings> based on a previously saved configuration. This
constructor will return C<undef> on a bad configuration file or failure
of a validity check. The returned object is ready for access. This is
new and experimental for Version 0.055.

  $PortObj2 = start Device::SerialPort ($Configuration_File_Name)
       || die;

The third constructor, B<tie>, will combine the B<start> with Perl's
support for tied FileHandles (see I<perltie>). Device::SerialPort will
implement the complete set of methods: TIEHANDLE, PRINT, PRINTF,
WRITE, READ, GETC, READLINE, CLOSE, and DESTROY. Tied FileHandle
support is new with Version 0.04 and the READ and READLINE methods
were added in Version 0.06. In "scalar context", READLINE sets B<stty_icanon>
to do character processing and calls B<lookfor>. It restores B<stty_icanon>
after the read. In "list context", READLINE does Canonical (line) reads if
B<stty_icanon> is set or calls B<streamline> if it is not. (B<stty_icanon>
is not altered). The B<streamline> choice allows duplicating the operation
of Win32::SerialPort for cross-platform scripts. 

The implementation attempts to mimic STDIN/STDOUT behaviour as closely
as possible: calls block until done and data strings that exceed internal
buffers are divided transparently into multiple calls. In Version 0.06,
the output separators C<$,> and C<$\> are also applied to PRINT if set.
The B<output_record_separator> and B<output_field_separator> methods can set
I<Port-FileHandle-Specific> versions of C<$,> and C<$\> if desired. Since
PRINTF is treated internally as a single record PRINT, C<$\> will be applied.
Output separators are not applied to WRITE (called as
C<syswrite FH, $scalar, $length, [$offset]>).
The input_record_separator C<$/> is not explicitly supported - but an
identical function can be obtained with a suitable B<are_match> setting.

  $PortObj2 = tie (*FH, 'Device::SerialPort', $Configuration_File_Name)
       || die;

The tied FileHandle methods may be combined with the Device::SerialPort
methods for B<read, input>, and B<write> as well as other methods. The
typical restrictions against mixing B<print> with B<syswrite> do not
apply. Since both B<(tied) read> and B<sysread> call the same C<$ob-E<gt>READ>
method, and since a separate C<$ob-E<gt>read> method has existed for some
time in Device::SerialPort, you should always use B<sysread> with the
tied interface (when it is implemented).

=over 8

Certain parameters I<SHOULD> be set before executing B<write_settings>.
Others will attempt to deduce defaults from the hardware or from other
parameters. The I<Required> parameters are:

=item baudrate

Any legal value.

=item parity

One of the following: "none", "odd", "even".
If you select anything except "none", you will need to set B<parity_enable>.

=item databits

An integer from 5 to 8.

=item stopbits

Legal values are 1 and 2.

=item handshake

One of the following: "none", "rts", "xoff".

=back

Some individual parameters (eg. baudrate) can be changed after the
initialization is completed. These will be validated and will
update the I<serial driver> as required. The B<save> method will
write the current parameters to a file that B<start, tie,> and
B<restart> can use to reestablish a functional setup.

  $PortObj = new Win32::SerialPort ($PortName, $quiet)
       || die "Can't open $PortName: $^E\n";    # $quiet is optional

  $PortObj->user_msg(ON);
  $PortObj->databits(8);
  $PortObj->baudrate(9600);
  $PortObj->parity("none");
  $PortObj->stopbits(1);
  $PortObj->handshake("rts");

  $PortObj->write_settings || undef $PortObj;

  $PortObj->save($Configuration_File_Name);
  $PortObj->baudrate(300);
  $PortObj->restart($Configuration_File_Name);	# back to 9600 baud

  $PortObj->close || die "failed to close";
  undef $PortObj;				# frees memory back to perl

=head2 Configuration Utility Methods

Use B<alias> to convert the name used by "built-in" messages.

  $PortObj->alias("MODEM1");

Starting in Version 0.07, a number of I<Application Variables> are saved
in B<$Configuration_File>. These parameters are not used internally. But
methods allow setting and reading them. The intent is to facilitate the
use of separate I<configuration scripts> to create the files. Then an
application can use B<start> as the Constructor and not bother with
command line processing or managing its own small configuration file.
The default values and number of parameters is subject to change.

  $PortObj->devicetype('none'); 
  $PortObj->hostname('localhost');  # for socket-based implementations
  $PortObj->hostaddr(0);            # a "false" value
  $PortObj->datatype('raw');        # 'record' is another possibility
  $PortObj->cfg_param_1('none');
  $PortObj->cfg_param_2('none');    # 3 spares should be enough for now
  $PortObj->cfg_param_3('none');

=head2 Configuration and Capability Methods

The Win32 Serial Comm API provides extensive information concerning
the capabilities and options available for a specific port (and
instance). This module will return suitable responses to facilitate
porting code from that environment.

The B<get_tick_count> method is a clone of the I<Win32::GetTickCount()>
function. It matches a corresponding method in I<Win32::CommPort>.
It returns time in milliseconds - but can be used in cross-platform scripts.

=over 8

Binary selections will accept as I<true> any of the following:
C<("YES", "Y", "ON", "TRUE", "T", "1", 1)> (upper/lower/mixed case)
Anything else is I<false>.

There are a large number of possible configuration and option parameters.
To facilitate checking option validity in scripts, most configuration
methods can be used in two different ways:

=item method called with an argument

The parameter is set to the argument, if valid. An invalid argument
returns I<false> (undef) and the parameter is unchanged. The function
will also I<carp> if B<$user_msg> is I<true>. The port will be updated
immediately if allowed (an automatic B<write_settings> is called).

=item method called with no argument in scalar context

The current value is returned. If the value is not initialized either
directly or by default, return "undef" which will parse to I<false>.
For binary selections (true/false), return the current value. All
current values from "multivalue" selections will parse to I<true>.

=item method called with no argument in list context

Methods which only accept a limited number of specific input values
return a list consisting of all acceptable choices. The null list
C<(undef)> will be returned for failed calls in list context (e.g. for
an invalid or unexpected argument). Only the baudrate, parity, databits,
stopbits, and handshake methods currently support this feature.

=back

=head2 Operating Methods

Version 0.04 adds B<pulse> methods for the I<RTS, BREAK, and DTR> bits. The
B<pulse> methods assume the bit is in the opposite state when the method
is called. They set the requested state, delay the specified number of
milliseconds, set the opposite state, and again delay the specified time.
These methods are designed to support devices, such as the X10 "FireCracker"
control and some modems, which require pulses on these lines to signal
specific events or data. Timing for the I<active> part of B<pulse_break_on>
is handled by I<POSIX::tcsendbreak(0)>, which sends a 250-500 millisecond
BREAK pulse. It is I<NOT> guaranteed to block until done.

  $PortObj->pulse_break_on($milliseconds);
  $PortObj->pulse_rts_on($milliseconds);
  $PortObj->pulse_rts_off($milliseconds);
  $PortObj->pulse_dtr_on($milliseconds);
  $PortObj->pulse_dtr_off($milliseconds);

In Version 0.05, these calls and the B<rts_active> and B<dtr_active> calls
verify the parameters and any required I<ioctl constants>, and return C<undef>
unless the call succeeds. You can use the B<can_ioctl> method to see if
the required constants are available. On Version 0.04, the module would
not load unless I<asm/termios.ph> was found at startup.

=head2 Stty Shortcuts

Version 0.06 adds primitive methods to modify port parameters that would
otherwise require a C<system("stty...");> command. These act much like
the identically-named methods in Win32::SerialPort. However, they are
initialized from "current stty settings" when the port is opened rather
than from defaults. And like I<stty settings>, they are passed to the
serial driver and apply to all operations rather than only to I/O
processed via the B<lookfor> method or the I<tied FileHandle> methods.
Each returns the current setting for the parameter. There are no "global"
or "combination" parameters - you still need C<system("stty...")> for that.

The methods which handle CHAR parameters set and return values as C<ord(CHAR)>.
This corresponds to the settings in the I<POSIX termios cc_field array>. You
are unlikely to actually want to modify most of these. They reflect the
special characters which can be set by I<stty>.

  $PortObj->is_xon_char($num_char);	# VSTART (stty start=.)
  $PortObj->is_xoff_char($num_char);	# VSTOP
  $PortObj->is_stty_intr($num_char);	# VINTR
  $PortObj->is_stty_quit($num_char);	# VQUIT
  $PortObj->is_stty_eof($num_char);	# VEOF
  $PortObj->is_stty_eol($num_char);	# VEOL
  $PortObj->is_stty_erase($num_char);	# VERASE
  $PortObj->is_stty_kill($num_char);	# VKILL
  $PortObj->is_stty_susp($num_char);	# VSUSP

Binary settings supported by POSIX will return 0 or 1. Several parameters
settable by I<stty> do not yet have shortcut methods. Contact me if you
need one that is not supported. These are the common choices. Try C<man stty>
if you are not sure what they do.

  $PortObj->stty_echo;
  $PortObj->stty_echoe;
  $PortObj->stty_echok;
  $PortObj->stty_echonl;
  $PortObj->stty_istrip;
  $PortObj->stty_icrnl;
  $PortObj->stty_igncr;
  $PortObj->stty_inlcr;
  $PortObj->stty_opost;
  $PortObj->stty_isig;
  $PortObj->stty_icanon;

The following methods require successfully loading I<ioctl constants>.
They will return C<undef> if the needed constants are not found. But
the method calls may still be used without syntax errors or warnings
even in that case.

  $PortObj->stty_ocrlf;
  $PortObj->stty_onlcr;
  $PortObj->stty_echoke;
  $PortObj->stty_echoctl;

=head2 Lookfor and I/O Processing 

Some communications programs have a different need - to collect
(or discard) input until a specific pattern is detected. For lines, the
pattern is a line-termination. But there are also requirements to search
for other strings in the input such as "username:" and "password:". The
B<lookfor> method provides a consistant mechanism for solving this problem.
It searches input character-by-character looking for a match to any of the
elements of an array set using the B<are_match> method. It returns the
entire input up to the match pattern if a match is found. If no match
is found, it returns "" unless an input error or abort is detected (which
returns undef).

Unlike Win32::SerialPort, B<lookfor> does not handle backspace, echo, and
other character processing. It expects the serial driver to handle those
and to be controlled via I<stty>. For interacting with humans, you will
probably want C<stty_icanon(1)> during B<lookfor> to obtain familiar
command-line response. The actual match and the characters after it (if
any) may also be viewed using the B<lastlook> method. It also adopts the
convention from Expect.pm that match strings are literal text (tested using
B<index>) unless preceeded in the B<are_match> list by a B<"-re",> entry.
The default B<are_match> list is C<("\n")>, which matches complete lines.

   my ($match, $after, $pattern, $instead) = $PortObj->lastlook;
     # input that MATCHED, input AFTER the match, PATTERN that matched
     # input received INSTEAD when timeout without match ("" if match)

   $PortObj->are_match("text1", "-re", "pattern", "text2");
     # possible match strings: "pattern" is a regular expression,
     #                         "text1" and "text2" are literal strings

Everything in B<lookfor> is still experimental. Please let me know if you
use it (or can't use it), so I can confirm bug fixes don't break your code.
For literal strings, C<$match> and C<$pattern> should be identical. The
C<$instead> value returns the internal buffer tested by the match logic.
A successful match or a B<lookclear> resets it to "" - so it is only useful
for error handling such as timeout processing or reporting unexpected
responses.

The B<lookfor> method is designed to be sampled periodically (polled). Any
characters after the match pattern are saved for a subsequent B<lookfor>.
Internally, B<lookfor> is implemented using the nonblocking B<input> method
when called with no parameter. If called with a count, B<lookfor> calls
C<$PortObj-E<gt>read(count)> which blocks until the B<read> is I<Complete> or
a I<Timeout> occurs. The blocking alternative should not be used unless a
fault time has been defined using B<read_interval, read_const_time, and
read_char_time>. It exists mostly to support the I<tied FileHandle>
functions B<sysread, getc,> and B<E<lt>FHE<gt>>. When B<stty_icanon> is
active, even the non-blocking calls will not return data until the line
is complete.

The internal buffers used by B<lookfor> may be purged by the B<lookclear>
method (which also clears the last match). For testing, B<lookclear> can
accept a string which is "looped back" to the next B<input>. This feature
is enabled only when C<set_test_mode_active(1)>. Normally, B<lookclear>
will return C<undef> if given parameters. It still purges the buffers and
last_match in that case (but nothing is "looped back"). You will want
B<stty_echo(0)> when exercising loopback.

The B<matchclear> method is designed to handle the
"special case" where the match string is the first character(s) received
by B<lookfor>. In this case, C<$lookfor_return == "">, B<lookfor> does
not provide a clear indication that a match was found. The B<matchclear>
returns the same C<$match> that would be returned by B<lastlook> and
resets it to "" without resetting any of the other buffers. Since the
B<lookfor> already searched I<through> the match, B<matchclear> is used
to both detect and step-over "blank" lines.

The character-by-character processing used by B<lookfor> is fine for
interactive activities and tasks which expect short responses. But it
has too much "overhead" to handle fast data streams.There is also a
B<streamline> method which is a fast, line-oriented alternative with
just pattern searching. Since B<streamline> uses the same internal buffers,
the B<lookclear, lastlook, are_match, and matchclear> methods act the same
in both cases. In fact, calls to B<streamline> and B<lookfor> can be
interleaved if desired (e.g. an interactive task that starts an upload and
returns to interactive activity when it is complete).

There are two additional methods for supporting "list context" input:
B<lastline> sets an "end_of_file" I<Regular Expression>, and B<linesize>
permits changing the "packet size" in the blocking read operation to allow
tuning performance to data characteristics. These two only apply during
B<READLINE>. The default for B<linesize> is 1. There is no default for
the B<lastline> method.

The I<Regular Expressions> set by B<are_match> and B<lastline>
will be pre-compiled using the I<qr//> construct on Perl 5.005 and higher.
This doubled B<lookfor> and B<streamline> speed in my tests with
I<Regular Expressions> - but actual improvements depend on both patterns
and input data.

The functionality of B<lookfor> includes a limited subset of the capabilities
found in Austin Schutz's I<Expect.pm> for Unix (and Tcl's expect which it
resembles). The C<$before, $match, $pattern, and $after> return values are
available if someone needs to create an "expect" subroutine for porting a
script. When using multiple patterns, there is one important functional
difference: I<Expect.pm> looks at each pattern in turn and returns the first
match found; B<lookfor> and B<streamline> test all patterns and return the
one found I<earliest> in the input if more than one matches.

=head2 Exports

Nothing is exported by default. The following tags can be used to have
large sets of symbols exported:

=over 4

=item :PARAM

Utility subroutines and constants for parameter setting and test:

	LONGsize	SHORTsize	nocarp		yes_true
	OS_Error

=item :STAT

The Constants named BM_* and CE_* are omitted. But the MS_*
Constants are defined for possible use with B<modemlines>. They are
assigned to corresponding functions, but the bit position will be
different from that on Win32.

Which incoming bits are active:

	MS_CTS_ON	MS_DSR_ON	MS_RING_ON	MS_RLSD_ON

Offsets into the array returned by B<status:>

	ST_BLOCK	ST_INPUT	ST_OUTPUT	ST_ERROR

=item :ALL

All of the above. Except for the I<test suite>, there is not really a good
reason to do this.

=back

=head1 NOTES

The object returned by B<new> is NOT a I<Filehandle>. You will be
disappointed if you try to use it as one.

e.g. the following is WRONG!!____C<print $PortObj "some text";>

This module uses I<POSIX termios> extensively. Raw API calls are B<very>
unforgiving. You will certainly want to start perl with the B<-w> switch.
If you can, B<use strict> as well. Try to ferret out all the syntax and
usage problems BEFORE issuing the API calls (many of which modify tuning
constants in hardware device drivers....not where you want to look for bugs).

With all the options, this module needs a good tutorial. It doesn't
have one yet.

=head1 KNOWN LIMITATIONS

The current version of the module has been tested with Perl 5.003 and
above. It was initially ported from Win32 and was designed to be used
without requiring a compiler or using XS. Since everything is (sometimes
convoluted but still pure) Perl, you can fix flaws and change limits if
required. But please file a bug report if you do.

The B<read> method, and tied methods which call it, currently can use a
fixed timeout which approximates behavior of the I<Win32::SerialPort>
B<read_const_time> and B<read_char_time> methods. It is used internally
by I<select>. If the timeout is set to zero, the B<read> call will return
immediately. A B<read> larger than 255 bytes will be split internally
into 255-byte POSIX calls due to limitations of I<select> and I<VMIN>.
The timeout is reset for each 255-byte segment. Hence, for large B<reads>,
use a B<read_const_time> suitable for a 255-byte read. All of this is
expeimental in Version 0.055.

  $PortObj->read_const_time(500);	# 500 milliseconds = 0.5 seconds
  $PortObj->read_char_time(5);		# avg time between read char

The timing model defines the total time allowed to complete the operation.
A fixed overhead time is added to the product of bytes and per_byte_time.

Read_Total = B<read_const_time> + (B<read_char_time> * bytes_to_read)

Write timeouts and B<read_interval> timeouts are not currently supported.

=head1 BUGS

See the limitations about lockfiles. Experiment if you like.

The location of C<termios.ph> is different on other Operating Systems.
Some may not have it at all or may use a different name. Please report
locations you find which differ from this so I can add them to later
versions.

With all the I<currently unimplemented features>, we don't need any more.
But there probably are some.

__Please send comments and bug reports to wcbirthisel@alum.mit.edu.

=head1 Win32::SerialPort & Win32API::CommPort

=head2 Win32::SerialPort Functions Not Currently Supported

  $LatchErrorFlags = $PortObj->reset_error;

  $PortObj->read_interval(100);		# max time between read char
  $PortObj->write_char_time(5);
  $PortObj->write_const_time(100);

=head2 Functions Handled in a POSIX system by "stty"

	xon_limit	xoff_limit	xon_char	xoff_char
	eof_char	event_char	error_char	stty_intr
	stty_quit	stty_eof	stty_eol	stty_erase
	stty_kill	stty_clear	is_stty_clear	stty_bsdel	
	stty_echoke	stty_echoctl	stty_ocrnl	stty_onlcr	

=head2 Win32::SerialPort Functions Not Ported to POSIX

	transmit_char

=head2 Win32API::CommPort Functions Not Ported to POSIX

	init_done	fetch_DCB	update_DCB	initialize
	are_buffers	are_baudrate	are_handshake	are_parity
	are_databits	are_stopbits	is_handshake	xmit_imm_char
	is_baudrate	is_parity	is_databits	is_write_char_time
	debug_comm	is_xon_limit	is_xoff_limit	is_read_const_time
	suspend_tx	is_eof_char	is_event_char	is_read_char_time
	is_read_buf	is_write_buf	is_buffers	is_read_interval
	is_error_char	resume_tx	is_stopbits	is_write_const_time
	is_binary	is_status	write_bg	is_parity_enable
	is_modemlines	read_bg		read_done	break_active
	xoff_active	is_read_buf	is_write_buf	xon_active

=head2 "raw" Win32 API Calls and Constants

A large number of Win32-specific elements have been omitted. Most of
these are only available in Win32::SerialPort and Win32API::CommPort
as optional Exports. The list includes the following:

=over 4

=item :RAW

The API Wrapper Methods and Constants used only to support them
including PURGE_*, SET*, CLR*, EV_*, and ERROR_IO*

=item :COMMPROP

The Constants used for Feature and Properties Detection including
BAUD_*, PST_*, PCF_*, SP_*, DATABITS_*, STOPBITS_*, PARITY_*, and 
COMMPROP_INITIALIZED

=item :DCB

The constants for the I<Win32 Device Control Block> including
CBR_*, DTR_*, RTS_*, *PARITY, *STOPBIT*, and FM_*

=back

=head2 Compatibility

This code implements the functions required to support the MisterHouse
Home Automation software by Bruce Winter. It does not attempt to support
functions from Win32::SerialPort such as B<stty_emulation> that already
have POSIX implementations or to replicate I<Win32 idosyncracies>. However,
the supported functions are intended to clone the equivalent functions
in Win32::SerialPort and Win32API::CommPort. Any discrepancies or
omissions should be considered bugs and reported to the maintainer.

=head1 AUTHORS

Based on Win32::SerialPort.pm, Version 0.8, by Bill Birthisel

Ported to linux/POSIX by Joe Doss for MisterHouse
Ported to Solaris/POSIX by Kees Cook for Sendpage
Ported to BSD/POSIX by Kees Cook for Sendpage

Currently maintained by:
Kees Cook, cook@cpoint.net, http://outflux.net/

=head1 SEE ALSO

Win32API::CommPort

Win32::SerialPort

Perltoot.xxx - Tom (Christiansen)'s Object-Oriented Tutorial

=head1 COPYRIGHT

Copyright (C) 1999, Bill Birthisel. All rights reserved.

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut
