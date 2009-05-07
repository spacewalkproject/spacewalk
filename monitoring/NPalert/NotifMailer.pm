package NOCpulse::Notif::NotifMailer;             

@ISA = qw (NOCpulse::Notif::Mailer);

use strict;
use Class::MethodMaker 
  new_with_init => 'new',
  new_hash_init => 'hash_init';

use Config::IniFiles;
use NOCpulse::Config;
use NOCpulse::Notif::Mailer;
use NOCpulse::Log::Logger;
use Data::Dumper;

my $Log=NOCpulse::Log::Logger->new(__PACKAGE__);

# Defaults

my $CONFIG     = NOCpulse::Config->new;
die unless $CONFIG;

my $cfg_file   = $CONFIG->get('notification','config_dir');
die "Error: I expected config_dir option to be present" unless $cfg_file;
$cfg_file .= '/static/notif.ini';

my $notify_cfg = new Config::IniFiles(-file    => $cfg_file,
                                        -nocase  => 1);
my $SERVER_ID  = $notify_cfg->val('server','serverid'); # $server_recid is the recid of the notification server
my $SERVER_IP  = $notify_cfg->val('server','serverip');

my $MX         = $CONFIG->get('mail', 'mx');
my $MAILDOMAIN = $CONFIG->get('mail', 'maildomain');
my $REPLYBASE  = $CONFIG->get('notification', 'frombase');
my $REPLYNAME  = $CONFIG->get('notification', 'fromname');
my $REPLYADDR  = sprintf("\"%s\" \<%s%02d\@%s>",
                           $REPLYNAME,
                           $REPLYBASE,
                           $SERVER_ID,
                           $MAILDOMAIN);

my %INSTANCE_DEFAULTS = (
    replyaddr     => $REPLYADDR,
    precedence    => 'special-delivery',
    priority      => 'urgent'
);

my @BITBUCKET = qw (nobody@nocpulse.com bitbucket@nocpulse.com);

##########
sub init {
##########
    my $self=shift;

    # Set defaults for values that weren't supplied to the constructor
    my %values = (%INSTANCE_DEFAULTS, @_);
    $self->hash_init(%values);
    return;
}

1;

######################
sub check_addressees {
######################
  my ($self,$smtp)=shift;

  my @addressees=$self->addressees;
  $self->addressees_clear;

  foreach my $address (@addressees) {
    $self->addressees_push($address) unless grep { /$address/ }  @BITBUCKET; 
  }
}

1;

__END__

=head1 NAME

NOCpulse::Notif::NotifMailer - An object tailored to send notification via SMTP.

=head1 SYNOPSIS

# Create a new email
  $email = NOCpulse::Notif::NotifMailer->new(
    'subject'   => 'This is the subject',
    'body'      => 'This is the main message of the email.' );

  # Add a recipient
  $email->addresses_push('nobody@nocpulse.com');

  # Send the email
  my $smtp=Net::SMTP->new();
  $email->send_via($smtp);
  $smtp->quit();

=head1 DESCRIPTION

The C<NotifMailer> object creates an interface with an SMTP server to send an email.  It uses the default reply address, precedence, and priority setting associated with a notification.

=head1 CLASS METHODS

=over 4

=item hash_init ( [%args] ) 

Creates a new object, accepting a hash of slot-name/value pairs with which to initialize the object. The slot-names are interpreted as the names of methods that can be called on the object after it is created and the values are the arguments to be passed to those methods.

=item new ( [%args] )

Create a new object with the supplied arguments, if any.

=back

=head1 METHODS

=over 4

=item check_addressees ( )

Trim the addressees list of unwanted recipients, namely nobody@nocpulse.com and bitbucket@nocpulse.com.

=item init ( [ %args ] )

Initializes the object with the given key value pairs, whose keys correspond to method names of this object.

=back

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-11-18 17:13:13 $

=head1 SEE ALSO

I<NOCpulse::Notif::Mailer>
I<NOCpulse::Notif::EmailContactMethod>
I<NOCpulse::Notif::PagerContactMethod>
B<notifier>

=cut
