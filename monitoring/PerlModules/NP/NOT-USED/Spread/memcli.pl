#!/usr/bin/perl
use NOCpulse::SpreadNetwork;

$host = `uname -n`;
chomp($host);
$localMemname = "#memory#$host";

$cell = SpreadConnection->newInitialized({
			address=>'localhost',
			privateName=>time()
		});
$|=1;
print $cell->get_mailbox."->$localMemname: ";

$request = SpreadMessage->newInitialized({
			addressee=>$localMemname,
			contents=>join(',',@ARGV)
		})->sendVia($cell);
$message = SpreadMessage->nextFrom($cell);
if ($message->get_sender) {
	$contents = $message->get_contents;
	chomp($contents);
	($status,$op,$key,$value) = split(
			/,/,
			$contents,
			4);
	$op=uc($op);
	print " |$status|$op|$key| from ".$message->get_sender."\n";
	print "\n$value\n";
}
