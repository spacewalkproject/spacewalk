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
use RHN::CryptoKey;
use RHN::Exception qw/throw catchable/;

package Sniglets::CryptoKey;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-ckey-details' => \&edit_ckey);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:edit_ckey_cb' => \&edit_ckey_cb);
  $pxt->register_callback('rhn:delete_ckey_cb' => \&delete_ckey_cb);
}

sub edit_ckey {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my $ck;
  if ($pxt->param('ckid')) {
    $ck = RHN::CryptoKey->lookup(-id => $pxt->param('ckid'));
  }
  else {
    $ck = new RHN::CryptoKey;
  }

  my %subst;
  $subst{ckey_description} = $ck->description;
  $subst{ckey_key} = $ck->key;

  my $current_type_id = $ck->crypto_key_type_id || -1;
  my $current_type_label = "(none)";
  my @type_options;

  for my $row (RHN::CryptoKey->key_type_list) {
    push @type_options, [ $row->{LABEL}, $row->{ID}, $row->{ID} == $current_type_id ];
    $current_type_label = $row->{LABEL} if $row->{ID} == $current_type_id;
  }

  $subst{ckey_type_text} = $current_type_label;

  PXT::Utils->escapeHTML_multi(\%subst);

  $subst{ckey_type_select} = PXT::HTML->select(-name => "ckey_crypto_key_type_id",
					       -options => \@type_options );
  return PXT::Utils->perform_substitutions($block, \%subst);
}

sub edit_ckey_cb {
  my $pxt = shift;

  my $ck;
  if ($pxt->param('ckid')) {
    $ck = RHN::CryptoKey->lookup(-id => $pxt->param('ckid'));
  }
  else {
    $ck = new RHN::CryptoKey;
  }

  my $desc = $pxt->dirty_param('ckey_description') || '';
  if ($desc =~ /^\s*$/) {
    $pxt->push_message(local_alert => "You must enter a Description.");
    return;
  }

  $ck->$_($pxt->dirty_param("ckey_$_")) for qw/description crypto_key_type_id/;
  $ck->org_id($pxt->user->org_id);

  if ($pxt->upload) {
    my $fh = $pxt->upload->fh;
    my $contents = do { local $/; <$fh> };
    $ck->key($contents);
  }
  else {
    $ck->key($ck->key || '');
  }

  unless ($ck->key) {
    $pxt->push_message(local_alert => "No data found for key.  Please choose another file.");
    return;
  }

  eval {
    $ck->commit;
  };

  if ($@) {
    my $E = $@;

    if (ref $E and $E->catchable and $E->constraint_value eq 'RHN_CRYPTOKEY_OID_DESC_UQ') {
      $pxt->push_message(local_alert => "Description must be unique. Please try a different one.");
      if ($pxt->param('ckid')) {
	$pxt->redirect("/network/keys/edit.pxt?ckid=" .$pxt->param('ckid'));
      } else {
	$pxt->redirect("/network/keys/edit.pxt");
      }
    } else {
      throw $E;
    }
  } else {
    $pxt->push_message(site_info => "Key updated.");
    $pxt->redirect("key_list.pxt");
  }
}

sub delete_ckey_cb {
  my $pxt = shift;

  my $ckid = $pxt->param('ckid');
  my $ck = RHN::CryptoKey->lookup(-id => $ckid);

  $ck->delete;
  $pxt->redirect("key_list.pxt");
}

1;
