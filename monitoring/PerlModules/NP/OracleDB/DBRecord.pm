package NOCpulse::DBRecord;
use strict;
use NOCpulse::Object;
use vars qw(@ISA);
@ISA=qw(NOCpulse::Object);
use NOCpulse::Utils::XML;
use Data::Dumper;


############ Class methods ##############
sub Instances
{
	my ($class) = @_;
        $class = ref($class) || $class;
	return $class->getClassVar('Instances');
}

sub InstancesList
{
	my ($class) = @_;
        $class = ref($class) || $class;
	my $Instances = $class->Instances;
	my @Instances = values(%$Instances);
	return \@Instances;
}

sub InstanceCount
{
	my ($class) = @_;
        $class = ref($class) || $class;
	my $Instances = $class->InstancesList;
	return scalar(@$Instances);
}

sub ReleaseAllInstances 
{
	my ($class) = @_;
        $class = ref($class) || $class;
	$class->setClassVar('Instances',{});
}

sub DBD
{
	my ($class,$config) = @_;
        $class = ref($class) || $class;
	return $class->ConfigValue('dbd');
}

sub DBName
{
	my ($class,$config) = @_;
        $class = ref($class) || $class;
	return $class->ConfigValue('dbname');
}

sub Username
{
	my ($class,$config) = @_;
        $class = ref($class) || $class;
	return  $class->ConfigValue('username');
}

sub Password
{
	my ($class,$config) = @_;
        $class = ref($class) || $class;
	return $class->ConfigValue('password');
}

sub OraHome
{
	my ($class,$config) = @_;
        $class = ref($class) || $class;
	return $config->val('oracle','ora_home');
}

sub Disconnect {
	my ($class) = @_;
        $class = ref($class) || $class;
	my $dbh = NOCpulse::DBRecord->getClassInstVar('DatabaseConnection');
	if ($dbh) {
		$dbh->disconnect;
		NOCpulse::DBRecord->setClassVar('DatabaseConnection', undef);
	}
}

sub DatabaseConnection
{
	my ($class) = @_;
        $class = ref($class) || $class;
	if (NOCpulse::DBRecord->getClassInstVar('DatabaseConnection')) {
		return NOCpulse::DBRecord->getClassInstVar('DatabaseConnection');
	} else {
		use RHN::DBI;
		if (my $dbMain = RHN::DBI->connect) {
			NOCpulse::DBRecord->setClassVar('DatabaseConnection', $dbMain);
			return $dbMain;
		}
	}
}

sub Commit
{
	my ($class) = @_;
        $class = ref($class) || $class;
	$class->DatabaseConnection->commit;
}

sub Rollback
{
	my ($class) = @_;
        $class = ref($class) || $class;
	$class->DatabaseConnection->rollback;
}

sub DoSql
{
	my ($class, $sqlStatement, @bindValues) = @_;
        $class = ref($class) || $class;
	my $dbMain = $class->DatabaseConnection;

	if ($class->getClassVar('EchoSQL')) {
	   print scalar(localtime), " NOCpulse::DBRecord::DoSql\n$sqlStatement\n";
	}

	my $sth = $dbMain->prepare($sqlStatement);
	my $ret;
	if ($sth) {
            eval {
                $ret = $sth->execute(@bindValues);
            };
            if ($@) {
                Carp::cluck "SQL error: $@", "\n------->$sqlStatement\n<-------\n";
                die $@;
            }
	}
	if (!$sth || !defined($ret)) {
	   # If RaiseError is on (the default in this class), the DB error
	   # has already been reported.
	   Carp::cluck 'SQL error: ', $dbMain->errstr, "\n------->$sqlStatement\n<-------\n";
	}
	return $sth;
}

sub LoadFromSqlWithBind
{
	my ($class, $sqlStatement, $bindArrayRef, @keyFields) = @_;
        $class = ref($class) || $class;
	my $sth = $class->DoSql($sqlStatement, @$bindArrayRef);
	if ($sth) {
	   my @result = $sth->fetchall_arrayref({});
	   $class->Absorb(@result,@keyFields);
	}
	return $class;
}

sub LoadFromSql
{
	my ($class, $sqlStatement, @keyFields) = @_;
	return $class->LoadFromSqlWithBind($sqlStatement, [], @keyFields);
}

sub LoadOneFromSqlWithBind {
	my ($class,$sqlStatement, $bindArrayRef) = @_;
	$class = ref($class)||$class;
    $class->LoadFromSqlWithBind($sqlStatement, $bindArrayRef);
    my $instances = $class->InstancesList;
    return $instances->[0];
}

sub LoadOneFromSql
{
	my ($class,$sqlStatement) = @_;
	return $class->LoadOneFromSqlWithBind($sqlStatement);
}

sub Absorb
{
	# Note that this is a class initializer - it sets up the Instances
	# class instance variable.
	my ($class,$listref,@keyFields) = @_;
        $class = ref($class) || $class;
	$class->ReleaseAllInstances;
	my $item;
	foreach $item (@$listref) {
		$class->newFromHash($item,@keyFields);
	}
	return $class;
}

sub Called
{
	my ($class,@keyFields) = @_;
        $class = ref($class) || $class;
	my $key = join(',',@keyFields);
	if (exists($class->Instances->{$key})) {
		return $class->Instances->{$key};
	} else {
		return undef
	}
}

sub Map
{
	my ($class,$method,$sortfn) = @_;
	$sortfn ||= sub {1};  # Default unsorted
        $class = ref($class) || $class;
	my $object;
	my $Instances = $class->InstancesList;
	foreach $object (sort {&$sortfn($a,$b)} @$Instances) {
		&$method($object); 
	}
}

sub Columns
{
	my ($class,$method) = @_;
        $class = ref($class) || $class;
	my $first = [$class->Instances]->[0];
	$first = [%$first]->[1];
	return sort(keys(%$first));
}

sub AsDump
{
	my ($class) = @_;
        $class = ref($class) || $class;
	return Data::Dumper->new([$class->Instances],[$class])->Dump;
}

sub AsXML
{
	my ($class) = @_;
        $class = ref($class) || $class;
	my $Instances = $class->InstancesList;
	my @Unblessed;
	my $item;
	foreach $item (@$Instances) {
		push(@Unblessed,{%$item});
	}
	return NOCpulse::Utils::XML->serialize(\@Unblessed);
}

sub LoadFromXML
{
	my ($class,$xml,@keyFields) = @_;
        $class = ref($class) || $class;
	my $data = NOCpulse::Utils::XML->unserialize($xml);
        $class->Absorb($data,@keyFields);
	return $data;
}

sub newFromHash
{
        my ($class,$self,@keyFields) = @_;
        $class = ref($class) || $class;
        bless $self,$class;
	my ($curKey,@keyArray);
	foreach $curKey (@keyFields) {
		push(@keyArray,$self->{$curKey});
	}
	my $keyField = join(',',@keyArray);
	$class->getClassVar('Instances')->{$keyField} = $self;
        $self->_initialize;
        return $self;
}

sub newFromXML
{
	# Note that XML::Dumper can only deal with 
	# native perl data types - it chokes like hell
	# on blessed types, so don't try to use this
	# mechanism with any object that stores other
	# objects as inst vars.
        my ($class,$xml,@keyFields) = @_;
        $class = ref($class) || $class;
	my $self = NOCpulse::Utils::XML->unserialize($xml);
	return $class->newFromHash($self,@keyFields);
}

sub asXML
{
	# Note that XML::Dumper can only deal with 
	# native perl data types - it chokes like hell
	# on blessed types, so don't try to use this
	# mechanism with any object that stores other
	# objects as inst vars.
	my $self = shift();
	return NOCpulse::Utils::XML->serialize({%$self});
}

sub asDump
{
	my $self = shift();
	return Data::Dumper->new([$self],['self'])->Dump;
}

1
