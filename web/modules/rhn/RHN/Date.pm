#
# Copyright (c) 2008 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
# 
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation. 
#

use strict;

package RHN::Date;

use RHN::Exception qw/throw/;

use Date::Parse;
use DateTime;
use Params::Validate;
Params::Validate::validation_options(strip_leading => "-");

# an RHN::Date object is basically a small layer of helpers around
# DateTime.  It is timezone aware, can parse strings into times, and
# can handle display conversions of dates to destination timezones.
# only the minimal number of DateTime methods are exposed to keep the
# implementation details as protected as possible

sub new {
  my $class = shift;
  my %params = validate(@_, { -now => 0, -epoch => 0, -string => 0, -user => 0, from_zone => 0, source => 0 });

  my $dt;
  if (exists $params{source}) {
    my $from = $params{source};
    if ($from->isa("RHN::Date")) {
      $from = $from->{dt};
    }
    elsif ($from->isa("DateTime")) {
      # nop
    }
    else {
      throw "Invalid source object $from for constructor";
    }

    $dt = $from->clone;
  }
  elsif (exists $params{now}) {
    $dt = DateTime->now(time_zone => "local");
  }
  elsif (exists $params{epoch}) {
    $dt = DateTime->from_epoch(epoch => $params{epoch}, time_zone => "local");
  }
  elsif (exists $params{string}) {
    my $from_zone = $params{from_zone};
    if ($from_zone) {
      $dt = DateTime->from_epoch(epoch => date_to_epoch($params{string}, $from_zone),
				 time_zone => "local");
    }
    else {
      $dt = DateTime->from_epoch(epoch => str2time($params{string}), time_zone => "local");
    }
  }
  else {
    throw "Missing parameter to RHN::Date constructor";
  }

  my $self = bless { dt => $dt }, $class;

  if ($params{user}) {
    $self->time_zone($params{user}->get_timezone);
  }

  return $self;
}

# helper constructor - clone the current RHN::Date
sub clone {
  my $self = shift;
  my $class = ref $self;

  return $class->new(-source => $self);
}

# helper constructor - an RHN::Date object representing 'now' in the
# default TZ
sub now {
  my $class = shift;

  return $class->new(now => 1);
}

# construct a date from constituent elements
sub construct {
  my $class = shift;
  my @tuples = @_;

  my $dt = new DateTime(@tuples);
  return $class->new(source => $dt);
}

# get/set the timezone associated with an RHN::Date obj
sub time_zone {
  my $self = shift;

  if (@_) {
    $self->{dt}->set_time_zone(shift);
  }

  return $self->{dt}->time_zone;
}

# internal function for conversion; a bit ineffecient right now but
# gets the job done
sub date_to_epoch {
  my $str = shift;
  my $zone_name = shift;

  my ($s, $m, $h, $day, $mon, $yr) = strptime($str);

  my $date = new DateTime(year => $yr + 1900,
			  month => $mon + 1,
			  day => $day,
			  hour => $h,
			  minute => $m,
			  second => $s,
			  time_zone => $zone_name);

  return $date->epoch;
}

# format a string to a given pattern
sub strftime {
  my $self = shift;

  return $self->{dt}->strftime(@_);
}

# for a given user, what is the short name of the timezone?  note that
# it depends on the time of year, so we accept a datetime object.  we
# default to now, which is suboptimal, but there is one case where a
# timezone is displayed without the time known (the schedule actions
# page, where the user inputs their time).  in this case, "now"'s
# timezone short name is more or less appropriate.

sub user_short_timezone {
  my $self_or_class = shift;
  my $user = shift;

  throw "no user!" unless $user;

  my $dtime;

  if (ref $self_or_class) {
    $dtime = $self_or_class->{dt};
  }
  else {
    $dtime = DateTime->now;
  }

  return $user->get_timezone->short_name_for_datetime($dtime);
}

# helper function for our classical "long_date" format; zoneless
sub long_date {
  my $self = shift;

  return $self->strftime("%Y-%m-%d %H:%M:%S");
}

# helper function for our classical "short_date" format; zoneless
sub short_date {
  my $self = shift;

  return $self->strftime("%Y-%m-%d");
}

# increment an RHN::Date object.  parameters are passed straight
# through to the datetime add method, which basically is like
# "$foo->add(hours => 2, minutes => 7), etc

sub add {
  my $self = shift;
  my @params = @_;

  $self->{dt}->add(@params);
}

# simple accessors
sub day { return shift->{dt}->day(@_); }
sub month { return shift->{dt}->month(@_); }
sub year { return shift->{dt}->year(@_); }
sub hour { return shift->{dt}->hour(@_); }
sub minute { return shift->{dt}->minute(@_); }
sub second { return shift->{dt}->second(@_); }
sub epoch { return shift->{dt}->epoch(@_); }

1;
