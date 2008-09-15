package NOCpulse::Probe::Utils::test::TestIPAddressRange;

use strict;

use NOCpulse::Probe::Utils::IPAddressRange;

use base qw(Test::Unit::TestCase);

sub test_init_ip {
    my $self = shift;

    my $addr = '1.2.3.4';
    my $ip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => $addr);
    $self->assert($ip->ip eq $addr, "IP not set: ", $ip->ip);
    $self->check_field($ip, 'XL_LO', 1);
    $self->check_field($ip, 'XL_HI', 1);
    $self->check_field($ip, 'ML_LO', 2);
    $self->check_field($ip, 'ML_HI', 2);
    $self->check_field($ip, 'MR_LO', 3);
    $self->check_field($ip, 'MR_HI', 3);
    $self->check_field($ip, 'XR_LO', 4);
    $self->check_field($ip, 'XR_HI', 4);

    $ip = NOCpulse::Probe::Utils::IPAddressRange->new(octets => [1, 2, 3, 4]);
    $self->assert($ip->ip eq $addr, "IP not set: ", $ip->ip);
    $self->check_field($ip, 'XL_LO', 1);
    $self->check_field($ip, 'XL_HI', 1);
    $self->check_field($ip, 'ML_LO', 2);
    $self->check_field($ip, 'ML_HI', 2);
    $self->check_field($ip, 'MR_LO', 3);
    $self->check_field($ip, 'MR_HI', 3);
    $self->check_field($ip, 'XR_LO', 4);
    $self->check_field($ip, 'XR_HI', 4);
}

sub test_init_octets {
    my $self = shift;

    my $addr = '5.6.7.8';
    my $ip = NOCpulse::Probe::Utils::IPAddressRange->new(octets => [5, 6, 7, 8]);
    $self->assert($ip->ip eq $addr, "IP not set: ", $ip->ip);
    $self->check_field($ip, 'XL_LO', 5);
    $self->check_field($ip, 'XL_HI', 5);
    $self->check_field($ip, 'ML_LO', 6);
    $self->check_field($ip, 'ML_HI', 6);
    $self->check_field($ip, 'MR_LO', 7);
    $self->check_field($ip, 'MR_HI', 7);
    $self->check_field($ip, 'XR_LO', 8);
    $self->check_field($ip, 'XR_HI', 8);
}

sub test_ranges {
    my $self = shift;

    my $addr;
    my $ip;

    $addr = '5.*.7-123.8';
    $ip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => $addr);
    $self->assert($ip->ip eq $addr, "IP not set: ", $ip->ip);
    $self->check_field($ip, 'XL_LO', 5);
    $self->check_field($ip, 'XL_HI', 5);
    $self->check_field($ip, 'ML_LO', 0);
    $self->check_field($ip, 'ML_HI', 255);
    $self->check_field($ip, 'MR_LO', 7);
    $self->check_field($ip, 'MR_HI', 123);
    $self->check_field($ip, 'XR_LO', 8);
    $self->check_field($ip, 'XR_HI', 8);
}

sub test_match {
    my $self = shift;

    my $addr;
    my $ip;

    $addr = '5.*.7-123.8';
    $ip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => $addr);
    $self->assert($ip->ip eq $addr, "IP not set: ", $ip->ip);
    $self->check_field($ip, 'XL_LO', 5);
    $self->check_field($ip, 'XL_HI', 5);
    $self->check_field($ip, 'ML_LO', 0);
    $self->check_field($ip, 'ML_HI', 255);
    $self->check_field($ip, 'MR_LO', 7);
    $self->check_field($ip, 'MR_HI', 123);
    $self->check_field($ip, 'XR_LO', 8);
    $self->check_field($ip, 'XR_HI', 8);

    $addr = '1-10.11-20.21-30.31-40';
    $ip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => $addr);

    my $new_ip;
    $addr = '5.15.25.35';
    $new_ip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => $addr);
    $self->assert($ip->matches($new_ip), "No match for $addr");

    $addr = '0.10.20.30';
    $new_ip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => $addr);
    $self->assert(!$ip->matches($new_ip), "Incorrect match for $addr");

    $addr = '1.10.20.30';
    $new_ip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => $addr);
    $self->assert(!$ip->matches($new_ip), "Incorrect match for $addr");

    $addr = '0.11.20.30';
    $new_ip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => $addr);
    $self->assert(!$ip->matches($new_ip), "Incorrect match for $addr");

    $addr = '0.10.21.30';
    $new_ip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => $addr);
    $self->assert(!$ip->matches($new_ip), "Incorrect match for $addr");

    $addr = '0.10.20.31';
    $new_ip = NOCpulse::Probe::Utils::IPAddressRange->new(ip => $addr);
    $self->assert(!$ip->matches($new_ip), "Incorrect match for $addr");
}

sub check_field {
    my ($self, $ip, $field, $expected) = @_;

    my $value = $ip->$field();
    $self->assert($value == $expected, "$field not $expected: $value");
}

1;
