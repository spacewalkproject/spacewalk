# $Id: count.awk,v 1.1.1.1 2002-01-11 00:21:34 apingel Exp $
#
# Print out the number of log records for transactions that we
# encountered.

/^\[/{
	if ($5 != 0)
		print $5
}
