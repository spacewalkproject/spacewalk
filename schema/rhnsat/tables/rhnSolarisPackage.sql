--
-- $Id$
--
create table rhnSolarisPackage (
   package_id              number
                           constraint rhn_solaris_pkg_pid_pk primary key
                           constraint rhn_solaris_pkg_pid_fk references rhnPackage(id)
                           on delete cascade,
   category                varchar2(2048)
                           constraint rhn_solaris_pkg_cat_nn not null,
   pkginfo                 varchar2(4000),
   pkgmap                  blob,
   intonly                 char(1) default 'N'
                           constraint rhn_solaris_pkg_io_ck check ( intonly in ('Y','N'))
)
tablespace [[8m_data_tbs]]
storage( pctincrease 1 freelists 16 )
initrans 32;





--
-- $Log$
--
