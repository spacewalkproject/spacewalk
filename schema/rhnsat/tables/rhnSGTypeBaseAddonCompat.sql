--
-- $Id$
--

create table
rhnSGTypeBaseAddonCompat
(
   base_id     number
               constraint rhn_sgt_bac_bid_nn not null
               constraint rhn_sgt_bac_bid_fk references rhnServerGroupType(id),
   addon_id    number
               constraint rhn_sgt_bac_aid_nn not null
               constraint rhn_sgt_bac_aid_fk references rhnServerGroupType(id)
)
	storage ( freelists 16 )
	initrans 32;


--
--
--
