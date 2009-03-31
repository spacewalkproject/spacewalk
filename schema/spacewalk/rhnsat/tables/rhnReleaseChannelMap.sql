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

create table
rhnReleaseChannelMap 
(
	product	        	varchar2(64)
                        constraint rhn_rcm_prodct_nn not null,
    version             varchar2(64)
                        constraint rhn_rcm_versn_nn not null,
    release             varchar2(64)
                        constraint rhn_rcm_relse_nn not null,
    channel_arch_id     number
                        constraint rhn_rcm_caid_nn not null,
    channel_id          number
                        constraint rhn_rcm_cid_nn not null,
    is_default          char(1)
                        constraint rhn_rcm_default_nn not null,
                        constraint rhn_rcm_default_ck
                            check (is_default in ('Y', 'N'))
)
	enable row movement
  ;

create index rhn_rcm_prod_ver_rel_caid_idx
	on rhnReleaseChannelMap(product, version, release, channel_arch_id)
	tablespace [[64k_tbs]]
  ;

alter table rhnReleaseChannelMap
add constraint rhn_rcm_pva_def_uniq
unique (product, version, channel_arch_id, is_default)
;

