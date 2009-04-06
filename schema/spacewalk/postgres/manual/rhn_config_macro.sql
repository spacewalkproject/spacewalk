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

--config_macro current prod row count = 202
create table 
rhn_config_macro
(
    environment         varchar(255)
                        not null
                        constraint rhn_confm_envir_environment_fk
                        references rhn_environment( name ),
    name                varchar(255)
                        not null,
    definition          varchar(255),
    description         varchar(255),
    editable            char(1) default 0
                        not null,
    last_update_user    varchar(40),
    last_update_date    date,
                        constraint rhn_confm_environment_name_pk 
                        primary key( environment, name ),
                        constraint rhn_confm_environment_name_pk
                        unique( environment, name )
--                      using index tablespace [[2m_tbs]]
)
  ;

comment on table rhn_config_macro 
    is 'confm configuration macro def';

--
--Revision 1.5  2004/04/28 23:10:52  kja
--Moving foreign keys where applicable and no circular dependencies exist.
--
--Revision 1.4  2004/04/16 21:49:57  kja
--Adjusted small table sizes.  Documented small tables that are primarily static
--as "reference tables."  Fixed up a few syntactical errs.
--
--Revision 1.3  2004/04/13 20:45:55  kja
--Tweak constraint names to start with rhn_.
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
