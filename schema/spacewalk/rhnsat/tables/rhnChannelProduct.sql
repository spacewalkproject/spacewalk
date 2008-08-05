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
-- $Id$
--

create table
rhnChannelProduct
(
	id		number
			constraint rhn_channelprod_id_nn not null
			constraint rhn_channelprod_id_pk primary key
				using index tablespace [[64k_tbs]],
    	product         varchar2(256)
	    	    	constraint rhn_channelprod_product_nn not null,
	version         varchar2(64)
	    	    	constraint rhn_channelprod_version_nn not null,
	beta            char(1) default 'N'
                        constraint rhn_channelprod_beta_nn not null
                        constraint rhn_channelprod_beta_ck
                                check (beta in ('Y', 'N')),
	created		date default (sysdate)
			constraint rhn_channelprod_created_nn not null,
	modified	date default (sysdate)
			constraint rhn_channelprod_modified_nn not null
)
	storage ( freelists 16 )
	enable row movement
	initrans 32;

create sequence rhn_channelprod_id_seq;

create unique index rhn_channelprod_p_v_b_uq
	on rhnChannelProduct(product, version, beta)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

-- $Log$
