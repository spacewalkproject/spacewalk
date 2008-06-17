#!/usr/bin/perl
use NOCpulse::SpreadNetwork;

$cell = SpreadConnection->newInitialized({
			address=>'localhost',
			privateName=>time()
		});
$|=1;

@nsids = (1015);

while (1) {
	foreach $nsid (@nsids) {
		$request = SpreadMessage->newInitialized({
					addressee=>'cmd'.$nsid,
					contents=>join(' ',@ARGV)
				})->sendVia($cell);
		$message = SpreadMessage->nextFrom($cell);
		if ($message->get_sender) {
			$contents = $message->get_contents;
			chomp($contents);
			print "$contents\n";
		}
	}
}
