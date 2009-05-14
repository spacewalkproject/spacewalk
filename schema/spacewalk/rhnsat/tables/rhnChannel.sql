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

create table
rhnChannel
(
	id		number
			constraint rhn_channel_id_nn not null
			constraint rhn_channel_id_pk primary key
				using index tablespace [[64k_tbs]],
	parent_channel	number
			constraint rhn_channel_parent_ch_fk
				references rhnChannel(id),
	org_id		number
			constraint rhn_channel_org_fk
				references web_customer(id),
        channel_arch_id number
			constraint rhn_channel_caid_nn not null
			constraint rhn_channel_caid_fk
				references rhnChannelArch(id),
	label		varchar2(128)
			constraint rhn_channel_label_nn not null,
	basedir		varchar2(256)
			constraint rhn_channel_basedir_nn not null,
	name		varchar2(256)
			constraint rhn_channel_name_nn not null,
	summary		varchar2(500)
			constraint rhn_channel_summary_nn not null,
	description	varchar2(4000),
    product_name_id number constraint rhn_channel_product_name_ch_fk
				references rhnProductName(id),
                 
    	gpg_key_url     varchar2(256),
	gpg_key_id	varchar2(14),
	gpg_key_fp	varchar2(50),
	end_of_life     date,
    receiving_updates  char(1)
                       default 'Y'
                       constraint rhn_channel_ru_nn not null
                       constraint rhn_channel_ru_ck
                         check (receiving_updates in ('Y', 'N')),
	last_modified	date default (sysdate)
			constraint rhn_channel_lm_nn not null,
     channel_product_id number
			constraint rhn_channel_cpid_fk
				references rhnChannelProduct(id),
	channel_access	varchar2(10) default 'private',
	maint_name	varchar2(128),
	maint_email	varchar2(128),
	maint_phone	varchar2(128),
	support_policy	varchar2(256),
	created		date default (sysdate)
			constraint rhn_channel_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_channel_modified_nn not null
)
	enable row movement
  ;

create sequence rhn_channel_id_seq start with 101;

create unique index rhn_channel_label_uq
	on rhnChannel(label)
	tablespace [[64k_tbs]]
  ;
create unique index rhn_channel_name_uq
	on rhnChannel(name)
	tablespace [[64k_tbs]]
  ;
create index rhn_channel_org_idx
	on rhnChannel(org_id, id)
	tablespace [[64k_tbs]]
	nologging;
create index rhn_channel_url_id_idx
	on rhnChannel(label, id)
	tablespace [[64k_tbs]]
	nologging;
create index rhn_channel_parent_id_idx
	on rhnChannel(parent_channel, id)
	tablespace [[64k_tbs]]
	nologging;
create index rhn_channel_access_idx
	on rhnChannel(channel_access)
	tablespace [[64k_tbs]]
	nologging;

show errors

--
-- Revision 1.60  2003/06/19 19:02:02  bretm
-- bugzilla:  89504
--
-- allocate column to store the end of life date for a channel
--
-- Revision 1.59  2003/01/30 16:11:28  pjones
-- storage parameters, also fix deps to make it build again
--
-- Revision 1.58  2002/11/18 23:27:07  pjones
-- gpg key id and fingerprint schema
--
-- Revision 1.57  2002/11/14 22:34:04  pjones
-- split triggers for rhnChannel off and fix them for arch
--
-- Revision 1.56  2002/11/13 23:41:52  misa
-- arch_family is gone
--
-- Revision 1.55  2002/11/13 22:45:20  pjones
-- add appropriate arch fields.
-- haven't deleted the old ones yet though
--
-- Revision 1.54  2002/11/13 00:22:36  misa
-- arch is gone, using arch_family_id
--
-- Revision 1.53  2002/09/12 20:33:59  bretm
-- o  stuff for the bea channel
--
-- Revision 1.52  2002/06/19 21:07:56  pjones
-- no on delete cascade for rhnChannel.id -> rhnChannel.id
--
-- Revision 1.51  2002/05/20 13:34:26  pjones
-- on delete cascade for rhnChannel foreign keys
--
-- Revision 1.50  2002/03/19 22:41:30  pjones
-- index tablespace names to match current dev/qa/prod (rhn_ind_xxx)
--
-- Revision 1.49  2002/03/08 23:01:05  pjones
-- split imports out into seperate files
