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
rhnFeature
(
        id              numeric
                        constraint rhn_feature_id primary key
--                      using index tablespace [[64k_tbs]]
                        ,
        label           varchar(32)
                        not null
                        constraint rhn_feature_label_uq_idx unique
--                      using index tablespace [[64k_tbs]]
                        ,
        name            varchar(64)
                        not null,
        created         date default(current_date)
                        not null,
        modified        date default(current_date)
                        not null
)
  ;

create sequence rhn_feature_seq;


