--
-- $Id$
--
-- rhnRedHatCanonVersion -- mapping odd RH versions to canonical ones

create table rhnRedHatCanonVersion
(
        version         varchar2(32)
                        constraint rhn_rh_canon_ver_v_nn not null
                        constraint rhn_rh_canon_ver_v_pk primary key,
        canon_version   varchar2(32)
                        constraint rhn_rh_canon_ver_cv_nn not null,
	created		date default(sysdate)
			constraint rhn_rh_canon_ver_created_nn not null,
	modified	date default(sysdate)
			constraint rhn_rh_canon_ver_modified_nn not null
)
	storage( freelists 16 )
	initrans 32;

-- $Log$
-- Revision 1.5  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.4  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
