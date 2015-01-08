#!/usr/bin/perl

# Remove unnecessary else blocks from java files.  To use this, run
# this script as:
#    ./unusedLocal.pl file_name
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

    # load the whole file into memory.
    open javaFile, "< $dirname/$filename" or die "Can't open $dirname/$filename: $!";
    @newFile = <javaFile>;
    close(javaFile);

    # Remove the else.
    if (not (@newFile[$lineNum - 1] =~ /\s*else {/)) {
        print "skipping $filename, $lineNum";
        next;
    }
    splice(@newFile, $lineNum - 1, 1);
    my $i = -1;
    my $numOpen = 1;
    while (1) {
        my $oldline = @newFile[$lineNum + $i];
        if ($oldline =~ /\s*}/) {
            $numOpen--;
            if ($numOpen == 0) { last; }
        }
        if ($oldline =~ /.*{/) { $numOpen++; }
        $oldline =~ s/^    //;
        @newFile[$lineNum + $i] = $oldline;
        $i++;
    }
    splice(@newFile, $lineNum + $i, 1);

    # write out the file.
    open javaFile, ">$dirname/$filename" or die "Can't open $dirname/$filename: $!";
    print javaFile @newFile;
    close(javaFile);
}
