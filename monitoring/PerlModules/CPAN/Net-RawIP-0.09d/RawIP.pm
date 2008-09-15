# Create sub modules 
package Net::RawIP::iphdr;
use Class::Struct qw(struct);
my @iphdr = qw(version ihl tos tot_len id frag_off ttl protocol check saddr 
daddr);
struct ( 'Net::RawIP::iphdr' => [ map { $_ => '$' } @iphdr ] );

package Net::RawIP::tcphdr;
use Class::Struct qw(struct);
my @tcphdr = qw(source dest seq ack_seq doff res1 res2 urg ack psh rst syn
fin window check urg_ptr data);
struct ( 'Net::RawIP::tcphdr' => [map { $_ => '$' } @tcphdr ] );

package Net::RawIP::udphdr;
use Class::Struct qw(struct);
my @udphdr = qw(source dest len check data);
struct ( 'Net::RawIP::udphdr' => [map { $_ => '$' } @udphdr ] );

package Net::RawIP::icmphdr;
use Class::Struct qw(struct);
my @icmphdr = qw(type code check gateway id sequence unused mtu data);
struct ( 'Net::RawIP::icmphdr' => [map { $_ => '$' } @icmphdr ] );

package Net::RawIP::generichdr;
use Class::Struct qw(struct);
my @generichdr = qw(data);
struct ( 'Net::RawIP::generichdr' => [map { $_ => '$' } @generichdr ] );

package Net::RawIP::opt;
use Class::Struct qw(struct);
my @opt = qw(type len data);
struct ( 'Net::RawIP::opt' => [map { $_ => '@' } @opt ] );

package Net::RawIP::ethhdr;
use Class::Struct qw(struct);
my @ethhdr = qw(dest source proto);
struct ( 'Net::RawIP::ethhdr' => [map { $_ => '$' } @ethhdr ] );

# Main package 
package Net::RawIP;
use Carp;
use vars qw($VERSION @ISA @EXPORT @EXPORT_OK $AUTOLOAD);
use subs qw(timem ifaddrlist);

require Exporter;
require DynaLoader;
require AutoLoader;
@ISA = qw(Exporter DynaLoader);

@EXPORT = qw(timem open_live dump_open dispatch dump loop linkoffset ifaddrlist rdev);
@EXPORT_OK = qw(
PCAP_ERRBUF_SIZE PCAP_VERSION_MAJOR PCAP_VERSION_MINOR lib_pcap_h
open_live open_offline dump_open lookupdev lookupnet dispatch
loop dump compile setfilter next datalink snapshot is_swapped major_version
minor_version stats file fileno perror geterr strerror close dump_close);  
%EXPORT_TAGS = ( 'pcap' => [
qw(
PCAP_ERRBUF_SIZE PCAP_VERSION_MAJOR PCAP_VERSION_MINOR lib_pcap_h
open_live open_offline dump_open lookupdev lookupnet dispatch
loop dump compile setfilter next datalink snapshot is_swapped major_version
minor_version stats file fileno perror geterr strerror close dump_close
timem linkoffset ifaddrlist rdev)  
                            ]
	       );	  	    

$VERSION = '0.09';

sub AUTOLOAD {
    my $constname;
    ($constname = $AUTOLOAD) =~ s/.*:://;
    croak "& not defined" if $constname eq 'constant';
    my $val = constant($constname, @_ ? $_[0] : 0);
    if ($! != 0) {
	if ($! =~ /Invalid/) {
	    $AutoLoader::AUTOLOAD = $AUTOLOAD;
	    goto &AutoLoader::AUTOLOAD;
	}
	else {
		croak "Your vendor has not defined Net::RawIP macro $constname";
	}
    }
    *$AUTOLOAD = sub () { $val };
    goto &$AUTOLOAD;
}
bootstrap Net::RawIP $VERSION;

# Warn if called from non-root accounts
carp "Must have EUID == 0 to use Net::RawIP" if $>;

# To prevent spurious warnings.  Actually, that doesn't work all too well;
# callers might have to set $^W to 0 themselves.
local $^W = 0;

# The constructor
sub new {
 my ($proto,$ref) = @_;
 my $class = ref($proto) || $proto;
 my $self = {};
 bless $self,$class;
# The sub protocol determination (tcp by default) 
 $self->proto($ref);
# The values by default
 $self->_unpack($ref);;
 return $self
}

sub proto {
 my ($class,$args) = @_;
 my @proto = qw(tcp udp icmp generic);
 my $proto;
 unless ($class->{'proto'}){
 map {$proto = $_ if exists $args->{$_} } @proto;
 $proto = 'tcp' unless $proto;
 $class->{'proto'} = $proto;
 }
 return $class->{'proto'}
}

# IP and TCP options 
sub optset {
 my($class,%arg) = @_;
# The number of members in the sub modules
 my %n = ('tcp',17,'udp',5,'icmp',9,'generic',1); 
 my $optproto;
 my $i;
 my $len;
# Initialize Net::RawIP::opt objects from argument
 map {
    my @array;
    $optproto = $_;
    $class->{"opts$optproto"} = new Net::RawIP::opt 
                                           unless $class->{"opts$optproto"};
    @{$class->{"opts$optproto"}->type} = ();
    @{$class->{"opts$optproto"}->len} = ();
    @{$class->{"opts$optproto"}->data} = ();
    map {
     @{$class->{"opts$optproto"}->$_()} = @{${$arg{$optproto}}{$_}};
        } 
    keys %{$arg{$optproto}};
      $i = 0;
# Count lengths of options 
    map {
$len = length($class->{"opts$optproto"}->data($i));
$len = 38 if $len > 38;
$class->{"opts$optproto"}->len($i,2+$len);
        $i++
        }
     @{${$arg{$optproto}}{'data'}};
# Fill an array with types,lengths,datas and put the reference of this array  
# to the sub module as last member   
    $i = 0;
    map { 
    push @array,
    ($_,$class->{"opts$optproto"}->len($i),$class->{"opts$optproto"}->data($i));
    $i++;
     } @{$class->{"opts$optproto"}->type}; 
    $i = 0;
    if($optproto eq 'tcp'){
    $i = 1;
    ${$class->{'tcphdr'}}[17] = 0 unless defined ${$class->{'tcphdr'}}[17];
    } 
    ${$class->{"$class->{'proto'}hdr"}}[$i+$n{$class->{'proto'}}] = [(@array)]
 } sort keys %arg;
# Repacking current packet
$class->_pack(1);
}

sub optget {
my($class,%arg) = @_;
my @array;
my $optproto;
my $i = 0;
my $type;
my %n = ('tcp',17,'udp',5,'icmp',9,'generic',1);
map {
  $optproto = $_;
# Get whole array if not specified type of option
  if(!exists ${$arg{"$optproto"}}{'type'}){
  if($optproto eq 'tcp'){$i = 1}
  push @array,
    (@{${$class->{"$class->{'proto'}hdr"}}[$i+$n{$class->{'proto'}}]});
  }
  else 
# Get array filled with specified options 
  {
    $i = 0;
  map {
    $type = $_;
    $i = 0; 
    map {
       if($type == $_){
  push @array,($class->{"opts$optproto"}->type($i));       
  push @array,($class->{"opts$optproto"}->len($i));       
  push @array,($class->{"opts$optproto"}->data($i));       
       }
     $i++;
     } @{$class->{"opts$optproto"}->type()};
   } @{${$arg{"$optproto"}}{'type'}};
  } 
    } sort keys %arg;
return (@array)
}

sub optunset {
my($class,@arg) = @_;
my @array;
my $optproto;
my $i = 0;
my %n = ('tcp',17,'udp',5,'icmp',9,'generic',1);
map {
  $optproto = $_;
  if($optproto eq 'tcp'){
  $i = 1;
# Look at RFC
  $class->{'tcphdr'}->doff(5);
  }
  else 
  {
# Look at RFC
  $class->{'iphdr'}->ihl(5);
  }
  $class->{"opts$optproto"} = 0;
  ${$class->{"$class->{'proto'}hdr"}}[$i+$n{$class->{'proto'}}] = 0;
    } sort @arg;
$class->_pack(1);
}

# An ethernet related initialization
# We open descriptor and get hardware and IP addresses of device by tap()   
sub ethnew {
 my($class,$dev,@arg) = @_;
 my($ip,$mac);
 $class->{'ethhdr'} = new Net::RawIP::ethhdr; 
 $class->{'tap'} = tap($dev,$ip,$mac);
 $class->{'ethdev'} = $dev;
 $class->{'ethmac'} = $mac;
 $class->{'ethip'} = $ip; 
 $class->{'ethhdr'}->dest($mac);
 $class->{'ethhdr'}->source($mac); 
 my $ipproto = pack ("n1",0x0800);
 $class->{'ethpack'}=$class->{'ethhdr'}->dest
                    .$class->{'ethhdr'}->source
		    .$ipproto;
 $class->ethset(@arg) if @arg;
}


sub ethset {
 my($self,%hash) = @_;
 map { $self->{'ethhdr'}->$_($hash{$_}) } keys %hash;
 my $source = $self->{'ethhdr'}->source;
 my $dest = $self->{'ethhdr'}->dest;
 
 if ($source =~ /^(\w\w):(\w\w):(\w\w):(\w\w):(\w\w):(\w\w)$/)
 {
 $self->{'ethhdr'}->source(
                     pack("C6",hex($1),hex($2),hex($3),hex($4),hex($5),hex($6))
	                  );
 $source = $self->{'ethhdr'}->source;
 }

 if ($dest =~ /^(\w\w):(\w\w):(\w\w):(\w\w):(\w\w):(\w\w)$/)
 {
 $self->{'ethhdr'}->dest(
                     pack("C6",hex($1),hex($2),hex($3),hex($4),hex($5),hex($6))
		        );
 $dest = $self->{'ethhdr'}->dest;
 }  
# host_to_ip returns IP address of target in host byteorder format
 $self->{'ethhdr'}->source(mac(host_to_ip($source)))
 unless($source =~ /[^A-Za-z0-9\-.]/ && length($source) == 6);
 $self->{'ethhdr'}->dest(mac(host_to_ip($dest)))
 unless($dest =~ /[^A-Za-z0-9\-.]/ && length($dest) == 6);
 my $ipproto = pack ("n1",0x0800);
 $self->{'ethpack'}=$self->{'ethhdr'}->dest.$self->{'ethhdr'}->source.$ipproto;
}

# Lookup for mac addresse in the ARP cache table 
# If not successul then send ICMP packet to target and retry lookup
sub mac {
 my $ip = $_[0];
 my $mac;
 my $obj;
    if(mac_disc($ip,$mac)){
    return $mac;
    }
    else{
    $obj = new Net::RawIP ({ip => {saddr => 0,
                                   daddr => $ip},
			    icmp => {}
			  });
    $obj->send(1,1);
        if(mac_disc($ip,$mac)){
	  return $mac;
        }
        else {
	my $ipn = sprintf("%u.%u.%u.%u",unpack("C4",pack("N1",$ip)));
	croak "Can't discover MAC address for $ipn";
	}
    }
}

sub ethsend {
my ($self,$delay,$times) = @_;
if(!$times){
$times = 1;
}
while($times){
# The send_eth_packet takes the descriptor,the name of device,the scalar
# with packed ethernet packet and the flag (0 - non-ip contents,1 - otherwise)  
send_eth_packet($self->{'tap'},$self->{'ethdev'},
           $self->{'ethpack'}.$self->{'pack'},1);
select(undef,undef,undef,$delay) if $delay;
$times--
}
} 

# Allow to send any frames
sub send_eth_frame {
my ($self,$frame,$delay,$times) = @_;
if(!$times){
$times = 1;
}
while($times){
send_eth_packet($self->{'tap'},$self->{'ethdev'},
           substr($self->{'ethpack'},0,12).$frame,0);
select(undef,undef,undef,$delay) if $delay;
$times--
}
} 

# The initialization with default values
sub _unpack {
 my ($self,$ref) = @_;
 $self->{'iphdr'} = new Net::RawIP::iphdr;
 eval '$self->{'."$self->{'proto'}".'hdr} = new Net::RawIP::'."$self->{'proto'}".'hdr';
 eval '$self->'."$self->{'proto'}_default"; 
 $self->set($ref);
}

sub tcp_default {
my ($class) = @_;
@{$class->{'iphdr'}} = (4,5,16,0,0,0x4000,64,6,0,0,0);
@{$class->{'tcphdr'}} = (0,0,0,0,5,0,0,0,0,0,0,0,0,0xffff,0,0,'');
}

sub udp_default {
my ($class) = @_;
@{$class->{'iphdr'}} = (4,5,16,0,0,0x4000,64,17,0,0,0);
@{$class->{'udphdr'}} = (0,0,0,0,'');
}

sub icmp_default {
my ($class) = @_;
@{$class->{'iphdr'}} = (4,5,16,0,0,0x4000,64,1,0,0,0); 	       
@{$class->{'icmphdr'}} = (0,0,0,0,0,0,0,0,'');
}

sub generic_default {
my ($class) = @_;
@{$class->{'iphdr'}} = (4,5,16,0,0,0x4000,64,0,0,0,0); 	       
@{$class->{'generichdr'}} = ('');
}

sub s2i {
return unpack("I1",pack("S2",@_))
}

sub _pack {
my $self = shift;
if (@_){
my @array;
push @array,@{$self->{'iphdr'}},@{$self->{"$self->{'proto'}hdr"}};
# A low level *_pkt_creat() functions take reference of array 
# with all of fields of the packet and return properly packed scalar  
eval '$self->{\'pack\'} = '."$self->{'proto'}".'_pkt_creat (\@array)';
}
return $self->{'pack'};
}

sub packet{
my $class = shift;
return $class->_pack
}

sub set {
my ($self,$hash) = @_;
# For handle C union in the ICMP header
my %un = qw(id sequence unused mtu);
my %revun = reverse %un;
my $meth; #XXX Why perl doesn't understand simple ->$un{$_}() ? 
# See Class::Struct
map {$self->{'iphdr'}->$_(${$hash->{'ip'}}{$_}) } keys %{$hash->{'ip'}}
if exists $hash->{'ip'};
map {$self->{"$self->{'proto'}hdr"}->$_(${$hash->{"$self->{'proto'}"}}{$_}) }
keys %{$hash->{"$self->{'proto'}"}}
if exists $hash->{"$self->{'proto'}"};
map {   
$self->{'icmphdr'}->$_(${$hash->{'icmp'}}{$_});
if(!/gateway/){
        if($un{$_}){ 
	     $meth = $un{$_};
             $self->{icmphdr}->gateway(s2i(($self->{icmphdr}->$_()),
                              ($self->{icmphdr}->$meth())))
        }       
        elsif($revun{$_}){ 
	    $meth = $revun{$_};
            $self->{icmphdr}->gateway(s2i(($self->{icmphdr}->$meth()),
            ($self->{icmphdr}->$_())))
        }
   } 
} keys %{$hash->{icmp}} if exists $hash->{icmp};
my $saddr = $self->{iphdr}->saddr;
my $daddr = $self->{iphdr}->daddr;
$self->{iphdr}->saddr(host_to_ip($saddr)) if($saddr !~ /^-?\d*$/);
$self->{iphdr}->daddr(host_to_ip($daddr)) if($daddr !~ /^-?\d*$/);
$self->_pack(1);
}

sub bset {
my ($self,$hash,$eth) = @_;
my $array;
my $i;
my $j;
my %n = ('tcp',17,'udp',5,'icmp',9,'generic',1);
  if($eth){
$self->{'ethpack'} = substr($hash,0,14);
$hash = substr($hash,14);
@{$self->{'ethhdr'}} = @{eth_parse($self->{'ethpack'})}
  } 
  $self->{'pack'} = $hash;
# The low level *_pkt_parse() functions take packet and return reference of
# of the array with fields from this packet
  eval '$array ='."$self->{'proto'}_pkt_parse(".'$hash)'; 
# Initialization of IP header object
  @{$self->{'iphdr'}} = @$array[0..10];
# Initialization of sub IP object
 @{$self->{"$self->{'proto'}hdr"}}= @$array[11..(@$array-1)];
# If last member in the sub object is a reference of 
# array with options then we have to initialize Net::RawIP::opt 
  if(ref(${$self->{"$self->{'proto'}hdr"}}[$n{$self->{'proto'}}]) eq 'ARRAY'){
 $j = 0;
 $self->{'optsip'} = new Net::RawIP::opt  unless $self->{'optsip'};
 @{$self->{'optsip'}->type} = ();
 @{$self->{'optsip'}->len} = ();
 @{$self->{'optsip'}->data} = ();
    for($i=0;$i<=(@{${$self->{"$self->{'proto'}hdr"}}[$n{$self->{'proto'}}]} - 2);$i = $i + 3){
 $self->{'optsip'}->type($j,
                 ${${$self->{"$self->{'proto'}hdr"}}[$n{$self->{'proto'}}]}[$i]);
 $self->{'optsip'}->len($j,
               ${${$self->{"$self->{'proto'}hdr"}}[$n{$self->{'proto'}}]}[$i+1]);
 $self->{'optsip'}->data($j,
               ${${$self->{"$self->{'proto'}hdr"}}[$n{$self->{'proto'}}]}[$i+2]);
 $j++;
    }
  }
# For handle TCP options
 if($self->{'proto'} eq 'tcp'){
  if(ref(${$self->{'tcphdr'}}[18]) eq 'ARRAY'){
$j = 0;
 $self->{'optstcp'} = new Net::RawIP::opt  unless $self->{'optstcp'};
 @{$self->{'optstcp'}->type} = ();
 @{$self->{'optstcp'}->len} = ();
 @{$self->{'optstcp'}->data} = ();
    for($i=0;$i<=(@{${$self->{'tcphdr'}}[18]} - 2);$i = $i + 3){
 $self->{'optstcp'}->type($j,
                 ${${$self->{'tcphdr'}}[18]}[$i]);
 $self->{'optstcp'}->len($j,
               ${${$self->{'tcphdr'}}[18]}[$i+1]);
 $self->{'optstcp'}->data($j,
               ${${$self->{'tcphdr'}}[18]}[$i+2]);
 $j++;
    }
  }
 }
}


sub get {
my ($self,$hash) = @_;
my $a = wantarray;
my @iphdr = qw(version ihl tos tot_len id frag_off ttl protocol check saddr 
daddr);
my @tcphdr = qw(source dest seq ack_seq doff res1 res2 urg ack psh rst syn
fin window check urg_ptr data);
my @udphdr = qw(source dest len check data);
my @icmphdr = qw(type code check gateway id sequence unused mtu data);
my @generichdr = qw(data);
my @ethhdr = qw(dest source proto);
my %ref =
('tcp',\@tcphdr,'udp',\@udphdr,'icmp',\@icmphdr,'generic',\@generichdr);
my @array;
my %h;

map { ${$$hash{ethh}}{$_} = '$' } @{$hash->{eth}};
map { ${$$hash{iph}}{$_} = '$' } @{$hash->{ip}};
map { ${$$hash{"$self->{'proto'}h"}}{$_} = '$' } @{$hash->{"$self->{'proto'}"}}; 
map {  if ($hash->{'ethh'}->{$_} eq '$') {
                                          if($a) {    
			                    push @array,$self->{'ethhdr'}->$_()
					  }
					  else   {
			                    $h{$_} = $self->{'ethhdr'}->$_()
					  }  
					 }
} @ethhdr if exists $hash->{'eth'};

map {  if ($hash->{'iph'}->{$_} eq '$') {
                                          if($a) {    
			                    push @array,$self->{'iphdr'}->$_()
					  }
					  else   {
			                    $h{$_} = $self->{'iphdr'}->$_()
					  }  
					 }
} @iphdr if exists $hash->{'ip'};

map { if ($hash->{"$self->{'proto'}h"}->{$_} eq '$') {
                                          if($a) {    
                                push @array,$self->{"$self->{'proto'}hdr"}->$_()
					  }
					  else   {
			        $h{$_} = $self->{"$self->{'proto'}hdr"}->$_()
					  }  
					 }
} @{$ref{"$self->{'proto'}"}} if exists $hash->{"$self->{'proto'}"};

  if($a){
         return (@array);
  }
  else {
         return {%h}
  }
}

sub send {
my ($self,$delay,$times) = @_;
if(!$times){
$times = 1;
}
$self->{'raw'} = rawsock() unless $self->{'raw'};
if($self->{'proto'} eq 'icmp' || $self->{'proto'} eq 'generic'){
$self->{'sock'} = set_sockaddr($self->{'iphdr'}->daddr,0);
}
else{
$self->{'sock'} = set_sockaddr($self->{'iphdr'}->daddr,
                               $self->{"$self->{'proto'}hdr"}->dest);
}
while($times){
    pkt_send ($self->{raw},$self->{'sock'},$self->{'pack'});
select(undef,undef,undef,$delay) if $delay;
$times--
}
} 

sub pcapinit {
my($self,$device,$filter,$size,$tout) = @_;
my $promisc = 0x100;
my ($erbuf,$pcap,$program);
croak "$erbuf" unless ($pcap = open_live($device,$size,$promisc,$tout,$erbuf));
croak "compile(): check string with filter" if (compile($pcap,$program,$filter,0,0) < 0);
setfilter($pcap,$program);
return $pcap
} 

sub pcapinit_offline {
my($self,$fname) = @_;
my ($erbuf,$pcap);
croak $erbuf unless ($pcap = open_offline($fname,$erbuf));
return $pcap;
}

sub rdev {
my $rdev;
my $ip = ($_[0] =~ /^-?\d+$/) ? $_[0] : host_to_ip($_[0]);
my $ipn = unpack("I",pack("N",$ip));
if(($rdev = ip_rt_dev($ipn)) eq 'proc'){
  my($dest,$mask);
  open(ROUTE,"/proc/net/route") || croak "Can't open /proc/net/route: $!";
  while(<ROUTE>){
                 next if /Destination/;
                 ($rdev,$dest,$mask) = (split(/\s+/))[0,1,7];
                 last unless ($ipn & hex($mask)) ^ hex($dest);
  }
  CORE::close(ROUTE);
  $rdev = 'lo' unless ($ip & 0xFF000000) ^ 0x7f000000; # For Linux 2.2.x 
}
  croak "rdev(): Destination unreachable" unless $rdev;
# The aliasing support
  $rdev =~ s/([^:]+)(:.+)?/$1/;
return $rdev;    
}

sub DESTROY {
my $self = shift;
closefd($self->{'raw'}) if exists $self->{'raw'};
closefd($self->{'tap'}) if exists $self->{'tap'};
}

1;
__END__

=head1 NAME

Net::RawIP - Perl extension for manipulate raw ip packets with interface to B<libpcap>

=head1 SYNOPSIS

  use Net::RawIP;
  $a = new Net::RawIP;
  $a->set({ip => {saddr => 'my.target.lan',daddr => 'my.target.lan'},
           tcp => {source => 139,dest => 139,psh => 1, syn => 1}});
  $a->send;
  $a->ethnew("eth0");
  $a->ethset(source => 'my.target.lan',dest =>'my.target.lan');	   
  $a->ethsend;
  $p = $a->pcapinit("eth0","dst port 21",1500,30);
  $f = dump_open($p,"/my/home/log");
  loop $p,10,\&dump,$f;

=head1 DESCRIPTION

This package provides a class object which can be used for
creating, manipulating and sending a raw ip packets with
optional feature for manipulating ethernet headers.

B<NOTE:> Ethernet related methods are implemented on Linux and *BSD only

=head1 Exported constants

  PCAP_ERRBUF_SIZE
  PCAP_VERSION_MAJOR
  PCAP_VERSION_MINOR
  lib_pcap_h

=head1 Exported functions

open_live
open_offline
dump_open
lookupdev
lookupnet
dispatch
loop
dump
compile
setfilter
next
datalink
snapshot
is_swapped
major_version
minor_version
stats
file
fileno
perror
geterr
strerror
close
dump_close
timem
linkoffset

By default exported functions are the B<loop>,B<dispatch>,B<dump_open>,B<dump>,
B<open_live>,B<timem>,B<linkoffset>,B<ifaddrlist>,B<rdev>. You have to use the export tag 
B<pcap> for export all of the pcap functions.
Please read the docs for the libpcap and look at L<Net::RawIP::libpcap(3pm)>.
The exported functions the B<loop> and the B<dispatch> can run a perl code refs
as a callbacks for packet analyzing and printing.
If B<dump_open> opens and returns a valid file descriptor,this descriptor can be 
used in the perl callback as a perl filehandle.Also fourth parameter for loop and 
dispatch can be an array or a hash reference and it can be unreferensed in a perl 
callback. The function B<next> returns a string scalar (next packet).Function 
B<timem()> returns a string scalar which looking like B<sec>.B<microsec>, 
where the B<sec> and the B<microsec> are the values which returned by gettimeofday(3) ,
if B<microsec> is less than 100000 then zeros will be added to the left side of
B<microsec> for adjusting to six digits. 
The function which called B<linkoffset> returns a number of the bytes
in the link protocol header e.g. 14 for a Ethernet or 4 for a Point-to-Point
protocol.This function has one input parameter (pcap_t* which is returned
by open_live). 

The B<ifaddrlist> function returns a hash reference,in this hash keys are 
all running network devices,values are ip addresses of those devices 
in an internet address format.

The B<rdev> function returns a name of the outgoing device for given 
destination address.
It has one input parameter (destination address in an internet address
or a domain name or a host byteorder int formats).

 

Please look at the examples.

=head1 CONSTRUCTOR

B<C<new>>   ({
              ip       => {IPKEY => IPVALUE,...},
              ARGPROTO => {PROTOKEY => PROTOVALUE,...} 
	  })	      

The B<C<ip>> is the key of the hash which value is a reference of the hash with 
parameters of the iphdr in the current IP packet.

The B<C<IPKEY>> is one of they (B<version> B<ihl> B<tos> B<tot_len> B<id>
B<frag_off> B<ttl> B<protocol> B<check> B<saddr> B<daddr>).
You can to specify all parameters,even B<check>.If you do not specify parameter,
then value by default will be used.
Of course the checksum will be calculated if you do not specify non-zero value
for it.
The values of the B<saddr> and the B<daddr> can be like www.oracle.com or
205.227.44.16, even they can be an integer  if you know what is 205.227.44.16 
as an unsigned int in the host format ;). 

The B<C<ARGPROTO>> is one of they (B<tcp> B<udp> B<icmp> B<generic>),
this key has used for B<DEFINE> subclass of the Net::RawIP. B<If you not
specify a ARGPROTO then by default value is the tcp>. 

You B<HAVE TO> initialize the subclass of the Net::RawIP object before use.

Here is a code for initializing the udp subclass in the Net::RawIP object.

$a = new Net::RawIP({udp =>{}});

or

$a = new Net::RawIP({ip => { tos => 22 }, udp => { source => 22,dest =>23 } });
 

You could B<NOT> change the subclass in the object after.

The default values of the B<ip> hash are 
(4,5,16,0,0,0x4000,64,6,0,0,0) for the B<tcp> or 
(4,5,16,0,0,0x4000,64,17,0,0,0) for the B<udp> or 
(4,5,16,0,0,0x4000,64,1,0,0,0) for the B<icmp> or 
(4,5,16,0,0,0x4000,64,0,0,0,0) for the B<generic>.

The B<C<PROTOKEY>> is one of (B<source> B<dest> B<seq> B<ack_seq> B<doff> 
B<res1> B<res2> B<urg> B<ack> B<psh> B<rst> B<syn> B<fin> B<window> B<check>
B<urg_ptr> B<data>) for the tcp or 

one of (B<type> B<code> B<check> B<gateway> B<id> B<sequence> B<unused> B<mtu> B<data>)
for the icmp or 

one of (B<source> B<dest> B<len> B<check> B<data>) for the udp or just 

B<data> for the generic.

You have to specify just B<gateway> - (int) or (B<id> and B<sequence>)
- (short and short) or (B<mtu> and B<unused>) - (short and short)
for the icmp because in the real icmp packet it's the C union.

The default values are (0,0,0,0,5,0,0,0,0,0,0,0,0,0xffff,0,0,'') for the tcp and
                  (0,0,0,0,0,0,0,0,'') for the icmp and 
                  (0,0,0,0,'') for the udp and 
                  ('') for the generic.

The valid values for B<urg> B<ack> B<psh> B<rst> B<syn> B<fin> are 0 or 1.
The value of B<data> is a string. Length of the result packet will be calculated
if you do not specify non-zero value for B<tot_len>. 

=head1 METHODS

=over 3

=item B<proto>

returns the name of the subclass current object e.g. B<tcp>.
No input parameters.

=item B<packet> 

returns a scalar which contain the packed ip packet of the current object.
No input parameters.

=item B<set> 

is a method for set the parameters to the current object. The given parameters
must look like the parameters for the constructor.

=item B<bset($packet,$eth)>

is a method for set the parameters for the current object.
B<$packet> is a scalar which contain binary structure (an ip or an eth packet).
This scalar must match with the subclass of the current object.
If B<$eth> is given and it have a non-zero value then assumed that packet is a
ethernet packet,otherwise it is a ip packet. 

=item B<get> 

is a method for get the parameters from the current object. This method returns
the array which will be filled with an asked parameters in order as they have ordered in
packet if you'd call it with an array context.
If this method is called with a scalar context then it returns a hash reference.
In that hash will stored an asked parameters as values,the keys are their names.
 
The input parameter is a hash reference. In this hash can be three keys.
They are a B<ip> and an one of the B<ARGPROTO>s. The value must be an array reference. This
array contain asked parameters.
E.g. you want to know current value of the tos from the iphdr and
the flags of the tcphdr.
Here is a code :

  ($tos,$urg,$ack,$psh,$rst,$syn,$fin) = $packet->get({
            ip => [qw(tos)],
	    tcp => [qw(psh syn urg ack rst fin)]
	    });

The members in the array can be given in any order.

For get the ethernet parameters you have to use the key B<eth> and the 
values of the array (B<dest>,B<source>,B<proto>). The values of the B<dest> and 
the B<source> will look like the output of the ifconfig(8) e.g. 00:00:E8:43:0B:2A. 

=item B<send($delay,$times)>

is a method which has used for send raw ip packet.
The input parameters are the delay seconds and the times for repeating send.
If you do not specify parameters for the B<send>,then packet will be sent once
without delay. 
If you do specify for the times a negative value then packet will be sent forever.
E.g. you want to send the packet for ten times with delay equal to one second.
Here is a code :

$packet->send(1,10);
The delay could be specified not only as integer but 
and as 0.25 for sleep to 250 ms or 3.5 to sleep for 3 seconds and 500 ms.

=item B<pcapinit($device,$filter,$psize,$timeout)>

is a method for some a pcap init. The input parameters are a device,a string with
a program for a filter,a packet size,a timeout.
This method will call the function open_live,then compile the filter string by compile(),
set the filter and returns the pointer (B<pcap_t *>).            	         

=item B<pcapinit_offline($fname)>

is a method for an offline pcap init.The input parameter is a name of the file
which contains raw output of the libpcap dump function.
Returns the pointer (B<pcap_t *>).  

=item B<ethnew>(B<$device>,B<dest> => B<ARGOFDEST>,B<source> => B<ARGOFSOURCE>)

is a method for init the ethernet subclass in the current object, B<$device> is a
required parameter,B<dest> and B<source> are an optional, B<$device> is an ethernet
device e.g. B<eth0>, an B<ARGOFDEST> and an B<ARGOFSOURCE> are a the ethernet addresses
in the ethernet header of the current object.

The B<ARGOFDEST> and the B<ARGOFSOURCE> can be given as a string which contain 
just 6 bytes of the real ethernet address or like the output of the ifconfig(8) 
e.g. 00:00:E8:43:0B:2A or just an ip address or a hostname of a target, 
then a mac address will be discovered automatically.

The ethernet frame will be sent with given addresses.
By default the B<source> and the B<dest> will be filled with a hardware address of   
the B<$device>.

B<NOTE:> For use methods which are related to the ethernet you have to before initialize
ethernet subclass by B<ethnew>. 

=item B<ethset>

is a method for set an ethernet parameters in the current object.
The given parameters must look like parameters for the B<ethnew> without
a B<$device>.

=item B<ethsend>

is a method for send an ethernet frame.
The given parameters must look like a parameters for the B<send>.

=item B<send_eth_frame>($frame,$times,$delay)

is a method for send any ethernet frame which you may construct by
hands.B<$frame> is a packed ethernet frame exept destination and
source fields(these fields can be setting by B<ethset> or B<ethnew>).
Another parameters must look like the parameters for the B<send>. 

=item B<optset>(OPTPROTO => { type => [...],data => [...] },...)

is a method for set an IP and a TCP options.
The parameters for the optset must be given as a key-value pairs.  
The B<OPTPROTO>,s are the prototypes of the options(B<ip>,B<tcp>),values are the hashes
references.The keys in this hashes are B<type> and B<data>.
The value of the B<type> is an array reference.
This array must be filled with an integers.Refer to a RFC for a valid types.The value of 
the B<data> also is an array reference. This array must be filled 
with strings which must contain all bytes from a option except bytes 
with type and length of an option.Of course indexes in those arrays must be 
equal for the one option.If type is equal to 0 or 1 then there is no bytes
with a length and a data,but you have to specify zero data for compability.

=item B<optget>(OPTPROTO => { type => [...] },...)  

is a method for get an IP and a TCP options.
The parameters for the optget must be given as key-value pairs.
The B<OPTPROTO> is the prototype of the options(B<ip>,B<tcp>),the values are 
the hashes references.The key is the B<type>.The value of the B<type> is an array reference.
The return value is an array which will be filled with asked types,lengths,datas
of the each type of the option in order as you have asked.If you do not specify type then
all types,lengths,datas of an options will be returned.
E.g. you want to know all the IP options from the current object.
Here is a code:

@opts = $a->optget(ip => {});

E.g. you want to know just the IP options with the type which equal to 131 and 137.
Here is a code:

($t131,$l131,$d131,$t137,$l137,$d137) = $a->optget(
                                   ip =>{
				        type =>[(131,137)]
				        }        );                        

=item B<optunset>

is a method for unset a subclass of the IP or the TCP options from a current
object.It can be used if you  won't use options in the current object later.
This method must be used only after the B<optset>.
The parameters for this method are the B<OPTPROTO>'s. 
E.g. you want to unset an IP options.
Here is a code:

$a->optunset('ip');

E.g. you want to unset a TCP and an IP options.
Here is a code:

$a->optunset('ip','tcp');

=back

=head1 AUTHOR

Sergey Kolychev <ksv@al.lg.ua>

=head1 COPYRIGHT

Copyright (c) 1998,1999 Sergey Kolychev. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=head1 SEE ALSO

perl(1),Net::RawIP::libpcap(3pm),tcpdump(1),RFC 791-793,RFC 768.


=cut

