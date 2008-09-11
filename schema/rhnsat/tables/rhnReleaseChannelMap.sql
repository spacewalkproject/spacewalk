--
-- $Id: rhnDistChannelMap.sql 110782 2007-02-13 16:31:18Z jslagle $
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
	storage ( freelists 16 )
	initrans 32;

create index rhn_rcm_prod_ver_rel_caid_idx
	on rhnReleaseChannelMap(product, version, release, channel_arch_id)
	tablespace [[64k_tbs]]
	storage ( freelists 16 )
	initrans 32;

