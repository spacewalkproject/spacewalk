package Time::System;

use 5.00503;
use strict;

require Exporter;
require DynaLoader;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
@ISA = qw(Exporter DynaLoader);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use Time::System ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
%EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

@EXPORT = qw(
	gettimeofday
	settimeofday
);
$VERSION = '0.01';

bootstrap Time::System $VERSION;


##################
sub gettimeofday {
##################
  my($sec, $usec) = _gettimeofday();

  return wantarray ? ($sec, $usec) : join('.', $sec, $usec);
}


##################
sub settimeofday {
##################
  my($sec, $usec) = @_;

  ($sec, $usec) = split(/\./, $sec, 2) unless ($usec);

  unless ($sec =~ /^\d+$/ and $usec =~ /^\d*$/) {
    $@ = "All args to settimeofday() must be numeric\n";
    return undef;
  }

  my($rv) = _settimeofday($sec, $usec);

  if ($rv == 0) {
    # Success
    return wantarray ? gettimeofday() : scalar(gettimeofday());
  } else {
    return undef;
  }

}

1;
__END__
=head1 NAME

Time::System - Perl extension for getting and setting the system time

=head1 SYNOPSIS

  use Time::System;

  my($sec, $usec)    = gettimeofday();
  my $time_with_usec = gettimeofday();

  settimeofday($sec, $usec)     or die "Couldn't set time: $@";
  settimeofday($time_with_usec) or die "Couldn't set time: $@";
  

=head1 DESCRIPTION

Time::System provides access to the gettimeofday() and settimeofday()
system calls.  In scalar context, B<gettimeofday()> returns seconds
and microseconds as a single floating-point number; in array context,
it returns them separately.  

Similarly, B<settimeofday()> may be called with a single
floating-point number, or with seconds and microseconds passed as
separate arguments.  B<settimeofday()> returns a true value on
success, and a false value with $@ set on error.

=head1 EXPORTS

gettimeofday
settimeofday


=head1 AUTHOR

Dave Faraldo<lt>dfaraldo@redhat.com<gt>

=head1 DATE

Last modified: $Date: 2003-09-05 21:51:43 $

=head1 SEE ALSO

L<gettimeofday(2)>, L<settimeofday(2)>

=cut
