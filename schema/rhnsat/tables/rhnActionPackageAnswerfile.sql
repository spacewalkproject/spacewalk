--
-- $Id$
--

create table
rhnActionPackageAnswerfile
(
	action_package_id number
			constraint rhn_act_p_af_apid_nn not null
			constraint rhn_act_p_af_apid_fk
				references rhnActionPackage(id)
				on delete cascade,
	answerfile	blob,
	created		date default(sysdate)
			constraint rhn_act_p_af_creat_nn not null,
	modified	date default(sysdate)
			constraint rhn_act_p_af_mod_nn not null
)
	tablespace [[blob]]
	storage ( freelists 16 )
	initrans 32;

create index rhn_act_p_af_aid_idx
	on rhnActionPackageAnswerfile( action_package_id )
	tablespace [[2m_tbs]]
	storage( pctincrease 1 freelists 16 )
	initrans 32
	nologging;

create or replace trigger
rhn_act_p_af_mod_trig
before insert or update on rhnActionPackageAnswerfile
for each row
begin
	:new.modified := sysdate;
end;
/
show errors

--
-- $Log$
-- Revision 1.3  2004/02/10 23:07:21  pjones
-- bugzilla: none -- tablename fix
--
-- Revision 1.2  2004/02/10 22:33:16  pjones
-- bugzilla: none -- update rhnActionPackageAnswerfile to reference new pk
--
-- Revision 1.1  2004/02/10 22:20:13  pjones
-- bugzilla: none -- initial table to hold answerfile data
--
