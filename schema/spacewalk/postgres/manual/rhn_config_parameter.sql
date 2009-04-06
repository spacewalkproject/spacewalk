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

--config_parameter current prod row count = 211
create table 
rhn_config_parameter
(
    group_name          varchar(255) not null
			constraint rhn_confp_grpnm_group_name_fk
    			references rhn_config_group( name ),
    name                varchar(255) not null,
    value               varchar(255),
    security_type       varchar(255) not null
			constraint rhn_confp_scrty_sec_type_fk
    			references rhn_config_security_type( name ),
    last_update_user    varchar(40),
    last_update_date    date,
			constraint rhn_confp_group_name_name_pk primary key ( group_name, name)
)  
;

comment on table rhn_config_parameter 
    is 'confp  configuration parameter definition';

--
--Revision 1.4  2004/05/04 23:02:54  kja
--Fix syntax errors.  Trim constraint/table/sequence names to legal lengths.
--
--Revision 1.3  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.2  2004/04/13 16:40:33  kja
--Tweaked a bit of syntax on modified files.  Added more script files for
--monitoring schema.
--
--Revision 1.1  2004/04/12 22:41:48  kja
--More monitoring schema.  Tweaked some sizes/syntax on previously added scripts.
--
--
--
--
--
