package NOCpulse::Notif::SimpleEmailContactMethod;             

@ISA = qw(NOCpulse::Notif::EmailContactMethod);       
use strict;
use NOCpulse::Notif::EmailContactMethod;

1;


__END__


=head1 NAME

NOCpulse::Notif::SimpleEmailContactMethod - An EmailContactMethod used for ad-hoc messages.

=head1 SYNOPSIS

# Create a new email contact method
$method=NOCpulse::Notif::SimpleEmailContactMethod->new(
  'email'          => 'nobody@nocpulse.com');

# Create the command that will send a specified alert to this destination
$cmd=$method->send($alert);

=head1 DESCRIPTION

The C<SimpleEmailContactMethod> object is a type of EmailContactMethod that is created as needed by the notification system and is primarily used for redirects.

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

B<NOCpulse::Notif::EmailContactMethod>
B<NOCpulse::Notif::Alert>
B<NOCpulse::Notif::NotifIniInterface>
B<notifier>

=cut
