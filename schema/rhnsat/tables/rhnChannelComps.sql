--
-- $Id$
--

create table
rhnChannelComps
(
   id       number
        constraint rhn_channelcomps_id_nn not null
        constraint rhn_channelcomps_id_pk primary key,
   channel_id      number
        constraint rhn_channelcomps_cid_nn not null
        constraint rhn_channelcomps_cid_fk
            references rhnChannel(id)
            on delete cascade,
    relative_filename   varchar2(256)
        constraint rhn_channelcomps_rfn_nn not null,
    last_modified   date default(sysdate)
        constraint rhn_channelcomps_lastmod_nn not null,
    created     date default(sysdate)
        constraint rhn_channelcomps_created_nn not null,
    modified    date default(sysdate)
        constraint rhn_channelcomps_modified_nn not null
)
    storage ( freelists 16 )
    enable row movement
    initrans 32;

create sequence rhn_channelcomps_id_seq start with 101;

create or replace trigger
rhn_channelcomps_mod_trig
before insert or update on rhnChannelComps
for each row
begin
    :new.modified := sysdate;
    -- allow us to manually set last_modified if we wish
    if :new.last_modified = :old.last_modified
    then
        :new.last_modified := sysdate;
        end if;
end rhn_channelcomps_mod_trig;
/
show errors
