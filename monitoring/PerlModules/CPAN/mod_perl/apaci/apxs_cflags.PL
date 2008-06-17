use lib qw(./lib ../lib);
use Apache::src ();

local $Apache::src::APXS = shift;

print Apache::src::apxs_cflags();
