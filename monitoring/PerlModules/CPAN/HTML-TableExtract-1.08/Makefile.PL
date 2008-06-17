use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME	   => 'HTML-TableExtract',
	      VERSION_FROM => 'lib/HTML/TableExtract.pm',
              PREREQ_PM    => {
			       HTML::Parser => 0,
			      }
	     );
