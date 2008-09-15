package Heap::Elem::Str;

use strict;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;
require AutoLoader;

@ISA = qw(Exporter AutoLoader Heap::Elem);

# No names exported.
@EXPORT = ( );

# Available for export: StrElem (to allocate a new Heap::Elem::Str value)
@EXPORT_OK = qw( StrElem );

$VERSION = '0.01';


# Preloaded methods go here.

sub new {
    my $class = shift;
    $class = ref($class) || $class;

    # two slot array, 0 for the string value, 1 for use by Heap
    my $self = [ shift, undef ];

    return bless $self, $class;
}

sub StrElem {	# exportable synonym for new
    Heap::Elem::Str->new(@_);
}

# get or set value slot
sub val {
    my $self = shift;
    @_ ? ($self->[0] = shift) : $self->[0];
}

# get or set heap slot
sub heap {
    my $self = shift;
    @_ ? ($self->[1] = shift) : $self->[1];
}

# compare two Str elems
sub cmp {
    my $self = shift;
    my $other = shift;
    return $self->[0] cmp $other->[0];
}

# Autoload methods go after =cut, and are processed by the autosplit program.

1;
__END__

=head1 NAME

Heap::Elem::Str - Perl extension for String Heap Elements

=head1 SYNOPSIS

  use Heap::Elem::Str( StrElem );
  use Heap::Fibonacci;

  my $heap = Heap::Fibonacci->new;
  my $elem;

  foreach $i ( 'aa'..'bz' ) {
      $elem = StrElem( $i );
      $heap->add( $elem );
  }

  while( defined( $elem = $heap->extract_minimum ) ) {
      print "Smallest is ", $elem->val, "\n";
  }

=head1 DESCRIPTION

Heap::Elem::Str is used to wrap string values into an element
that can be managed on a heap.  The top of the heap will have
the smallest element still remaining.  (See L<Heap::Elem::StrRev>
if you want the heap to always return the largest element.)

The details of the Elem interface are described in L<Heap::Elem>.

The details of using a Heap interface are described in L<Heap>.

=head1 AUTHOR

John Macdonald, jmm@elegant.com

=head1 SEE ALSO

Heap(3), Heap::Elem(3), Heap::Elem::StrRev(3).

=cut
