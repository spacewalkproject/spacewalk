--
-- $Id$
--
-- data for rhnEmailAddressState

insert into rhnEmailAddressState ( id, label )
	values (rhn_eastate_id_seq.nextval, 'unverified');
insert into rhnEmailAddressState ( id, label )
	values (rhn_eastate_id_seq.nextval, 'pending');
insert into rhnEmailAddressState ( id, label )
	values (rhn_eastate_id_seq.nextval, 'pending_warned');
insert into rhnEmailAddressState ( id, label )
	values (rhn_eastate_id_seq.nextval, 'verified');
insert into rhnEmailAddressState ( id, label )
	values (rhn_eastate_id_seq.nextval, 'needs_verifying');
	
commit;

-- $Log$
-- Revision 1.3  2003/01/22 18:48:37  cturner
-- rename column, add intermediary email step
--
-- Revision 1.2  2003/01/14 05:24:27  cturner
-- needs_verifying state will be the default new sdtate now, allowing unverified to simply be legacy
--
-- Revision 1.1  2003/01/10 17:44:02  pjones
-- new email address table
--
