#!/usr/bin/perl
use File::Temp  qw/  tempfile tempdir /;

if( @ARGV != 2){
        print "Arguments:\n  ./query-execution-plan.pl  CONNECT_STRING   QUERY_FILE\nProvides the explain plan for a query specified by QUERY_FILE\n";
        exit 1;
}

$connect_string =  $ARGV[0];
$query_file = $ARGV[1];

#currently doesn't work too well with sqlplus, feel free to improve!
#$program = "yasql";
$program = "sqlplus";




$head = "delete plan_table;\n explain plan for ";
$tail = <<EOF;
select
  substr (lpad(' ', level-1) || operation || ' (' || options || ')',1,30 ) "Operation",
  object_name                                                              "Object"
from
  plan_table
start with id = 0
connect by prior id=parent_id;
EOF



$query_contents = `cat $query_file`;


($outFH, $outFile) =   tempfile(SUFFIX => ".sql");

print $outFH "set linesize 1000\n";
print $outFH "set pagesize 1000\n";
print $outFH $head;
print $outFH $query_contents;
print $outFH $tail;
print $outFH "rollback;\n";
print $outFH "\n quit;\n";
#print $outFH "/";
close($outFH);


system( "$program $connect_string \@$outFile" );


