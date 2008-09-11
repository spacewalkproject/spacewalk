--
-- $Id$
--

insert into rhnCryptoKeyType(id, label, description) values
	(rhn_cryptokeytype_id_seq.nextval,'GPG','GPG');
insert into rhnCryptoKeyType(id, label, description) values
	(rhn_cryptokeytype_id_seq.nextval,'SSL','SSL');

commit;

--
-- $Log$
-- Revision 1.1  2003/11/13 15:29:17  pjones
-- bugzilla: 109896 -- add schema to hold cryptographic keys
--
