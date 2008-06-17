package NetworkFilesystems;
use SysVStep;
@ISA=qw(SysVStep);
use NOCpulse::SatCluster;

sub instVarDefinitions
{
        my $self = shift();
        $self->SUPER::instVarDefinitions;
        $self->addInstVar('cluster');
}
 
sub initialize
{
        my ($self,$params) = @_;
        my $self =  $self->SUPER::initialize(@params);
        $self->set_cluster(PhysCluster->newInitialized);
        return $self;
}

sub printStatus
{
	my ($self,@params) = @_;
	$self->SUPER::printStatus(@params);
	my ($mountpoint,$source);
	my $mounts = $self->mounts;
	if ($self->isRunning) {
		while (($mountpoint,$source) = each(%$mounts)) {
			$self->dprint(0,"$source is mounted at $mountpoint");
		}
	} else {
		while (($mountpoint,$source) = each(%$mounts)) {
			$self->dprint(0,"$source is (probably) NOT mounted at $mountpoint");
		}
	}
}

sub mounts
{
	my $self = shift();
	my ($mounts,$mountpoint,$source,%result);
	$mounts = $self->get_cluster->get_NetworkFilesystem;
	while (($mountpoint,$sourceObj) = each(%$mounts)) {
		$result{$mountpoint} = $sourceObj->get_source;
	}
	return \%result;
}


sub startActions
{
	my $self = shift();
	use Data::Dumper;
	my ($mountpoint,$source,$mounts);
	$mounts = $self->mounts;
	while (($mountpoint,$source) = each(%$mounts)) {
		$self->dprint(0,"Mounting $source to $mountpoint...");
		if (! -d $mountpoint ) {
			$self->dprint(0,"Creating mountpoint $mountpoint");
			if ( ! mkdir($mountpoint,0750) ) {
				$self->dprint(0,"Error creating mountpoint $mountpoint: $!");
			} else {
				$self->addStopAction("rmdir('$mountpoint')");
			}
		} else {
			$self->dprint(0,"Mountpoint $mountpoint exists; no need to create it\n");
			$self->addStopAction("rmdir('$mountpoint')");
		}
		if ( -d $mountpoint) {
			$self->shell("/bin/mount -tnfs $source $mountpoint");
			if (! $self->get_lastShell->get_exit) {
				$self->addShellStopAction("/bin/umount $mountpoint");
			} else {
				$self->dprint(0,"Error attempting to mount $source to $mountpoint");
			}
		} else {
			$self->dprint(0,"Unable to mount $source - mountpoint doesn't exist");
		}
	}
}

1;
