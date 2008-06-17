package NOCpulse::Probe::DataSource::WQLQuery;

# Information from WQLQuery for a single query
use strict;

use Class::MethodMaker
    new_with_init => 'new',
    new_hash_init => 'hash_init',
    ;

# The format of the WQLQuery output should exactly match
# the semantics for a Perl array of hashes.
sub init {
    my ($self, $results) = @_;
    
    my @hashes = eval($results);

    if (@hashes != 1) {

        my $msg = NOCpulse::Probe::MessageCatalog->instance->wql_query('too_many_results');
        throw NOCpulse::Probe::ConfigError($msg);
    }
    
    
    # Since there is no obvious key to uniquely identify the
    # entries for the results, the results are constrained to
    # dealing with just the first entry for now.
    Class::MethodMaker->get_set(keys(%{$hashes[0]}));
    
    $self->hash_init(%{$hashes[0]});
    
    return $self;
}

1;

__END__
