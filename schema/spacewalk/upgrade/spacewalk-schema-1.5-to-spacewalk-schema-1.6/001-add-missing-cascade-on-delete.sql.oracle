
alter table rhnerratanotificationqueue drop constraint rhn_enqueue_cid_fk;
alter table rhnerratanotificationqueue add constraint rhn_enqueue_cid_fk foreign key (channel_id) references rhnchannel(id) on delete cascade;

alter table rhnerrataqueue drop constraint rhn_equeue_cid_fk;
alter table rhnerrataqueue add constraint rhn_equeue_cid_fk foreign key (channel_id) references rhnchannel(id) on delete cascade;

alter table rhnreleasechannelmap drop constraint rhn_rcm_cid_fk;
alter table rhnreleasechannelmap add constraint rhn_rcm_cid_fk foreign key (channel_id) references rhnchannel(id) on delete cascade;

