#!/usr/bin/perl
use NOCpulse::SpreadNetwork;
use Data::Dumper;

my $connection = SpreadConnection->newInitialized({
		address=>'localhost',
		privateName=>'kernel'.$ARGV[0],
		readTimeout=>5
});

while (1) {
	if ($connection->isConnected) {
		SpreadMessage->newInitialized({
				addressee=>'scheduler',
				contents=>'WANT_EVENT'
		})->sendVia($connection);
	
		$message = SpreadMessage->nextFrom($connection);
		if ($message) {
			my $thing = $message->asObject;
			print Dumper($thing);
		} else {
			print "Timeout - retrying\n";
		}
	} else {
		print "Reconnecting...\n";
		$connection->reconnect;
	}
}

