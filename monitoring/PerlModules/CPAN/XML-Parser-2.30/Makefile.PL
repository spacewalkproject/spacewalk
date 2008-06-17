use ExtUtils::MakeMaker;
use Config;

$expat_libpath = '';
$expat_incpath = '';

my @replacement_args;

foreach (@ARGV) {
  if (/^EXPAT(LIB|INC)PATH=(.+)/) {
    if ($1 eq 'LIB') {
      $expat_libpath = $2;
    }
    else {
      $expat_incpath = $2;
    }
  }
  else {
    push(@replacement_args, $_);
  }
}

@ARGV = @replacement_args;

unless ($expat_libpath) {
  # Test for existence of libexpat
  my $found = 0;
  foreach (split(/\s+/, $Config{libpth})) {
    if (-f "$_/libexpat." . $Config{so}) {
      $found = 1;
      last;
    }
  }

  unless ($found) {
    die <<'Expat_Not_Installed;';

Expat must be installed prior to building XML::Parser and I can't find
it in the standard library directories. You can download expat from:

http://sourceforge.net/projects/expat/

If expat is installed, but in a non-standard directory, then use the
following options to Makefile.PL:

    EXPATLIBPATH=...  To set the directory in which to find libexpat

    EXPATINCPATH=...  To set the directory in which to find expat.h

For example:

    perl Makefile.PL EXPATLIBPATH=/home/me/lib EXPATINCPATH=/home/me/include

Note that if you build against a shareable library in a non-standard location
you may (on some platforms) also have to set your LD_LIBRARY_PATH environment
variable at run time for perl to find the library.

Expat_Not_Installed;
  }
}

# Don't try to descend into Expat directory for testing

sub MY::test
{
  my $self = shift;

  my $hold = delete $self->{DIR};
  my $ret = $self->MM::test(@_);
  $self->{DIR} = $hold if defined($hold);
  $ret;
}

@extras = ();

push(@extras,
     CAPI => 'TRUE')
    if ($PERL_VERSION >= 5.005 and $OSNAME eq 'MSWin32'
	and $Config{archname} =~ /-object\b/i);

push(@extras,
     ABSTRACT_FROM => 'Parser.pm',
     AUTHOR        => 'Clark Cooper (coopercc@netheaven.com)')
    if ($ExtUtils::MakeMaker::Version >= 5.4301);
     
WriteMakefile(
              NAME	=> 'XML::Parser',
	      DIR	=> [qw(Expat)],
              dist      => {COMPRESS => 'gzip', SUFFIX => '.gz'},
              VERSION_FROM => 'Parser.pm',
	      @extras
             );

