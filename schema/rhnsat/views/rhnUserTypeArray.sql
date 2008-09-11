-- $Id$
--
create or replace view rhnUserTypeArray (
       user_id, type_id_t, type_label_t, type_name_t
)
as
select
    U.id,
    cast(multiset(select utb.type_id
    	    	  from rhnUserTypeBase utb 
    	    	  where utb.user_id = u.id)
	 as user_group_id_t),
    cast(multiset(select utb.type_label
    	    	  from rhnUserTypeBase utb
    	    	  where utb.user_id = u.id)
	 as user_group_label_t),
    cast(multiset(select utb.type_name
    	    	  from rhnUserTypeBase utb
    	    	  where utb.user_id = u.id)
	 as user_group_name_t)
from 
    web_contact u
/


-- $Log$
-- Revision 1.4  2001/06/29 08:30:53  cturner
-- more underscore changes, plus switching from rhnUser to web_contact.  may switch back later, but avoiding synonyms and such seems to make things cleaner
--
-- Revision 1.3  2001/06/27 02:05:25  gafton
-- add Log too
--
