
package Date::Language;

use     strict;
use     Time::Local;
use     Carp;
use     vars qw($VERSION @ISA);
require Date::Format;

$VERSION = "1.10";
@ISA     = qw(Date::Format::Generic);

sub new
{
 my $self = shift;
 my $type = shift || $self;

 $type =~ s/^(\w+)$/Date::Language::$1/;

 croak "Bad language"
	unless $type =~ /^[\w:]+$/;

 eval "require $type"
	or croak $@;

 bless [], $type;
}

# Stop AUTOLOAD being called ;-)
sub DESTROY {}

sub AUTOLOAD
{
 use vars qw($AUTOLOAD);

 if($AUTOLOAD =~ /::strptime\Z/o)
  {
   my $self = $_[0];
   my $type = ref($self) || $self;
   require Date::Parse;

   no strict 'refs';
   *{"${type}::strptime"} = Date::Parse::gen_parser(
	\%{"${type}::DoW"},
	\%{"${type}::MoY"},
	\@{"${type}::Dsuf"},
	1);

   goto &{"${type}::strptime"};
  }

 croak "Undefined method &$AUTOLOAD called";
}

sub str2time
{
 my $me = shift;
 my @t = $me->strptime(@_);

 return undef
	unless @t;

 my($ss,$mm,$hh,$day,$month,$year,$zone) = @t;
 my @lt  = localtime(time);

 $hh    ||= 0;
 $mm    ||= 0;
 $ss    ||= 0;

 $month = $lt[4]
	unless(defined $month);

 $day  = $lt[3]
	unless(defined $day);

 $year = ($month > $lt[4]) ? ($lt[5] - 1) : $lt[5]
	unless(defined $year);

 return defined $zone ? timegm($ss,$mm,$hh,$day,$month,$year) - $zone
    	    	      : timelocal($ss,$mm,$hh,$day,$month,$year);
}

1;
