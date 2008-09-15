#
# a script for exporting Netscape navigator's certificate database
# (aspa@hip.fi).
#
# $Id: export_certs.pl,v 1.1.1.1 2003-08-22 19:58:45 cvs Exp $.
#
# additional information:
# - http://www.drh-consultancy.demon.co.uk/cert7.html
# - man xxd
#
# conversion from DER format:
# /usr/local/ssl/bin/x509 -inform der -text < cert.der
#

use strict;

my (%certhash, $key, $val);
my $cert_db_path = $ENV{'HOME'} . "/.netscape/cert7";
my $rcnt = 0;

print STDERR "opening '$cert_db_path'.\n";

if( ! dbmopen(%certhash, $cert_db_path, undef) ) {
	print STDERR "dbmopen failed: '$!'.\n";
}

while ( ($key, $val) = each %certhash ) {
  my ($rec_type, $data, $klen, $vlen, $cert);

  $rcnt++;

  # get key info: [type] [data]
  ($rec_type, $data) = unpack("Ca*", $key);
  
  # get additional diagnostics info.
  $klen = length($key);
  $vlen = length($val);
  print STDERR "$rcnt: \t record type: '$rec_type'. key len: " . 
    "'$klen, \t value len: '$vlen'.\n";

  # check record type.
  if($rec_type != 1) {
    # not a certificate record. skip it.
    next;
  }

  # it is a certificate record.

  # certificates are stored in DER format starting at offset 13.
  $cert = substr($val, 13);

  # save cert in DER format.
  open(C_FILE, ">tmp/cert-$rcnt.der");
  print C_FILE "$cert";
  close(C_FILE);

}

dbmclose(%certhash);

