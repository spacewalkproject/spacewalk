update rhnChecksumType
   set label = translate(label, ' -', ' ');

update rhnChecksumType
   set description = label || 'sum';

commit;

