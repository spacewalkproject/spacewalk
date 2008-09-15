package NOCpulse::Probe::DataSource::MySQL;

use strict;

use NOCpulse::Probe::Error;
use NOCpulse::Probe::Shell::Local;

use base qw(NOCpulse::Probe::DataSource::AbstractOSCommand);

use Class::MethodMaker
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);

use constant LOCAL_SHELL => 'NOCpulse::Probe::Shell::Local';

sub init {
    my ($self, %in_args) = @_;

    my $shell_class = LOCAL_SHELL;

    my %own_args = ();

    $self->default_datasource_args(\%in_args, \%own_args);

    $in_args{timeout_seconds} = delete $in_args{timeout};

    $own_args{shell} = $shell_class->new(%in_args);

    $self->SUPER::init(%own_args);

    return $self;
}

sub ensure_program_installed {
    my ($self, $program_path) = @_;

    my $old_die_flag = $self->die_on_failure;
    $self->die_on_failure(0);

    $self->execute("test -x $program_path");

    $self->die_on_failure($old_die_flag);

    if ($self->command_status == 1) {
        my $msg = sprintf($self->_message_catalog->status('missing_program'), $program_path);
        throw NOCpulse::Probe::DataSource::MissingProgramError($msg);
    }
}


sub status {
    my ($self, $host, $port, $user, $password) = @_;
    my $binary = '/usr/bin/mysqladmin';

    $self->die_on_failure(0);

    $self->ensure_program_installed($binary);

    #BZ 164820: IP addresses with leading zeros in any octets need
    #to be fixed so requests work correctly
    my @octets = split(/\./, $host);
    foreach my $octet (@octets) {
        $octet =~ s/^0*//;
        $octet = 0 unless $octet;
    }
    $host = join('.', @octets);

    my ($result);
    if ($password) {
	$Log->log_method(1, "Found password, using it\n");
	$result = $self->execute("$binary -h $host -P $port -u $user -p$password extended-status");
    } else {
	$Log->log_method(1, "No password found, using non -p version\n");
	$result = $self->execute("$binary -h $host -P $port -u $user extended-status");
    }

    if ($self->shell->stderr =~ /connect to server at .* failed/) {
	$Log->log_method(1, "Errors found: " . $self->shell->stderr);
	my $msg = "Could not establish connection to MySQL database on host $host";
	throw NOCpulse::Probe::DataSource::ConnectError($msg); 
    }

    return ($result);

}

sub accessibility {
    my ($self, $host, $port, $db, $user, $password) = @_;
    my $binary = '/usr/bin/mysql';

    $self->die_on_failure(0);

    $self->ensure_program_installed($binary);

    #BZ 164820: IP addresses with leading zeros in any octets need
    #to be fixed so requests work correctly
    my @octets = split(/\./, $host);
    foreach my $octet (@octets) {
        $octet =~ s/^0*//;
        $octet = 0 unless $octet;
    }
    $host = join('.', @octets);

    my ($result);
    if ($password) {
	$Log->log_method(1, "Found password, using it\n");
	$result = $self->execute("$binary -h $host -P $port -u $user -p$password $db -e status");
    } else {
	$Log->log_method(1, "No password found, using non -p version\n");
	$result = $self->execute("$binary -h $host -P $port -u $user $db -e status");
    }

   return ($result);

}

1;

__END__


=head1 NAME

  NOCpulse::Probe::DataSource::MySQL.pm - Datasource that uses the mysqladmin program to report data about a given MySQL database


=head1 SYNOPSIS

  The methods available are to be used by NOCpulse::Probe modules found in the NOCpulsePlugins package.
  This datasource is specifically for use by the probes in the /opt/home/nocpulse/libexec/MySQL directory.

=head1 DESCRIPTION

  Need to add a description

=head1 METHODS

=over 4

=item

=back

=head1 BUGS

Will add bugs as I find them.

=head1 AUTHOR

 Nick Hansen <nhansen@redhat.com>
 Last updated: $id$

=head1 SEE ALSO

L<NOCpulse::Probe::Overview|PerlModules::NP::Probe::Overview>,
L<NOCpulse::Probe::DataSource::Overview|PerlModules::NP::Probe::DataSource::Overview>,
L<NOCpulse::Probe::ProbeRunner|PerlModules::NP::Probe::ProbeRunner>,
L<NOCpulse::Probe::ItemStatus|PerlModules::NP::Probe::ItemStatus>

=cut
