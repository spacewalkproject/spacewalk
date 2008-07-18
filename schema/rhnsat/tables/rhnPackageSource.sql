--
-- $Id$
--

create table
rhnPackageSource
(
        id              number
			constraint rhn_pkgsrc_id_nn not null
                        constraint rhn_pkgsrc_id_pk primary key
				using index tablespace [[64k_tbs]]
			storage(pctincrease 1),
        org_id          number
                        constraint rhn_pkgsrc_oid_fk
				references web_customer(id)
				on delete cascade,
	source_rpm_id	number
			constraint rhn_pkgsrc_srid_nn not null
			constraint rhn_pkgsrc_srid_fk
				references rhnSourceRPM(id),
        package_group   number
			constraint rhn_pkgsrc_group_nn not null
                        constraint rhn_pkgsrc_group_fk
				references rhnPackageGroup(id),
        rpm_version     varchar2(16)
			constraint rhn_pkgsrc_rpm_ver_nn not null,
        payload_size    number
			constraint rhn_pkgsrc_paysize_nn not null,
        build_host      varchar2(256)
			constraint rhn_pkgsrc_bh_nn not null,
        build_time      date
			constraint rhn_pkgsrc_bt_nn not null,
        -- In case they resigned the source package
        sigmd5          varchar2(64)
			constraint rhn_package_sigmd5_nn not null,
        vendor          varchar2(64)
			constraint rhn_pkgsrc_vendor_nn not null,
	cookie		varchar2(128)
			constraint rhn_pkgsrc_cookie_nn not null,
        path            varchar2(1000),
        md5sum          varchar2(64)
	                constraint rhn_pkgsrc_md5sum_nn not null,
        package_size    number
	                constraint rhn_pkgsrc_ps_nn not null,
	last_modified	date default (sysdate)
			constraint rhn_pkgsrc_lm_nn not null,
        created         date default (sysdate)
			constraint rhn_pkgsrc_created_nn not null,
        modified        date default (sysdate)
			constraint rhn_pkgsrc_modified_nn not null
)
	storage( pctincrease 1 freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_package_source_id_seq;

create unique index rhn_pkgsrc_srid_oid_uq
	on rhnPackageSource(source_rpm_id, org_id)
	tablespace [[64k_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32;

create or replace trigger
rhn_pkgsrc_mod_trig
before insert or update on rhnPackageSource
for each row
begin
        :new.modified := sysdate;
	:new.last_modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.19  2003/03/15 00:05:01  pjones
-- org_id fk cascades
--
-- Revision 1.18  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.17  2003/01/24 16:42:23  pjones
-- last_modified on rhnPackage and rhnPackageSource
--
-- Revision 1.16  2002/05/28 20:56:40  misa
-- Updated the source packages schema
--
-- Revision 1.15  2002/05/10 22:00:48  pjones
-- add rhnFAQClass, and make it a dep for rhnFAQ
-- add grants where appropriate
-- add cvs id/log where it's been missed
-- split data out where appropriate
-- add excludes where appropriate
-- make sure it still builds (at least as sat).
-- (really this time)
--
