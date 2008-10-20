
package NOCpulse::SatConfig::ConfigDocument;

use strict;

use NOCpulse::Object;
use Digest::MD5 qw(md5_hex);
use Apache2::RequestRec ();
use Apache2::RequestIO ();
use vars qw(@ISA);

@ISA = qw ( NOCpulse::Object );

# Keep in synch with scheduleEvents
use constant CONFIG_DOC_VERSION => '1.1';

sub instVarDefinitions
{
    my $self = shift();
    $self->addInstVar('versionSection');
    $self->addInstVar('netsaintSection');
    $self->addInstVar('probeSection');
    $self->addInstVar('commandParamSection');
    $self->addInstVar('commandMetricSection');
    $self->addInstVar('messagesSection');
    return $self;
}

sub initialize
{
    my $self = shift();
    $self->set_messagesSection([]);
    return $self;
}

sub addMessage
{
    my ($self,@messages) = @_;
    my $messageListRef = $self->get_messagesSection;
    my $message;
    foreach $message (@messages) {
	push(@$messageListRef,$message);
    }
}

sub sendToSatellite
{
    my $self = shift;
    my $cgi = shift;
    my $request = shift;
    
    my $CRLF = "\015\012"; # "\r\n" is not portable
    my $CRLFCRLF = $CRLF.$CRLF;
    my $boundary = '-' x 60;

    local $| = 1;

    # This is essential to prevent the smon proxy layer from stripping
    # the multipart header from the content.
    $request->content_type('application/octet-stream');

    $request->print(qq!HTTP/1.1 200 OK! . $CRLF);
    $request->print(qq!Content-Type: multipart/x-mixed-replace;boundary="$boundary"! . $CRLFCRLF);

    my $type = $cgi->multipart_init( -boundary => $boundary );
    $type = (split("\n",$type,2))[1];
    $request->print( $type );

    $request->print( 'Content-Type: text/plain'.$CRLFCRLF );

    my $messageListRef = $self->get_messagesSection;
    my $message;
    foreach $message (@$messageListRef) {
	$request->print( $message."\n" );
    }
    $request->print( $cgi->multipart_end );
    
    # Payload sections -- checksums, then data
    my @checksums;
    push(@checksums, md5_hex($self->get_netsaintSection));
    push(@checksums, md5_hex($self->get_probeSection));
    push(@checksums, md5_hex($self->get_commandParamSection));
    push(@checksums, md5_hex($self->get_commandMetricSection));
    
    $request->print( 'Content-Type: text/plain'.$CRLFCRLF );
    $request->print( join(":", @checksums) );
    $request->print( $cgi->multipart_end );
    
    $request->print( 'Content-Type: text/plain'.$CRLFCRLF );
    $request->print( CONFIG_DOC_VERSION );
    $request->print( $cgi->multipart_end );
    
    $request->print( 'Content-Type: text/plain'.$CRLFCRLF );
    $request->print( $self->get_netsaintSection );
    $request->print( $cgi->multipart_end );
    
    $request->print( 'Content-Type: text/plain'.$CRLFCRLF );
    $request->print( $self->get_probeSection );
    $request->print( $cgi->multipart_end );
    
    $request->print( 'Content-Type: text/plain'.$CRLFCRLF );
    $request->print( $self->get_commandParamSection );
    $request->print( $cgi->multipart_end );
    
    $request->print( 'Content-Type: text/plain'.$CRLFCRLF );
    $request->print( $self->get_commandMetricSection );
    $request->print( $cgi->multipart_end );
}

1;
