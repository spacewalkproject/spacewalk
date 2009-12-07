update rhnChecksumType
   set label = translate(label, ' -', ' ');

update rhnChecksumType
   set description = label || 'sum';

insert into rhnChecksumType (id, label, description) values
            (rhn_checksum_id_seq.nextval, 'sha224', 'sha224sum' );

commit;

