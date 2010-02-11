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

package Sniglets::ListView::ContactMethodList;

use Sniglets::ListView::List;
use RHN::DataSource::ContactMethod;

our @ISA = qw/Sniglets::ListView::List/;

my %mode_data;
sub mode_data { return \%mode_data }

_register_modes();

sub trap {
  return "rhn:contact_method_list_cb";
}

sub list_of { return "contact methods" }

sub _register_modes {

  Sniglets::ListView::List->add_mode(-mode => "users_contact_methods",
			   -datasource => RHN::DataSource::ContactMethod->new,
			   -provider => \&users_methods_provider);

  Sniglets::ListView::List->add_mode(-mode => "orgs_contact_method_tree",
			   -datasource => RHN::DataSource::ContactMethod->new,
			   -provider => \&orgs_method_tree_provider);
}



sub users_methods_provider {
  my $self = shift;
  my $pxt = shift;

  my $uid = $pxt->param('uid') || $pxt->user->id;
  my $user = RHN::User->lookup(-id => $uid);
  my %ret = $self->default_provider($pxt, (-user_id => $user->id));

  return (%ret);
}


sub orgs_method_tree_provider {
  my $self = shift;
  my $pxt = shift;

  my $oid = $pxt->user->org->id;
  my %ret = $self->default_provider($pxt, (-org_id => $oid));

  # mark the first contact method for each contact for rendering of
  # the tree.
  my $current_contact = 0;
  my $method_index = 0;

  foreach my $row (@{$ret{data}}) {
    if ($row->{CONTACT_ID} != $current_contact) {
      $current_contact = $row->{CONTACT_ID};
      my $contact_row = { CONTACT_ID => $row->{CONTACT_ID},
                          CONTACT_LOGIN => $row->{CONTACT_LOGIN},
                          METHOD_NAME => '',
                          METHOD_TARGET => '', 
                          METHOD_ID => '' };

      if (not $row->{METHOD_ID}) {
	$row->{METHOD_NAME} = '(No contact methods for user)';
      }

      splice @{$ret{data}}, $method_index, 0, $contact_row;
    }
    ++$method_index;
  }
  return (%ret);
}


# only increment when we're on the first method of a new contact.
sub incr_row_counter {
  my $self = shift;
  my $row = shift;
  my $pxt = shift;

  if ($self->datasource->mode eq 'orgs_contact_method_tree') {
    if (not exists $row->{METHOD_NAME} or (exists $row->{METHOD_NAME} and $row->{METHOD_NAME} eq '')) {
      $self->SUPER::incr_row_counter($self, $row, $pxt);
    }
  }
  else {
    $self->SUPER::incr_row_counter($row, $pxt);
  }
}

sub render_url {
  my $self = shift;
  my $pxt = shift;
  my $url = shift;
  my $row = shift;
  my $url_column = shift;

  if (($self->datasource->mode eq 'orgs_contact_method_tree') && ($row->{METHOD_NAME} eq '')) {
    $url = "/network/users/details/contact_methods/index.pxt?uid={column:contact_id}";
    $url_column = "CONTACT_LOGIN";

    if (not $pxt->user->is('org_admin')) {
      $url = "/network/monitoring/notifications/contact_methods/index.pxt?uid={column:contact_id}";
    }
  }

  my $ret;

  if (($self->datasource->mode eq 'orgs_contact_method_tree') && ($row->{METHOD_NAME} ne '')) {
    if (not $pxt->user->is('org_admin')) {
      $url = '/network/monitoring/notifications/contact_methods/edit.pxt?cmid={column:method_id}';
    }

    $ret = '<img src="/img/branch.gif" />&#160;';

    if (not $row->{METHOD_ID}) {
      return $ret . $row->{METHOD_NAME};
    }
  }

  $ret = $ret . $self->SUPER::render_url($pxt, $url, $row, $url_column);

  return $ret;
}

1;
