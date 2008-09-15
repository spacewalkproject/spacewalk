package IO::ScalarArray;


=head1 NAME

IO::ScalarArray - IO:: interface for reading/writing an array of scalars


=head1 SYNOPSIS

If you have any Perl5, you can use the basic OO interface...

    use IO::ScalarArray;
    
    # Open a handle on an array-of-scalars:
    $AH = new IO::ScalarArray;
    $AH->open(\@a);
    
    # Open a handle on an array-of-scalars, read it line-by-line, 
    # then close it:
    $AH = new IO::ScalarArray \@a;
    while ($_ = $AH->getline) { print "Line: $_" }
    $AH->close;
        
    # Open a handle on an array-of-scalars, and slurp in all the lines:
    $AH = new IO::ScalarArray \@a;
    print $AH->getlines; 
     
    # Open a handle on an array-of-scalars, and append to it:
    $AH = new IO::ScalarArray \@a;
    $AH->print("bar\n");
    print "some string is now: ", $somestring, "\n";
      
    # Get the current position:
    $pos = $AH->getpos;         ### $AH->tell() also works
     
    # Set the current position:
    $AH->setpos($pos);          ### $AH->seek(POS,WHENCE) also works
      
    # Open an anonymous temporary scalar array:
    $AH = new IO::ScalarArray;
    $AH->print("Hi there!\nHey there!\n");
    $AH->print("Ho there!\n");
    print "I got: ", @{$AH->aref}, "\n";      ### get at value

If your Perl is 5.004 or later, you can use the TIEHANDLE
interface, and read/write as array-of-scalars just like files:

    use IO::ScalarArray;

    # Writing to a scalar array...
    my @a; 
    tie *OUT, 'IO::ScalarArray', \@a;
    print OUT "line 1\nline 2\n", "line 3\n";
    print "s is now... [", join('', @a), "]\n"; 
     
    # Reading and writing an anonymous scalar array... 
    tie *OUT, 'IO::ScalarArray';
    print OUT "line 1\nline 2\n", "line 3\n";
    tied(OUT)->seek(0,0);
    while (<OUT>) { print "LINE: ", $_ }


=head1 DESCRIPTION

This class implements objects which behave just like FileHandle
(or IO::Handle) objects, except that you may use them to write to
(or read from) scalars.  They can be tiehandle'd as well.  

For writing large amounts of data with individual print() statements, 
this is likely to be more efficient than IO::Scalar.

Basically, this:

    my @a;
    $AH = new IO::ScalarArray \@a;
    $AH->print("Hel", "lo, ");     
    $AH->print("world!\n");     

Or this (if you have 5.004 or later):

    my @a;
    $AH = tie *OUT, 'IO::ScalarArray', \@a;
    print OUT "Hel", "lo, "; 
    print OUT "world!\n"; 

Causes @a to be set to the following arrayt of 3 strings:

    ( "Hel" , 
      "lo, " , 
      "world!\n" )

Compare this with IO::Scalar.


=head1 PUBLIC INTERFACE

=cut

use Carp;
use strict;
use vars qw($VERSION @ISA);
use IO::Handle;

# The package version, both in 1.23 style *and* usable by MakeMaker:
$VERSION = substr q$Revision: 1.999 $, 10;

# Inheritance:
@ISA = qw(IO::Handle);
require IO::WrapTie and push @ISA, 'IO::WrapTie::Slave' if ($] >= 5.004);


#==============================

=head2 Construction 

=over 4

=cut

#------------------------------

=item new [ARGS...]

I<Class method.>
Return a new, unattached array handle.  
If any arguments are given, they're sent to open().

=cut

sub new {
    my $self = bless {}, shift;
    $self->open(@_) if @_;
    $self;
}
sub DESTROY { 
    shift->close;
}


#------------------------------

=item open [ARRAYREF]

I<Instance method.>
Open the array handle on a new array, pointed to by ARRAYREF.
If no ARRAYREF is given, a "private" array is created to hold
the file data.

Returns the self object on success, undefined on error.

=cut

sub open {
    my ($self, $aref) = @_;

    # Sanity:
    defined($aref) or do {my @a; $aref = \@a};
    (ref($aref) eq "ARRAY") or croak "open needs a ref to a array";

    # Setup:
    $self->setpos([0,0]);
    $self->{AR} = $aref;
    $self;
}

#------------------------------

=item opened

I<Instance method.>
Is the array handle opened on something?

=cut

sub opened {
    shift->{AR};
}

#------------------------------

=item close

I<Instance method.>
Disassociate the array handle from its underlying array.
Done automatically on destroy.

=cut

sub close {
    my $self = shift;
    %$self = ();
    1;
}

=back

=cut



#==============================

=head2 Input and output

=over 4

=cut

#------------------------------

=item flush 

I<Instance method.>
No-op, provided for OO compatibility.

=cut

sub flush {} 

#------------------------------

=item getc

I<Instance method.>
Return the next character, or undef if none remain.
This does a read(1), which is somewhat costly.

=cut

sub getc {
    my $buf = '';
    ($_[0]->read($buf, 1) ? $buf : undef);
}

#------------------------------

=item getline

I<Instance method.>
Return the next line, or undef on end of data.
Can safely be called in an array context.
Currently, lines are delimited by "\n".

=cut

sub getline {
    my $self = shift;
    my ($str, $line) = (undef, '');

    # Until we hit EOF (or exitted because of a found line):
    until ($self->eof) {
	# If at end of current string, go forward to next one (won't be EOF):
	if ($self->_eos) {++$self->{Str}, $self->{Pos}=0};

	# Get ref to current string in array, and set internal pos marker:
	$str = \($self->{AR}[$self->{Str}]);  # get current string
	pos($$str) = $self->{Pos};            # start matching at this point

        # Get from here to either newline or end of string, and add to line:
	$$str =~ m/\G(.*?)((\n)|\Z)/g;        # match to 1st newline or EOS
	$line .= $1.$2;                       # add it
	$self->{Pos} += length($1.$2);        # move forward by amount matched
	return $line if $3;                   # done, got a line with "\n"
    }
    return ($line eq '') ? undef : $line;  # return undef if EOF
}

#------------------------------

=item getlines

I<Instance method.>
Get all remaining lines.
It will croak() if accidentally called in a scalar context.

=cut

sub getlines {
    my $self = shift;
    wantarray or croak("Can't call getlines in scalar context!");
    my ($line, @lines);
    push @lines, $line while (defined($line = $self->getline));
    @lines;
}

#------------------------------

=item print ARGS...

I<Instance method.>
Print ARGS to the underlying array.  

Currently, this always causes a "seek to the end of the array"
and generates a new array entry.  This may change in the future.

=cut

sub print {
    my $self = shift;
    push @{$self->{AR}}, join('', @_);      # add the data
    $self->setpos([scalar(@{$self->{AR}}), 0]);
    1;
}

#------------------------------

=item read BUF, NBYTES, [OFFSET];

I<Instance method.>
Read some bytes from the array.
Returns the number of bytes actually read, 0 on end-of-file, undef on error.

=cut

sub read {
    my $self = $_[0];
    my $n    = $_[2];
    my $off  = $_[3] || 0;

    ### print "getline\n";
    my $justread;
    my $len;
    ($off ? substr($_[1], $off) : $_[1]) = '';
    
    # Stop when we have zero bytes to go, or when we hit EOF:
    until (!$n or $self->eof) {       
        # If at end of current string, go forward to next one (won't be EOF):
        if ($self->_eos) {
            ++$self->{Str};
            $self->{Pos} = 0;
        }

        # Get longest possible desired substring of current string:
        $justread = substr($self->{AR}[$self->{Str}], $self->{Pos}, $n);
        $len = length($justread);
        $_[1] .= $justread;
        $n           -= $len; 
        $self->{Pos} += $len;
    }
    return length($_[1])-$off;
}

#------------------------------

=item write BUF, NBYTES, [OFFSET];

I<Instance method.>
Write some bytes into the array.

=cut

sub write {
    my $self = $_[0];
    my $n    = $_[2];
    my $off  = $_[3] || 0;

    my $data = substr($_[1], $n, $off);
    $n = length($data);
    $self->print($data);
    return $n;
}


=back

=cut



#==============================

=head2 Seeking/telling and other attributes

=over 4

=cut

#------------------------------

=item autoflush 

I<Instance method.>
No-op, provided for OO compatibility.

=cut

sub autoflush {} 

#------------------------------

=item binmode

I<Instance method.>
No-op, provided for OO compatibility.

=cut

sub binmode {} 

#------------------------------

=item clearerr

I<Instance method.>  Clear the error and EOF flags.  A no-op.

=cut

sub clearerr { 1 }

#------------------------------

=item eof 

I<Instance method.>  Are we at end of file?

=cut

sub eof {
    ### print "checking EOF [$self->{Str}, $self->{Pos}]\n";
    ### print "SR = ", $#{$self->{AR}}, "\n";
    return 0 if ($_[0]->{Str} < $#{$_[0]->{AR}});         # before EOA
    return 1 if ($_[0]->{Str} > $#{$_[0]->{AR}});         # after EOA
    (($_[0]->{Str} == $#{$_[0]->{AR}}) && ($_[0]->_eos)); # at EOA, past EOS
}

#------------------------------
#
# _eos
#
# I<Instance method, private.>  Are we at end of the CURRENT string?
#

sub _eos {
    ($_[0]->{Pos} >= length($_[0]->{AR}[$_[0]->{Str}]));  # past last char  
}

#------------------------------

=item seek POS,WHENCE

I<Instance method.>
Seek to a given position in the stream.
Only a WHENCE of 0 (SEEK_SET) is supported.

=cut

sub seek {
    my ($self, $pos, $whence) = @_; 
    die "IO::ScalarArray::seek: whence of $whence not supported\n" if $whence;

    # Advance through array until done:
    my $istr = 0;
    while (($pos >= 0) && ($istr < scalar(@{$self->{AR}}))) {
	if (length($self->{AR}[$istr]) > $pos) {  # it's in this string! 
	    return $self->setpos([$istr, $pos]);
	}
	else {                                    # it's in next string
	    $pos -= length($self->{AR}[$istr++]);    # move forward one string
	}
    }
    # If we reached this point, pos is at or past end; zoom to EOF:
    return $self->setpos([scalar(@{$self->{AR}}), 0]);
}

#------------------------------

=item tell

I<Instance method.>
Return the current position in the stream, as a numeric offset.

=cut

sub tell {
    my $self = shift;
    my $off = 0;
    my ($s, $str_s);
    for ($s = 0; $s < $self->{Str}; $s++) {      # count all "whole" scalars
	defined($str_s = $self->{AR}[$s]) or $str_s = '';
	###print STDERR "COUNTING STRING $s (". length($str_s) . ")\n";
	$off += length($str_s);
    }
    ###print STDERR "COUNTING POS ($self->{Pos})\n";
    return ($off += $self->{Pos});               # plus the final, partial one
}

#------------------------------

=item setpos POS

I<Instance method.>
Seek to a given position in the array, using the opaque getpos() value.
Don't expect this to be a number.

=cut

sub setpos { 
    my ($self, $pos) = @_;
    (ref($pos) eq 'ARRAY') or
	die "setpos: only use a value returned by getpos!\n";
    ($self->{Str}, $self->{Pos}) = @$pos;
}

#------------------------------

=item getpos

I<Instance method.>
Return the current position in the array, as an opaque value.
Don't expect this to be a number.

=cut

sub getpos {
    [$_[0]->{Str}, $_[0]->{Pos}];
}

#------------------------------

=item aref

I<Instance method.>
Return a reference to the underlying array.

=cut

sub aref {
    shift->{AR};
}

=back

=cut

#------------------------------
# Tied handle methods...
#------------------------------

# Conventional tiehandle interface:
sub TIEHANDLE { shift->new(@_) }
sub GETC      { shift->getc(@_) }
sub PRINT     { shift->print(@_) }
sub PRINTF    { shift->print(sprintf(shift, @_)) }
sub READ      { shift->read(@_) }
sub READLINE  { wantarray ? shift->getlines(@_) : shift->getline(@_) }
sub WRITE     { shift->write(@_); }
sub CLOSE     { shift->close(@_); }

#------------------------------------------------------------

1;
__END__

# SOME PRIVATE NOTES:
#
#     * The "current position" is the position before the next
#       character to be read/written.
#
#     * Str gives the string index of the current position, 0-based
#
#     * Pos gives the offset within AR[Str], 0-based.
#
#     * Inital pos is [0,0].  After print("Hello"), it is [1,0].


=head1 VERSION

$Id: ScalarArray.pm,v 1.999 2001-03-30 03:11:52 dparker Exp $


=head1 AUTHOR

=head2 Principal author

Eryq (F<eryq@zeegee.com>).
President, ZeeGee Software Inc (F<http://www.zeegee.com>).


=head2 Other contributors 

Thanks to the following individuals for their invaluable contributions
(if I've forgotten or misspelled your name, please email me!):

I<Andy Glew,>
for suggesting C<getc()>.

I<Brandon Browning,>
for suggesting C<opened()>.

I<Eric L. Brine,>
for his offset-using read() and write() implementations. 

=cut

#------------------------------
1;

