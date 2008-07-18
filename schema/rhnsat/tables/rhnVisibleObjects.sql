create table rhnVisibleObjects(
  pxt_session_id number not null,
  object_id number not null,
  object_type varchar(40) not null,
  constraint rhn_vis_objs_sess_fk
    foreign key (pxt_session_id)
    references PXTSessions(id)
    on delete cascade
)
	enable row movement
	;

create unique index rhn_vis_objs_sess_obj_type_idx
        on rhnVisibleObjects(pxt_session_id, object_id, object_type);

