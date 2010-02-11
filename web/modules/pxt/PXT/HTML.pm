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

package PXT::HTML;

use strict;

use Carp;
use PXT::Utils;
use Apache2::RequestUtil ();

use Params::Validate qw/validate/;
Params::Validate::validation_options(strip_leading => "-");

# used to create default names for form elems
my %elem_names = map { $_ => 1 }
                 qw{ text textarea reset submit form hidden password
                     checkbox select radio_group id radio_button file };

my $verbose = 0;


sub htmlify_text {
  my $class = shift;
  my $text = shift;

  warn "undef text in htmlify_text, called from '", join(' ', caller), "'\n"
    unless defined $text;

  $text = PXT::Utils->escapeHTML($text);
  $text =~ s((https?://\S+[\S,.;][^\s.?!]))(<A HREF="$1">$1</A>)gms;
  $text =~ s([\n])(<br />)gism;

  return $text;
}

sub htmlify_text_no_escape {
  my $class = shift;
  my $text = shift;

  $text =~ s((https?://\S+[\S,.;]))(<A HREF="$1">$1</A>)gms;
  $text =~ s([\n])(<br />)gism;

  return $text;
}

sub verbose {
  my $class = shift;
  $verbose = ( $_[0] =~ /(on|1|true)/i ? 1 : 0 );
}

#formstart(
# -method => GET||POST,
# -enctype => multipart|application
# -action => url
# -name => formname
# -target => windowname
# );
sub form_start {
  my $class = shift;
  my %e = @_;
  my $ret;

  $e{-name} = "form" . $elem_names{'form'}++ unless($e{-name});

  # this is a bit ugly, but we REALLY shouldn't render forms w/o any
  # action at all
  if (Apache2::RequestUtil->can('request') and not defined $e{-action}) {
    $e{-action} ||= Apache2::RequestUtil->request->pnotes('pxt_request')->uri;
  }

  if (not exists $e{-action}) {
    Carp::cluck "Form without action, possible stability issues if page is result of GET request";
  }

  if($e{-method} !~ /get|post/i) {
    $class->_spew($class ."->form_start called w/o a METHOD defined\n");
  }

  if($e{-enctype}) {
    if($e{-enctype} =~ /^multipart$/ ) {
      $e{-enctype} = "multipart/form-data";
    }
    if($e{-enctype} =~ /^application$/i ) {
      $e{-enctype} = "application/x-www-form-urlencoded";
    }
  }

  return $class->_format(\%e, "form", -open => 1);
}

#hidden(
#	-name => foo,
#	-value => foo);
sub hidden {
  my $class = shift;
  my %e = @_;

  if(not exists $e{-name}) {
    $e{-name} = "hidden" . $elem_names{'hidden'}++;
    $class->_spew("->hidden name not supplied\n");
  }

  return $class->_format(\%e,"input type=\"hidden\"");
}

#text(
#	-name => foo,
#	-value => foo,
#	-maxlength => 30,
#	-size => 15);
sub text{
  my $class = shift;
  my %e = @_;
  if(!$e{-name}) {
    $e{-name} = "text" . $elem_names{'text'}++;
    $class->_spew("->text no name given, defaulting to " . $e{-name});
  }

  return $class->_format(\%e,"input type=\"text\"");
}

#file(
#	-name => foo,
#	-value => foo,
#	-accept => 'text/plain');
sub file {
  my $class = shift;
  my %e = @_;
  if(!$e{-name}) {
    $e{-name} = "file" . $elem_names{'file'}++;
    $class->_spew("->file no name given, defaulting to " . $e{-name});
  }

  return $class->_format(\%e,"input type=\"file\"");
}

#password(
#	-name => foo,
#	-value => foo,
#	-size => 12,
#	-maxlength -> 30);
sub password {
  my $class = shift;
  my %e = @_;
  if(!$e{-name}) {
    $e{-name} = "password" . $elem_names{'password'}++;
    $class->_spew("->password no name given, defaulting to " . $e{-name});
  }

  return $class->_format(\%e,"input type=\"password\"");
}

#textarea(
#	-name => foo,
#	-value => foo,
#	-rows => 12,
#	-cols => 60,
#	-wrap => 'VIRTUAL');
sub textarea {
  my $class = shift;
  my %e = @_;
  my $value = $e{-value} || "";
  delete $e{-value} if(exists $e{-value});;

  if(!$e{-name}) {
    $e{-name} = "textarea" . $elem_names{'textarea'}++;
    $class->_spew("->textarea no name given, defaulting to " . $e{-name});
  }

  return $class->_format(\%e,"textarea", -open => 1) . $value . "</textarea>";
}

#submit(
#	-name => foo,
#	-value => "Click Me");
sub submit {
  my $class = shift;
  my %e = @_;
  if(!$e{-name}) {
    $e{-name} = "submit" . ( $elem_names{'submit'}++ == 1 ? "" : $elem_names{'submit'} - 2 );
    $class->_spew("->submit no name given, defaulting to " . $e{-name});
  }
  $e{-value} = "submit" if(!$e{-value});

  my $opts = '';
  foreach (keys %e) {
    next unless $_;
    /^\-(.*)$/;
    $opts .= sprintf(" %s=\"%s\"",lc($1),$e{$_});
  }

  return sprintf "<input type=\"submit\" $opts />";
}

#submit(
#	-name => foo,
#	-value => "Click Me");
sub submit_image {
  my $class = shift;
  my %e = @_;
  if(!$e{-name}) {
    $e{-name} = "image" . ( $elem_names{'image'}++ == 1 ? "" : $elem_names{'image'} - 2 );
    $class->_spew("->submit no name given, defaulting to " . $e{-name});
  }

  my $opts = '';
  foreach (keys %e) {
    next unless $_;
    /^\-(.*)$/;
    $opts .= sprintf(" %s=\"%s\"",lc($1),$e{$_});
  }

  return sprintf "<input type=\"image\" $opts />";
}

#reset(
#	-name => foo,
#	-value => "Reset Form");
sub reset {
  my $class = shift;
  my %e = @_;
  if(!$e{-name}) {
    $e{-name} = "reset" . ( $elem_names{'reset'}++ == 1 ? "" : $elem_names{'reset'} - 2 );
    $class->_spew("->reset no name given, defaulting to " . $e{-name});
  }
  $e{-value} = "reset" if(!$e{-value});

  return $class->_format(\%e,"input type=\"reset\"");
}

# create a single checkbox
# checkbox(
#	-name => 'foo',
#	-value => 'bar',
#	-checked => ( 1 || on || yes || checked ) box will be checked
sub checkbox {
  my $class = shift;
  my %e = @_;
  my $checked = "";
  my $disabled = "";

  if(exists $e{-checked}) {
    $checked = $e{-checked};
    delete $e{-checked};
  }

  if(exists $e{-disabled}) {
    $disabled = $e{-disabled};
    delete $e{-disabled};
  }

  if(!$e{-name}) {
    $e{-name} = "checkbox" . $elem_names{'checkbox'}++;
    $class->_spew("->checkbox no name given, defaulting to " . $e{-name});
  }

  return $class->_format(\%e,"input type=\"checkbox\"", -checked => $checked, -disabled => $disabled);
}

#radio_group(
#	-name => foo,
#	-buttons => [ [label, value, checked], [label, value, checked], ... ]
sub radio_group {
  my $class = shift;
  my %e = @_;
  my $sep = $e{-separator} || "\n";

  if(!$e{-name}) {
    $e{-name} = "radiogrp" . $elem_names{'radio_group'}++;
    $class->_spew("->checkbox_group no name given, defaulting to " . $e{-name});
  }

  my $ret;

  foreach (@{$e{-buttons}}) {
     my $label = $_->[0] || "";
     my $value = $_->[1] || "";
     my $checked = $_->[2] || "";
     $ret .= $class->_format({ -value => $value, -name => $e{-name}},
                             "input type=\"radio\"", -checked => $checked );
     $ret .= "$label$sep";
  }

  return $ret;
}

#radio_button(
#             -label => foo,
#             -value => bar,
#             -checked => 1 );
sub radio_button {
  my $class = shift;
  my %e = @_;

  if (! $e{-name}) {
    $e{-name} = "radio" . $elem_names{'radio_button'}++;
    $class->_spew("->radio_button no name given, defaulting to " . $e{-name});
  }

  my $checked = 0;

  if(exists $e{-checked}) {
    $checked = $e{-checked};
    delete $e{-checked};
  }

  my $ret = $class->_format(\%e, q(input type="radio"), -checked => $checked );

  return $ret;
}

#select(
#	-name => foo,
#	-size => 1,
#	-multiple => 1,
#	-options => [ [label, value, selected],[label, value, selected], ...]);
#
sub select {
  my $class = shift;
  my %e = @_;

  if(!$e{-name}) {
    $e{-name} = "select" . $elem_names{'select'}++;
    $class->_spew("->select no name given, defaulting to " . $e{-name});
  }

  my $multiple = "";
  my $onChange = "";
  my $options = $e{-options};
  die "no options specified for PXT::HTML->select" unless defined $e{-options};
  delete $e{-options};

  if ($e{-multiple}) {
    $multiple = ' multiple="1"';
  }
  delete $e{-multiple};

  if ($e{-onChange}) {
    $onChange = ' onChange="' . $e{-onChange} . '"';
  }

  my $ret = $class->_format(\%e,"select" . $multiple . $onChange, -open => 1) . "\n";

  my $in_optgroup = 0;

  foreach (@{$options}) {
     my $label = defined $_->[0] ? $_->[0] : "unlabeled";
     my $value = $_->[1] || "";
     my $selected = $_->[2] || "";
     my $optgroup = $_->[3] || "";

     if ($optgroup) {
       if ($in_optgroup) { # close the last one
	 $ret .= "</optgroup>\n";
       }
       $in_optgroup = 1;

       $ret .= $class->_format({ -label => $label }, 'optgroup', -open => 1) . "\n";
     }
     else {
       $ret .= $class->_format({ -value => $value }, 'option', -selected => $selected, -open => 1);
       $ret .= $label . "</option>\n";
     }
  }

  if ($in_optgroup) {
    $ret .= "</optgroup>\n";
  }

  return $ret . "</select>";
}

sub form_end {
  my $class = shift;
  return "</form>";
}

#
# "Private"
#
sub _spew {
  warn @_ if($verbose);
}

sub _format {
  my $class = shift;
  my $e = shift;
  my $elem_type = shift;
  my %ops = @_;
  my $ret;

  foreach my $key (keys %{$e}) {
    if ($key =~ m/^-(.*)$/) {
      # this is quite odd.  sometimes the "name" param became "n0c0".
      # copying it to a temp var fixes it.  quite odd.  probably a bug
      # in 5.8.0.  also may show up elsewhere...

      my $buggy_utf8 = lc($1);
      # if default value is empy, leave it, so browser can override it
      # but only if input it type of hidden, text, password or if type is 
      # not specified, which should be treated as text
      next if (($buggy_utf8 eq 'value') and not ($e->{$key}) and 
        (($elem_type =~ /type="?hidden"?/i) or ($elem_type =~ /type="?text"?/i) or 
        ($elem_type =~ /type="?password"?/i) or ($elem_type =~ /^input(\s*)?$/i)));
      $ret .= sprintf(' %s="%s"', $buggy_utf8, defined $e->{$key} ? $e->{$key} : '');
    }
  }

  if($ops{-checked} && $ops{-checked} =~ /1|on|yes|true|checked/i) {
    $ret .= " checked=\"1\"";
  }

  if($ops{-selected} && $ops{-selected} =~ /1|on|yes|true|selected/i) {
    $ret .= " selected=\"1\"";
  }

  if($ops{-disabled} && $ops{-disabled} =~ /1|yes|true|disabled/i) {
    $ret .= " disabled=\"1\"";
  }

  my $close = $ops{-open} ? ">" : " />\n";

  return "<" . $elem_type . $ret . "$close";
}

sub link {
  my $class = shift;
  my $url = shift;
  my $label = shift;
  my $css_class = shift || '';
  my $target = shift || '';

  $label ||= $url;

  $css_class = qq{ class="$css_class"} if $css_class;
  $target = qq{ target="$target"} if $target;

  return sprintf qq{<a href="%s"$css_class$target>%s</a>}, $url, $label;
}

sub link2 {
  my $class = shift;
  my %params = validate(@_, { url => 1, text => 0, css => 0, target => 0, params => 0 });

  my $url = $params{url};
  my $label = PXT::Utils->escape_html($params{text} || $params{url});
  my $css_class = $params{css};
  my $target = $params{target};

  my %inside;
  $inside{class} = $css_class
    if $css_class;
  $inside{target} = $target
    if $target;

  if ($params{params}) {
    if ($url =~ /\?/) {
      $url .= "&";
    }
    else {
      $url .= "?";
    }

    my $p = $params{params};
    $url .=
      join("&amp;",
	   map { sprintf q{%s=%s}, PXT::Utils->escapeURI($_), PXT::Utils->escapeURI($p->{$_}) }
	   sort keys %{$p});
  }

  $inside{href} = $url;

  return
    sprintf qq{<a %s>%s</a>},
      join(" ", map { sprintf q{%s="%s"}, $_, $inside{$_} } keys %inside),
	$label;
}

sub img {
  my $class = shift;
  my %params = @_;

  if (not exists $params{-src}) {
    die "srcless img";
  }

  my @inner;
  for my $attr (qw/src border class alt hspace title align/) {
    next unless exists $params{"-$attr"};
    push @inner, sprintf(qq{$attr="$params{-$attr}"});
  }

  my $inner_str = join(" ", @inner);

  return qq{<img $inner_str />};
}

1;
