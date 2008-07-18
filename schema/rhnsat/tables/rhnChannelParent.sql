create table
rhnChannelParent
(
        channel 	number 
			constraint rhn_cp_ch_nn not null
   			constraint rhn_cp_ch_fk
				references rhnChannel(id) on delete cascade,
	parent_channel 	number
			constraint rhn_cp_parent_ch_nn not null
   			constraint rhn_cp_parent_ch_fk
                        	references rhnChannel(id),
        created         date default (sysdate)
                        constraint rhn_chp_created_nn not null,
        modified        date default (sysdate)
                        constraint rhn_chp_modified_nn not null
)
	enable row movement
;

create unique index rhn_cp_c_uq
	on rhnChannelParent(channel, parent_channel);

-- $Log$
-- Revision 0.1 2007/07/18 13:33:00 shughes
-- initial version
