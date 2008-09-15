use ExtUtils::MakeMaker;
WriteMakefile(
   NAME => "Date::Manip",
   VERSION_FROM => "Manip.pm",
   ($] >= 5.005
      ? (ABSTRACT   => 'Routines for parsing/manipulating dates and time.',
         AUTHOR     => 'Sullivan Beck (sbeck@cise.ufl.edu)')
      : ()),
  'dist' => {COMPRESS=>'gzip',SUFFIX=>'gz'}
);
