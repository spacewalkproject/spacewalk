--
-- $Id$
-- 
-- This specifies the list of transaction packages for a given delta
-- It's just like rhnTransactionElement, except it's for rhnPackageDelta entries
-- instead.
--
-- Note that this only really exists because we want labels, and so 
-- we need something between rhnActionPackageDelta and rhnTransactionPackage .

create table
rhnPackageDeltaElement
(
	package_delta_id	number
				constraint rhn_pdelement_pdid_nn not null
				constraint rhn_pdelement_pdid_fk
					references rhnPackageDelta(id)
					on delete cascade,
	transaction_package_id	number
				constraint rhn_pdelement_tpid_nn not null
				constraint rhn_pdelement_tpid_fk
					references rhnTransactionPackage(id)
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_pdelement_pdid_tpid_uq
	on rhnPackageDeltaElement(package_delta_id, transaction_package_id)
	tablespace [[8m_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.1  2003/06/10 19:42:25  pjones
-- package delta actions
--

