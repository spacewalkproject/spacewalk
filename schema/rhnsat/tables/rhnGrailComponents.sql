-- 
-- $Id$
--/

create table
rhnGrailComponents
(
        id              number
                        constraint rhn_grail_comp_pk primary key
                                using index tablespace [[64k_tbs]],
        component_pkg   varchar2(64)
                        constraint rhn_grail_comp_pkg_nn not null,
        component_mode  varchar2(64)
                        constraint rhn_grail_comp_mode_nn not null,
        config_mode     varchar2(64),
        component_label varchar2(128),
        role_required   number
                        constraint rhn_grail_comp_role_type_fk
                                references rhnUserGroupType(id)
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_grail_components_seq;

create unique index rhn_grail_comp_pkg_mode_uq
	on rhnGrailComponents(component_pkg, component_mode)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

create unique index rhn_grail_comp_label_uq
	on rhnGrailComponents(component_label)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- 
-- $Log$
-- Revision 1.6  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.5  2002/03/19 22:41:31  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.4  2002/02/21 16:27:19  pjones
-- rhn_ind -> [[64k_tbs]]
-- rhn_ind_02 -> [[server_package_index_tablespace]]
-- rhn_tbs_02 -> [[server_package_tablespace]]
--
-- for perl-Satcon so satellite can be created more directly.
--
-- Revision 1.3  2001/07/03 23:41:17  pjones
-- change unique constraints to unique indexes
-- move to something like a single postfix for uniques (_uq)
-- try to compensate for bad style
--
-- Revision 1.2  2001/06/27 05:04:35  pjones
-- this makes tables work
--
-- Revision 1.1  2001/06/27 02:26:25  pjones
-- pxt and grail
--
--
--/
