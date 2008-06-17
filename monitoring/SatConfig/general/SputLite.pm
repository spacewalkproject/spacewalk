package SputLite;
use GogoSysVStep;
@ISA=qw(GogoSysVStep);

# Remainder in .ini file

## NOTE!  Original has this in /etc/cron.d - need some equiv mechanism...
# 0 * * * * root /etc/rc.d//init.d/commandqueue status || /etc/rc.d//init.d/commandqueue start 

1;
