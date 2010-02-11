#
# Copyright (c) 2008--2010 Red Hat, Inc.
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
package PXT::Trace;

use Cache::FileCache;

sub create {
  my $class = shift;
  my $id = shift;

  my $self = bless { user => undef, id => $id }, $class;
  return $self;
}

sub user {
  my $self = shift;

  if (@_) {
    $self->{user} = shift;
  }

  return $self->{user};
}

sub id {
  my $self = shift;

  if (@_) {
    $self->{id} = shift;
  }

  return $self->{id};
}

sub last_request_time {
  my $self = shift;

  return $self->{last_request_time};
}

sub add_hit {
  my $self = shift;
  my $hit = shift;

  push @{$self->{hits}}, $hit;
  $self->{last_request_time} = time;
}

sub hits {
  my $self = shift;

  return @{$self->{hits}};
}

sub deserialize {
  my $class = shift;
  my $str = shift;

  no strict;
  my $trace = eval $str;
  use strict;

  die "Error parsing trace data: $@" unless $trace and ref($trace) and $trace->isa("PXT::Trace");

  return $trace;
}

sub serialize {
  my $self = shift;

  use Data::Dumper;
  return Dumper($self);
}

package PXT::Trace::DB;

sub lookup {
  my $class = shift;
  my $id = shift;

  my $cache = new Cache::FileCache({namespace => 'pxt_trace'});
  return $cache->get($id);
}

sub all_traces {
  my $class = shift;

  my $cache = $class->get_cache;
  my @ret;
  for my $k ($cache->get_keys) {
    next if $k eq 'tracing_active';

    push @ret, $k;
  }
  return map { PXT::Trace::DB->lookup($_) } @ret;
}


sub commit {
  my $class = shift;
  my $trace = shift;

  my $cache = $class->get_cache;
  $cache->set($trace->id, $trace);
}

sub active {
  my $class = shift;

  my $cache = $class->get_cache;

  if (@_) {
    $cache->set(tracing_active => shift);
  }

  return $cache->get('tracing_active') || 0;
}

sub get_cache {
  return new Cache::FileCache({namespace => 'pxt_trace'});
}

package PXT::Trace::Hit;

sub new {
  my $class = shift;

  return bless { }, $class;
}

my %allowed_methods =
  (
   (map { $_ => 'scalar' } qw /uri method result_code duration content_length alert/),
   (map { $_ => 'list' } qw /params extras seen_html extra_data/),
  );

sub DESTROY { }
sub AUTOLOAD {
  my $self = shift;
  our $AUTOLOAD;

  my $method = $AUTOLOAD;
  $method =~ s/.*:://;
  my $variant = '';
  if ($method =~ /^push_(.*)/) {
    $variant = 'push';
    $method = $1;
  }

  my $method_type = $allowed_methods{"push_$method"} || $allowed_methods{$method};
  if (not defined $method_type) {
    die "Unknown method $method to object of class $self";
  }
  if ($method_type eq 'scalar') {
    if (@_) {
      $self->{$method} = shift;
    }
    return $self->{$method};
  }
  elsif ($method_type eq 'list') {
    if ($variant eq 'push') {
      push @{$self->{$method}}, @_;
      return;
    }
    else {
      if (@_) {
	$self->{$method} = [ @_ ];
      }
      return @{$self->{$method} || []};
    }
  }

  die "Unknown method type $method_type for method $method of class $self";
}

1;
