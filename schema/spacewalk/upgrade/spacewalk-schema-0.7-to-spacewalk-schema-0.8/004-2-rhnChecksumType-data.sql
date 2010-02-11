update rhnChecksumType
   set label = translate(label, ' -', ' ');

update rhnChecksumType
   set description = upper(label) || 'sum';

commit;

