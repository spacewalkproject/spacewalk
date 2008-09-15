package Net::DHCPClient;
$Net::DHCPClient::VERSION = (qw($Revision: 1.1.1.1 $))[1];

=head1 NAME

  Net::DHCPClient - A DHCP Client API

=cut

use strict;

use Carp;
use Net::RawIP qw(:pcap);

use Data::Dumper;
use FileHandle;

use vars qw($AUTOLOAD);

my %fields = (
	      interface => undef,
	      macaddr => undef,
	      src => undef,
	      dest => undef,
	      op => undef,
	      htype => undef,
	      hlen => undef,
	      hops => undef,
	      xid => undef,
	      secs => undef,
	      flags => undef,
	      ciaddr => undef,
	      yiaddr => undef,
	      siaddr => undef,
	      giaddr => undef,
	      sname => undef,
	      bootfile => undef,
	      debug => undef,
	      options => undef,
	      timeout => undef,
	      );

sub new {
  my $that = shift;
  my $class = ref( $that ) || $that;
  my $self = {
	      _permitted => \%fields,
	      %fields,
	     };

  bless $self, $class;

  if ( @_ ) {
    my %conf = @_;
    while ( my( $k, $v ) = each %conf ) {
      $self->$k( $v );
    }
  }

  return $self;
}

sub AUTOLOAD {
  my $self = shift;
  my $type = ref( $self ) || croak "$self is not an object";
  my $name = $AUTOLOAD;

  if ( @_ ) {
    return $self->{$name} = shift;
  } else {
    return $self->{$name};
  }
}

sub discover {
  my $self = shift;
  my %options = @_;
  
  $self->ciaddr( 0 );
  $self->yiaddr( 0 );
  $self->siaddr( 0 );
  $self->giaddr( 0 );

  $options{53} = '1';

  $self->doit( \%options );
}

sub request {
  my $self = shift;
  my %options = @_;

  $self->ciaddr( $self->yiaddr );

  $options{53} = '3';

  $self->doit( \%options );
}

sub decline {
  my $self = shift;
  my %options = @_;

  $options{53} = '4';

  $self->doit( \%options );
}

sub release {
  my $self = shift;
  my %options = @_;

  $options{53} = '7';

  $self->doit( \%options );
} 
  
sub inform {
  my $self = shift;
  my %options = @_;

  $options{53} = '8';

  $self->doit( \%options );
} 

sub doit {
  my $self = shift;
  my $o = shift; 
  my %options = %$o;

  my $macaddr = $self->macaddr;
  my $interface = $self->interface;

  my $op = 1; 
  my $htype = $self->htype || 1;
  my $hlen = $self->hlen || 6;
  my $ciaddr = $self->client_ip() || '0.0.0.0';
  my $yiaddr = $self->your_ip() || '0.0.0.0';
  my $siaddr = $self->server_ip() || '0.0.0.0';
  my $giaddr = $self->relay_ip() || '0.0.0.0';
  my $sname = $self->sname || 0;
  my $file = $self->bootfile || 0;

  my $timeout = $self->timeout || 10;

  my $dstmac;
  my $dstip;

  if ( $self->src ) {
    $dstmac = net2mac( $self->src );
  } else {
    $dstmac = 'ff:ff:ff:ff:ff:ff';
  }

  if ( $self->siaddr ) {
    $dstip = $self->server_ip();
  } else {
    $dstip = '255.255.255.255';
  }

  my $srcip = $self->your_ip();

  my $xid = sprintf "%0.8d", int( rand 99999999 );

  my $data = $self->encode( op => $op, htype => $htype, hlen => $hlen, 
			    hops => 0, xid => $xid, secs => 0, flags => 0, 
			    ciaddr => $ciaddr, yiaddr => $yiaddr, 
			    siaddr => $siaddr, giaddr => $giaddr, 
			    chaddr => $macaddr, sname => $sname, 
			    file => $file, options => \%options );

  my $p = new Net::RawIP( {udp => {}} );

  $p->ethnew( $interface );
  $p->ethset( source => $macaddr, dest => $dstmac);

  $p->set( {ip => {saddr => $srcip, daddr => $dstip},
	    udp => {source => 68, dest => 67, data => $data}} );

  my $filter = "ether dst $macaddr and dst port 68";

  my $a = new Net::RawIP;
  my @f;

  my $done = 0;

  STDERR->close;

  my $pcap = $a->pcapinit( $interface, $filter, 1500, 500 );

  STDERR->fdopen( 2, "w+" );

  $SIG{ALRM} = sub { die "timeout" };

  while ( ! $done ) {

    if ( $self->debug ) {

      my $op53 = $options{'53'};

      print "XMIT:\n";
      printf
	"xid %u:\tsaddr=%s daddr=%s\n\t\tsrc=%s dest=%s op=%d\n",
	  $xid, $srcip, $dstip, $macaddr, $dstmac, $op53;
    }

    $p->ethsend;

    if ( $options{'53'} == 7 ) {
      return 1;
    }

    eval {

      while ( sprintf( "%x", $self->xid ) ne sprintf( "%u", $xid ) ) {

	alarm( $timeout );

	loop $pcap, 1, sub { 
	  my $time = timem();
	  $p->bset( substr( $_[2], 14 ) );
	
	  $self->dest( substr( $_[2], 0, 6) );
	  $self->src( substr( $_[2], 6, 6) );
	
	  my @g = $p->get( {ip => [qw(ttl saddr daddr)],
			    udp => [qw(data)]} );

	  $self->decode( $g[3] );

	  $done = 1;

	  if ( $self->debug ) {
	
	    my $x = $self->options();
	    my %options = %$x;

	    my $op53 = $options{'53'};

	    print "RCVD:\n";
	    printf 
	      "xid %lx:\n    %lu\tttl=%u saddr=%s daddr=%s\n\t\tsrc=%s dest=%s op=%d\n",
		$self->xid, $xid, $g[0], ip2dot( $g[1] ), ip2dot( $g[2] ),
		  net2mac( $self->src ), net2mac( $self->dest ), $op53;
	  }

	  if ( $self->debug > 5 ) {
	    printf "%u %x\n", $xid, $self->xid;
	  }
	
	}, \@f;

	alarm( 0 );
      }
    };

    if ( $@ ) {
      if ( $@ =~ /timeout/ ) {
	if ( $self->debug ) {
	  print "TIMEOUT\n";
	}
	return 0;
      } else {
	alarm( 0 );
	die;
	}
    }
  }

  my $x = $self->options();

  my %options = %$x;

  if ( $self->debug > 5 ) {
    print "Returning from doit()\n";
  }

  return 1;
}

sub decode {
  my $self = shift;
  my $data = shift;
  my @fields = ('op', 'htype', 'hlen', 'hops', 'xid', 'secs', 'flags',
		'ciaddr', 'yiaddr', 'siaddr', 'giaddr');
  my %options; 

  my $bootp = substr $data, 0, 239;
  my $opts = substr $data, 240;
  my @bootp = unpack "H2 H2 H2 H2 H8 H4 H4 H8 H8 H8 H8 H32 H128 H256", $bootp;

  for ( my $i;  $i <= 10; $i++ ) { $bootp[$i] = hex( $bootp[$i] ); }

  for ( my $i; $i <= $#bootp; $i++ ) {
    my $method = $fields[$i];
    $self->$method( $bootp[$i] );
  }

  my @opts = unpack "C" x ( length( $data ) - 240 ), $opts;

  for ( my $i = 0; $i <= $#opts; $i++ ) {
    
    my $opt = $opts[$i++];
    my $len = $opts[$i++];
    my $offset = $len + $i - 1;
    my $string = "";

    for ( my $q = $i; $q <= $offset; $q++ ) {
      if ( $string ) {
	$string = sprintf "%s %d", $string, $opts[$q];
      } else {
	$string = sprintf "%d", $opts[$q];
      }
    }

    $options{$opt} = $string;

    $i = $i + $len - 1;
  }

  $self->options( \%options );
}

sub encode {
  my $self = shift;
  my %c = @_;
  
  my $magic = pack "C4", 99, 130, 83, 99;

  my @ciaddr = split /\./, $c{'ciaddr'};
  my @yiaddr = split /\./, $c{'yiaddr'};
  my @siaddr = split /\./, $c{'siaddr'};
  my @giaddr = split /\./, $c{'giaddr'};
  
  my @chaddr = mac2net( $c{'chaddr'} );

  my $data = pack "C4 H8 H4 H4 C4 C4 C4 C4 C16 H128 H256", 
  $c{'op'}, $c{'htype'}, $c{'hlen'}, $c{'hops'}, $c{'xid'}, $c{'secs'},
  $c{'flags'}, @ciaddr, @yiaddr, @siaddr, @giaddr, @chaddr, $c{'sname'}, 
  $c{'file'};

  $data = join '', $data, $magic;

  my $o = $c{'options'}; 
  my %options = %$o;

  foreach my $key ( keys %options ) {
    my @p = split / /, $options{$key};
    map { $_ = hex( $_ ); } @p;

    my $format = sprintf "C%d", $#p+3;

    my $options = pack $format, $key, $#p+1, @p;

    $data = join '', $data, $options;
  }

  my $end = pack "C2", 255, 0;

  $data = join '', $data, $end;

  return $data;
}

sub net2mac {
  return sprintf( "%.2x:%.2x:%.2x:%.2x:%.2x:%.2x", unpack( "C6", shift ) );
}

sub mac2net {
  my @a = split /:/, shift;

  for ( 1..10 ) {
    push @a, '0';
  }

  map { $_ = hex($_); } @a;
    
  return @a;
}

sub ip2dot {
  return sprintf( "%u.%u.%u.%u", unpack( "C4", pack( "N", shift ) ) );
}

sub dot2ip {
  return unpack( "N", pack( "C4", split( /\./, shift ) ) );
}

sub client_ip {
  my $self = shift;

  return ip2dot( $self->ciaddr );
}

sub reply {
  my $self = shift;

  my @ops = ( '', 'discover', 'offer', 'request', 'decline', 'ack', 'nak',
	      'release', 'inform' );

  my $x = $self->options;
  my %options = %$x;

  return ( $ops[$options{'53'}] );
}

sub your_ip {
  my $self = shift;

  return ip2dot( $self->yiaddr );
}

sub server_ip {
  my $self = shift;

  return ip2dot( $self->siaddr );
}

sub relay_ip {
  my $self = shift;

  return ip2dot( $self->giaddr );
}

sub domain_name {
  my $self = shift;

  my $o = $self->options;
  my %options = %$o;

  my @l = split / /, $options{15};

  return( pack "C*", @l );
}

sub server_lookup {
  my $self = shift;
  my $option = shift;

  my $o = $self->options;
  my %options = %$o;

  my @val = split / /, $options{$option};

  my @servers;

  for ( my $i; $i <= $#val; $i++ ) {
    push @servers, sprintf "%d.%d.%d.%d", 
           $val[$i++], $val[$i++], $val[$i++], $val[$i];
  }

  return @servers; 
}
  
sub domain_name_server {
  my $self = shift;

  return $self->server_lookup(6);
}

sub server_identifier {
  my $self = shift;

  return $self->server_lookup(54);
}

sub router {
  my $self = shift;

  return $self->server_lookup(3);
}

sub subnet_mask {
  my $self = shift;
  
  return $self->server_lookup(1);
}

sub ntp_server {
  my $self = shift;
  
  return $self->server_lookup(42);
}

sub time_server {
  my $self = shift;

  return $self->server_lookup(4);
}

sub netbios_nameserver {
  my $self = shift;
  
  return $self->server_lookup(44);
}

sub broadcast {
  my $self = shift;

  return $self->server_lookup(28);
}

=head1 SYNOPSIS

  use Net::DHCPClient;

  my $dhcp = new Net::DHCPClient( maccaddr => '0a:0a:0a:0a:0a:0a', 
				  interface => 'eth0' );

  $dhcp->discover( 61 => '0a 0a 0a 0a 0a 0a' );

=cut

=head1 DESCRIPTION

This module provides methods for implementing a DHCP client. It allows perl 
scripts to interacts with DHCP servers.

This module is used by constructing a new DHCPClient object via the 
constructor method, providing it (minimally) with the machine address and
the network interface that is to be used for the DHCP transaction with
the DHCP server. 

Information after each DHCP call is stored in the instance variables of
the object. Refer to RFC2131 for the designations of the named fields. 
Options (sometimes called vendor extensions) are stored in an instance
variable in the object called options as a references to a hash. The options
themselves are keys by the decimal designation of the option, and the values
of the hash are string representations of the hex values that should be passed
to the DHCP server with the options. Please refer to RFC2132 for a complete 
listing.

Some common option fields are available through methods in this object for 
convenience. They are listed in this document.

This document is not a replacement for RFC2131 or RFC2132, and you will
probably need a copy of them handy if you are coding DHCP clients.


=cut

=head2 Class Methods

The constructor is the only class method that should be invoked. It takes
as its parameters minimally the machine address and the interface for which
the DHCP transaction should take place.

=head2 Object Methods

Object methods must be invoked against objects created via the B<new>
method.

There are two kinds of object methods -- those that invoke DHCP transactions
and those that interpret the results of a DHCP transaction. I am grouping
them separately for this reason.

B<DHCPClient> transaction object methods

All of the B<DHCPClient> transaction methods take named parameters as their
arguments, where paramters are named for the decimal representation of the 
options that can be set in the DHCP packet, and set to a string representation
of the hex values that should be set for the named parameter in the DHCP
packet. Whew. Fear not, examples are below. 

=over 4

=item decline

The decline method declines an offer from a DHCP server.

=item discover

The discover method broadcasts a DHCPDISCOVER on the local subnet.

=item inform

The inform method requests information from a DHCP server.

=item release

The release method releases the lease of the IP address.

=item request

The request method requests a DHCP lease.

=back

B<DHCPClient> result object methods

These methods are built as conveniences to get the data that is contained
in the result of a DHCP transaction returned in a usable form. All of the
data can be had by going through the object instance variables by hand, but
I would not recommend it. These methods will not return anything useful
until a DHCP transaction has taken place.

Note -- unless otherwise noted, an IP address returned by an object
method listed in this documentation should be considered to be a string
containing the address is dotted notation. 

=over 4

=item broadcast

Returns the broadcast address.

=item client_ip

Returns the IP address of the client that made the request to the DHCP server.

=item domain_name

Returns the domain name that the server has provided.

=item domain_name_server

Returns a list of IP addresses of the domain name servers.

=item netbiod_nameserver

Returns a list of the IP addresses of the netbiod domain name servers
(i.e. NT Domain servers)

=item ntp_server

Returns a list of IP address of the Network Time Protocol server.

=item relay_ip

Returns the IP address of the agent that relayed your DHCP request to the 
DHCP server (probably a router).

=item reply

Returns a string indicating what the server reply was. 

=item server_identifier

Returns a server identifier -- it is usually an IP address of the server,
but does not necessarily need to be. This method assumes an IP address.

=item server_ip

Returns the IP address of the DHCP server that handled your request.

=item subnet_mask

Returns the subnet mask.

=item time_server

Returns a list of the IP addresses of the time servers.

=item your_ip

Returns the IP address that the DHCP server has offered to your client.

=back

=head1 Change log

     Revision 1.0  2001/04/19
     Initial release

=head1 AUTHOR

  Joshua Walgenbach
  Indiana Unversity
  jwalgenb@indiana.edu

=head1 COPYRIGHT

  Copyright 2000, Joshua Walgenbach
  All rights reserved

This program is free software; you can redistribute it and/or modify
it under the terms of either:

=over 4

=item

a) the "Artistic License" which comes with this Kit, or

b) the GNU General Public License as published by the Free Software 
Foundation; either version 1, or (at your option) any later version.

=back

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See either
the GNU General Public License or the Artistic License for more details.

=cut

1;

