#!/usr/bin/perl
use NOCpulse::SpreadNetwork;
use NOCpulse::Scheduler::Event;
use FreezeThaw qw(freeze);

$connection = SpreadConnection->newInitialized({
			address=>'marvin',
			privateName=>'scheduler'
		});
$connection->join('scheduler');
while (1) {
	if ($connection->isConnected) {
		my $message = SpreadMessage->nextFrom($connection);
		if ($message->get_sender) {
			print time().' '.$message->get_contents.' from '.$message->get_sender."\n";
			my $event = NOCpulse::Scheduler::Event->new;
			$event->{'id'} = $message->get_sender.time();
			SpreadMessage->newInitialized({
				addressee=>$message->get_sender,
				contents=>freeze($event)
			})->sendVia($connection);
		}
	} else {
		print "Reconnecting...\n";
		$connection->reconnect;
	}
}
