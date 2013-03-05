alter table rhnksdata add update_type varchar2(7) default ('none') not null;
alter table rhnksdata add constraint rhn_ks_update_type check (update_type in ('all', 'red_hat', 'none'));
