-- created by Oraschemadoc Mon Aug 31 10:54:34 2009
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "MIM1"."RHNUSERTYPEARRAY" ("USER_ID", "TYPE_ID_T", "TYPE_LABEL_T", "TYPE_NAME_T") AS 
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
