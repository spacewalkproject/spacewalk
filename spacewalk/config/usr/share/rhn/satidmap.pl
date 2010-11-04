#!/usr/bin/perl

$| = 1;

use LWP::UserAgent;

$timeout = 4; # Short, because apache will block on this, but long, because startup load is high
%KeyToId;  # This persists globally in apache and as such is a cache

sub clusterIdFromKey
{
	my $key = shift();
	if (exists($KeyToId{$key})) {
		return $KeyToId{$key}
	} else {
		my $ua = LWP::UserAgent->new;
		$ua->agent("SatIDXL8r/1.0 ");
		my $req = HTTP::Request->new(GET => "http://localhost/cgi-bin/translate_key.cgi?scout_shared_key=$key");
		$req->content_type('application/x-www-form-urlencoded');

		# alarm around this else apache can hang
		my $res;
		eval {
			local $SIG{ALRM} = sub { die "alarm\n" }; # NB: \n required
			alarm $timeout;
			$res = $ua->request($req);
			alarm 0;
		};

		if ($res->is_success) {
			my $id = $res->content;
			chomp($id);
			$KeyToId{$key} = $id;
			return $id;
		} else {
			return "NULL";
		}
	}
}


while (<STDIN>) {
	use Data::Dumper;
	my $rawUrl= $_;
	chomp($rawUrl);
	my @locAndVals = split('\?',$rawUrl,2);
	my @kvPairs = split('&',$locAndVals[1]);
	my (%kvs,$pair,@fixedPairs);
	foreach $pair (@kvPairs) {
		my ($key,$val) = split('=',$pair,2);
		if (($key eq 'satcluster') ||($key eq 'cluster_id')) {
			$val = clusterIdFromKey($val);
		}
		push(@fixedPairs,"$key=$val");
	}
	my $result = join('&',@fixedPairs);
	$result = @locAndVals[0].'?'.$result;
	print "$result\n";
}
