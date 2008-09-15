# This awk script parses C input files looking for lines marked "PUBLIC:"
# and "EXTERN:".  (PUBLIC lines are DB internal function prototypes and
# #defines, EXTERN are DB external function prototypes and #defines.)  The
# PUBLIC lines are put into two versions of per-directory include files:
# one version for normal use, and one version to be post-processed based
# on creating unique file names for every global symbol in the DB library.
# The EXTERN lines are put into two versions of the db.h file, again, one
# version for normal use, and one version to be post-processed for unique
# naming.
/PUBLIC:/ {
	sub("^.*PUBLIC:[	 ][	 ]*", "")
	if ($0 ~ "^#if|^#endif") {
		print $0 >> inc_file
		print $0 >> uinc_file
		next
	}
	if ($0 ~ "^#define.*[(]") {
		print $0 >> inc_file
		def = gensub("[(]", "@DB_VERSION_UNIQUE_NAME@(", 2)
		print def >> uinc_file
		next
	}
	if ($0 ~ "^#define") {
		print $0 >> inc_file
		sub("[	 ]*$", "@DB_VERSION_UNIQUE_NAME@")
		print $0 >> uinc_file
		next
	}
	pline = sprintf("%s %s", pline, $0)
	if (pline ~ "));") {
		sub("^[	 ]*", "", pline)
		print pline >> inc_file
		if (pline ~ db_version_unique_name)
			print pline >> uinc_file;
		else {
			def = gensub("[	 ][	 ]*__P.*", "", 1, pline)
			sub("^.*[	 ][*]*", "", def)
			printf("#define	%s %s@DB_VERSION_UNIQUE_NAME@\n%s\n",
			    def, def, pline) >> uinc_file
		}
		pline = ""
	}
}
/EXTERN:/ {
	sub("^.*EXTERN:[	 ][	 ]*", "")
	if ($0 ~ "^#if|^#endif") {
		print $0 >> ext_file
		print $0 >> uext_file
		next
	}
	if ($0 ~ "^#define.*[(]") {
		print $0 >> ext_file
		def = gensub("[(]", "@DB_VERSION_UNIQUE_NAME@(", 2)
		print def >> uext_file
		next
	}
	if ($0 ~ "^#define") {
		print $0 >> ext_file
		sub("[	 ]*$", "@DB_VERSION_UNIQUE_NAME@")
		print $0 >> uext_file
		next
	}
	eline = sprintf("%s %s", eline, $0)
	if (eline ~ "));") {
		sub("^[	 ]*", "", eline)
		print eline >> ext_file
		if (pline ~ db_version_unique_name)
			print pline >> uext_file;
		else {
			def = gensub("[	 ][	 ]*__P.*", "", 1, eline)
			sub("^.*[	 ][*]*", "", def)
			printf("#define	%s %s@DB_VERSION_UNIQUE_NAME@\n%s\n",
			    def, def, eline) >> uext_file
		}
		eline = ""
	}
}
