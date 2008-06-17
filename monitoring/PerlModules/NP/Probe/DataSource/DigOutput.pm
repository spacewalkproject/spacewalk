package NOCpulse::Probe::DataSource::DigEntry;

# Information from dig for a single resolved name
use strict;

use Data::Dumper;

use Class::MethodMaker
  get_set =>
  [qw(
      name
      ip
      dns_info
     )],
  new_hash_init => 'new',
  ;

1;

sub to_string {
    return Dumper(shift);
}


package NOCpulse::Probe::DataSource::DigOutput;

# Container for dig entries

use strict;

use NOCpulse::Log::Logger;

use Class::MethodMaker
  get_set =>
  [qw(
      total_time
      time_units
     )],
  list =>
  [qw(
      hits
     )],
  new_with_init => 'new',
  ;

my $Log = NOCpulse::Log::Logger->new(__PACKAGE__);


sub init {
    my ($self, $results) = @_;

    $results or return;

    # ;; ANSWER SECTION:
    # www.nocpulse.com.        4H IN A        216.136.199.13
    my $answer_section = $results;
    $answer_section =~ s/^.*ANSWER SECTION:\n|\n\n.*$//sg;

    $Log->log(4, "Answer section:\n$answer_section\n");

    if ($answer_section !~ /^;/) {
        my @answer_lines = grep(!/^;/, split(/\n/, $answer_section));
        foreach my $line (@answer_lines) {
            next unless $line;
            $Log->log(4, "Line $line\n");
	    my(@fields) = split(/\s+/, $line);
	    my $name    = shift(@fields);      # First field is the name
	    my $ip      = pop(@fields);        # Last field is the IP (or CNAME)
	    my $stuff   = join(' ', @fields);  # Everything else is "stuff"
	    $Log->log(2, "Hit: $name, $ip, $stuff\n");
            $self->hits_push(NOCpulse::Probe::DataSource::DigEntry->new(name    => $name,
                                                                        ip       => $ip,
                                                                        dns_info => $stuff));
        }
    }
    $results =~ /query time: (\d+) (\w+)$/im;
    $self->total_time($1);
    $self->time_units($2);

    return $self;
}

1;

