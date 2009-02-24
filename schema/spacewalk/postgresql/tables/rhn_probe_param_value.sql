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

--probe_param_value current prod row count = 316971
create table 
rhn_probe_param_value
(
    probe_id            numeric not null
			constraint rhn_ppval_chkpb_probe_id_fk
    			references rhn_probe( recid )
    			on delete cascade,
    command_id          numeric not null,
    param_name          varchar(40) not null,
    value               varchar(1024),
    last_update_user    varchar(40),
    last_update_date    date,
			constraint rhn_ppval_p_id_cmd_id_parm_pk primary key ( probe_id, command_id, param_name ),
			constraint rhn_ppval_cmd_id_parm_nm_fk foreign key ( command_id, param_name )
    			references rhn_command_parameter( command_id, param_name )
    			on delete cascade

)
  ;

comment on table rhn_probe_param_value 
    is 'ppval  param value for a probe running a command';

--
--Revision 1.3  2004/05/06 17:35:10  kja
--More syntax/identifier length changes.
--
--Revision 1.2  2004/04/30 14:36:51  kja
--Moving foreign keys for non-circular dependencies.
--
--Revision 1.1  2004/04/13 22:05:17  kja
--More monitoring schema.
--
--
--
--
--
