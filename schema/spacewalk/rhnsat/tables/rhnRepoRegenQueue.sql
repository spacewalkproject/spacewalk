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
rhnRepoRegenQueue
( 
       id                 number 
                          constraint rhn_reporegenq_id_nn not null enable 
                          constraint rhn_reporegenq_id_pk primary key,
       channel_label      varchar2(128)
                          constraint rhn_reporegenq_chan_label_nn not null enable,
       client             varchar2(128),
       reason             varchar2(128),
       force              char(1),
       bypass_filters     char(1),
       next_action        date default (sysdate),
       created            date default (sysdate) 
                          constraint rhn_reporegenq_created_nn not null enable,
       modified           date default (sysdate) 
                          constraint rhn_reporegenq_modified_nn not null enable
  );

create sequence rhn_repo_regen_queue_id_seq start with 101;

create or replace trigger rhn_repo_regen_queue_mod_trig
before insert or update on rhnRepoRegenQueue
for each row
begin
    :new.modified := sysdate;
end;
