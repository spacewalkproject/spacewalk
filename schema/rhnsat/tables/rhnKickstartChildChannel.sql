create table
rhnKickstartChildChannel
(
        channel_id   number
                         constraint rhn_ks_cc_cid_nn not null
                         constraint rhn_ks_cc_cid_fk
                                references rhnChannel(id)
                                on delete cascade,
        ksdata_id number
                        constraint rhn_ks_cc_ksd_nn not null
                        constraint rhn_ks_cc_ksd_fk
                                references rhnKSData(id)
                                on delete cascade,
        created         date default(sysdate)
                        constraint rhn_ks_cc_cre_nn not null,
        modified        date default(sysdate)
                        constraint rhn_ks_cc_mod_nn not null
)
        storage( freelists 16 )
	enable row movement
        initrans 32;

create unique index rhn_ks_cc_uq
        on rhnKickstartChildChannel(channel_id, ksdata_id)
        tablespace [[4m_tbs]]
        storage( freelists 16 )
        initrans 32;

create or replace trigger
rhn_ks_cc_mod_trig
before insert or update on rhnKickstartChildChannel
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

