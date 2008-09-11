--
-- $Id$
--/

create table
rhnTag
(
	id              number
			constraint rhn_tag_id_nn not null
			constraint rhn_tag_id_pk primary key,
	name_id         number
	    	    	constraint rhn_tag_nid_nn not null
			constraint rhn_tag_nid_fk
				references rhnTagName(id),
        org_id          number
                        constraint rhn_tag_oid_nn not null
                        constraint rhn_tag_oid_fk
                                references web_customer(id)
				on delete cascade,
       	created		date default(sysdate)
			constraint rhn_tag_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_tag_modified_nn not null
);

create unique index rhn_tag_oid_nid_uq
    	on rhnTag(org_id, name_id);

create sequence rhn_tag_id_seq;

create or replace trigger
rhn_tag_mod_trig
before insert or update on rhnTag
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.1  2003/10/15 20:29:53  bretm
-- bugzilla:  107189
--
-- 1st pass at snapshot tagging schema
--
