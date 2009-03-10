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
	product	        	varchar(64) not null,
    version             varchar(64) not null,
    release             varchar(64) not null,
    channel_arch_id     numeric not null,
    channel_id          numeric not null,
-- TODO: Should this be a boolean?
    is_default          char(1) not null,
                        constraint rhn_rcm_default_ck
                            check (is_default in ('Y', 'N'))
)
;

create index rhn_rcm_prod_ver_rel_caid_idx
	on rhnReleaseChannelMap(product, version, release, channel_arch_id)
--	tablespace [[64k_tbs]]
  ;

