--
-- $Id$
--/

create table
rhnPackageChangelog
(
        package_id      number
                        constraint rhn_pkg_changelog_pid_nn not null
                        constraint rhn_pkg_changelog_pid_fk
				references rhnPackage(id),
        name            varchar2(128)
			constraint rhn_pkg_changelog_name not null,
        text            varchar2(3000)
			constraint rhn_pkg_changelog_text not null,
        time            date
			constraint rhn_pkg_changelog_time not null,
        created         date default(sysdate)
			constraint rhn_pkg_changelog_created_nn not null,
        modified        date default(sysdate)
			constraint rhn_pkg_changelog_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create unique index rhn_pkg_cl_pid_n_txt_time_uq
        on rhnPackageChangelog(package_id, name, text, time)
        nologging tablespace [[32m_tbs]]
	storage ( freelists 16 )
	initrans 32;

create or replace trigger 
rhn_package_changelog_mod_trig
before insert or update on rhnPackageChangelog
for each row 
begin 
        :new.modified := sysdate; 
end; 
/ 
show errors 

-- $Log$
-- Revision 1.19  2004/12/07 20:18:56  cturner
-- bugzilla: 142156, simplify the triggers
--
-- Revision 1.18  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.17  2003/01/24 16:42:23  pjones
-- last_modified on rhnPackage and rhnPackageSource
--
-- Revision 1.16  2002/04/30 16:24:12  misa
-- The index is unique now.
--
-- Revision 1.15  2002/04/26 15:05:09  pjones
-- trim logs that have satconish words in them
--
