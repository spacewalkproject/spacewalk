#!/usr/bin/perl
use NOCpulse::SpreadNetwork;

$host = `uname -n`;
chomp($host);
$name = "memory";

$connection = SpreadConnection->newInitialized({
			address=>'localhost',
			privateName=>$name,
			recieveMembershipInfo=>1
		});
print "Running on $host as ".$connection->get_mailbox."\n";

$connection->join('memory');

$|=1;
print "Waiting for messages";
MESSAGE: while (1) {
	if ($connection->isConnected) {
		$message = SpreadMessage->nextFrom($connection);
		if (! $message ) {
			print ".";
		} else {
			if ($message->get_sender eq $connection->get_mailbox) {
				print "Ignoring message from self\n";
				next MESSAGE;
			}
			$contents = $message->get_contents;
			($op,$key,$value) = split(
					/,/,
					$contents,
					3);
			$op=uc($op);
			print time()." |$op|$key| from ".$message->get_sender."\n";
			$reply = SpreadMessage->newInitialized({
					addressee=>$message->get_sender
				});

			if ( $op eq 'GET') {
				$reply->set_contents("OK,GET,$key,".$Memory{$key});
			} elsif ($op eq 'SET') {
				$Memory{$key} = $value;
				$reply->set_contents("OK,SET,$key");
				SpreadMessage->newInitialized({
							addressee=>'memory',
							contents=>"SET,$key,$value"
						})->sendVia($connection);
			} elsif ($op eq 'DEL') {
				delete($Memory{$key});
				$reply->set_contents("OK,DEL,$key");
			} elsif ($op eq 'LST') {
				$reply->set_contents("OK,LST,$key,".join("\n",keys(%Memory)));
			} else {
				$reply->set_contents("ERROR,$op,$key");
			}
			$reply->sendVia($connection);
		}
	} else {
		print "Reconnecting...\n";
		$connection->reconnect;
	}
}
