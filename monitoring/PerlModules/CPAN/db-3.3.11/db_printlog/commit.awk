# $Id: commit.awk,v 1.1.1.1 2002-01-11 00:21:34 apingel Exp $
#
# Output tid of committed transactions.

/txn_regop/ {
	print $5
}
