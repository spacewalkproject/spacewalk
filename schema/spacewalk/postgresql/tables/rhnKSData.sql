--
-- Copyright (c) 2008 Red Hat, Inc.
--
-- This software is licensed to you under the GNU General Public License,
-- version 2 (GPLv2). There is NO WARRANTY for this software, express or
-- implied, including the implied warranties of MERCHANTABILITY or FITNESS
-- FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
-- along with this software; if not, see
-- http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
-- 
-- Red Hat trademarks are not licensed under GPLv2. No permission is
-- granted to use or replicate Red Hat trademarks that are incorporated
-- in this software or its documentation. 
--
--
--
--

create sequence rhn_ks_id_seq;

create table
rhnKSData
(
	id			numeric not null
				constraint rhn_ks_id_pk primary key
--					using index tablespace [[8m_tbs]]
                                ,
	ks_type			varchar(8) not null,
				constraint rhn_ks_type_ck
					check (ks_type in ('wizard','raw')),
	org_id			numeric not null
				constraint rhn_ks_oid_fk
					references web_customer(id)
					on delete cascade,
	is_org_default          char(1) default('N') not null
				constraint rhn_ks_default_ck
					check (is_org_default in ('Y','N')),
	label			varchar(64) not null,
	comments		varchar(4000),
	active			char(1) default('Y') not null
				constraint rhn_ks_active_ck
					check (active in ('Y','N')),
    postLog     char(1) default('N') not null
                constraint rhn_ks_post_log_ck
                    check (postLog in ('Y','N')),
    preLog     char(1) default('N') not null
                constraint rhn_ks_pre_log_ck
                    check (preLog in ('Y','N')),
    kscfg      char(1) default('N') not null
                constraint rhn_ks_cfg_save_ck
                    check (kscfg in ('Y','N')),
        cobbler_id              varchar(64),
	pre			bytea,
	post			bytea,
        nochroot_post           bytea,
	static_device           varchar(32),
        kernel_params           varchar(128),
        verboseup2date char(1) default('N') not null
                constraint rhn_ks_verbose_up2date_ck
                check (verboseup2date in ('Y','N')),
        nonchrootpost char(1) default('N') not null
                constraint rhn_ks_nonchroot_post_ck
                check (nonchrootpost in ('Y','N')),
	created			timestamp default (current_timestamp) not null,
	modified		timestamp default (current_timestamp) not null,
				constraint rhn_ks_oid_label_uq unique ( org_id, label )
)
  ;

create index rhn_ks_oid_label_id_idx
	on rhnKSData( org_id, label, id )
--	tablespace [[8m_tbs]]
  ;
/*
create or replace trigger
rhn_ks_mod_trig
before insert or update on rhnKSData
for each row
begin
	:new.modified := sysdate;
end;
/
show errors
*/

---
---
--- Revision 1.8  2004/01/08 04:56:15  rnorwood
--- bugzilla: 109764 - kernel params for kickstarts - schema and web UI.
---
--- Revision 1.7  2003/12/15 16:25:42  rnorwood
--- bugzilla: 109811 - add --nochroot %post script editing.
---
--- Revision 1.6  2003/11/16 22:03:55  cturner
--- bugzilla: 107585.  schema supporting static/dhcp association with a kickstart
---
--- Revision 1.5  2003/11/12 07:03:47  rnorwood
--- bugzilla: 109057 - sql files for kickstart profile name uniqueness fix.
---
--- Revision 1.4  2003/10/09 19:47:37  misa
--- Typo
---
--- Revision 1.3  2003/10/09 16:13:09  rnorwood
--- bugzilla: 106681 - add 'org default' kickstarts.
---
--- Revision 1.2  2003/09/17 16:45:37  rnorwood
--- bugzilla: 103307 - rename rhnKickstart due to extreme weirdness with Oracle::DBD.
---
--- Revision 1.1  2003/09/11 20:55:42  pjones
--- bugzilla: 104231
---
--- tables to handle kickstart data
---
