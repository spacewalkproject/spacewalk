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
        id              number
                        constraint rhn_feature_id primary key
                                using index tablespace [[64k_tbs]],
        label           varchar2(32)
                        constraint rhn_feature_label_nn not null,
        name            varchar2(64)
                        constraint rhn_feature_name_nn not null,
        created         date default(sysdate)
                        constraint rhn_feature_created_nn not null,
        modified        date default(sysdate)
                        constraint rhn_feature_modified_nn not null
)
	enable row movement
  ;

create sequence rhn_feature_seq;

create unique index rhn_feature_label_uq_idx 
	on rhnFeature(label)
	tablespace [[64k_tbs]]
  ;

