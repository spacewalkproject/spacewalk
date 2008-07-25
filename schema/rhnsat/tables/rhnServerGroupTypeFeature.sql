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
-- $Id: $ 
--

create table
rhnServerGroupTypeFeature
(
        server_group_type_id     number
                                 constraint rhn_sgt_sgtid_nn not null
                                 constraint rhn_sgt_sgid_fk references rhnServerGroupType(id),
        feature_id               number
                                 constraint rhn_sgt_fid_nn not null
                                 constraint rhn_sgt_fid_fk references rhnFeature(id),
        created                  date default(sysdate)
                                 constraint rhn_sgt_feat_created_nn not null,
        modified                 date default(sysdate)
                                 constraint rhn_sgt_feat_mod_nn not null
)
        storage ( freelists 16 )
	enable row movement
        initrans 32;

create unique index rhn_sgt_feat_sgtid_fid_uq_idx
        on rhnServerGroupTypeFeature(server_group_type_id, feature_id)
        tablespace [[64k_tbs]]
        storage ( freelists 16 )
        initrans 32;

