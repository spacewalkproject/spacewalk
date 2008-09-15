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

package Sniglets::Sets;

use Carp;
use Data::Dumper;
use RHN::Exception qw/throw/;

use RHN::Set;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag('rhn-set-totals' => \&set_totals);
  $pxt->register_tag('rhn-xml-checker' => \&xml_checker);
}

sub register_callbacks {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_callback('rhn:clear_set_cb', \&clear_set_cb);
}

sub set_totals {
  my $pxt = shift;
  my %params = @_;

  my $block = $params{__block__};
  my @set_stats = $pxt->user->selection_details;
  my %sets = map {$_->[0] => $_->[1]} @set_stats;

  if ($params{set}) {
    if ($params{noun}) {
      return sprintf("%s %s%s selected",
		     $sets{$params{set}} || "No",
		     $params{noun},
		     ((not exists $sets{$params{set}}) || $sets{$params{set}} > 1) ? "s" : "");
    }
    else {
      return sprintf "%d", $sets{$params{set}} || 0;
    }
  }

  foreach my $set (qw/system_list server_group_list user_group_list user_list package_upgradable_list package_installable_list package_removable_list errata_list channel_list/) {

    $block =~ s/\{${set}_set_count\}/$sets{$set} ? $sets{$set} : '0'/eg;
  }

  return $block;
}

sub clear_set_cb {
  my $pxt = shift;

  my $set_label = $pxt->pnotes('set_to_clear') || $pxt->dirty_param('selection');
  my $set = RHN::Set->lookup(-label => $set_label, -uid => $pxt->user->id);

  throw "No valid set!" unless $set;
  $set->empty;
  $set->commit;

  $pxt->redirect($pxt->param('set_clear_redirect') || $pxt->uri);
}

sub xml_checker {
  my $pxt = shift;

  $pxt->manual_content(1);
  $pxt->no_cache(1);
  $pxt->content_type('text/xml');
  $pxt->send_http_header;

  my %set_var_map = ( system_list => "sid" );
  my $set_label = $pxt->dirty_param('set_label');

  if (not $set_label or not exists $set_var_map{$set_label}) {
    $pxt->print("INVALID SET");
    return;
  }

  my $set = new RHN::DB::Set $set_label, $pxt->user->id;

  my @which = $pxt->param($set_var_map{$set_label});

  if ($pxt->dirty_param("checked") and $pxt->dirty_param("checked") eq "on") {
    $set->immediate_add(@which);
  }
  else {
    $set->immediate_remove(@which);
  }
  RHN::DB->connect->commit;

  my $count = $set->element_count;
  my $header_message;

  if ($count == 0) {
    $header_message = 'No systems selected';
  }
  elsif ($count == 1) {
    $header_message = '1 system selected';
  }
  else {
    $header_message = "$count systems selected";
  }

  my $pagination_message = "($count selected)";

  my $ret = <<EOS;
<?xml version="1.0" encoding="utf-8"?>

<ssm-data>
  <ssm-count-header-message>$header_message</ssm-count-header-message>
  <ssm-count-pagination-message>$pagination_message</ssm-count-pagination-message>
  <ssm-count>$count</ssm-count>
</ssm-data>
EOS

  $pxt->print($ret);
}

1;
