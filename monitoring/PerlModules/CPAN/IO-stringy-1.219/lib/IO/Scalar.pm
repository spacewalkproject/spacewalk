package IO::Scalar;


=head1 NAME

IO::Scalar - IO:: interface for reading/writing a scalar


=head1 SYNOPSIS

If you have any Perl5, you can use the basic OO interface...

    use IO::Scalar;
    
    ### Open a handle on a string:
    $SH = new IO::Scalar;
    $SH->open(\$somestring);
    
    ### Open a handle on a string, read it line-by-line, then close it:
    $SH = new IO::Scalar \$somestring;
    while ($_ = $SH->getline) { print "Line: $_" }
    $SH->close;
        
    ### Open a handle on a string, and slurp in all the lines:
    $SH = new IO::Scalar \$somestring;
    print $SH->getlines; 
     
    ### Open a handle on a string, and append to it:
    $SH = new IO::Scalar \$somestring
    $SH->print("bar\n");        ### will add "bar\n" to the end   
      
    ### Get the current position:
    $pos = $SH->getpos;         ### $SH->tell() also works
     
    ### Set the current position:
    $SH->setpos($pos);          ### $SH->seek(POS,WHENCE) also works
        
    ### Open an anonymous temporary scalar:
    $SH = new IO::Scalar;
    $SH->print("Hi there!");
    print "I got: ", ${$SH->sref}, "\n";      ### get at value

If your Perl is 5.004 or later, you can use the TIEHANDLE
interface, and read/write scalars just like files:

    use IO::Scalar;

    ### Writing to a scalar...
    my $s; 
    tie *OUT, 'IO::Scalar', \$s;
    print OUT "line 1\nline 2\n", "line 3\n";
    print "s is now... $s\n"
     
    ### Reading and writing an anonymous scalar... 
    tie *OUT, 'IO::Scalar';
    print OUT "line 1\nline 2\n", "line 3\n";
    tied(OUT)->seek(0,0);
    while (<OUT>) { print "LINE: ", $_ }

Stringification now works, too!

    my $SH = new IO::Scalar \$somestring;
    $SH->print("Hello, ");
    $SH->print("world!");
    print "I've got: <$SH>\n";

You can also make the objects sensitive to the $/ setting,
just like IO::Handle wants them to be:

    my $SH = new IO::Scalar \$somestring;
    $SH->use_RS(1);           ### perlvar's short name for $/
    ...
    local $/ = "";            ### read paragraph-at-a-time
    $nextpar = $SH->getline;



=head1 DESCRIPTION

This class implements objects which behave just like FileHandle
(or IO::Handle) objects, except that you may use them to write to
(or read from) scalars.  They can be tiehandle'd as well.  

Basically, this:

    my $s;
    $SH = new IO::Scalar \$s;
    $SH->print("Hel", "lo, ");         # OO style
    $SH->print("world!\n");            # ditto

Or this (if you have 5.004 or later):

    my $s;
    $SH = tie *OUT, 'IO::Scalar', \$s;
    print OUT "Hel", "lo, ";           # non-OO style
    print OUT "world!\n";              # ditto

Or this (if you have 5.004 or later):

    my $s;
    $SH = IO::Scalar->new_tie(\$s);
    $SH->print("Hel", "lo, ");         # OO style...
    print $SH "world!\n";              # ...or non-OO style!

Causes $s to be set to:    

    "Hello, world!\n" 


=head1 PUBLIC INTERFACE

=cut

use Carp;
use strict;
use vars qw($VERSION @ISA);
use IO::Handle;

### Stringification, courtesy of B. K. Oxley (binkley):  :-)
use overload '""'   => sub { ${$_[0]->{SR}} };
use overload 'bool' => sub { 1 };      ### have to do this, so object is true! 

### The package version, both in 1.23 style *and* usable by MakeMaker:
$VERSION = substr q$Revision: 1.999 $, 10;

### Inheritance:
@ISA = qw(IO::Handle);
require IO::WrapTie and push @ISA, 'IO::WrapTie::Slave' if ($] >= 5.004);

#==============================

=head2 Construction 

=over 4

=cut

#------------------------------

=item new [ARGS...]

I<Class method.>
Return a new, unattached scalar handle.  
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

=item open [SCALARREF]

I<Instance method.>
Open the scalar handle on a new scalar, pointed to by SCALARREF.
If no SCALARREF is given, a "private" scalar is created to hold
the file data.

Returns the self object on success, undefined on error.

=cut

sub open {
    my ($self, $sref) = @_;

    # Sanity:
    defined($sref) or do {my $s = ''; $sref = \$s};
    (ref($sref) eq "SCALAR") or croak "open() needs a ref to a scalar";

    # Setup:
    $self->{Pos} = 0;          ### seek position
    $self->{SR}  = $sref;      ### scalar reference
    $self;
}

#------------------------------

=item opened

I<Instance method.>
Is the scalar handle opened on something?

=cut

sub opened {
    shift->{SR};
}

#------------------------------

=item close

I<Instance method.>
Disassociate the scalar handle from its underlying scalar.
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

=cut

sub getc {
    my $self = shift;
    
    # Return undef right away if at EOF; else, move pos forward:
    return undef if $self->eof;  
    substr(${$self->{SR}}, $self->{Pos}++, 1);
}
 
#------------------------------

=item getline

I<Instance method.>
Return the next line, or undef on end of string.  
Can safely be called in an array context.
Currently, lines are delimited by "\n".

=cut

sub getline {
    my $self = shift;

    # Return undef right away if at EOF:
    return undef if $self->eof;

    # Get next line:
    my $sr = $self->{SR};
    my $i  = $self->{Pos};	        # Start matching at this point.

    ### Minimal impact implementation!
    ### We do the fast fast thing (no regexps) if using the
    ### classic input record separator.
    my $RS = $self->{UseRS} ? $/ : "\012";

    ### Case 1: $RS is undef: slurp all...    
    if    (!defined($RS)) {
	$self->{Pos} = length $$sr;
        return substr($$sr, $i);
    }

    ### Case 2: $RS is "\n": zoom zoom zoom...
    elsif ($RS eq "\012") {    
        
        ### Seek ahead for "\n"... yes, this really is faster than regexps.
        my $len = length($$sr);
        for (; $i < $len; ++$i) {
           last if ord (substr ($$sr, $i, 1)) == 10;
        }

        ### Extract the line:
        my $line;
        if ($i < $len) {                ### We found a "\n":
            $line = substr ($$sr, $self->{Pos}, $i - $self->{Pos} + 1);
            $self->{Pos} = $i+1;            ### Remember where we finished up.
        }
        else {                          ### No "\n"; slurp the remainder:
            $line = substr ($$sr, $self->{Pos}, $i - $self->{Pos});
            $self->{Pos} = $len;
        }
        return $line; 
    }

    ### Case 3: $RS is ref to int.  Bail out.
    elsif (ref($RS)) {
        croak '$RS as ref to int is currently unsupported';
    }

    ### Case 4: $RS is either "" (paragraphs) or something weird...
    ###         This is Graham's general-purpose stuff, which might be 
    ###         a tad slower than Case 2 for typical data, because
    ###         of the regexps.
    else {                
        pos($$sr) = $i;

	### If in paragraph mode, skip leading lines (and update i!):
        length($RS) or 
	    (($$sr =~ m/\G\n*/g) and ($i = pos($$sr)));

        ### If we see the separator in the buffer ahead...
        if (length($RS)                       
	    ?  $$sr =~ m,\Q$RS\E,g         ###   (ordinary sep) TBD: precomp!
            :  $$sr =~ m,\n\n,g            ###   (a paragraph)
            ) {
            $self->{Pos} = pos $$sr;
            return substr($$sr, $i, $self->{Pos}-$i);
        }
        ### Else if no separator remains, just slurp the rest:
        else {      
            $self->{Pos} = length $$sr;
            return substr($$sr, $i);
        }
    }
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
Print ARGS to the underlying scalar.  

B<Warning:> Currently, this always causes a "seek to the end of the string"; 
this may change in the future.

=cut

sub print {
    my $self = shift;
    ${$self->{SR}} .= join('', @_);
    $self->{Pos} = length(${$self->{SR}});
    1;
}

#------------------------------

=item read BUF, NBYTES, [OFFSET]

I<Instance method.>
Read some bytes from the scalar.
Returns the number of bytes actually read, 0 on end-of-file, undef on error.

=cut

sub read {
    my $self = $_[0];
    my $n    = $_[2];
    my $off  = $_[3] || 0;

    my $read = substr(${$self->{SR}}, $self->{Pos}, $n);
    $n = length($read);
    $self->{Pos} += $n;
    ($off ? substr($_[1], $off) : $_[1]) = $read;
    return $n;
}

#------------------------------

=item write BUF, NBYTES, [OFFSET]

I<Instance method.>
Write some bytes to the scalar.

=cut

sub write {
    my $self = $_[0];
    my $n    = $_[2];
    my $off  = $_[3] || 0;

    my $data = substr($_[1], $off, $n);
    $n = length($data);
    $self->print($data);
    return $n;
}

#------------------------------

=item sysread BUF, LEN, [OFFSET]

I<Instance method.>
Read some bytes from the scalar.
Returns the number of bytes actually read, 0 on end-of-file, undef on error.

=cut

sub sysread {
  my $self = shift;
  $self->read (@_);
}

#------------------------------

=item syswrite BUF, NBYTES, [OFFSET]

I<Instance method.>
Write some bytes to the scalar.

=cut

sub syswrite {
  my $self = shift;
  $self->write (@_);
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
    my $self = shift;
    ($self->{Pos} >= length(${$self->{SR}}));
}

#------------------------------

=item seek OFFSET, WHENCE

I<Instance method.>  Seek to a given position in the stream.

=cut

sub seek {
    my ($self, $pos, $whence) = @_;
    my $eofpos = length(${$self->{SR}});

    # Seek:
    if    ($whence == 0) { $self->{Pos} = $pos }             # SEEK_SET
    elsif ($whence == 1) { $self->{Pos} += $pos }            # SEEK_CUR
    elsif ($whence == 2) { $self->{Pos} = $eofpos + $pos}    # SEEK_END
    else                 { croak "bad seek whence ($whence)" }

    # Fixup:
    if ($self->{Pos} < 0)       { $self->{Pos} = 0 }
    if ($self->{Pos} > $eofpos) { $self->{Pos} = $eofpos }
    1;
}

#------------------------------

=item sysseek OFFSET, WHENCE

I<Instance method.> Identical to C<seek OFFSET, WHENCE>, I<q.v.>

=cut

sub sysseek {
    my $self = shift;
    $self->seek (@_);
}

#------------------------------

=item tell

I<Instance method.>
Return the current position in the stream, as a numeric offset.

=cut

sub tell { shift->{Pos} }

#------------------------------

=item use_RS [YESNO]

I<Instance method.>
Obey the curent setting of $/, like IO::Handle does?
Default is false.

=cut

sub use_RS {
    my ($self, $yesno) = @_;
    $self->{UseRS} = $yesno;
}

#------------------------------

=item setpos POS

I<Instance method.>
Set the current position, using the opaque value returned by C<getpos()>.

=cut

sub setpos { shift->seek($_[0],0) }

#------------------------------

=item getpos 

I<Instance method.>
Return the current position in the string, as an opaque object.

=cut

*getpos = \&tell;


#------------------------------

=item sref

I<Instance method.>
Return a reference to the underlying scalar.

=cut

sub sref { shift->{SR} }


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



=back

=cut

=head1 VERSION

$Id: Scalar.pm,v 1.999 2001-03-30 03:13:03 dparker Exp $


=head1 AUTHORS


=head2 Principal author

Eryq (F<eryq@zeegee.com>).
President, ZeeGee Software Inc (F<http://www.zeegee.com>).


=head2 Other contributors 

The full set of contributors always includes the folks mentioned
in L<IO::Stringy/"CHANGE LOG">.  But just the same, special
thanks to the following individuals for their invaluable contributions
(if I've forgotten or misspelled your name, please email me!):

I<Andy Glew,>
for contributing C<getc()>.

I<Brandon Browning,>
for suggesting C<opened()>.

I<David Richter,>
for finding and fixing the bug in C<PRINTF()>.

I<Eric L. Brine,>
for his offset-using read() and write() implementations. 

I<Richard Jones,>
for his patches to massively improve the performance of C<getline()>
and add C<sysread> and C<syswrite>.

I<B. K. Oxley (binkley),>
for stringification and inheritance improvements,
and sundry good ideas.


=cut
