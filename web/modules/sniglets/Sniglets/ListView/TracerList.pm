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

package Sniglets::ListView::TracerList;

use Sniglets::ListView::List;
use RHN::Token;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:dev_tracer_cb";
}

sub _register_modes {
  Sniglets::ListView::List->add_mode(-mode => "dev_tracer_sessions",
			   -datasource => Sniglets::ListView::TracerList::SessionDS->new);

  Sniglets::ListView::List->add_mode(-mode => "dev_tracer_hits",
			   -datasource => Sniglets::ListView::TracerList::HitDS->new);
}

package Sniglets::ListView::TracerList::SessionDS;
use PXT::Trace;

sub new {
  my $class = shift;

  return bless { }, $class;
}

sub mode { }
sub clean { }
sub required_params { }

sub execute_query {
  my @ret = sort { $b->last_request_time <=> $a->last_request_time } PXT::Trace::DB->all_traces;

  return [ map { { (ID => $_->id,
		    USER => $_->user,
		    DOWNLOAD => "Download",
		    LAST_HIT => scalar localtime $_->last_request_time,
		    ACTIVE => time - $_->last_request_time < 7200 ? "Active" : "Inactive",
		    HIT_COUNT => scalar($_->hits),
		   )} } @ret ];
}

sub slice_data { return $_[1] }
sub elaborate { return $_[1] }

package Sniglets::ListView::TracerList::HitDS;
use PXT::Trace;

sub new {
  my $class = shift;

  return bless { }, $class;
}

sub mode { }
sub clean { }
sub required_params { return "session_id" }

sub execute_query {
  my $self = shift;
warn "XXX: @_";
  my %params = @_;

  my $trace = PXT::Trace::DB->lookup($params{-session_id});

  my $i = 1;
  return [ map { { ID => $i++, METHOD => $_->method, URI => $_->uri } } $trace->hits ];
}

sub slice_data { return $_[1] }
sub elaborate { return $_[1] }

1;
