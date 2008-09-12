--
-- $Id$
--

CREATE OR REPLACE
PACKAGE rhn_org
IS
	version varchar2(100) := '$Id$';

    CURSOR server_group_by_label(org_id_in NUMBER, group_label_in VARCHAR2) IS
    	   SELECT SG.*
	     FROM rhnServerGroupType SGT,
	     	  rhnServerGroup SG
	    WHERE SG.group_type = SGT.id
	      AND SGT.label = group_label_in
	      AND SG.org_id = org_id_in;
	    
    FUNCTION find_server_group_by_type(org_id_in NUMBER, 
                                       group_label_in VARCHAR2) 
    RETURN NUMBER;

    procedure delete_org(org_id_in in number);
    procedure delete_user(user_id_in in number, deleting_org in number := 0);

END rhn_org;
/
SHOW ERRORS

-- $Log$
-- Revision 1.7  2004/07/13 22:46:04  pjones
-- bugzilla: 125938 -- nothing uses update_errata_cache() any more, remove it
--
-- Revision 1.6  2004/02/10 15:05:01  pjones
-- bugzilla: none -- add version tag here
--
-- Revision 1.5  2003/02/18 16:35:45  pjones
-- delete_user
--
-- Revision 1.4  2002/05/10 22:08:23  pjones
-- id/log
--
