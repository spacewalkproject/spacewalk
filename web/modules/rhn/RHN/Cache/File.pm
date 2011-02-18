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

package RHN::Cache::File;

use strict;

use RHN::Exception qw/throw/;
use Params::Validate qw/:all/;
use File::Spec;

my %field_defaults = (__path__ => '',
		      __contents__ => '',
		      __parsed_contents__ => undef,
		      __no_cache__ => 0,
		      __cache_time__ => 0,
		      __parser__ => sub { return shift },
		     );

my %valid_args = (path      => { type => SCALAR, optional => 1 },
		  directory => { type => SCALAR, optional => 1 },
		  name      => { type => SCALAR, optional => 1 },
		  no_cache  => { type => SCALAR, optional => 1 },
		  parser  => { type => CODEREF, optional => 1 },
		 );

my %cache;

# path - the directory and name of the file in question.  Must provide either this or directory+name
# directory - the directory where the file lives.
# name - the name of the file.
# no_cache - if true, then don't cache the data, just keep track of modification time.

sub new {
  my $class = shift;
  my %args = validate_with(params => \@_,
			   spec => \%valid_args,
			   strip_leading => '-');

  my $self = bless { %field_defaults }, $class;

  foreach (grep { exists $args{$_} } qw/path no_cache parser/) {
    $self->$_($args{$_});
  }

  if (exists $args{directory} and exists $args{name}) {
    $self->path(File::Spec->catfile($args{directory}, $args{name}));
  }

  $self->_validate;

  if (exists $cache{$self->path()}) {
    return $cache{$self->path()};
  }

  $cache{$self->path()} = $self;

  return $self;
}

# Public methods

sub last_modified {
  my $self = shift;

  return (stat $self->path())[9] || 0;
}

# Get the file contents, from the cache if available, otherwise from disk.
sub contents {
  my $self = shift;

  if ($self->is_up2date and not $self->no_cache) {
    return $self->{__contents__};
  }

  my $path = $self->path;
  local $/;
  local * DATA;
  open(DATA, '<', $path) or throw "Could not open '$path' - $!";
  my $ret = <DATA>;
  close(DATA);

  unless ($self->no_cache) {
    $self->{__contents__} = $ret;
  }

  return $ret;
}

sub parse {
  my $self = shift;

  if ($self->is_up2date and not $self->no_cache) {
    return $self->{__parsed_contents__};
  }

  my $parser = $self->parser;
  my $ret = &{$parser}($self->contents);

  $self->cache_time($self->last_modified);

  unless ($self->no_cache) {
    $self->{__parsed_contents__} = $ret;
  }

  return $ret;
}

# Has the file been touched since being cached?
sub is_up2date {
  my $self = shift;

  return ($self->cache_time and ($self->last_modified == $self->cache_time)) ? 1 : 0;
}

# Accessors.

sub path {
  my $self = shift;
  my $path = shift;

  if (defined $path) {
    $self->{__path__} = $path;
  }

  return $self->{__path__};
}

sub directory {
  my $self = shift;
  my ($vol, $dir, $file) = File::Spec->splitpath($self->path);

  return $dir;
}

sub name {
  my $self = shift;
  my ($vol, $dir, $file) = File::Spec->splitpath($self->path);

  return $file;
}

sub parser {
  my $self = shift;
  my $parser = shift;

  if (defined $parser) {
    throw "parser ($parser) is not a code ref." unless (ref $parser eq 'CODE');
    $self->{__parser__} = $parser;
  }

  return $self->{__parser__};
}

sub cache_time {
  my $self = shift;
  my $cache_time = shift;

  if (defined $cache_time) {
    $self->{__cache_time__} = $cache_time;
  }

  return $self->{__cache_time__};
}

sub no_cache {
  my $self = shift;
  my $no_cache = shift;

  if (defined $no_cache) {
    if ($no_cache) {
      $self->{__no_cache__} = 1;
    }
    else {
      $self->{__no_cache__} = 0;
    }
  }

  return $self->{__no_cache__};
}

#Private methods.

sub _validate {
  my $self = shift;

  foreach (qw/path/) {
    throw "${_} not specified in new for '$self'" unless $self->$_();
  }

  return 1;
}

1;

