-- created by Oraschemadoc Wed Dec 21 14:59:50 2011
-- visit http://www.yarpen.cz/oraschemadoc/ for more info

  CREATE OR REPLACE FORCE VIEW "SPACEWALK"."RHNUSERTYPECOMMAVIEW" ("USER_ID", "IDS", "LABELS", "NAMES") AS 
  select
    uta.user_id,
    id_join(', ', uta.type_id_t),
    label_join(', ', uta.type_label_t),
    name_join(', ', uta.type_name_t)
from
    rhnUserTypeArray uta
 
/
