#!/usr/bin/perl
use NOCpulse::SpreadNetwork;
use Data::Dumper;
$connection = SpreadConnection->newInitialized({
			address=>shift(),
			privateName=>time()
		});
$|=1;

$request = SpreadMessage->newInitialized({
			addressee=>shift(),
			contents=>join(' ',@ARGV)
		})->sendVia($connection);
$message = SpreadObjectMessage->NextFrom($connection);
if ($message) {
	print "-----FROM: ".$message->get_sender."\n";
	print "-----STDOUT\n".$message->get_stdout;
	print "-----STDERR\n".$message->get_stderr;
	print "-----EXIT\n".$message->get_exit;
	print "\n";
	exit($message->get_exit);
} else {
	print $connection->spreadErrorMessage."\n";
	exit($connection->spreadErrorNumber);
}
