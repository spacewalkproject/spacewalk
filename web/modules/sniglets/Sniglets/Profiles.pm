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

package Sniglets::Profiles;

use RHN::Profile;
use RHN::Channel;
use RHN::Manifest;
use RHN::Exception qw/throw catchable/;

use PXT::Utils;

use Data::Dumper;

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:sync_server_cb' => \&sync_server_cb);
}

sub sync_server_cb {
  my $pxt = shift;
  my $missing_packages_option = shift || '';

  my $earliest_date = $pxt->dirty_param('schedule_date') || Sniglets::ServerActions->parse_date_pickbox($pxt);
  my $set_label = $pxt->dirty_param('set_label');
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  my %valid_name_id = map { $_, 1 } $set->contents;

  my $source_profile_id = $pxt->param('prid');
  my $source_system_id = $pxt->param('sid_1');

  my $source;
  my $victim = RHN::Server->lookup(-id => $pxt->param('sid'));

  if ($source_profile_id) {
    $source = RHN::Profile->lookup(-id => $source_profile_id);
  }
  elsif ($source_system_id) {
    $source = RHN::Server->lookup(-id => $source_system_id);
  }
  else {
    die 'no source for sync operation?';
  }

  my $source_manifest = $source->load_package_manifest;
  my $victim_manifest = $victim->load_package_manifest;

  my @channels = map { $_->{ID} } $victim->server_channels;

  my %missing_packages = map { $_->name => $_ }
    grep { $valid_name_id{$_->name_id} } ($source_profile_id
			   ? $source->profile_packages_missing_from_channels(-channels => \@channels)
                           : $source->system_packages_missing_from_channels(-channels => \@channels));

  if (%missing_packages) {
    if ($missing_packages_option eq 'remove_packages') { # if the package exists on the victim, leave it alone
      $source_manifest->remove_packages(grep { defined } values %missing_packages);
      $source_manifest->add_packages(grep { defined }
				     map { $victim_manifest->packages_by_name_arch($_->name_arch) }
				     values %missing_packages);
    }
    elsif ($missing_packages_option eq 'subscribe_to_channels') {
      my @valid_child_channels =
	grep { $pxt->user->verify_channel_access($_) } RHN::Channel->children($source->base_channel_id);

      my @needed_channels;

      foreach my $cid (@valid_child_channels) {
	my @channel_packages = grep {
	  RHN::Package->is_package_in_channel(-cid => $cid,
					      -evr_id => $_->evr_id,
					      -name_id => $_->name_id) } values %missing_packages;

	if (@channel_packages) { # some of the missing packages are in this channel
	  push @needed_channels, $cid;

	  foreach my $pkg (@channel_packages) {
	    delete $missing_packages{$pkg->{NAME}};
	  }
	}
      }

      my $trans = RHN::DB->connect;
      $trans->nest_transactions;

      my @errors;

      foreach my $cid (@needed_channels) {
	eval {
	  $victim->subscribe_to_channel($cid);
	};
	if ($@) {
	  my $E = $@;
	  if ($E =~ /channel_family_no_subscriptions/) {
	    push @errors, { cid => $cid,
			    exception => $@ };
	  }
	  else {
	    $trans->nested_rollback;
	    throw $E;
	  }
	}
      }

      if (@errors) {
	$trans->nested_rollback;

	my %channel_family_names = map { (RHN::Channel->family($_->{cid})->{NAME}, 1) } @errors;
	my $message = join (', ', map { "<strong>$_</strong>" } keys %channel_family_names);

	if (scalar @errors == 1) {
	  $pxt->push_message(local_alert => sprintf(<<EOQ, $message));
You need an entitlement to %s to perform this package sync action.
EOQ
	}
	else {
	  $pxt->push_message(local_alert => sprintf(<<EOQ, $message));
To perform this package sync action, you need the following entitlements: %s.
EOQ
	}

	$set->empty;
	$set->commit;

	$pxt->redirect('/rhn/systems/details/packages/profiles/ShowProfiles.do?sid=' . $victim->id);
      }

      $trans->nested_commit;

      if (%missing_packages) { # still some missing, get rid of 'em
	$source_manifest->remove_packages(grep { defined } values %missing_packages);
	$source_manifest->add_packages(grep { defined }
				       map { $victim_manifest->packages_by_name_arch($_->name_arch) }
				       values %missing_packages);
      }
    }
    else {
      my %params = (sid => $victim->id);
      $params{sid_1} = $source_system_id if $source_system_id;
      $params{prid} = $source_profile_id if $source_profile_id;
      $params{set_label} = $set_label;
      $params{schedule_date} = $earliest_date;

      $pxt->redirect("/rhn/systems/details/packages/profiles/MissingPackages.do?" . join('&', map { $_ . '=' . $params{$_} } keys %params));
    }
  }

  my $comparison = $source_manifest->compare_manifests($victim_manifest);

  $comparison =
    [ grep { exists $valid_name_id{($_->{S1} || $_->{S2})->name_id} } @$comparison
    ];

  my $action_id = RHN::Scheduler->schedule_package_sync(-user_id => $pxt->user->id,
							-org_id => $pxt->user->org_id,
							-server_id => $victim->id,
							-earliest => $earliest_date,
							-comparison => $comparison);

  $set->empty;
  $set->commit;

  my $msg = <<EOQ;
You have successfully <strong><a href="/network/systems/details/history/event.pxt?sid=%d&amp;hid=%d">scheduled</a></strong>
a package profile sync for <strong>%s</strong> from <strong>%s</strong>.
EOQ
  $pxt->push_message(site_info =>
		     sprintf($msg, $pxt->param('sid'), $action_id, PXT::Utils->escapeHTML($victim->name),PXT::Utils->escapeHTML($source->name)) );

  if ($source_profile_id) {
    $pxt->redirect(sprintf("compare.pxt?prid=%d&sid=%d", $source->id, $victim->id));
  }
  else {
    $pxt->redirect(sprintf("system_compare.pxt?sid_1=%d&sid=%d", $source->id, $victim->id));
  }
}

1;
