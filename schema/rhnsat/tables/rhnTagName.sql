--
-- $Id$
--/

create table
rhnTagName
(
        id              number
        	    	constraint rhn_tn_id_nn not null
    	    	    	constraint rhn_tn_id_pk primary key,
        name            varchar2(128)
    	    	    	constraint rhn_tn_name_nn not null,
       	created		date default(sysdate)
			constraint rhn_tn_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_tn_modified_nn not null
);

create unique index rhn_tn_name_uq
    	on rhnTagName(name);

create sequence rhn_tagname_id_seq;

create or replace trigger
rhn_tn_mod_trig
before insert or update on rhnTagName
for each row
begin
        :new.modified := sysdate;
end;
/
show errors


-- $Log$
-- Revision 1.2  2003/10/16 18:50:13  bretm
-- bugzilla:  107189
--
-- o  functions for tagging (single + bulk)
-- o  make tag names 128 instead of 256 maxlength
--
-- Revision 1.1  2003/10/15 20:29:53  bretm
-- bugzilla:  107189
--
-- 1st pass at snapshot tagging schema
--
