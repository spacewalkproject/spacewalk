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

package Sniglets::HTML;

use Params::Validate qw/validate/;

use PXT::HTML;
use RHN::Exception qw/throw/;
use RHN::DataSource::General;
use Sniglets::Navi::Node;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("rhn-help", \&rhn_help);
  $pxt->register_tag("rhn-if-var", \&if_var, -5);
  $pxt->register_tag("rhn-unless-var", \&unless_var, -5);

  $pxt->register_tag("rhn-creation-link", \&creation_link);
  $pxt->register_tag("rhn-deletion-link", \&deletion_link);

  $pxt->register_tag("rhn-toolbar", \&toolbar);

  $pxt->register_tag("rhn-checkable", \&rhn_checkable, 10);

  $pxt->register_tag("rhn-autorefresh-widget", \&rhn_autorefresh_widget);
  $pxt->register_tag("rhn-return-link", \&return_link);
}


sub rhn_checkable {
  my $pxt = shift;
  my %params = @_;

  foreach (qw/type name value/) {
    die "no $_ specified" unless defined $params{$_};
  }

  my $type = $params{type};

  PXT::Debug->log(7, "type:  $type");

  my %type_translation = (radio => 'radio_button');

  PXT::Debug->log(7, "checkable $type $params{name} checked:  $params{checked}");

  die "wrong type:  $type" unless ($type eq 'radio' or $type eq 'checkbox');

  $type = $type_translation{$type} if exists $type_translation{$type};

  PXT::Debug->log(7, "translated type:  $type");

  return PXT::HTML->$type(-name => $params{name},
			  -value => $params{value},
			  -checked => ($params{checked} ? 'checked="1"' : ''));
}

sub toolbar {
  my $pxt = shift;
  my %params = @_;

  my $img = '';
  my $help = '';
  my @toolbar;
  my $base = $params{base};

  die "no base!  should be like h1 or h2" unless $base;

  if (defined $params{img}) {
    $img = PXT::HTML->img(-src => $params{img},
                          -alt => $params{'alt'} || '');
  }
  

  if (defined $params{'help-url'}) {
    $help = rhn_help($pxt, (href => $params{'help-url'},
			    guide => $params{'help-guide'}));
  }

  my $mixins = [];
  if ($params{acl_mixins}) {
    $mixins = [ split(/,\s*/, $params{acl_mixins}) ];
  }

  my $acl = new PXT::ACL (mixins => $mixins);

  if (defined $params{'misc-img'} and $acl->eval_acl($pxt, $params{'misc-acl'} || '')) {
      push @toolbar, misc_link($pxt, (url => $params{'misc-url'},
				      img => $params{'misc-img'},
				      alt => $params{'misc-alt'},
				      text => $params{'misc-text'}));
  }

  if (defined $params{'creation-url'} and $acl->eval_acl($pxt, $params{'creation-acl'} || '')) {
    PXT::Debug->log(7, "acl: " . ($params{'creation-acl'} || '(none)'));
    push @toolbar, creation_link($pxt, (url => $params{'creation-url'}, type => $params{'creation-type'}) );
  }

  if (defined $params{'deletion-url'} and $acl->eval_acl($pxt, $params{'deletion-acl'} || '')) {
    push @toolbar, deletion_link($pxt, (url => $params{'deletion-url'}, type => $params{'deletion-type'}) );
  }

  my $toolbar = join(" | ", @toolbar);

  return qq{<div class="toolbar-$base"><div class="toolbar">$toolbar</div>$img $params{__block__}$help</div>};
}

sub creation_link {
  my $pxt = shift;
  my %params = @_;

  return qq{<span class="toolbar"><a href="$params{url}"><img src="/img/action-add.gif" alt="create new $params{type}" title="add new $params{type}" />create new $params{type}</a></span>};
}

sub deletion_link {
  my $pxt = shift;
  my %params = @_;

  return qq{<span class="toolbar"><a href="$params{url}"><img src="/img/action-del.gif" alt="delete $params{type}" title="delete $params{type}" />delete $params{type}</a></span>};
}

sub misc_link {
  my $pxt = shift;
  my %params = @_;

  return qq{<span class="toolbar"><a href="$params{url}"><img src="$params{img}" alt="$params{'alt'}" title="$params{'alt'}" />$params{text}</a></span>};
}

sub rhn_help {
  my $pxt = shift;
  my %params = @_;

  my $guide = $params{guide} || '';
  my $href = $params{href} || '';

  return render_help_link(-user => $pxt->user,
			  -guide => $guide,
			  -href => $href,
			  -block => qq(<img src="/img/rhn-icon-help.gif" alt="Help Icon" />),
			  -satellite => $params{satellite});
}

sub render_help_link {
  my %params = validate(@_, {-user => 1, -guide => 0, -href => 1, -block => 0, -satellite => 0});
  my $user = $params{-user};
  my $guide = $params{-guide} || 'reference';
  my $href = $params{-href};
  my $text = $params{-block};
  my $satellite_only = $params{-satellite};

  my $url_prefix;

  if ($satellite_only) {
    $url_prefix = '/rhn/help/satellite/en-US/';
  }
  elsif ($guide ne 'reference') {
    $url_prefix = "/rhn/help/$guide/en-US/";
  }
  else {
    $url_prefix = '/rhn/help/reference/en-US/';
  }

  my $url = $url_prefix . $href;

  my $link;
  if ($text) {
    $link = qq(<a href="$url" target="_new" class="help-title">$text</a>);
  }
  else {
    $link = $url;
  }

  return $link;
}

sub if_var {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  return $block if ($pxt->passthrough_param($attr{formvar}) or $pxt->context($attr{formvar}));

  return;
}

sub unless_var {
  my $pxt = shift;
  my %attr = @_;

  my $block = $attr{__block__};

  return $block unless ($pxt->passthrough_param($attr{formvar}) or $pxt->context($attr{formvar}));

  return;
}

my %refresh_speeds =
  ( fast => [ [ 0, "None" ],
	      [ 5, "5 seconds" ],
	      [ 15, "15 seconds" ],
	      [ 30, "30 seconds" ],
	      [ 60, "1 minute" ],
	      [ 120, "2 minutes" ],
	      [ 300, "5 minutes" ],
	      [ 600, "10 minutes" ],
	    ],
    slow => [ [ 0, "None" ],
	      [ 60, "1 minute" ],
	      [ 120, "2 minutes" ],
	      [ 300, "5 minutes" ],
	      [ 600, "10 minutes" ],
	      [ 1800, "30 minutes" ],
	    ],
  );
sub rhn_autorefresh_widget {
  my $pxt = shift;
  my %attr = @_;
  my $speed = $attr{speed};
  die "invalid speed: $speed" unless exists $refresh_speeds{$speed};
  my $propagate = $attr{propagate} || '';
  my @prop_vars = split m(\s*\|\s*), $propagate;

  my $current_speed = $pxt->dirty_param('refresh_speed') || $refresh_speeds{$speed}->[0]->[0];

  # build the options for the select box.  also find the current speed
  # in the table, if anywhere.
  my (@select_options, $found);
  for my $speed_row (@{$refresh_speeds{$speed}}) {
    if ($speed_row->[0] == $current_speed) {
      $found = 1;
      push @select_options, [ $speed_row->[1], $speed_row->[0], 1 ];
    }
    else {
      push @select_options, [ $speed_row->[1], $speed_row->[0], 0 ];
    }
  }
  if (not $found) {
    $select_options[0]->[2] = 1;
  }

  my $url = $pxt->derelative_url($pxt->uri);
  $url .= "?refresh_speed=$current_speed";

  if (@prop_vars) {
    for my $var (@prop_vars) {
      $url .= "&" . $var . "=" . PXT::Utils->escapeURI($pxt->passthrough_param($var));
    }
  }

  $current_speed = 0 unless $found;
  if ($current_speed) {
    $pxt->header_out(Refresh => "$current_speed; $url");
  }

  # This form is a GET now instead of a POST, because for some
  # messed-up reason, newer versions of IE don't handle the Refresh
  # header properly on POST requests.  See bug #165468.
  my $ret;
  $ret .= PXT::HTML->form_start(-method => 'GET');
  $ret .= "<strong>Automatically reload page: </strong>";
  $ret .= PXT::HTML->select(-name => "refresh_speed", -options => \@select_options);
  $ret .= PXT::HTML->hidden(-name => $_, -value => ($pxt->passthrough_param($_) || '')) for @prop_vars;
  $ret .= PXT::HTML->hidden(-name => 'refresh_speed', -value => $current_speed);
  $ret .= " " . PXT::HTML->submit(-value => 'Change Reload Time');
  $ret .= PXT::HTML->form_end;

  return $ret;
}

sub return_link {
  my $pxt = shift;
  my %params = @_;

  my $trees = $pxt->pnotes("navi_trees") || { };

  my $deepest = -1;
  my $which = '';
  my $formvars = [];

  foreach my $tree (keys %{$trees}) {
    if ($trees->{$tree}->{depth} > $deepest) {
      $deepest = $trees->{$tree}->{depth};
      $which = $tree;
      $formvars = $trees->{$tree}->{formvars};
    }
  }

  my $url = $pxt->session->get("${which}_navi_location") || $params{default};

  throw "param default needed but not provided." unless $url;

  my %subst;

  $subst{return_url} = $url;

  if (@{$formvars}) {
    # argh!  get around & + i18N issue by using ; as seperator...
    $subst{return_url} .= '?' . join(";", map {"$_=" . ($pxt->passthrough_param($_) || '')} @{$formvars});
  }

  $subst{return_url} = PXT::Utils->escapeURI($subst{return_url});

  return PXT::Utils->perform_substitutions($params{__block__}, \%subst);
}

1;
