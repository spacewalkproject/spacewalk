require 5.004;
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'	   => 'URI',
    'VERSION_FROM' => 'URI.pm',
    'PREREQ_PM'    => {	
	                 'MIME::Base64' => 2,
		      },
    dist           => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
);
