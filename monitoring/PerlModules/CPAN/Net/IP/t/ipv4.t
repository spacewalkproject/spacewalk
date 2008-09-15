use lib "./t";
use ExtUtils::TBone;
use Net::IP qw(:PROC);

BEGIN {
	if (eval (require Math::BigInt))
	{
		$math_bigint = 1;
	};
};

my $numtests = 21;

# Create checker:
my $T = typical ExtUtils::TBone;

$numtests++ if $math_bigint;

$T->begin($numtests);
#------------------------------------------------------------------------------



$ip = new Net::IP('195.114.80/24',4);

$T->ok (defined($ip),$Net::IP::Error);
$T->ok_eq ($ip->binip(),'11000011011100100101000000000000',$ip->error());
$T->ok_eq ($ip->ip(),'195.114.80.0',$ip->error());
$T->ok_eq ($ip->short(),'195.114.80.0',$ip->error());
$T->ok_eqnum ($ip->prefixlen(),24,$ip->error());
$T->ok_eqnum ($ip->version(),4,$ip->error());
$T->ok_eqnum ($ip->size(),256,$ip->error());
$T->ok_eq ($ip->binmask(),'11111111111111111111111100000000',$ip->error());
$T->ok_eq ($ip->mask(),'255.255.255.0',$ip->error());
$T->ok_eqnum ($ip->intip(),3279048704,$ip->error()) if $math_bigint;
$T->ok_eq ($ip->iptype(),'PUBLIC',$ip->error());
$T->ok_eq ($ip->reverse_ip(),'80.114.195.in-addr.arpa.',$ip->error());
$T->ok_eq ($ip->last_bin(),'11000011011100100101000011111111',$ip->error());
$T->ok_eq ($ip->last_ip(),'195.114.80.255',$ip->error());

$ip->set('202.31.4/24');
$T->ok_eq ($ip->ip(),'202.31.4.0',$ip->error());

$ip->set('234.245.252.253/2');
$T->ok_eq ($ip->error(),'Invalid prefix 11101010111101011111110011111101/2',$ip->error());
$T->ok_eqnum ($ip->errno(),171,$ip->error());

$ip->set('62.33.41.9');
$ip2 = new Net::IP('0.1.0.5');
$T->ok_eq ($ip->binadd($ip2)->ip(),'62.34.41.14',$ip->error());

$ip->set('133.45.0/24');
$ip2 = new Net::IP('133.45.1/24');
$T->ok_eqnum ($ip->aggregate($ip2)->prefixlen(),23,$ip->error());

$ip2 = new Net::IP('133.44.255.255');
$T->ok_eqnum ($ip->bincomp('gt',$ip2),1,$ip->error());

$ip = new Net::IP('133.44.255.255-133.45.0.42');

$T->ok_eq (($ip->find_prefixes())[3],'133.45.0.40/31',$ip->error());

$ip->set('201.33.128.0/22');
$ip2->set('201.33.129.0/24');

$T->ok_eqnum ($ip->overlaps($ip2),$IP_B_IN_A_OVERLAP,$ip->error());


#------------------------------------------------------------------------------
$T->end;
1;
