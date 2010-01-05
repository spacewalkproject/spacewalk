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

package RHN::Postal;
use strict;

use PXT::Parser;
use PXT::Config;
use RHN::Mail;
use RHN::TemplateString;
use Text::Wrap qw/wrap/;

my @allowed_params = qw/wrap_body allow_all_domains/;

sub new {
  my $class = shift;
  my %attr = @_;

  my $self = bless { wrap => 0,
		     allow_all_domains => 0 }, $class;

  foreach my $param (@allowed_params) {
    if (exists $attr{$param}) {
      $self->$param($attr{$param});
    }
  }

  return $self;
}

sub template {
  my $self = shift;
  my $filename = shift;
  my $absolute = shift;

  my $full_filename;
  if (not $absolute) {
    die "invalid filename, must be server root relative"
      if $filename =~ m(^/) or $filename =~ m(\.\.);

    my $basedir = PXT::Config->get('formletter_dir');
    $full_filename = "$basedir/$filename";
  }
  else {
    $full_filename = $filename;
  }

  open FH, "< $full_filename"
    or die "Can't open $full_filename: $!";

  local $/ = undef;
  my $body = <FH>;

  close FH;

  $self->{original_body} = $body;
}

sub inline_template {
  my $self = shift;
  my $text = shift;

  $self->{original_body} = $text;
}

sub set_tag {
  my $self = shift;
  my $tag = shift;
  my $val = shift;

  $self->{tags}->{$tag} = $val;
}

sub hide_tag {
  my $self = shift;
  my $tag = shift;

  $self->{hidden_tags}->{$tag} = 1;
}

sub unhide_tag {
  my $self = shift;
  my $tag = shift;

  $self->{passthrough_tags}->{$tag} = 1;
}

sub subject {
  my $self = shift;
  my $subject = shift;

  if (defined $subject) {
    $self->{subject} = $subject;
  }

  return $self->{subject};
}

sub to {
  my $self = shift;
  my $to = shift;

  $self->{to} = $to;
}

sub from {
  my $self = shift;
  my $from = shift;

  $self->{from} = $from;
}

sub bcc {
  my $self = shift;
  my $bcc = shift;

  $self->{bcc} = $bcc;
}

sub cc {
  my $self = shift;
  my @ccs = @_;
  
  my $cc = join(', ', @ccs);

  $self->{cc} = $cc;
}

sub sendmail_from {
  my $self = shift;
  my $from = shift;

  $self->{sendmail_from} = $from;
}

sub set_header {
  my $self = shift;
  my $h = shift;
  my $v = shift;

  $self->{headers}->{$h} = $v;
}

sub render {
  my $self = shift;

  die "Missing required params"
    unless exists $self->{original_body};

  my $p = new PXT::Parser;

  $p->register_tag("postal-letter" =>
		   sub {
		     my %params = @_;
		     if (exists $params{subject}) {
		       my $subject = $params{subject};
		       my $product_name = PXT::Config->get('product_name');
		       $subject =~ s!&product_name;!$product_name!g;
		       $self->subject($subject);
                     }
		     return $params{__block__};
		   }
		  );

  $p->register_tag("postal-comment" =>
		   sub {
		     return '';
		   }
                  );

  $p->register_tag("postal-template-replace" => \&template_replace, -5);
  $p->register_tag("postal-template-block" => \&template_block, -5);

  foreach my $t (keys %{$self->{tags}}) {
    $p->register_tag($t => sub { $self->{tags}->{$t} });
  }

  foreach my $t (keys %{$self->{hidden_tags}}) {
    $p->register_tag($t => sub { '' });
  }

  foreach my $t (keys %{$self->{passthrough_tags}}) {
    $p->register_tag($t => sub { my %params = @_; $params{__block__} || '' });
  }

  $self->{current_body} = $self->{original_body};
  $p->expand_tags(\$self->{current_body});

  die "No pre-defined or inline subject" if not exists $self->{subject};
}

sub current_body {
  my $self = shift;

  die "Body not yet rendered"
    unless exists $self->{current_body};

  return $self->{current_body};
}

sub wrap_body {
  my $self = shift;

  $self->{wrap} = 1;
}

sub allow_all_domains {
  my $self = shift;
  my $flag = shift;

  if (defined $flag) {
    $self->{allow_all_domains} = $flag;
  }

  return $self->{allow_all_domains};
}

sub send {
  my $self = shift;
  my %params = @_;
  my $slow = $params{-slow} || 0;

  $self->set_header("X-RHN-Email" => $self->{to});
  my $username = $self->{tags}->{username} || $self->{tags}->{login};
  $self->set_header("X-RHN-Login" => $username)
    if defined $username;

  die "Body not yet rendered"
    unless exists $self->{current_body};
  die "No recipient specified"
    unless exists $self->{to};

  my $subject = $self->{subject};
  $subject = PXT::Utils->perform_substitutions($subject, $self->{tags});
  my $body = $self->{current_body};

  if ($self->{wrap}) {
    $body = wrap("", "", $body);
  }
  RHN::Mail->send(to => $self->{to},
		  subject => $subject,
		  body => $body,
		  sendmail_from => $self->{sendmail_from},
		  from => $self->{from},
		  cc => $self->{cc},
		  bcc => $self->{bcc},
          slow => $slow,
		  headers => $self->{headers} || { },
		  allow_all_domains => $self->allow_all_domains);
}

sub template_replace {
  my %params = @_;

  my $label = $params{label};
  my $default = $params{default};
  die "No label." unless $label;

  if ($params{__block__} and PXT::Config->get('satellite')) {
    return $params{__block__};
  }

  my $from_db = RHN::TemplateString->get_string(-label => $label);

  # if a default was specified in the .xml file,
  # and no override is found in the db, return the .xml's default
  if ($default and not $from_db) {
    return $default;
  }

  return $from_db;
}

sub template_block {
  my %params = @_;

  unless (PXT::Config->get('satellite')) {
    return '';
  }

  my %subst = RHN::TemplateString->load_all;

  return PXT::Utils->perform_substitutions($params{__block__}, \%subst);
}

1;
