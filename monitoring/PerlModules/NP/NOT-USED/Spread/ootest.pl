#!/usr/bin/perl
use NOCpulse::SpreadNetwork;
use NOCpulse::PlugFrame::Probe;

$connection = SpreadConnection->newInitialized({
			address=>'localhost',
			privateName=>'perltest'
		});

$connection->join('scheduler');

my $probe = Probe->new;

SpreadMessage->newInitialized({
		addressee=>'scheduler',
		contents=>$probe->storeString
})->sendVia($connection);

$probe = undef;

$message = SpreadMessage->nextFrom($connection);
print $message->printString;
print $message->asObject->printString;
