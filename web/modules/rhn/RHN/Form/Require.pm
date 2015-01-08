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

package RHN::Form::Require;

use strict;

use RHN::Exception qw/throw/;

use Mail::RFC822::Address;

my %requires = ('response' => \&response,
                'min-length' => \&min_length,
                'max-length' => \&max_length,
                'valid-email' => \&valid_email,
                'valid-multi-email' => \&valid_multi_email,
                'label' => \&valid_label,
                'numeric' => \&numeric,
                'regexp' => \&regexp,
                fqdn => \&fqdn,
                'fqdn-and-port' => \&fqdn_and_port,
                'valid-ip' => \&valid_ip,
               );

# Require a response of some sort.
sub response {
  my $widget = shift;
  my $param = shift;
  my $text = shift;

  return "Please respond to all required fields." 
      unless ((defined $text) && ($text ne ''));

  return 0;
}

sub valid_label {
  my $widget = shift;
  my $param = shift;
  my $text = shift || '';

  return "{widget_name} can only contain letters, numbers, dashes, dots, and underscores."
    if $text =~ /[^a-z0-9-._]/i;

  return 0;
}

sub min_length {
  my $widget = shift;
  my $param = shift;
  my $text = shift || '';

  return "{widget_name} must be at least {param} characters long." unless (length $text >= $param);

  return 0;
}

sub max_length {
  my $widget = shift;
  my $param = shift;
  my $text = shift || '';

  return "{widget_name} cannot be longer than {param} characters." unless (length $text <= $param);

  return 0;
}

sub valid_email {
  my $widget = shift;
  my $param = shift;
  my $text = shift || '';

  return "<b>$text</b> does not appear to be a valid e-mail address." unless (Mail::RFC822::Address::valid($text));

  return 0;
}

sub valid_multi_email {
  my $widget = shift;
  my $param = shift;
  my $text = shift || '';

  my @addys = grep { $_ } split(/[\s,]+/, $text);
  my @errors;

  foreach my $addy (@addys) {
    my $err = valid_email($widget, $param, $addy);
    if ($err) {
      push @errors, $err;
    }
  }

  if (@errors) {
    return join("<br/>\n", @errors);
  }

  return 0;
}

sub numeric {
  my $widget = shift;
  my $param = shift;
  my $text = shift || '';

  return "{widget_name} must contain only digits." if ($text =~ /\D/);

  return 0;
}

sub regexp {
  my $widget = shift;
  my $regexp = shift;
  my $text = shift || '';

  return "Invalid {widget_name}." unless ($text =~ /$regexp/);

  return 0;
}

sub test_fqdn {
  my ($widget, $fqdn, $text, $allowed_regexp) = @_;

  return 0 unless $text;

  my @parts = split(/\./, $text);
  my @non_empty_parts = grep { $_ } @parts;

  return "Invalid {widget_name}: <strong>$text</strong> does not appear to be a valid hostname."
    unless (scalar @parts >= 2 and scalar @parts == scalar @non_empty_parts);

  if ($text =~ $allowed_regexp) {
    return "Invalid {widget_name}: <strong>$text</strong> contains a character that is not allowed in a hostname: <strong>$1</strong>";
  }

  return 0;
}

sub fqdn {
  my ($widget, $fqdn, $text) = @_;
  return test_fqdn($widget, $fqdn, $text, qr/([^a-zA-z0-9\.-])/);
}

sub fqdn_and_port {
  my ($widget, $fqdn, $text) = @_;
  return test_fqdn($widget, $fqdn, $text, qr/([^a-zA-z0-9\.:-])/);
}

sub valid_ip {
  my $widget = shift;
  my $ip = shift;
  my $text = shift || '';

  return 0 unless $text;

  my @parts = split(/\./, $text);
  my @non_empty_parts = grep { $_ or ($_ eq '0') } @parts;
  my @out_of_range_parts = grep { $_ < 0 or $_ > 255 } @parts;

  return "<strong>$text</strong> does not appear to be a valid ip address."
    unless (scalar @parts == 4 and scalar @parts == scalar @non_empty_parts
            and (not @out_of_range_parts) and ($parts[3] != 0));

  return 0;
}

sub lookup_require {
  my $self = shift;
  my $name = shift;

  throw "Unknown require '$name'."
    unless exists $requires{$name};

  return $requires{$name};
}

1;
