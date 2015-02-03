#!/usr/bin/perl

# Remove unused private member variables from java files.  To use this, run
# this script as:
#    ./unreadField.pl file_name
# The file_name argument is a file with the format:
#
# filename directory line ###

my @args = shift;
my $fname = @args[0];
open FILE, "< $fname" or die "Can't open $fname: $!";

@lines = <FILE>;
while ($line = pop @lines) {
    my $filename;
    my $dirname;
    my $lineNum;

    ($filename, $dirname, $lineNum) = ($line =~ /(\S*) *(\S*) *line (\d*)/);

    next if ($dirname =~ /^$/);

    print "processing: $dirname/$filename\n";

    open javaFile, "< $dirname/$filename" or die "Can't open $dirname/$filename: $!";
    @newFile = <javaFile>;
#    print "Line to remove: @newFile[$lineNum - 1]";
    splice(@newFile, $lineNum - 1, 1);
    close(javaFile);

    open javaFile, ">$dirname/$filename" or die "Can't open $dirname/$filename: $!";
    print javaFile @newFile;
    close(javaFile);
}
