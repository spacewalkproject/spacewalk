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

package PXT::Handlers;

use RHN::DB ();
use PXT::Config ();
use PXT::Handlers ();
use PXT::Utils ();

sub register_primary_tags {
  my $class = shift;
  my $parser = shift;
  my $pxt = shift;
  my $pxt_use_classes = shift;

  $parser->register_tag('pxt-use' => [ \&pxt_use_handler, $pxt_use_classes ], -200);
  $parser->register_tag('pxt-include' => \&pxt_include_handler, -150);
  $parser->register_tag('pxt-passthrough' => \&pxt_passthrough_handler, -1000);
  $parser->register_tag('pxt-form' => \&pxt_form_handler, -1000);
  $parser->register_tag('pxt-comment' => sub { return '' }, -1000);
  $parser->register_tag('pxt-a' => \&pxt_a_handler, -1000);
  $parser->register_tag('pxt-config' => \&pxt_config_handler);
  $parser->register_tag('pxt-http-status' => \&pxt_http_status_handler);
  $parser->register_tag('pxt-hidden' => \&pxt_hidden_handler, 500);

  $parser->register_tag('pxt-profile' => \&pxt_profile_handler, 5000);

  $parser->register_tag('pxt-formvar' => \&pxt_formvar_handler, -500);
}

sub register_secondary_tags {
  my $class = shift;
  my $parser = shift;

  $parser->register_tag('pxt-include-late' => \&pxt_include_handler, 150);
  $parser->register_tag('pxt-pnote' => \&pxt_pnote_handler, 5000);
  $parser->register_tag('pxt-session' => \&pxt_session_handler, 5000);
  $parser->register_tag('pxt-messages' => \&pxt_messages_handler, 5000);
}


sub pxt_http_status_handler {
  my $pxt = shift;
  my %a = @_;

  my $code;

  unless (defined $a{code} and $a{code} =~ m/^\d\d\d$/) {
    die "invalid arguments to http status handler:  " . join(", ", %a);
  }

  $code = $a{code};
  $pxt->status($code);

  return '';
}

sub pxt_formvar_handler {
  my $pxt = shift;
  my %a = @_;
  return $pxt->prefill_form_values($a{__block__});
}

sub pxt_use_handler {
  my $pxt = shift;
  my %a = @_;
  push @{$a{__function_params__}->[0]}, $a{class} || $a{module} ;
  return '';
}

sub pxt_include_handler {
  my $pxt = shift;
  my %a = @_;

  my @files;
  my $document_root = $pxt->document_root;

  # allow glob support
  if (exists $a{glob}) {
    # glob, but glob remands relative or absolute paths... so derelative them, tossing in docroot
    push @files, sort glob File::Spec->catfile($document_root, $pxt->derelative_path($a{glob}));

    # sadly, since the glob had to be absolute paths, we now need to
    # un-absolute them.  a bit icky.
    for (@files) {
      s/^$document_root//;
    }
  }
  else {
    push @files, $a{file};
  }
  delete $a{file};
  delete $a{glob};

  my $ret;
  for my $file (@files) {
    $file = $pxt->derelative_path($file);

    my $parsed = $pxt->include(-path => $file, map { ("-$_" => $a{$_}) } keys %a);
    $parsed =~ s(<pxt:include_block />)($a{__block__} ? $a{__block__} : "")egism;

    $ret .= $parsed;
  }

  return $ret;
}

sub pxt_passthrough_handler {
  my $pxt = shift;
  my %a = @_;
  return $a{__block__} || '';
}

sub pxt_form_handler {
  my $pxt = shift;
  my %a = @_;
  $a{action} ||= $pxt->uri;
  my $block = delete $a{__block__};
  my $s = join(" ", map {lc($_) . qq(="$a{$_}")} keys %a);
  return "<form $s>" . $block . "</form>";
}

sub pxt_messages_handler {
  return shift->message_tag_handler(@_);
}

sub pxt_a_handler {
  my $pxt = shift;
  my %a = @_;
  $a{href} = $pxt->derelative_url($a{href});
  my $block = delete $a{__block__};
  my $s = join(" ", map {lc($_) . qq(="$a{$_}")} keys %a);
  return "<a $s>" . $block . "</a>";
}

sub pxt_hidden_handler {
  my $pxt = shift;
  my %a = @_;
  my $ret = '';

  my @names;
  my @params;

  foreach my $to_replicate (split /[|]/, $a{name}) {

    if ($to_replicate =~ m/\*/) {

      $to_replicate =~ s{\*}{.*?}gism;

      @params = $pxt->param() if (!@params);

      my @matched_params = grep { /$to_replicate/ } @params;

      push @names, @matched_params;
    }
    else {
      push @names, $to_replicate;
    }
  }

  foreach my $name (@names) {
    if (defined $pxt->passthrough_param($name)) {
      $ret .= sprintf(qq{<input type="hidden" name="$name" value="%s" />}, $pxt->passthrough_param($name));
    }
  }

  return $ret;
}

sub pxt_pnote_handler {
  my $pxt = shift;
  my %a = @_;
  return $pxt->pnotes($a{key});
}

sub pxt_session_handler {
  my $pxt = shift;
  my %a = @_;

  my $ret = '';
  $ret = $pxt->session->get($a{name}) if ($a{name} and $pxt->session);
  return $ret;
}

sub pxt_profile_handler {
  my $pxt = shift;

  my $dbh = RHN::DB->soft_connect;

  if ($dbh and PXT::Config->get("profile_queries")) {
    my $ret = join("<br /><br />", map { '<span style="white-space: nowrap; font-family: monospace;">' . PXT::Utils->escapeHTML($_) . '</span>' } $dbh->profile_format);
    return qq{<div class="debug-profile">$ret</div>};
  }

  return "";
}

sub pxt_config_handler {
  my $pxt = shift;
  my %params = @_;

  die "pxt-config: missing attribute 'var'" unless $params{var};

  return PXT::Config->get($params{var});
}

1;
