package FirstBoot;
use SysVStep;
@ISA=qw(SysVStep);

$FirstBootProg='/etc/rc.d/np.d/firstboot';

sub overview
{
	return "Runs and then removes $FirstBootProg if it exists and is executable";
}

sub startActions
{
	my $self = shift();
	if ( -f $FirstBootProg ) {
		$self->dprint(0,"Found $FirstBootProg - executing");
		chmod(0755,$FirstBootProg);
		$self->shell($FirstBootProg);
		$self->dprint(0,"Removing $FirstBootProg");
		unlink($FirstBootProg);
	} else {
		$self->dprint(0,"No $FirstBootProg found - doing nothing");
	}
}


1;
