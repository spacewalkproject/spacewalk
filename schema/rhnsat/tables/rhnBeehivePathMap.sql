--
-- $Id$
--
-- XXX is this apropriate for sat?

create table rhnBeehivePathMap
(
    path            varchar2(128)
                    constraint rhn_beehive_path_map_p_nn not null
                    constraint rhn_beehive_path_map_p_pk primary key
                        using index tablespace [[64k_tbs]],
    beehive_path    varchar2(128)
                    constraint rhn_beehive_path_map_bp_nn not null,
    ftp_path        varchar2(128)
                    constraint rhn_beehive_path_map_fp_nn not null,
    created         date default SYSDATE,
    modified        date default SYSDATE
)
	storage ( freelists 16 )
	initrans 32;

create or replace trigger
rhn_beehive_path_map_mod_trig
before insert or update on rhnBeehivePathMap
for each row
begin
    :new.modified := SYSDATE;
end rhn_beehive_mod_trig;
/
show errors

-- $Log$
-- Revision 1.10  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.9  2002/05/10 21:54:44  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
--
