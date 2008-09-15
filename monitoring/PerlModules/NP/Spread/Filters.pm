package Filter;
use NOCpulse::Object;
@ISA=qw(Object);

sub initialize
{
	my ($self,$next) = @_;
	$self->SUPER::initialize();
	$self->set_next($next);
	if (defined($next)) {
		$next->set_prev($self);
	}
	return $self;
}

sub instVarDefinitions
{
	my $self = shift;
	$self->addInstVar('next');
	$self->addInstVar('prev');
	$self->addInstVar('tailCache');
}

sub tail
{
	my $self = shift();
	if (! defined($self->get_next)) {
		return $self;
	} else {
		if (! $self->get_tailCache) {
			$self->set_tailCache($self->get_next->tail);
		}
		return $self->get_tailCache;
	}
}


sub _encode
{
	my ($self,$string) = @_;
	# Abstract - subclasses should override
	return $string;
}

sub _decode
{
	my ($self,$string) = @_;
	# Abstract - subclasses should override
	return $string;
}

sub encode
{
	my ($self,$string) = @_;
	$string = $self->_encode($string);
	if (defined($self->get_next)) {
		return $self->get_next->encode($string);
	} else {
		return $string;
	}
}

sub decode
{
	my ($self,$string) = @_;
	$string = $self->_decode($string);
	if (defined($self->get_prev)) {
		return $self->get_prev->decode($string);
	} else {
		return $string;
	}
}

package BlowfishFilter;
@ISA=qw(Filter);
use strict;
use Crypt::CBC;

sub initialize
{
	my ($self,$next,$key) = @_;
	$self->set_cipher(
		Crypt::CBC->new( {
			'key' => $key,
			'cipher' => 'Blowfish',
			'regenerate_key' => 1
		} )
	);
	return $self->SUPER::initialize($next);
}

sub instVarDefinitions
{
	my $self = shift();
	$self->SUPER::instVarDefinitions;
	$self->addInstVar('cipher');
}

sub _encode
{
    my ($self,$string) = @_;
    return $self->get_cipher->encrypt($string);
}

sub _decode
{
    my ($self,$string) = @_;
    return $self->get_cipher->decrypt($string);
}

1

