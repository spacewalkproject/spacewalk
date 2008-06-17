package NOCpulse::Probe::DataSource::SQLPlusQuery;

use strict;

use Error ':try';
use NOCpulse::Probe::Error;
use NOCpulse::Probe::Shell::SQLPlus;

use base qw(NOCpulse::Probe::DataSource::AbstractOSCommand);

use Class::MethodMaker
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

sub init {
    my ($self, %in_args) = @_;

    my %own_args = ();

    $self->default_datasource_args(\%in_args, \%own_args);

    $own_args{shell} = NOCpulse::Probe::Shell::SQLPlus->new(%in_args);

    $self->SUPER::init(%own_args);

    return $self;
}

1;

__END__
