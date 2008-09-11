-- $Id$
--
CREATE OR REPLACE VIEW
rhnUserAppletOverview
(
    	    user_id,
    	    security_count,
	    bug_count,
	    enhancement_count
)
AS
SELECT      USP.user_id,
    	    SUM((SELECT COUNT(*) FROM rhnServerErrataTypeView SEV 
	         WHERE SEV.server_id = USP.server_id
	         AND SEV.errata_type = 'Security Advisory')),
    	    SUM((SELECT COUNT(*) FROM rhnServerErrataTypeView SEV 
	         WHERE SEV.server_id = USP.server_id
	         AND SEV.errata_type = 'Bug Fix Advisory')),
    	    SUM((SELECT COUNT(*) FROM rhnServerErrataTypeView SEV 
	         WHERE SEV.server_id = USP.server_id
	         AND SEV.errata_type = 'Product Enhancement Advisory'))
FROM        rhnUserServerPerms USP
GROUP BY    USP.user_id
/

-- $Log$
-- Revision 1.3  2001/06/27 02:05:25  gafton
-- add Log too
--
