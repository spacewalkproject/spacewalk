use lib "./t";
use ExtUtils::TBone;
use Net::IP qw(:PROC);

BEGIN {
	if (eval (require Math::BigInt))
	{
		$math_bigint = 1;
	};
};

my $numtests = 18;

# Create checker:
my $T = typical ExtUtils::TBone;

$numtests++ if $math_bigint;

$T->begin($numtests);
#------------------------------------------------------------------------------

$ip = new Net::IP('dead:beef:0::/48',6);

$T->ok (defined($ip),$Net::IP::ERROR);
$T->ok_eq ($ip->binip(),'11011110101011011011111011101111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000',$ip->error());
$T->ok_eq ($ip->ip(),'dead:beef:0000:0000:0000:0000:0000:0000',$ip->error());
$T->ok_eq ($ip->short(),'dead:beef::',$ip->error());
$T->ok_eqnum ($ip->prefixlen(),48,$ip->error());
$T->ok_eqnum ($ip->version(),6,$ip->error());
$T->ok_eq ($ip->mask(),'ffff:ffff:ffff:0000:0000:0000:0000:0000',$ip->error());
$T->ok_eqnum ($ip->intip(),295990755014133383690938178081940045824,$ip->error()) if $math_bigint;
$T->ok_eq ($ip->iptype(),'UNASSIGNED',$ip->error());
$T->ok_eq ($ip->reverse_ip(),'0.0.0.0.f.e.e.b.d.a.e.d.ip6.int.',$ip->error());
$T->ok_eq ($ip->last_ip(),'dead:beef:0000:ffff:ffff:ffff:ffff:ffff',$ip->error());

$ip->set('202.31.4/24',4);
$T->ok_eq ($ip->ip(),'202.31.4.0',$ip->error());

$ip->set(':1/128');
$T->ok_eq ($ip->error(),'Invalid address :1 (starts with :)',$ip->error());
$T->ok_eqnum ($ip->errno(),109,$ip->error());


$ip->set('ff00:0:f000::');
$ip2 = new Net::IP('0:0:1000::');
$T->ok_eq ($ip->binadd($ip2)->short(),'ff00:1::',$ip->error());

$ip->set('::e000:0/112');
$ip2->set('::e001:0/112');
$T->ok_eqnum ($ip->aggregate($ip2)->prefixlen(),111,$ip->error());

$ip2->set('::dfff:ffff');
$T->ok_eqnum ($ip->bincomp('gt',$ip2),1,$ip->error());

$ip->set('::e000:0 - ::e002:42');

$T->ok_eq (($ip->find_prefixes())[2],'0000:0000:0000:0000:0000:0000:e002:0040/127',$ip->error());

$ip->set('ffff::/16');
$ip2->set('8000::/16');

$T->ok_eqnum ($ip->overlaps($ip2),$IP_NO_OVERLAP,$ip->error());

$T->end;
1;

