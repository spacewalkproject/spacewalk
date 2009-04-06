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
--

--contact_methods current prod row count = 705
create table 
rhn_contact_methods
(
    recid                            numeric(12) not null
        				constraint rhn_cmeth_recid_notzero check (recid > 0) 
        				constraint rhn_cmeth_recid_pk primary key
--		            		using index tablespace [[2m_tbs]]
                ,
    method_name                      varchar(20),
    contact_id                       numeric(12) not null
					constraint rhn_cmeth_contact_id_fk 
				    	references web_contact( id ),
    schedule_id                      numeric(12)
					constraint rhn_cmeth_schedule_id_fk 
    					references rhn_schedules( recid ),
    method_type_id                   numeric(12) not null
					constraint rhn_cmeth_method_type_id_fk
    					references rhn_method_types( recid ),
    pager_type_id                    numeric(12)
					constraint rhn_cmeth_pager_type_id_fk 
    					references rhn_pager_types( recid ),
    pager_pin                        varchar(20),
    pager_email                      varchar(50),
    pager_max_message_length         numeric(6)
        				constraint rhn_cmeth_pgr_length_limit 
        				check (pager_max_message_length between 10 and 1920),
    pager_split_long_messages        char(1),
    email_address                    varchar(50),
    email_reply_to                   varchar(50),
    last_update_user                 varchar(40),
    last_update_date                 date,
    snmp_host                        varchar(255),
    snmp_port                        numeric(5),
    notification_format_id           numeric(12) default 4 not null
					constraint rhn_cmeth_ntfmt_id_fk 
    					references rhn_notification_formats( recid ),
    sender_sat_cluster_id            numeric(12)
					constraint rhn_cmeth_sender_sat_clus_fk
    					references rhn_sat_cluster( recid ),
					constraint rhn_cmeth_id_name_uq unique ( contact_id, method_name )
--  					using tablespace [[2m_tbs]]

)
;

comment on table rhn_contact_methods 
    is 'cmeth  contact method definitions';

create index rhn_cmeth_sndr_scid_idx
    on rhn_contact_methods ( sender_sat_cluster_id )
--    tablespace [[2m_tbs]]
  ;

create index rhn_cmeth_contact_id_idx
    on rhn_contact_methods ( contact_id )
--    tablespace [[2m_tbs]]
  ;

create index rhn_cmeth_method_type_id_idx
    on rhn_contact_methods ( method_type_id )
--    tablespace [[2m_tbs]]
  ;

create index rhn_cmeth_schedule_id_idx
    on rhn_contact_methods ( schedule_id )
--    tablespace [[2m_tbs]]
  ;

--create sequence rhn_contact_methods_recid_seq;

--create or replace trigger 
--rhn_cmeth_val_trig
--before insert or update on rhn_contact_methods
--referencing new as new old as old
--for each row
--declare
--    msg  varchar2(200);
--    missing_data exception;
--begin
--    msg :='missing or invalid data for contact_methods table';
    
--    if :new.method_type_id = 1
--    then

    --- pager fields pager_email,pager_split_long_messages should be not null
  --      if (
    --        :new.pager_email   is null     or
      --      :new.pager_split_long_messages  is null )
 --       then
--            raise missing_data;
--        end if;
--    end if;

--    if :new.method_type_id = 2
--    then
    
    --- the all email fields but email_reply_to should be not null
--        if :new.email_address is null
--        then
--            raise missing_data;
--        end if;
--    end if;
    
--    if :new.method_type_id = 5
--    then
    
    --- the all sntp fields be not null
--        if (:new.snmp_host is null   or
--           :new.snmp_port is null)
--        then
--            raise missing_data;
--        end if;
--    end if;
    
--    exception
--    when missing_data then
 --   raise_application_error (-20012,msg);
--    when others then
--    raise;
--end;
--/
--show errors

--
--Revision 1.14  2005/02/15 22:07:09  jslagle
--bz #140447
--Dropped rhn_cmeth_tznms_sched_zone_id constraint for dropped schedule_zone_id column.
--
--Revision 1.13  2005/02/15 21:57:04  jslagle
--bz #none
--Fixed erroneous comma.
--
--Revision 1.12  2005/02/15 20:35:05  jslagle
--bz #140447
--Dropped column schedule_zone_id.
--
--Revision 1.11  2004/11/20 03:47:41  cturner
--bugzilla: noidea.  revert the change that removes the column; it will default to GMT and not be updated by the trigger, but should work sufficiently for getting notifications back up and running
--
--Revision 1.9  2004/11/05 17:32:06  pjones
--bugzilla: 137567 -- if we don't handle exceptions, the first firing will
--fail on satellite, where we don't have rhnUserInfo yet.
--
--Revision 1.8  2004/11/04 19:25:21  pjones
--bugzilla: 137567 -- add a trigger to update timezones
--
--Revision 1.7  2004/05/28 22:27:32  pjones
--bugzilla: none -- audit usage of rhnServer/web_contact/web_customer in
--monitoring schema
--
--Revision 1.6  2004/05/28 20:02:27  pjones
--bugzilla: none -- add a "/" so it'll build the trigger and not syntax error
--on the next statement.
--
--Revision 1.5  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.4  2004/04/30 14:36:50  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.3  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.2  2004/04/21 21:23:18  kja
--Added triggers.
--
--Revision 1.1  2004/04/13 16:40:33  kja
--Tweaked a bit of syntax on modified files.  Added more script files for
--monitoring schema.
--
--
--
--
--
