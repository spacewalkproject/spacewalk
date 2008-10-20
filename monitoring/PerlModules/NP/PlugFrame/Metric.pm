package Metric;

use strict;

use NOCpulse::PersistentObject;
@Metric::ISA=qw(NOCpulse::PersistentObject);

sub named {
    my ($class,$instanceName) = @_;   
    return $class->newInitializedNamed($instanceName);
}

sub hasValue {
    my $self = shift();
    return $self->get_value;
}

sub templateNodes {
    my $self = shift();
    my @parts = split('->',$self->get_Template_string);
    return @parts;
}

sub metricId {
    my $self = shift();
    my ($junk, $metricId) = split('->', $self->get_name, 2);
    return $metricId;
}

sub templateAndMetricIds
{
    my $self = shift();
    my ($template,$metricId) = split('->',$self->get_name,2);
    my ($junk1,$templateId,$junk2) = split(/(^.*)_.?/,$template,2);
    return [$templateId,$metricId];
}

1;
