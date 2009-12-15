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

package PXT::Utils;
use strict;

use Apache2::Util ();
use HTML::Entities ();
use POSIX;
use Date::Parse;
use Carp qw/croak/;

# this is a temporary conversion until we do the database schema
# alteration.  this lets us get a head start.
my %timezone_conversions =
  ( -11 => 'Pacific/Midway',
    -10 => 'Pacific/Honolulu',
    -9 => 'America/Anchorage',
    -8 => 'America/Los_Angeles',
    -7 => 'America/Denver',
    -6 => 'America/Chicago',
    -5 => 'America/New_York',
    -4 => 'America/Halifax',
    '-3.5' => 'America/St_Johns',
    -3 => 'America/Sao_Paulo',
    -2 => 'Atlantic/South_Georgia',
    -1 => 'Atlantic/Azores',
    0 => 'GMT',
    1 => 'Europe/Paris',
    2 => 'Europe/Bucharest',
    3 => 'Europe/Moscow',
    '3.5' => 'Asia/Tehran',
    4 => 'Indian/Mauritius',
    '4.5' => 'Asia/Tehran',
    5 => 'Indian/Maldives',
    '5.5' => 'Asia/Calcutta',
    '5.75' => 'Asia/Katmandu',
    6 => 'Indian/Chagos',
    '6.5' => 'Indian/Cocos',
    7 => 'Asia/Jakarta',
    8 => 'Asia/Hong_Kong',
    9 => 'Asia/Tokyo',
    '9.5' => 'Australia/Darwin',
    10 => 'Australia/Sydney',
    11 => 'Pacific/Guadalcanal',
    '11.5' => 'Pacific/Norfolk',
    12 => 'Pacific/Wallis',
    13 => 'Pacific/Enderbury'
  );

sub olson_from_offset {
  my $class = shift;
  my $offset = shift;

  return $timezone_conversions{$offset};
}

# return a list of the selectable timezones for user prefs
sub get_timezones {
  my $class = shift;

  my $ds = new RHN::DataSource::Simple(-querybase => "User_queries",
                                       -mode => "available_timezones");

  my $result = $ds->execute_query();

  return @$result;
}

# take 2 timestamps, return relative difference between them
sub relative_time_diff {
  my $class = shift;
  my $time1 = shift; # timestamp
  my $time2 = shift; # timestamp

  # might want to suck in Date::Calc, but for now do this...

  my $delta = abs($time2 - $time1);

  my %diff;
  $diff{seconds} = $delta % 60;
  $diff{minutes} = int($delta / 60) % 60;
  $diff{hours} = int($delta / 3600) % 24;
  $diff{days} = int($delta / 86400);
  $diff{direction} = $time2 > $time1 ? 1 : -1;

  return \%diff;
}

# given the output of relative_time_diff, show a prettier string
# (also must give the fields you want, ie. 'day', 'minute', 'second', etc...)
sub pretty_relative_time {
  my $class = shift;
  my $diff_ref = shift;
  my @fields = @_;

  my @ret;
  foreach my $singular (@fields) {
    my $plural = $singular . 's';
    my $value = $diff_ref->{$plural};
    push @ret, $value eq 1 ? $value . " $singular" : $value . " $plural";
  }

  if (scalar(@ret) > 1) {
    $ret[-1] = 'and ' . $ret[-1];
  }

  return join(", ", @ret);
}

sub split_attributes {
  my $blob = shift;

  my @ret;
  my @a = $blob =~ m((\S+)="([^"]*)")g;
  while (my ($attr, $val) = splice @a, 0, 2) {
    push @ret, $attr, $val;
  }

  @a = $blob =~ m((\S+)=([^\s"]+))g;
  while (my ($attr, $val) = splice @a, 0, 2) {
    push @ret, $attr, $val;
  }

  return @ret;
}

sub country_selectbox {
  my ($class, $formvar, $lang, $default, $current, $allow_empty) = @_;

  $lang ||= 'en';
  $current ||= $default || '';

  my $dbh = RHN::DB->connect;

  my $sql = "SELECT vc.code, nvl(short_name_tl, short_name)
               FROM valid_countries vc, valid_countries_tl tl
               where tl.lang (+) = ? and tl.code (+)= vc.code
               ORDER BY vc.short_name";

  my $sth = $dbh->prepare($sql);
  $sth->execute($lang);

  my @codes;

  while (my @r = $sth->fetchrow) {

    next if (grep { $_ eq uc $r[0] } qw/US CA MX/);

    push @codes, \@r;
  }
  $sth->finish();

  unshift @codes, ( ["US", "United States"], ["MX", "Mexico"], ["CA", "Canada"]);

  if ($allow_empty) {
    unshift @codes, [ "", "None" ];
  }

  my @opts;
  foreach my $country (@codes) {
    push @opts, [ $country->[1], $country->[0], (lc($country->[0]) eq lc($current)) ? 1 : 0 ];
  }

  my $ret = PXT::HTML->select(-name => $formvar,
			      -size => 1,
			      -options => \@opts);

  return $ret;
}

sub paginate_variables {
  my $class = shift;
  my $block = shift;
  my ($upper, $lower, $total, $page_size) = @_;

  my ($prev_lower, $prev_upper) = ($lower - $page_size,
				   $lower - 1);

  my ($next_lower, $next_upper) = ($upper + 1,
				   $upper + $page_size);

  my ($first_lower, $first_upper) = (1, $page_size);

  my $last_upper = $total;

  my $last_lower = ($total % $page_size) == 0 ? $total - $page_size  + 1 : $total - ($total % $page_size) + 1;

  if ($prev_lower < 1) {
    $prev_lower = 1;
    $prev_upper = $page_size;
  }

  if ($next_lower > $total) {
    $next_lower = $lower;
    $next_upper = $upper;
  }
  else {
    $next_upper = $total if $next_upper > $total;
  }

  $block =~ s/\{current_total\}/$total/g;

  $block =~ s/\{next_lower\}/$next_lower/g;
  $block =~ s/\{next_upper\}/$next_upper/g;
  $block =~ s/\{current_lower\}/$lower/g;
  $block =~ s/\{current_upper\}/$upper/g;
  $block =~ s/\{prev_lower\}/$prev_lower/g;
  $block =~ s/\{prev_upper\}/$prev_upper/g;
  $block =~ s/\{first_lower\}/$first_lower/g;
  $block =~ s/\{first_upper\}/$first_upper/g;
  $block =~ s/\{last_lower\}/$last_lower/g;
  $block =~ s/\{last_upper\}/$last_upper/g;

  return $block;
}

sub escapeHTML {
  my $class = shift;
  my $text = shift;

  warn "undef text in escapeHTML, called from '", join(' ', caller), "'\n"
    unless defined $text;

  return HTML::Entities::encode_entities($text, '<>&"');
}

# escape either elements of an arrayref or values of a hashref
sub escapeHTML_multi {
  my $class = shift;
  my $ref = shift;

  return unless defined $ref;

  if (! ref $ref) {
    return HTML::Entities::encode_entities($ref, '<>&"');
  }
  elsif (ref $ref eq 'HASH') {
    foreach my $key (keys %{$ref}) {
      $ref->{$key} = $class->escapeHTML_multi($ref->{$key});
    }
  }
  elsif (ref $ref eq 'ARRAY') {
    foreach my $elem (@{$ref}) {
      $elem = $class->escapeHTML_multi($elem);
    }
  }
  else {
    croak "Unhandled ref '$ref' from '" . (caller) . "'\n";
  }

  return $ref;
}

sub escape_html {
  my $class = shift;
  return HTML::Entities::encode_entities(shift, '<>&"');
}

sub escapeURI {
  my $class = shift;
  my $str;
  if (scalar @_) {
     $str = shift;
  }
  else {
    $str = '';
  }
  my $ret = Apache2::Util::escape_path($str, Apache2::RequestUtil->request->pool);
  $ret =~ s(\+)(%2b)g;
  return $ret;
}

sub unescapeURI {
  my $class = shift;
  my $str = shift || '';

  $str =~ s/\+/ /g;
  $str =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
  $str =~ s(%2b)(\+)g;

  return $str;
}


sub perform_substitutions {
  my $class = shift;
  my $block = shift;
  my $prefix = shift;
  my $map = shift;

  if (not ref $map) {
    $map = $prefix;
    $prefix = '';
  }

  foreach my $k (keys %$map) {
    my $sub = defined $map->{$k} ? $map->{$k} : '';
    $block =~ s/\{$prefix$k\}/$sub/g;
  }

  return $block;
}

sub generate_salt {
  my $class = shift;
  my $length = shift;

  my @chars = ('a' .. 'z', 'A' .. 'Z', '0' .. '9', '.', '/');
  my $ret;

  $ret .= $chars[int rand @chars] while $length--;

  return $ret;
}

sub random_password {
  my $class = shift;
  my $length = shift;

  die "random password too short"
    unless $length > 5;

  my $ret;
  my @chars = ('a'..'z');
  my @nums = ('0'..'9');

  $ret .= $chars[int rand @chars]
    while $length-- > 5;

  $ret .= $nums[int rand @nums]
    while $length-- >= 0;

  return $ret;
}

sub prefix_selectbox {
  my ($class, $formvar, $default) = @_;

  my $dbh = RHN::DB->connect;

  my $sql = "SELECT text FROM web_user_prefix WHERE text <> '.' AND text <> ' ' ORDER BY text";

  my $sth = $dbh->prepare($sql);
  $sth->execute;

  my @codes;
  while (my ($prefix) = $sth->fetchrow) {
    push @codes, [ $prefix, $prefix, $default ne '.' ? $default eq $prefix : $prefix eq 'Mr.' ];
  }
  $sth->finish();

  return PXT::HTML->select(-name => $formvar,
			   -options => \@codes);
}

# take a positive integer, return a pretty version with commas
sub commafy {
  my $class = shift;
  my $n = scalar reverse shift;

  $n =~ s/(\d\d\d)(?!$)/$1,/g;

  return scalar reverse $n;
}

sub humanify {
  my $class = shift;
  my $n = shift;
  my $suffix = shift || '';
  my $dec = shift;

  my $unit = '';
  my $form;
  if ($dec) {
    $form = "%.${dec}f";
  }
  else {
    $form = "%d";
  }

  if ($n > 1 * 1024 * 1024 * 1024) {
    $n = sprintf $form, $n/1024/1024/1024;
    $unit = 'G';
  }
  elsif ($n > 1 * 1024 * 1024) {
    $n = sprintf $form, $n/1024/1024;
    $unit = 'M';
  }
  elsif ($n > 1 * 1024) {
    $n = sprintf $form, $n/1024;
    $unit = 'K';
  }

  if ($unit) {
    return "$n$unit$suffix";
  }
  else {
    return "$n$suffix";
  }
}

sub untaint {
  my $class = shift;
  my $dref = shift;

  if ($$dref =~ /\A(.*)\Z/ms) {
    $$dref = $1;
  }
}

sub random_bits {
  my $class = shift;
  my $n = shift;

  open(RANDOM, '/dev/urandom') or die 'could not open /dev/urandom for reading!';
  binmode(RANDOM);
  my $rand_data;
  my $result = read(RANDOM, $rand_data, $n >> 3);
  close(RANDOM);

  unless (defined $result) {
    die 'could not read from /dev/urandom!';
  }

  return $rand_data;
}


sub get_subtag_body {
  my $class = shift;
  my $tagname = shift;
  my $source = shift;

  if ($source =~ m{<$tagname>(.*?)</$tagname>}ism) {
    return $1;
  }

  return undef;
}

sub replace_subtag {
  my $class = shift;
  my $tagname = shift;
  my $target = shift;
  my $replacement = shift;

  $target =~ s{<$tagname>.*?</$tagname>}{$replacement}ism;

  return $target;
}

1;
