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

package Grail::Frame;
use Carp;
use Grail::Canvas;

sub register_tags {
  my $class = shift;
  my $pxt = shift;

  $pxt->register_tag("grail-canvas" => \&canvas_handler, -100);
  $pxt->register_tag("grail-early-canvas" => \&canvas_handler, -101);
  $pxt->register_tag("grail-canvas-template" => \&canvas_template_handler, 100);
  $pxt->register_tag("grail-canvas-replacement" => \&canvas_replacement_handler, 50);
}

sub canvas_handler {
  my $pxt = shift;
  my %params = @_;

  my $canvas = new Grail::Canvas;

  my $replacements = $pxt->pnotes('canvas_replacements') || {};

  if ($params{mode} and exists $replacements->{$params{mode}}) {
    $params{__block__} = $replacements->{$params{mode}};
  }

  return $canvas->render($pxt, -mode => "render_canvas", -params => [ $params{mode}, $params{__block__} ]);
}

sub canvas_replacement_handler {
  my $pxt = shift;
  my %params = @_;

  my $canvas = new Grail::Canvas;
  my $mode = $params{mode};

  my $replacements = $pxt->pnotes('canvas_replacements') || {};
  $replacements->{$mode} = $params{__block__};
  $pxt->pnotes('canvas_replacements', $replacements);

  return ''
}

sub canvas_template_handler {
  my $pxt = shift;
  my %params = @_;

  my $canvas = new Grail::Canvas;
  my $file = $params{base};
  my $mode = $params{mode};
  my $title = $params{title};

  if ($mode) {
    my $replacements = $pxt->pnotes('canvas_replacements') || {};
    $replacements->{$mode} = $params{__block__};
    $pxt->pnotes('canvas_replacements', $replacements);
    $pxt->pnotes('page_title', $title) if $title;
  }

  return $pxt->include($file);
}

1;
