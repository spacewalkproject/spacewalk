--
-- $Id$
--

create table
rhnActivationKey
(
	token		varchar2(48)
			constraint rhn_act_key_token_nn not null
			constraint rhn_act_key_token_uq unique,
	reg_token_id	number
			constraint rhn_act_key_reg_tid_nn not null
			constraint rhn_act_key_reg_tid_fk
				references rhnRegToken(id)
				on delete cascade,
	ks_session_id	number
			constraint rhn_act_key_ks_sid_fk
				references rhnKickstartSession(id)
				on delete cascade,
	created		date default sysdate
			constraint rhn_act_key_created_nn not null,
	modified	date default sysdate
			constraint rhn_act_key_modified_nn not null
)
	storage( freelists 16 )
	enable row movement
	initrans 32;

create index rhn_act_key_kssid_rtid_idx
on rhnActivationKey (ks_session_id, reg_token_id)
        tablespace [[64k_tbs]]
        storage( freelists 16 )
        initrans 32
        nologging;

create index rhn_act_key_rtid_idx 
    on rhnActivationKey (reg_token_id)
    tablespace [[64k_tbs]]
    storage ( freelists 16 )
    initrans 32
    nologging;



create or replace trigger
rhn_act_key_mod_trig
before insert or update on rhnActivationKey
for each row
begin
        :new.modified := sysdate;
end;
/
show errors

-- $Log$
-- Revision 1.1  2003/10/08 17:25:44  misa
-- bugzilla: 106573  Schema for rhnActivationKey
--
--
