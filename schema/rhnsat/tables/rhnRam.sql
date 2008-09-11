--
-- $Id$
--/

create table
rhnRam
(
        id              number
			constraint rhn_ram_id_nn not null
                        constraint rhn_ram_id_pk primary key
                        using index tablespace [[4m_tbs]],
        server_id       number
			constraint rhn_ram_server_nn not null
                        constraint rhn_ram_server_fk
                                references rhnServer(id),
        ram             number
			constraint rhn_ram_ram_nn not null,
        swap            number
			constraint rhn_ram_swap_nn not null,
        created         date default(sysdate)
			constraint rhn_ram_created_nn not null,
        modified        date default(sysdate)
			constraint rhn_ram_modified_nn not null
)
	storage( freelists 16 )
	initrans 32;

create sequence rhn_ram_id_seq;

create index rhn_ram_sid_idx on
        rhnRam(server_id)
        tablespace [[4m_tbs]]
	storage( freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_ram_mod_trig
before insert or update on rhnRam
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.11  2004/02/09 16:38:38  pjones
-- bugzilla: 115049 -- rework delete_server to be driven from the pl/sql instead
-- of with cascaded deletes
--
-- Revision 1.10  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.9  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
