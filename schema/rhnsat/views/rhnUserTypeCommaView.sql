-- $Id$
--
create or replace view rhnUserTypeCommaView (
       user_id, ids, labels, names
)
as
select
    uta.user_id,
    id_join(', ', uta.type_id_t),
    label_join(', ', uta.type_label_t),
    name_join(', ', uta.type_name_t)
from	   
    rhnUserTypeArray uta
/


-- $Log$
-- Revision 1.3  2001/06/27 02:05:25  gafton
-- add Log too
--
