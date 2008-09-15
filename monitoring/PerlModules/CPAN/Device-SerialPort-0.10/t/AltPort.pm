package AltPort;
# Inheritance test for test3.t and test4.t only

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = '0.10';
require Exporter;
use Device::SerialPort qw( :PARAM 0.07 );
@ISA = qw( Exporter Device::SerialPort );
@EXPORT= qw();
@EXPORT_OK= @Device::SerialPort::EXPORT_OK;
%EXPORT_TAGS = %Device::SerialPort::EXPORT_TAGS;

my $in = SHORTsize;
print "AltPort import=$in\n";
1;
