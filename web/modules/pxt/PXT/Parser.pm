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

package PXT::Parser;

use strict;
use bytes;

use PXT::Utils;
use Time::HiRes;
use BSD::Resource;
use PXT::Config;
use Scalar::Util;

sub new {
  my $class = shift;

  my $self = bless { tag_handlers => [ ],
		     callbacks => [ ],
		   }, $class;

  return $self;
}

sub register_tag {
  my $self = shift;
  my $tag = shift;
  my $handler = shift;
  my $priority = shift;

  push @{$self->{tag_handlers}}, [ $tag, $handler, $priority || 0 ];
}

sub tags { return @{$_[0]->{tag_handlers}} }

sub register_callback {
  my $self = shift;
  my $callback = shift;
  my $handler = shift;

  push @{$self->{callbacks}}, $callback, $handler;
}

sub callbacks { return @{$_[0]->{callbacks}} }

sub expand_tags {
  my $self = shift;
  my $dataref = shift;

  my @tags = $self->tags;

  if ($$dataref =~ /<(pxt|rhn):/) {
    warn "Egads, there seems to be a <pxt:...> or <rhn:...> tag somewhere...";
  }

  foreach my $tblock (sort { $a->[2] <=> $b->[2] } @tags) {
    my ($tag, $handler) = @$tblock;

    my @then = (Time::HiRes::time, getrusage);
    $self->expand_tag($tag, $handler, $dataref, @_);
    my @now = (Time::HiRes::time, getrusage);

    my $threshold = PXT::Config->get('tag_timing_threshold');

    if ($threshold && ($now[0] - $then[0]) > $threshold) {
      warn sprintf "[timing] slow expansion of tag '%s': %.4f seconds (%.4f user/%.4f sys)\n",
	$tag, ($now[0] - $then[0]), ($now[1] - $then[1]), ($now[2] - $then[2]);
    }
  }
}

sub expand_tag {
  my $self = shift;
  my $tag = shift;
  my $handler = shift;
  my $dataref = shift;

  my $single;
  my @params = @_;

  while(1) {
    my $single = 1;
    my $start = index $$dataref, "<$tag/>";
    if ($start < 0) {
      $start = index $$dataref, "<$tag>";
      $single = 0;
    }
    if ($start < 0) {
      $start = index $$dataref, "<$tag ";
      $single = 0;
    }

    return if $start < 0;

    my ($end, $actual_tag, $close_tag);

    if ($single) {
      $end = $start + length($tag) + 2;
      $close_tag = -1;
    }
    else {
      $end = index $$dataref, ">", $start;

      # is the '>' preceded by a '/', forming a '/>' ?
      my $has_children = 1;
      if (substr($$dataref, $end - 1, 1) eq '/') {
	$has_children = 0;
      }

      $close_tag = index $$dataref, "</$tag>", $end;

      # ... continued from above.  does it have children, but no close
      # tag?  oops
      if ($close_tag < 0 and $has_children) {
	die "PXT::Parser->expand_tag: '$tag' is childless but not of form <$tag ... />";
      }
    }
    $actual_tag = substr $$dataref, $start + 1, $end - $start - 1;

    my %attrs = PXT::Utils::split_attributes($actual_tag);

    if ($close_tag < 0) {
      my $val;

      if (ref $handler eq 'ARRAY') {
	$val = $handler->[0]->(@params, __function_params__ => [ @{$handler}[1..$#$handler] ], %attrs);
      }
      else {
	$val = $handler->(@params, %attrs);
      }
      if (not defined $val) {
	$val = '';
      }

      PXT::Utils->untaint(\$val)
	  if Scalar::Util::tainted($val);

      substr($$dataref, $start, $end - $start + 1) = $val;
    }
    else {
      my $val;

      if (ref $handler eq 'ARRAY') {
	$val = $handler->[0]->(@params, __function_params__ => [ @{$handler}[1..$#$handler] ],
			       %attrs, __block__ => substr($$dataref, $end + 1, $close_tag - $end - 1));
      }
      else {
	$val = $handler->(@params, %attrs,
			  __block__ => substr($$dataref, $end + 1, $close_tag - $end - 1));
      }
      if (not defined $val) {
	$val = '';
      }

      PXT::Utils->untaint(\$val)
	  if Scalar::Util::tainted($val);

      substr ($$dataref, $start, $close_tag + length("</$tag>") - $start) = $val || '';
    }
  }
}

1;
