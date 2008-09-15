package ExtUtils::TBone;


=head1 NAME

ExtUtils::TBone - a "skeleton" for writing "t/*.t" test files.


=head1 SYNOPSIS

Include a copy of this module in your t directory (as t/ExtUtils/TBone.pm),
and then write your t/*.t files like this:

    use lib "./t";             # to pick up a ExtUtils::TBone
    use ExtUtils::TBone;

    # Make a tester... here are 3 different alternatives:
    my $T = typical ExtUtils::TBone;                 # standard log
    my $T = new ExtUtils::TBone;                     # no log 
    my $T = new ExtUtils::TBone "testout/Foo.tlog";  # explicit log
    
    # Begin testing, and expect 3 tests in all:
    $T->begin(3);                           # expect 3 tests
    $T->msg("Something for the log file");  # message for the log
    
    # Run some tests:    
    $T->ok($this);                  # test 1: no real info logged
    $T->ok($that,                   # test 2: logs a comment
	   "Is that ok, or isn't it?"); 
    $T->ok(($this eq $that),        # test 3: logs comment + vars 
	   "Do they match?",
	   This => $this,
	   That => $that);
     
    # That last one could have also been written... 
    $T->ok_eq($this, $that);            # does 'eq' and logs operands
    $T->ok_eqnum($this, $that);         # does '==' and logs operands 
     
    # End testing:
    $T->end;   


=head1 DESCRIPTION

This module is intended for folks who release CPAN modules with 
"t/*.t" tests.  It makes it easy for you to output syntactically
correct test-output while at the same time logging all test
activity to a log file.  Hopefully, bug reports which include
the contents of this file will be easier for you to investigate.


=head1 LOG FILE

A typical log file output by this module looks like this:

    1..3
     
    ** A message logged with msg().
    ** Another one.
    1: My first test, using test(): how'd I do?
    1: ok 1
    
    ** Yet another message.
    2: My second test, using test_eq()...
    2: A: The first string
    2: B: The second string
    2: not ok 2
    
    3: My third test.
    3: ok 3
    
    END

Each test() is logged with the test name and results, and
the test-number prefixes each line.
This allows you to scan a large file easily with "grep" (or, ahem, "perl").
A blank line follows each test's record, for clarity.


=head1 PUBLIC INTERFACE

=cut

# Globals:
use strict;
use vars qw($VERSION);
use FileHandle;
use File::Basename;

# The package version, both in 1.23 style *and* usable by MakeMaker:
$VERSION = substr q$Revision: 1.1.1.1 $, 10;



#------------------------------

=head2 Construction

=over 4

=cut

#------------------------------

=item new [ARGS...]

I<Class method, constructor.>
Create a new tester.  Any arguments are sent to log_open().

=cut

sub new {
    my $self = bless {
	OUT  =>\*STDOUT,
	Begin=>0,
	End  =>0,
	Count=>0,
    }, shift;
    $self->log_open(@_) if @_;
    $self;
}

#------------------------------

=item typical

I<Class method, constructor.>
Create a typical tester.  Use this instead of new() for most applicaitons.
The directory "testout" is created for you automatically, to hold
the output log file.

=cut

sub typical {
    my $class = shift;
    my ($tfile) = basename $0;
    unless (-d "testout") {
	mkdir "testout", 0755 
	    or die "Couldn't create a 'testout' subdirectory: $!\n";
	### warn "$class: created 'testout' directory\n";
    }
    $class->new($class->catfile('.', 'testout', "${tfile}log"));
}

#------------------------------
# DESTROY
#------------------------------
# Class method, destructor.
# Automatically closes the log.
#
sub DESTROY {
    $_[0]->log_close;
}


#------------------------------

=back

=head2 Doing tests

=over 4

=cut

#------------------------------

=item begin NUMTESTS

I<Instance method.>
Start testing.

=cut

sub begin {
    my ($self, $n) = @_;
    return if $self->{Begin}++;
    $self->l_print("1..$n\n\n");
    print {$self->{OUT}} "1..$n\n";
}

#------------------------------

=item end

I<Instance method.>
End testing.

=cut

sub end {
    my ($self) = @_;
    return if $self->{End}++;
    $self->l_print("END\n");
    print {$self->{OUT}} "END\n";
}

#------------------------------

=item ok BOOL, [TESTNAME], [PARAMHASH...]

I<Instance method.>
Do a test, and log some information connected with it.
Use it like this:

    $T->ok(-e $dotforward);

Or better yet, like this:

    $T->ok((-e $dotforward), 
	   "Does the user have a .forward file?");

Or even better, like this:

    $T->ok((-e $dotforward), 
	   "Does the user have a .forward file?",
	   User => $ENV{USER},
	   Path => $dotforward,
	   Fwd  => $ENV{FWD});

That last one, if it were test #3, would be logged as:

    3: Does the user have a .forward file?
    3:   User: "alice"
    3:   Path: "/home/alice/.forward"
    3:   Fwd: undef
    3: ok

You get the idea.  Note that defined quantities are logged with delimiters 
and with all nongraphical characters suitably escaped, so you can see 
evidence of unexpected whitespace and other badnasties.  
Had "Fwd" been the string "this\nand\nthat", you'd have seen:

    3:   Fwd: "this\nand\nthat"

And unblessed array refs like ["this", "and", "that"] are 
treated as multiple values:

    3:   Fwd: "this"
    3:   Fwd: "and"
    3:   Fwd: "that"

=cut

sub ok { 
    my ($self, $ok, $test, @ps) = @_;
    ++($self->{Count});      # next test

    # Report to harness:
    my $status = ($ok ? "ok " : "not ok ") . $self->{Count};
    print {$self->{OUT}} $status, "\n";

    # Log:
    $self->ln_print($test, "\n") if $test;
    while (@ps) {
	my ($k, $v) = (shift @ps, shift @ps);
	my @vs = ((ref($v) and (ref($v) eq 'ARRAY'))? @$v : ($v));
	foreach (@vs) { 
	    if (!defined($_)) {  # value not defined: output keyword
		$self->ln_print(qq{  $k: undef\n});
	    }
	    else {               # value defined: output quoted, encoded form
		s{([\n\t\x00-\x1F\x7F-\xFF\\\"])}
                 {'\\'.sprintf("%02X",ord($1)) }exg;
	        s{\\0A}{\\n}g;
	        $self->ln_print(qq{  $k: "$_"\n});
            }
	}
    }
    $self->ln_print($status, "\n");
    $self->l_print("\n");
    1;
}


#------------------------------

=item ok_eq ASTRING, BSTRING, [TESTNAME], [PARAMHASH...]

I<Instance method.>  
Convenience front end to ok(): test whether C<ASTRING eq BSTRING>, and
logs the operands as 'A' and 'B'.

=cut

sub ok_eq {
    my ($self, $this, $that, $test, @ps) = @_;
    $self->ok(($this eq $that), 
	      ($test || "(Is 'A' string-equal to 'B'?)"),
	      A => $this,
	      B => $that,
	      @ps);
}


#------------------------------

=item ok_eqnum ANUM, BNUM, [TESTNAME], [PARAMHASH...]

I<Instance method.>  
Convenience front end to ok(): test whether C<ANUM == BNUM>, and
logs the operands as 'A' and 'B'.  

=cut

sub ok_eqnum {
    my ($self, $this, $that, $test, @ps) = @_;
    $self->ok(($this == $that), 
	      ($test || "(Is 'A' numerically-equal to 'B'?)"),
	      A => $this,
	      B => $that,
	      @ps);
}

#------------------------------

=back

=head2 Logging messages

=over 4

=cut

#------------------------------

=item log_open PATH

I<Instance method.>
Open a log file for messages to be output to.  This is invoked
for you automatically by C<new(PATH)> and C<typical()>.

=cut

sub log_open {
    my ($self, $path) = @_;
    $self->{LogPath} = $path;
    $self->{LOG} = FileHandle->new(">$path") || die "open $path: $!";
    $self;
}

#------------------------------

=item log_close

I<Instance method.>
Close the log file and stop logging.  
You shouldn't need to invoke this directly; the destructor does it.

=cut

sub log_close {
    my $self = shift;
    close(delete $self->{LOG}) if $self->{LOG};
}

#------------------------------

=item log MESSAGE...

I<Instance method.>
Log a message to the log file.  No alterations are made on the
text of the message.  See msg() for an alternative.

=cut

sub log {
    my $self = shift;
    print {$self->{LOG}} @_ if $self->{LOG};
}

#------------------------------

=item msg MESSAGE...

I<Instance method.>
Log a message to the log file.  Lines are prefixed with "** " for clarity,
and a terminating newline is forced.

=cut

sub msg { 
    my $self = shift;
    my $text = join '', @_;
    chomp $text; 
    $text =~ s{^}{** }gm;
    $self->l_print($text, "\n");
}

#------------------------------
#
# l_print MESSAGE...
#
# Instance method, private.
# Print to the log file if there is one.
#
sub l_print {
    my $self = shift;
    print { $self->{LOG} } @_ if $self->{LOG};
}

#------------------------------
#
# ln_print MESSAGE...
#
# Instance method, private.
# Print to the log file, prefixed by message number.
#
sub ln_print {
    my $self = shift;
    foreach (split /\n/, join('', @_)) { 
	$self->l_print("$self->{Count}: $_\n");
    }
}

#------------------------------

=back

=head2 Utilities

=over 4

=cut

#------------------------------

=item catdir DIR, ..., DIR

I<Class/instance method.>
Concatenate several directories into a path ending in a directory.
Lightweight version of the one in the (very new) File::Spec.

Paths are assumed to be absolute.
To signify a relative path, the first DIR must be ".",
which is processed specially.

On Mac, the path I<does> end in a ':'.
On Unix, the path I<does not> end in a '/'.

=cut

sub catdir {
    my $self = shift;
    my $relative = shift @_ if ($_[0] eq '.');
    if ($^O eq 'Mac') {
	return ($relative ? ':' : '') . (join ':', @_) . ':';
    }
    else {
	return ($relative ? './' : '/') . join '/', @_;
    }
}

#------------------------------

=item catfile DIR, ..., DIR, FILE

I<Class/instance method.>
Like catdir(), but last element is assumed to be a file.
Note that, at a minimum, you must supply at least a single DIR. 

=cut

sub catfile {
    my $self = shift;
    my $file = pop;
    if ($^O eq 'Mac') {
	return $self->catdir(@_) . $file;
    }
    else {
	return $self->catdir(@_) . "/$file";
    }
}

#------------------------------

=back


=head1 CHANGE LOG

B<Current version:>
$Id: TBone.pm,v 1.1.1.1 2001-03-29 23:55:41 dparker Exp $

=over 4

=item Version 1.116

Cosmetic improvements only.


=item Version 1.112

Added lightweight catdir() and catfile() (a la File::Spec)
to enhance portability to Mac environment.


=item Version 1.111

Now uses File::Basename to create "typical" logfile name,
for portability.


=item Version 1.110

Fixed bug in constructor that surfaced if no log was being used. 

=back

Created: Friday-the-13th of February, 1998.


=head1 AUTHOR

Eryq (F<eryq@zeegee.com>).
President, ZeeGee Software Inc. (F<http://www.zeegee.com>)

=cut

#------------------------------

1;
__END__

my $T = new ExtUtils::TBone "testout/foo.tlog";
$T->begin(3);
$T->msg("before 1\nor 2");
$T->ok(1, "one");
$T->ok(2, "Two");
$T->ok(3, "Three", Roman=>'III', Arabic=>[3, '03'], Misc=>"3\nor 3");
$T->end;

1;

