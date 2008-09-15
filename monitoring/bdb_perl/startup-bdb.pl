
use Apache::Constants ();
use CGI ();
CGI->compile(':all');
use URI::Escape ();

use DB_File::Lock;
use NOCpulse::BDB ();

return 1;
