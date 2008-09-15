BEGIN { push @INC, qw(. .. ../lib ../../lib ../../../lib) }

package Crypt::Blowfish;

require Exporter;
require DynaLoader;

@ISA = (Exporter, DynaLoader);

bootstrap Crypt::Blowfish;


use Benchmark qw(timediff timestr);
use strict;
use Carp;

sub usage
{
    my ($package, $filename, $line, $subr) = caller(1);
	$Carp::CarpLevel = 2;
	croak "Usage: $subr(@_)"; 
}


sub blocksize { 8; }
sub keysize { 56; }

sub new
{
	usage("new Blowfish key") unless @_ == 2;

	my $type = shift; my $self = {}; bless $self, $type;

	$self->{'ks'} = Crypt::Blowfish::init(shift);

	$self;
}

sub encrypt
{
	usage("encrypt data[8 bytes]") unless @_ == 2;

	my $self = shift;
	my $data = shift;

	Crypt::Blowfish::crypt($data, $data, $self->{'ks'}, 0);

	$data;
}

sub decrypt
{
	usage("decrypt data[8 bytes]") unless @_ == 2;

	my $self = shift;
	my $data = shift;

	Crypt::Blowfish::crypt($data, $data, $self->{'ks'}, 1);

	$data;
}


package main;


#
# '6162636465666768696a6b6c6d6e6f707172737475767778797a',
#			'424c4f5746495348', '324ed0fef413a203',
#
# '57686f206973204a6f686e2047616c743f', 'fedcba9876543210', 'cc91732b8022f684')
#
# "Ayn Rand" FEDCBA9876543210 e113f4102cfcce43
#

print "1..11\n";

my $key = pack("H*", "6162636465666768696a6b6c6d6e6f707172737475767778797a");
my $in = pack("H*", "424c4f5746495348");
my $out = pack("H*", "324ed0fef413a203");

my $cipher = new Crypt::Blowfish $key;

print "not " unless ($cipher->encrypt($in) eq $out);
print "ok 1\n";

my $key = pack("H*", "57686f206973204a6f686e2047616c743f");
my $in = pack("H*", "fedcba9876543210");
my $out = pack("H*", "cc91732b8022f684");

my $cipher = new Crypt::Blowfish $key;

print "not " unless ($cipher->decrypt($out) eq $in);
print "ok 2\n";

my $key = "Ayn Rand";
substr($key, 3, 1) = pack("C", ord(substr($key, 3, 1))+128);
substr($key, 7, 1) = pack("C", ord(substr($key, 7, 1))+128);
my $in = pack("H*", "fedcba9876543210");
my $out = pack("H*", "e113f4102cfcce43");

my $cipher = new Crypt::Blowfish $key;

print "not " unless ($cipher->encrypt($in) eq $out);
print "ok 3\n";

my $key = pack("H*", "0000000000000000");
my $in =  pack("H*", "0000000000000000");
my $out = pack("H*", "4EF997456198DD78");

my $cipher = new Crypt::Blowfish $key;

print "not " unless($cipher->encrypt($in) eq $out);
print "ok 4\n";

my $key = pack("H*", "FFFFFFFFFFFFFFFF");
my $in =  pack("H*", "0000000000000000");
my $out = pack("H*", "F21E9A77B71C49BC");

my $cipher = new Crypt::Blowfish $key;

print "not " unless ($cipher->decrypt($out) eq $in);
print "ok 5\n";

my $key = pack("H*", "FFFFFFFFFFFFFFFF");
my $in  = pack("H*", "FFFFFFFFFFFFFFFF");
my $out = pack("H*", "51866FD5B85ECB8A");

my $cipher = new Crypt::Blowfish $key;

print "not " unless ($cipher->encrypt($in) eq $out);
print "ok 6\n";

my $key = pack("H*", "3000000000000000");
my $in  = pack("H*", "1000000000000001");
my $out = pack("H*", "7D856F9A613063F2");

my $cipher = new Crypt::Blowfish $key;

print "not " unless ($cipher->encrypt($in) eq $out);
print "ok 7\n";

my $key = pack("H*", "1111111111111111");
my $in  = pack("H*", "1111111111111111");
my $out = pack("H*", "2466DD878B963C9D");

my $cipher = new Crypt::Blowfish $key;

print "not " unless ($cipher->encrypt($in) eq $out);
print "ok 8\n";

my $key = pack("H*", "584023641ABA6176");
my $in  = pack("H*", "004BD6EF09176062");
my $out = pack("H*", "452031C1E4FADA8E");

my $cipher = new Crypt::Blowfish $key;

print "not " unless ($cipher->encrypt($in) eq $out);
print "ok 9\n";

my $key = pack("H*", "0101010101010101");
my $in  = pack("H*", "0123456789ABCDEF");
my $out = pack("H*", "FA34EC4847B268B2");

my $cipher = new Crypt::Blowfish $key;

print "not " unless ($cipher->encrypt($in) eq $out);
print "ok 10\n";

{
	print "\nRunning standard mode speed tests.. encrypting with non-cached cipher\n";
	my $t0 = new Benchmark;

	for(1..5000){
		my $key = pack("H*", "0101010101010101");
		my $in  = pack("H*", "0123456789ABCDEF");
		my $out = pack("H*", "FA34EC4847B268B2");

		my $cipher = new Crypt::Blowfish $key;
		$cipher->encrypt($in);
	}

	my $t1 = new Benchmark;
	my $td = Benchmark::timediff($t1,$t0);
	my $ts = Benchmark::timestr($td);

	print "5,000 cycles: $ts\n";

}; # end standard mode (encrypt) speed test non-cached cipher

{
        print "\nRunning standard mode speed tests.. decrypting with non-cached cipher\n";
        my $t0 = new Benchmark;

        for(1..5000){
                my $key = pack("H*", "0101010101010101");
                my $in  = pack("H*", "0123456789ABCDEF");
                my $out = pack("H*", "FA34EC4847B268B2");

                my $cipher = new Crypt::Blowfish $key;
                $cipher->decrypt($out);
        }

        my $t1 = new Benchmark;
        my $td = Benchmark::timediff($t1,$t0);
        my $ts = Benchmark::timestr($td);

        print "5,000 cycles: $ts\n";

}; # end standard mode (decrypt) speed test non-cached cipher


my $key = pack("H*", "0101010101010101");
my $cipher = new Crypt::Blowfish $key;
{
        print "\nRunning standard mode speed tests.. encrypting with cached cipher\n";
        my $t0 = new Benchmark;

        for(1..10000){
                my $in  = pack("H*", "0123456789ABCDEF");
                my $out = pack("H*", "FA34EC4847B268B2");

                $cipher->encrypt($in);
        }

        my $t1 = new Benchmark;
        my $td = Benchmark::timediff($t1,$t0);
        my $ts = Benchmark::timestr($td);

        print "10,000 cycles: $ts\n";


}; # end standard mode (encrypt) speed test cached cipher

{
        print "\nRunning standard mode speed tests.. decrypting with cached cipher\n";
        my $t0 = new Benchmark;

        for(1..10000){
                my $in  = pack("H*", "0123456789ABCDEF");
                my $out = pack("H*", "FA34EC4847B268B2");

                $cipher->decrypt($out);
        }

        my $t1 = new Benchmark;
        my $td = Benchmark::timediff($t1,$t0);
        my $ts = Benchmark::timestr($td);

        print "10,000 cycles: $ts\n";


}; # end standard mode (decrypt) speed test cached cipher


print "\nTesting Cipher Block Chaining..\n";
eval 'use Crypt::CBC';

if(!$@) {
	if($Crypt::CBC::VERSION < 1.22) { 
		$@ = "CBC mode requires Crypt::CBC version 1.22 or higher."; 
	} else {

		my $cipher = new Crypt::CBC(pack("H*","0123456789ABCDEFF0E1D2C3B4A59687"),"Blowfish");
		my $ciphertext = $cipher->encrypt(pack("H*","37363534333231204E6F77206973207468652074696D6520666F722000"));
		my $plaintext  = $cipher->decrypt($ciphertext);

		if($plaintext eq "7654321 Now is the time for \0") {
		print "ok 11 - CBC Mode\n";
		} else {
		print unpack("H*",$plaintext) . " :decrypted\n";
		print unpack("H*","7654321 Now is the time for \0") . " :orig\n";
		print "not ok 11 - CBC Mode failed\n";
		}
	}
} # end no errors

if($@) {
	print "Error (probably harmless):\n$@\n";
}

