#!/usr/bin/perl

# (c) 2004, Red Hat, Inc
# All rights reserved
#
# Simple util to spit out

  my $query = <<EOF;
        <trans-unit id="##ID##">
          <source>##SOURCE##</source>
        </trans-unit>
EOF

print <<EOF
      <group>
        <context-group name="ctx">
          <context context-type="sourcefile">NOTFILLEDOUT</context>
        </context-group>
        <note>COMMENT</note>
EOF
    ;
while (<>) {
    my $line = $_;

    #if ($line =~ m/^\#/) { next; }
    $line =~ s/\n//g;
    $line =~ s/"//g;
    my @nameval = split (",",$line);
    my $name = $nameval[-2];
    my $value = $nameval[-1];

    #print "Name: $name\n";
    #print "Value: $value\n";

    my $tunit = $query;
    $tunit =~ s/##ID##/$name/g;
    $tunit =~ s/##SOURCE##/$value/g;
    print $tunit;
}

print "    </group>\n";
