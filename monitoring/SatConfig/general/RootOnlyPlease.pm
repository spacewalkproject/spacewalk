package RootOnlyPlease;

if ( $< != 0 ) {
	die("Sorry, you *must* be root to use this program\n");
}

1;
