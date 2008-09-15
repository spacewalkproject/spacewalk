#!/usr/bin/perl

use strict;
use FileHandle;
use GDBM_File;
use Net::SMTP;
use NOCpulse::Config;
use NOCpulse::Debug;
use NOCpulse::Notif::Acknowledgement;

umask(022);

my $program          = 'ack_enqueuer';
my $CFG              = new NOCpulse::Config;                           # Config object
my $QUEUE_DIR        = $CFG->get('notification', 'ack_queue_dir'); # Dir for queuing alerts
my $NEW_QUEUE_DIR    = "$QUEUE_DIR/.new";
my $tmp_dir          = $CFG->get('notification','tmp_dir');
my $SEND_GDBM        = "$tmp_dir/sendhistory.gdbm";
my $LOG_DIR          = "/var/tmp/";

my $t=NewTicketId();
my $new_file="$NEW_QUEUE_DIR/$t";
my $file="$QUEUE_DIR/$t";

my $output = new NOCpulse::Debug;

# - Ack handler log 
my $acklog   = $output->addstream(LEVEL  => 2,
            FILE   => "$LOG_DIR/$program.log",
            APPEND => 1);
die "unable to open acklog $!" unless $acklog;
$acklog->timestamps(1) if $acklog;
my $ackfile   = $output->addstream(LEVEL  => 1,
            FILE   => "$new_file");
die "unable to open $new_file: $!" unless $ackfile;

# Send id database
my %send_history;
tie(%send_history, 'GDBM_File', $SEND_GDBM, O_RDONLY, 0644);

# Connect to the smtp server
my $MX      = $CFG->get('mail', 'mx');
my $TIMEOUT = 30;
my $smtp    = Net::SMTP->new (  $MX,
                                Timeout => $TIMEOUT,
                                Debug   => 1 );



########
# MAIN #
########

$output->dprint(2,"$t:\n");
while (<STDIN>) {
  $output->dprint(1,"$_");
}
$acklog->dprint(1,"\n[end of message]\n");
$ackfile->close();

my $ack=NOCpulse::Notif::Acknowledgement->from_file($new_file);
my $send_id=$ack->send_id();

my $is_rejected;
if ($send_id) {
  $is_rejected=!exists($send_history{$send_id});
} else {
  $is_rejected=1;
}

if ($is_rejected) {
  $ack->ack_result('send id not found');
  $ack->reply($smtp) if $smtp;
  $acklog->dprint(1,"REJECTED [send id: $send_id not found]\n\n\n");
  unlink($new_file);
} else {
  rename($new_file,$file);
  $acklog->dprint(1,"ACCEPTED [send id: $send_id]\n\n\n");
}




#################
sub NewTicketId {
#################
  return sprintf "%010d_%06d", time(), $$;
}

__END__

=head1 NAME

ack_enqueuer.pl - script for enqueue email acknowledgements to files.

=head1 SYNOPSIS

ack_enqueuer.pl is invoked via sendmail alias, in /etc/aliases, for rogerthat on the notification system:

rogerthat:  "| /opt/notification/scripts/ack_enqueuer.pl"

=head1 DESCRIPTION

This script enqueue email acknowledgements to files, one per file, for later processing by the notification system.  It also enqueues any other mail messages, such as bounces received by the rogerthat alias.

=head1 BUGS

No known bugs.

=head1 AUTHOR

Karen Jacqmin-Adams <kja@redhat.com>

Last update: $Date: 2004-12-17 20:10:07 $

=head1 SEE ALSO

B</opt/notification/scripts/notifserver.pl>
B<NOCpulse::Notif::FileQueue>

=cut
