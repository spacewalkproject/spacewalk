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

package RHN::Mail;
use strict;

use PXT::Config;
use Params::Validate;

my @header_order = qw/To From Subject/;
my $DEFAULT_FROM = PXT::Config->get('default_mail_from');

# given a list of possible recipients, validate they're allowed to receive
# email in the current environment
sub validate_allowed_recipients {
  my $class = shift;
  my @recipients = @_;

  my @allowed_domains = split(/,\s*/, PXT::Config->get('restrict_mail_domains'));
  my @disallowed_domains = split(/,\s*/, PXT::Config->get('disallowed_mail_domains'));
  #warn join(", ", @disallowed_domains);

  if (@allowed_domains) {
    foreach my $recipient (map { split /,\s*/, $_ } @recipients) {
      unless (grep { $recipient =~ /.*\@$_>?/ } @allowed_domains ) {
	return;
      }
    }
  }

  if (@disallowed_domains) {
    foreach my $recipient (map { split /,\s*/, $_ } @recipients) {
      if (grep { $recipient =~ /.*\@$_>?/ } @disallowed_domains ) {
	return;
      }
    }
  }

  return 1;
}

sub send {
  my $class = shift;
  my %params = validate(@_, {to => 1,
			     subject => 1,
			     body => 1,
			     cc => 0,
			     bcc => 0,
			     headers => 0,
			     from => 0,
			     sendmail_from => 0,
			     slow => 0,
			     allow_all_domains => 0,
			     no_default_headers => 0,
			    });

  my $headers = $params{headers};

  my $from = $params{from} || $DEFAULT_FROM;
  my $sendmail_from = $params{sendmail_from} || $from;
  $sendmail_from =~ /^(.*)$/;
  $sendmail_from = $1;


  # make sure everyone who should get this message is allowed to
  if (not $params{allow_all_domains}) {
    unless ($class->validate_allowed_recipients(grep {$_} ($params{to}, $params{cc}, $params{bcc}))) {
      return;
    }
  }

  my %header;
  $header{From} = $from;
  $header{To} = delete $params{to};
  $header{Cc} = delete $params{cc};
  
  $header{Subject} = delete $params{subject};

  # set up rest of the headers and make sure we're not doing something naughty w/ any of them...
  my @illegal_headers = qw/to cc bcc/;
  if ($params{headers}) {
    foreach my $k (keys %{$params{headers}}) {
      die "illegal header key:  $k" if grep { $k =~ m/^$_$/i} @illegal_headers;
      $header{$k} = $params{headers}->{$k};
    }
  }
  undef @illegal_headers;

  unless ($params{no_default_headers}) {
    $header{'Content-Type'} = "text/plain; charset=US-ASCII";
    $header{'Errors-To'} ||= $from;
  }

  $header{"X-RHN-Email"} = $header{To};

  my $output;

  $output .= "To: $header{To}\n";

  if ($header{Cc}) {
    $output .= "Cc: $header{Cc}\n";
  }

  if ($header{Bcc}) {
    $output .= "Bcc: $header{Bcc}\n";
  }

  $output .= "From: $header{From}\n";
  $output .= "Subject: $header{Subject}\n";
  
  delete @header{qw/To Cc Bcc From Subject/};

  $output .= "$_: $header{$_}\n" foreach keys %header;

  undef %header;

  $output .= "\n";
  $output .= $params{body};

  $from =~ /^(.*)$/;
  $from = $1;

  my @command = ('/usr/sbin/sendmail', '-t', '-oi', "-f'$sendmail_from'");

  if ($params{slow}) {
    push @command, ('-O', 'DeliveryMode=q');
  }

  $ENV{PATH} = "/bin:/usr/bin";

  my $command = join(' ', @command);
  
  open SM, "|$command"
    or die "Can't spawn sendmail: $!";

  print SM $output;
  if (not close SM) {
    if ($!) {
      die "Can't close sendmail: $!";
    }
    else {
      warn "sendmail returned failure code $?";
    }
  }
}

1;
